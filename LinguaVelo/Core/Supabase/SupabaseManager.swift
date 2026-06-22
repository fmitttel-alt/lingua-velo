import Foundation

// MARK: - Supabase Manager
// Lightweight REST-based Supabase client (no SDK dependency needed)

@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()

    private let baseURL: String
    private let anonKey: String
    private var authToken: String?
    private let session = URLSession.shared

    init() {
        self.baseURL = Config.supabaseURL
        self.anonKey = Config.supabaseAnonKey
    }

    // MARK: - Auth

    func signUp(email: String, password: String) async throws -> String {
        let body: [String: Any] = ["email": email, "password": password]
        let result = try await post(path: "/auth/v1/signup", body: body, auth: false)
        guard let token = (result as? [String: Any])?["access_token"] as? String else {
            throw SupabaseError.authFailed
        }
        authToken = token
        return token
    }

    func signIn(email: String, password: String) async throws -> String {
        let body: [String: Any] = ["email": email, "password": password, "grant_type": "password"]
        let result = try await post(path: "/auth/v1/token", body: body, auth: false)
        guard let token = (result as? [String: Any])?["access_token"] as? String else {
            throw SupabaseError.authFailed
        }
        authToken = token
        return token
    }

    // MARK: - Profile

    func upsertProfile(_ profile: UserProfile) async throws {
        let body: [String: Any] = [
            "level": profile.level.rawValue,
            "goals": profile.goals.map { $0.rawValue },
            "selected_avatar": profile.selectedAvatarID,
            "total_sessions": profile.totalSessionsCompleted,
            "total_vocab": profile.totalVocabLearned,
            "current_streak": profile.currentStreak,
            "onboarding_done": profile.onboardingCompleted
        ]
        _ = try await post(path: "/rest/v1/user_profiles?on_conflict=auth_id", body: body)
    }

    func fetchProfile() async throws -> [String: Any]? {
        try await get(path: "/rest/v1/user_profiles?select=*&limit=1") as? [String: Any]
    }

    // MARK: - FSRS Sync

    func syncCards(_ cards: [FSRSCard]) async throws {
        let formatter = ISO8601DateFormatter()
        let rows: [[String: Any]] = cards.map { card in
            var row: [String: Any] = [
                "vocabulary_id": card.vocabularyID.uuidString,
                "state": card.state.rawValue,
                "stability": card.stability,
                "difficulty": card.difficulty,
                "elapsed_days": card.elapsedDays,
                "scheduled_days": card.scheduledDays,
                "reps": card.reps,
                "lapses": card.lapses,
                "next_review_at": formatter.string(from: card.nextReview)
            ]
            if let last = card.lastReview {
                row["last_review_at"] = formatter.string(from: last)
            }
            return row
        }
        _ = try await post(path: "/rest/v1/fsrs_cards?on_conflict=user_id,vocabulary_id", body: rows as AnyObject)
    }

    // MARK: - Sessions

    func saveSession(_ result: SessionResult, lessonID: String) async throws {
        let fmt = ISO8601DateFormatter()
        let body: [String: Any] = [
            "lesson_id": lessonID,
            "mode": result.mode.rawValue,
            "started_at": fmt.string(from: result.startedAt),
            "completed_at": fmt.string(from: result.completedAt),
            "exercises_total": result.exercisesTotal,
            "exercises_ok": result.exercisesCorrect,
            "exercises_skip": result.exercisesSkipped
        ]
        _ = try await post(path: "/rest/v1/sessions", body: body)
    }

    // MARK: - HTTP Helpers

    private func post(path: String, body: Any, auth: Bool = true) async throws -> Any {
        var req = URLRequest(url: URL(string: baseURL + path)!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("return=representation", forHTTPHeaderField: "Prefer")
        req.setValue("apikey \(anonKey)", forHTTPHeaderField: "Authorization")
        if auth, let token = authToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await session.data(for: req)
        return try JSONSerialization.jsonObject(with: data)
    }

    private func get(path: String) async throws -> Any {
        var req = URLRequest(url: URL(string: baseURL + path)!)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("apikey \(anonKey)", forHTTPHeaderField: "Authorization")
        if let token = authToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, _) = try await session.data(for: req)
        return try JSONSerialization.jsonObject(with: data)
    }
}

enum SupabaseError: LocalizedError {
    case authFailed
    case networkError

    var errorDescription: String? {
        switch self {
        case .authFailed:    return "Anmeldung fehlgeschlagen."
        case .networkError:  return "Netzwerkfehler."
        }
    }
}
