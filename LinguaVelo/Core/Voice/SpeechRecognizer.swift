import Foundation
import Speech
import AVFoundation
import Combine

// MARK: - Speech Recognizer (Apple on-device STT)

@MainActor
class SpeechRecognizer: ObservableObject {
    static let shared = SpeechRecognizer()

    @Published var transcript: String = ""
    @Published var isListening: Bool = false
    @Published var isAvailable: Bool = false
    @Published var error: SpeechError?

    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var silenceTimer: Timer?
    private var onResult: ((String) -> Void)?
    private var onFinal: ((String) -> Void)?

    private let silenceThreshold: TimeInterval = 1.8   // auto-stop after silence

    init() {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "it-IT"))
        checkPermissions()
    }

    // MARK: Permissions

    func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.isAvailable = status == .authorized
            }
        }
    }

    // MARK: Start / Stop

    func startListening(
        onPartial: @escaping (String) -> Void,
        onFinal: @escaping (String) -> Void
    ) {
        guard !isListening else { return }
        self.onResult = onPartial
        self.onFinal = onFinal
        do {
            try startSession()
            isListening = true
            error = nil
        } catch {
            self.error = .sessionFailed(error.localizedDescription)
        }
    }

    func stopListening() {
        guard isListening else { return }
        audioEngine.stop()
        request?.endAudio()
        task?.cancel()
        silenceTimer?.invalidate()
        cleanup()
        isListening = false
    }

    // MARK: Internal

    private func startSession() throws {
        if audioEngine.isRunning { audioEngine.stop() }
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request else { throw SpeechError.noRequest }
        request.requiresOnDeviceRecognition = Config.enableOfflineSTT
        request.shouldReportPartialResults = true
        request.addsPunctuation = false

        let inputNode = audioEngine.inputNode
        let fmt = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: fmt) { [weak self] buf, _ in
            self?.request?.append(buf)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.transcript = text
                    self.onResult?(text)
                    self.resetSilenceTimer()
                }
            }
            if let error {
                DispatchQueue.main.async {
                    self.error = .recognitionError(error.localizedDescription)
                    self.stopListening()
                }
            }
        }
    }

    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceThreshold, repeats: false) { [weak self] _ in
            guard let self else { return }
            let final = self.transcript
            Task { @MainActor in
                self.onFinal?(final)
                self.stopListening()
            }
        }
    }

    private func cleanup() {
        request = nil
        task = nil
        silenceTimer = nil
        transcript = ""
    }
}

// MARK: - Wake Word Detector

@MainActor
class WakeWordDetector: ObservableObject {
    @Published var detected: String? = nil    // detected avatar name

    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var isRunning = false

    private let avatarNames = Avatar.all.map { $0.name.lowercased() }

    func start() {
        guard Config.enableWakeWord, !isRunning else { return }
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "it-IT"))
        do { try startEngine() } catch { print("WakeWord engine error: \(error)") }
    }

    func stop() {
        audioEngine.stop()
        request?.endAudio()
        task?.cancel()
        isRunning = false
    }

    private func startEngine() throws {
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request else { return }
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let fmt = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: fmt) { [weak self] buf, _ in
            self?.request?.append(buf)
        }
        audioEngine.prepare()
        try audioEngine.start()
        isRunning = true

        task = recognizer?.recognitionTask(with: request) { [weak self] result, _ in
            guard let self, let result else { return }
            let text = result.bestTranscription.formattedString.lowercased()
            if text.contains("senti") {
                for name in self.avatarNames {
                    if text.contains(name) {
                        DispatchQueue.main.async { self.detected = name }
                        return
                    }
                }
            }
        }
    }
}

// MARK: - Errors

enum SpeechError: LocalizedError {
    case noRequest
    case sessionFailed(String)
    case recognitionError(String)
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .noRequest:               return "Mikrofon-Anfrage konnte nicht erstellt werden."
        case .sessionFailed(let m):    return "Sitzung fehlgeschlagen: \(m)"
        case .recognitionError(let m): return "Erkennungsfehler: \(m)"
        case .permissionDenied:        return "Mikrofon-Zugriff verweigert. Bitte in den Einstellungen erlauben."
        }
    }
}
