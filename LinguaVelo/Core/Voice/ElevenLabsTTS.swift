import Foundation
import AVFoundation

// MARK: - ElevenLabs Text-to-Speech

@MainActor
class ElevenLabsTTS: ObservableObject {
    static let shared = ElevenLabsTTS()

    @Published var isSpeaking: Bool = false
    @Published var error: String?

    private var audioPlayer: AVAudioPlayer?
    private let cache = NSCache<NSString, NSData>()
    private let session = URLSession.shared

    // MARK: Speak

    func speak(text: String, voiceID: String, onComplete: (() -> Void)? = nil) {
        Task {
            do {
                let data = try await fetchAudio(text: text, voiceID: voiceID)
                await play(data: data, onComplete: onComplete)
            } catch {
                self.error = error.localizedDescription
                onComplete?()
            }
        }
    }

    func stop() {
        audioPlayer?.stop()
        isSpeaking = false
    }

    // MARK: Private

    private func fetchAudio(text: String, voiceID: String) async throws -> Data {
        let cacheKey = "\(voiceID):\(text)" as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached as Data
        }

        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceID)/stream")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(Config.elevenLabsAPIKey, forHTTPHeaderField: "xi-api-key")
        req.setValue("application/octet-stream", forHTTPHeaderField: "Accept")

        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_multilingual_v2",
            "voice_settings": [
                "stability": 0.65,
                "similarity_boost": 0.80,
                "style": 0.35,
                "use_speaker_boost": true
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw TTSError.serverError
        }
        cache.setObject(data as NSData, forKey: cacheKey)
        return data
    }

    private func play(data: Data, onComplete: (() -> Void)?) async {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
            isSpeaking = true
            audioPlayer?.play()

            // Wait for completion
            let duration = audioPlayer?.duration ?? 0
            try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000) + 100_000_000)
            isSpeaking = false
            onComplete?()
        } catch {
            isSpeaking = false
            self.error = error.localizedDescription
            onComplete?()
        }
    }
}

enum TTSError: LocalizedError {
    case serverError
    case invalidKey

    var errorDescription: String? {
        switch self {
        case .serverError: return "ElevenLabs konnte die Sprache nicht generieren."
        case .invalidKey:  return "Ungültiger ElevenLabs API Key."
        }
    }
}

// MARK: - Tutor Dialogue via Google Gemini API

class TutorDialogue {
    nonisolated(unsafe) static let shared = TutorDialogue()

    private let session = URLSession.shared

    func respond(
        userInput: String,
        avatarName: String,
        level: LanguageLevel,
        context: String
    ) async throws -> String {
        guard !Config.geminiAPIKey.isEmpty, Config.enableTutorDialog else {
            return "Tutor-Dialog nicht aktiv. Trage deinen Gemini API Key in Config.swift ein."
        }

        let model = "gemini-2.5-flash"
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(Config.geminiAPIKey)"
        let url = URL(string: urlString)!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let systemPrompt = """
        Du bist \(avatarName), ein freundlicher italienischer Sprachtutor in der App Lingua Velo. \
        Die App richtet sich an Radfahrende, die auf Reisen Italienisch lernen wollen. \
        Niveau des Lernenden: \(level.rawValue). \
        Sei kurz (max. 2 Sätze), motivierend und klar. Antworte auf Deutsch, verwende aber viel Italienisch. \
        Lektionskontext: \(context)
        """

        let body: [String: Any] = [
            "system_instruction": [
                "parts": [["text": systemPrompt]]
            ],
            "contents": [
                ["role": "user", "parts": [["text": userInput]]]
            ],
            "generationConfig": [
                "maxOutputTokens": 200,
                "temperature": 0.7
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw TutorError.serverError
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let candidates = json?["candidates"] as? [[String: Any]]
        let content = candidates?.first?["content"] as? [String: Any]
        let parts = content?["parts"] as? [[String: Any]]
        return parts?.first?["text"] as? String ?? "Forza, continua!"
    }
}

enum TutorError: LocalizedError {
    case serverError
    var errorDescription: String? { "Gemini konnte keine Antwort generieren." }
}
