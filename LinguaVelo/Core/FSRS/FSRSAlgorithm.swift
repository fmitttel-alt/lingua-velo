import Foundation

// MARK: - FSRS v5 Implementation
// Free Spaced Repetition Scheduler — https://github.com/open-spaced-repetition/fsrs4anki

struct FSRSCard: Identifiable, Codable {
    let id: UUID
    let vocabularyID: UUID
    var state: CardState
    var stability: Double     // S — how long memory lasts
    var difficulty: Double    // D — intrinsic difficulty 1–10
    var elapsedDays: Int
    var scheduledDays: Int
    var reps: Int
    var lapses: Int
    var lastReview: Date?
    var nextReview: Date
    var createdAt: Date

    init(vocabularyID: UUID) {
        self.id = UUID()
        self.vocabularyID = vocabularyID
        self.state = .new
        self.stability = 0
        self.difficulty = 5
        self.elapsedDays = 0
        self.scheduledDays = 0
        self.reps = 0
        self.lapses = 0
        self.lastReview = nil
        self.nextReview = Date()
        self.createdAt = Date()
    }

    var isDue: Bool { Date() >= nextReview }
}

enum CardState: String, Codable {
    case new       = "Neu"
    case learning  = "Lernen"
    case review    = "Wiederholung"
    case relearning = "Neu lernen"
}

enum Rating: Int, Codable, CaseIterable {
    case again = 1
    case hard  = 2
    case good  = 3
    case easy  = 4

    var label: String {
        switch self {
        case .again: return "Nochmal"
        case .hard:  return "Schwer"
        case .good:  return "Gut"
        case .easy:  return "Leicht"
        }
    }

    var color: String {
        switch self {
        case .again: return "#E8847A"
        case .hard:  return "#F2B0A8"
        case .good:  return "#9FB89A"
        case .easy:  return "#5F7861"
        }
    }
}

// MARK: - FSRS Scheduler

struct FSRSScheduler {

    // FSRS v5 parameters (default)
    private let w: [Double] = [
        0.4072, 1.1829, 3.1262, 15.4722, 7.2102,
        0.5316, 1.0651, 0.0589, 1.5330, 0.1544,
        1.0039, 1.9746, 0.1100, 0.2900, 2.2700,
        0.2500, 2.9898, 0.5100, 0.4300
    ]
    private let requestRetention: Double = 0.90
    private let maximumInterval: Int = 36500

    func schedule(card: FSRSCard, rating: Rating, reviewedAt: Date = Date()) -> FSRSCard {
        var c = card
        let elapsed = card.lastReview.map { Int(reviewedAt.timeIntervalSince($0) / 86400) } ?? 0
        c.elapsedDays = elapsed

        switch card.state {
        case .new:
            return scheduleNew(card: &c, rating: rating, reviewedAt: reviewedAt)
        case .learning, .relearning:
            return scheduleLearning(card: &c, rating: rating, reviewedAt: reviewedAt)
        case .review:
            return scheduleReview(card: &c, rating: rating, reviewedAt: reviewedAt)
        }
    }

    private func scheduleNew(card: inout FSRSCard, rating: Rating, reviewedAt: Date) -> FSRSCard {
        card.difficulty = initDifficulty(rating: rating)
        card.stability  = initStability(rating: rating)
        card.lastReview = reviewedAt
        card.reps += 1

        switch rating {
        case .again:
            card.state = .learning
            card.scheduledDays = 0
            card.nextReview = reviewedAt.addingTimeInterval(60)
        case .hard:
            card.state = .learning
            card.scheduledDays = 0
            card.nextReview = reviewedAt.addingTimeInterval(300)
        case .good:
            card.state = .learning
            card.scheduledDays = 0
            card.nextReview = reviewedAt.addingTimeInterval(600)
        case .easy:
            card.state = .review
            let days = max(1, nextInterval(stability: card.stability))
            card.scheduledDays = days
            card.nextReview = Calendar.current.date(byAdding: .day, value: days, to: reviewedAt)!
        }
        return card
    }

    private func scheduleLearning(card: inout FSRSCard, rating: Rating, reviewedAt: Date) -> FSRSCard {
        card.lastReview = reviewedAt
        card.reps += 1

        switch rating {
        case .again:
            card.lapses += 1
            card.state = .relearning
            card.difficulty = updateDifficulty(d: card.difficulty, rating: rating)
            card.stability = stabilityAfterForgetting(d: card.difficulty, s: card.stability, r: retrievability(card: card))
            card.nextReview = reviewedAt.addingTimeInterval(60)
        case .hard, .good:
            card.state = .review
            card.difficulty = updateDifficulty(d: card.difficulty, rating: rating)
            card.stability = shortTermStability(s: card.stability, rating: rating)
            let days = max(1, nextInterval(stability: card.stability))
            card.scheduledDays = days
            card.nextReview = Calendar.current.date(byAdding: .day, value: days, to: reviewedAt)!
        case .easy:
            card.state = .review
            card.difficulty = updateDifficulty(d: card.difficulty, rating: rating)
            card.stability = shortTermStability(s: card.stability, rating: rating)
            let days = max(1, nextInterval(stability: card.stability))
            card.scheduledDays = days
            card.nextReview = Calendar.current.date(byAdding: .day, value: days, to: reviewedAt)!
        }
        return card
    }

    private func scheduleReview(card: inout FSRSCard, rating: Rating, reviewedAt: Date) -> FSRSCard {
        card.lastReview = reviewedAt
        card.reps += 1
        let r = retrievability(card: card)

        switch rating {
        case .again:
            card.lapses += 1
            card.state = .relearning
            card.difficulty = updateDifficulty(d: card.difficulty, rating: rating)
            card.stability = stabilityAfterForgetting(d: card.difficulty, s: card.stability, r: r)
            card.nextReview = reviewedAt.addingTimeInterval(60)
            card.scheduledDays = 0
        default:
            card.state = .review
            card.difficulty = updateDifficulty(d: card.difficulty, rating: rating)
            card.stability = stabilityAfterRecall(d: card.difficulty, s: card.stability, r: r, rating: rating)
            let days = max(1, nextInterval(stability: card.stability))
            card.scheduledDays = days
            card.nextReview = Calendar.current.date(byAdding: .day, value: days, to: reviewedAt)!
        }
        return card
    }

    // FSRS formulas
    private func initDifficulty(rating: Rating) -> Double {
        let d = w[4] - exp(w[5] * Double(rating.rawValue - 1)) + 1
        return clamp(d, lo: 1, hi: 10)
    }

    private func initStability(rating: Rating) -> Double {
        max(w[rating.rawValue - 1], 0.1)
    }

    private func updateDifficulty(d: Double, rating: Rating) -> Double {
        let dd = w[6] * (3 - Double(rating.rawValue))
        let next = d + dd * (10 - d) / 9
        let mean = w[7] + w[8] * exp(-w[9] * (next - 1))   // simplified mean reversion
        return clamp(next + mean - 5.5, lo: 1, hi: 10)
    }

    private func stabilityAfterRecall(d: Double, s: Double, r: Double, rating: Rating) -> Double {
        let bonus: Double = rating == .hard ? w[15] : (rating == .easy ? w[16] : 1)
        let sNew = s * (exp(w[8]) * (11 - d) * pow(s, -w[9]) * (exp((1 - r) * w[10]) - 1) * bonus + 1)
        return max(sNew, 0.1)
    }

    private func stabilityAfterForgetting(d: Double, s: Double, r: Double) -> Double {
        let sNew = w[11] * pow(d, -w[12]) * (pow(s + 1, w[13]) - 1) * exp((1 - r) * w[14])
        return max(min(sNew, s), 0.1)
    }

    private func shortTermStability(s: Double, rating: Rating) -> Double {
        s * exp(w[17] * (Double(rating.rawValue) - 3 + w[18]))
    }

    private func retrievability(card: FSRSCard) -> Double {
        guard let last = card.lastReview else { return 0 }
        let t = max(0, Date().timeIntervalSince(last) / 86400)
        return pow(1 + 9 / 10 * t / card.stability, -1)
    }

    private func nextInterval(stability: Double) -> Int {
        let interval = stability / 9 * (pow(requestRetention, -1 / 0.9) - 1)
        return min(Int(interval.rounded()), maximumInterval)
    }

    private func clamp(_ v: Double, lo: Double, hi: Double) -> Double {
        max(lo, min(hi, v))
    }
}

// MARK: - FSRS Manager (UserDefaults-backed for offline)

@MainActor
class FSRSManager: ObservableObject {
    static let shared = FSRSManager()

    @Published var dueCards: [FSRSCard] = []
    @Published var allCards: [FSRSCard] = []

    private let scheduler = FSRSScheduler()
    private let storageKey = "fsrs_cards_v1"

    init() { load() }

    func addCard(for vocabID: UUID) {
        guard !allCards.contains(where: { $0.vocabularyID == vocabID }) else { return }
        let card = FSRSCard(vocabularyID: vocabID)
        allCards.append(card)
        save()
        refreshDue()
    }

    func review(card: FSRSCard, rating: Rating) {
        let updated = scheduler.schedule(card: card, rating: rating)
        if let idx = allCards.firstIndex(where: { $0.id == card.id }) {
            allCards[idx] = updated
        }
        save()
        refreshDue()
    }

    func refreshDue() {
        dueCards = allCards.filter { $0.isDue }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(allCards) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let cards = try? JSONDecoder().decode([FSRSCard].self, from: data)
        else { return }
        allCards = cards
        refreshDue()
    }
}
