import Foundation

// MARK: - Language Level

enum LanguageLevel: String, Codable, CaseIterable {
    case a0 = "A0"
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"

    var displayName: String {
        switch self {
        case .a0: return "Absoluter Anfänger"
        case .a1: return "Anfänger"
        case .a2: return "Grundkenntnisse"
        case .b1: return "Mittelstufe"
        }
    }
}

// MARK: - Learning Goal

enum LearningGoal: String, Codable, CaseIterable, Identifiable {
    case travel        = "Reise-Italienisch"
    case cycling       = "Unterwegs bestellen & fragen"
    case conversation  = "Allgemeine Konversation"
    case emergency     = "Notfälle & Probleme lösen"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .travel:       return "map.fill"
        case .cycling:      return "bicycle"
        case .conversation: return "bubble.left.and.bubble.right.fill"
        case .emergency:    return "cross.circle.fill"
        }
    }
}

// MARK: - Vocabulary Card

struct VocabCard: Identifiable, Codable {
    let id: UUID
    let italian: String
    let german: String
    let pronunciation: String   // phonetic hint
    let exampleSentence: String
    let exampleTranslation: String
    let category: VocabCategory
    let audioURL: String?       // ElevenLabs cached audio

    init(
        id: UUID = UUID(),
        italian: String,
        german: String,
        pronunciation: String,
        exampleSentence: String,
        exampleTranslation: String,
        category: VocabCategory,
        audioURL: String? = nil
    ) {
        self.id = id
        self.italian = italian
        self.german = german
        self.pronunciation = pronunciation
        self.exampleSentence = exampleSentence
        self.exampleTranslation = exampleTranslation
        self.category = category
        self.audioURL = audioURL
    }
}

enum VocabCategory: String, Codable, CaseIterable {
    case greetings      = "Begrüßung"
    case food           = "Essen & Trinken"
    case directions     = "Wegbeschreibung"
    case accommodation  = "Unterkunft"
    case cycling        = "Radfahren"
    case numbers        = "Zahlen"
    case emergency      = "Notfall"
    case weather        = "Wetter"
    case phrases        = "Redewendungen"

    var icon: String {
        switch self {
        case .greetings:     return "hand.wave.fill"
        case .food:          return "fork.knife"
        case .directions:    return "signpost.right.fill"
        case .accommodation: return "bed.double.fill"
        case .cycling:       return "bicycle"
        case .numbers:       return "number.circle.fill"
        case .emergency:     return "exclamationmark.triangle.fill"
        case .weather:       return "cloud.sun.fill"
        case .phrases:       return "quote.bubble.fill"
        }
    }
}

// MARK: - Lesson

struct Lesson: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let level: LanguageLevel
    let category: VocabCategory
    let exercises: [Exercise]
    let introText: String?
    var isCompleted: Bool = false
    var completionCount: Int = 0

    var totalExercises: Int { exercises.count }

    init(id: String, title: String, subtitle: String, level: LanguageLevel,
         category: VocabCategory, exercises: [Exercise], introText: String? = nil,
         isCompleted: Bool = false, completionCount: Int = 0) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.level = level
        self.category = category
        self.exercises = exercises
        self.introText = introText
        self.isCompleted = isCompleted
        self.completionCount = completionCount
    }
}

// MARK: - Exercise

struct Exercise: Identifiable, Codable {
    let id: UUID
    let type: ExerciseType
    let prompt: String               // What the tutor says/asks
    let promptItalian: String?       // Italian version if applicable
    let correctAnswer: String
    let alternatives: [String]       // Wrong answers for multiple choice
    let hint: String?
    let vocabularyID: UUID?

    init(
        id: UUID = UUID(),
        type: ExerciseType,
        prompt: String,
        promptItalian: String? = nil,
        correctAnswer: String,
        alternatives: [String] = [],
        hint: String? = nil,
        vocabularyID: UUID? = nil
    ) {
        self.id = id
        self.type = type
        self.prompt = prompt
        self.promptItalian = promptItalian
        self.correctAnswer = correctAnswer
        self.alternatives = alternatives
        self.hint = hint
        self.vocabularyID = vocabularyID
    }
}

enum ExerciseType: String, Codable {
    case listenAndRepeat   = "Hören & Wiederholen"
    case translate         = "Übersetzen"
    case fillInBlank       = "Lückentext"
    case multipleChoice    = "Multiple Choice"
    case pronunciation     = "Aussprache"
    case conversation      = "Gespräch"
    case listenOnly        = "Nur Zuhören"   // For cycling at high speed
}

// MARK: - Session Result

struct SessionResult {
    let lessonID: String
    let startedAt: Date
    let completedAt: Date
    let exercisesTotal: Int
    let exercisesCorrect: Int
    let exercisesSkipped: Int
    let mode: LearningMode

    var accuracy: Double {
        guard exercisesTotal > 0 else { return 0 }
        return Double(exercisesCorrect) / Double(exercisesTotal)
    }

    var duration: TimeInterval { completedAt.timeIntervalSince(startedAt) }
}

enum LearningMode: String, Codable {
    case stationary = "Stationär"
    case cycling    = "Fahrmodus"
    case review     = "Wiederholung"
}

// MARK: - User Profile

struct UserProfile: Codable {
    var id: UUID
    var level: LanguageLevel
    var goals: [LearningGoal]
    var selectedAvatarID: String
    var totalSessionsCompleted: Int
    var totalVocabLearned: Int
    var currentStreak: Int
    var lastSessionDate: Date?
    var prefersDarkMode: Bool
    var prefersCyclingMode: Bool
    var onboardingCompleted: Bool

    static var new: UserProfile {
        UserProfile(
            id: UUID(),
            level: .a0,
            goals: [.cycling],
            selectedAvatarID: "luigi",
            totalSessionsCompleted: 0,
            totalVocabLearned: 0,
            currentStreak: 0,
            lastSessionDate: nil,
            prefersDarkMode: true,
            prefersCyclingMode: false,
            onboardingCompleted: false
        )
    }
}
