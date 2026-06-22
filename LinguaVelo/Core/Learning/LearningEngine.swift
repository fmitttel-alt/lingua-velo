import Foundation
import Combine
import CoreMotion
import CoreLocation

// MARK: - Learning Session Engine

@MainActor
class LearningEngine: ObservableObject {
    static let shared = LearningEngine()

    // Session state
    @Published var currentExercise: Exercise?
    @Published var sessionMode: LearningMode = .stationary
    @Published var isListeningForAnswer: Bool = false
    @Published var lastTranscript: String = ""
    @Published var feedback: ExerciseFeedback?
    @Published var sessionProgress: Double = 0
    @Published var currentSpeed: Double = 0   // km/h
    @Published var isHighSpeed: Bool = false
    @Published var sessionActive: Bool = false

    // Services
    private let tts = ElevenLabsTTS.shared
    private let stt = SpeechRecognizer.shared
    private let fsrs = FSRSManager.shared

    // Session data
    private var exercises: [Exercise] = []
    private var exerciseIndex: Int = 0
    private var correct: Int = 0
    private var startTime = Date()
    private var selectedAvatar: Avatar = .default
    private var userLevel: LanguageLevel = .a0

    // Motion
    private let motionManager = CMMotionActivityManager()
    private let locationManager = CLLocationManager()
    private var locationDelegate: LocationDelegate?

    // MARK: - Start Session

    func startSession(
        lesson: Lesson,
        avatar: Avatar,
        mode: LearningMode,
        level: LanguageLevel
    ) {
        self.exercises = lesson.exercises
        self.selectedAvatar = avatar
        self.sessionMode = mode
        self.userLevel = level
        self.exerciseIndex = 0
        self.correct = 0
        self.startTime = Date()
        self.sessionActive = true
        self.sessionProgress = 0

        if mode == .cycling { startSpeedMonitoring() }
        advanceToNextExercise()
    }

    func endSession() -> SessionResult {
        stopSpeedMonitoring()
        sessionActive = false
        return SessionResult(
            lessonID: "",
            startedAt: startTime,
            completedAt: Date(),
            exercisesTotal: exercises.count,
            exercisesCorrect: correct,
            exercisesSkipped: exercises.count - exerciseIndex,
            mode: sessionMode
        )
    }

    // MARK: - Exercise Flow

    func advanceToNextExercise() {
        guard exerciseIndex < exercises.count else {
            sessionProgress = 1.0
            return
        }

        let exercise = currentExerciseForMode()
        currentExercise = exercise
        sessionProgress = Double(exerciseIndex) / Double(exercises.count)
        feedback = nil

        // Tutor speaks the prompt
        let prompt = buildTutorPrompt(exercise: exercise)
        tts.speak(text: prompt, voiceID: selectedAvatar.voiceID) { [weak self] in
            Task { @MainActor [weak self] in
                self?.startListeningIfNeeded(exercise: exercise)
            }
        }
    }

    // In high-speed cycling mode, convert to listen-only
    private func currentExerciseForMode() -> Exercise {
        var ex = exercises[exerciseIndex]
        if isHighSpeed && sessionMode == .cycling {
            ex = Exercise(
                id: ex.id,
                type: .listenOnly,
                prompt: ex.prompt,
                promptItalian: ex.promptItalian,
                correctAnswer: ex.correctAnswer
            )
        }
        return ex
    }

    // MARK: - Answer Evaluation

    func submitAnswer(_ text: String) {
        guard let exercise = currentExercise else { return }
        isListeningForAnswer = false
        lastTranscript = text

        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let expected   = exercise.correctAnswer.lowercased()
        let isCorrect  = evaluateAnswer(given: normalized, expected: expected)

        if isCorrect { correct += 1 }

        // Update FSRS if vocabulary linked
        if let vocabID = exercise.vocabularyID {
            let rating: Rating = isCorrect ? .good : .again
            if let card = fsrs.allCards.first(where: { $0.vocabularyID == vocabID }) {
                fsrs.review(card: card, rating: rating)
            }
        }

        let fb = ExerciseFeedback(
            isCorrect: isCorrect,
            userAnswer: text,
            correctAnswer: exercise.correctAnswer,
            encouragement: encouragement(correct: isCorrect)
        )
        feedback = fb

        // Speak feedback
        tts.speak(text: fb.encouragement, voiceID: selectedAvatar.voiceID) { [weak self] in
            Task { @MainActor [weak self] in
                self?.exerciseIndex += 1
                try? await Task.sleep(nanoseconds: 300_000_000)
                self?.advanceToNextExercise()
            }
        }
    }

    func skip() {
        isListeningForAnswer = false
        exerciseIndex += 1
        advanceToNextExercise()
    }

    // MARK: - Voice Input

    func startListeningForAnswer() {
        guard !isListeningForAnswer else { return }
        isListeningForAnswer = true
        stt.startListening(
            onPartial: { [weak self] partial in self?.lastTranscript = partial },
            onFinal:   { [weak self] final in self?.submitAnswer(final) }
        )
    }

    private func startListeningIfNeeded(exercise: Exercise) {
        guard exercise.type != .listenOnly,
              sessionMode == .cycling || exercise.type == .pronunciation || exercise.type == .conversation
        else { return }
        startListeningForAnswer()
    }

    // MARK: - Speed Monitoring

    private func startSpeedMonitoring() {
        locationDelegate = LocationDelegate { [weak self] speed in
            Task { @MainActor [weak self] in
                guard let self else { return }
                let kmh = speed * 3.6
                self.currentSpeed = max(0, kmh)
                self.isHighSpeed = kmh > Config.maxCyclingSpeed
            }
        }
        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func stopSpeedMonitoring() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Helpers

    private func buildTutorPrompt(exercise: Exercise) -> String {
        switch exercise.type {
        case .listenAndRepeat:
            return "Ripeti dopo di me: \(exercise.correctAnswer)"
        case .translate:
            return exercise.prompt
        case .pronunciation:
            return "Pronuncia: \(exercise.promptItalian ?? exercise.correctAnswer)"
        case .listenOnly:
            return "\(exercise.promptItalian ?? exercise.correctAnswer). \(exercise.correctAnswer)"
        default:
            return exercise.prompt
        }
    }

    private func evaluateAnswer(given: String, expected: String) -> Bool {
        // Phonetic fuzzy matching — strip accents, compare
        let g = given.folding(options: .diacriticInsensitive, locale: .current)
        let e = expected.folding(options: .diacriticInsensitive, locale: .current)
        if g == e { return true }
        // Check if core word is there (allow minor STT errors)
        let words = e.components(separatedBy: " ")
        let matchCount = words.filter { g.contains($0) }.count
        return Double(matchCount) / Double(max(words.count, 1)) >= 0.7
    }

    private func encouragement(correct: Bool) -> String {
        if correct {
            return ["Bravissimo!", "Perfetto!", "Esatto!", "Benissimo!", "Magnifico!"].randomElement()!
        } else {
            return ["Non fa niente, riprova!", "Quasi! La risposta è:", "Corretto è:"].randomElement()!
        }
    }
}

// MARK: - Exercise Feedback

struct ExerciseFeedback {
    let isCorrect: Bool
    let userAnswer: String
    let correctAnswer: String
    let encouragement: String
}

// MARK: - Location Delegate

private class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var onSpeed: (CLLocationSpeed) -> Void
    init(onSpeed: @escaping (CLLocationSpeed) -> Void) { self.onSpeed = onSpeed }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let speed = locations.last?.speed, speed >= 0 { onSpeed(speed) }
    }
}
