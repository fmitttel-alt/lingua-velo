import Foundation
import Combine
import CoreLocation

// MARK: - Learning Session Engine

@MainActor
class LearningEngine: ObservableObject {
    static let shared = LearningEngine()

    @Published var currentExercise: Exercise?
    @Published var sessionMode: LearningMode = .stationary
    @Published var feedback: ExerciseFeedback?
    @Published var sessionProgress: Double = 0
    @Published var sessionActive: Bool = false
    @Published var sessionFinished: Bool = false

    private var exercises: [Exercise] = []
    private var exerciseIndex: Int = 0
    private var correct: Int = 0
    private var startTime = Date()
    private var currentLesson: Lesson?

    // MARK: - Start Session

    func startSession(lesson: Lesson, avatar: Avatar, mode: LearningMode, level: LanguageLevel) {
        self.exercises = lesson.exercises
        self.currentLesson = lesson
        self.sessionMode = mode
        self.exerciseIndex = 0
        self.correct = 0
        self.startTime = Date()
        self.sessionActive = true
        self.sessionFinished = false
        self.sessionProgress = 0
        self.feedback = nil
        showCurrentExercise()
    }

    func endSession() -> SessionResult {
        sessionActive = false
        return SessionResult(
            lessonID: currentLesson?.id ?? "",
            startedAt: startTime,
            completedAt: Date(),
            exercisesTotal: exercises.count,
            exercisesCorrect: correct,
            exercisesSkipped: max(0, exercises.count - exerciseIndex),
            mode: sessionMode
        )
    }

    // MARK: - Exercise Flow

    private func showCurrentExercise() {
        guard exerciseIndex < exercises.count else {
            sessionProgress = 1.0
            sessionFinished = true
            currentExercise = nil
            return
        }
        currentExercise = exercises[exerciseIndex]
        sessionProgress = Double(exerciseIndex) / Double(max(exercises.count, 1))
        feedback = nil
    }

    func submitAnswer(_ text: String) {
        guard let exercise = currentExercise else { return }

        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let expected   = exercise.correctAnswer.lowercased()
        let isCorrect  = evaluateAnswer(given: normalized, expected: expected)

        if isCorrect { correct += 1 }

        feedback = ExerciseFeedback(
            isCorrect: isCorrect,
            userAnswer: text,
            correctAnswer: exercise.correctAnswer,
            encouragement: encouragement(correct: isCorrect)
        )
    }

    func advance() {
        exerciseIndex += 1
        showCurrentExercise()
    }

    func skip() {
        exerciseIndex += 1
        showCurrentExercise()
    }

    // MARK: - Helpers

    private func evaluateAnswer(given: String, expected: String) -> Bool {
        let g = given.folding(options: .diacriticInsensitive, locale: .current)
        let e = expected.folding(options: .diacriticInsensitive, locale: .current)
        if g == e { return true }
        let words = e.components(separatedBy: " ")
        let matchCount = words.filter { g.contains($0) }.count
        return Double(matchCount) / Double(max(words.count, 1)) >= 0.7
    }

    private func encouragement(correct: Bool) -> String {
        if correct {
            return ["Bravissimo!", "Perfetto!", "Esatto!", "Benissimo!", "Magnifico!"].randomElement()!
        } else {
            return ["Non fa niente! Weiter üben.", "Fast! Die Antwort ist:", "Corretto è:"].randomElement()!
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
