import SwiftUI

@main
struct LinguaVeloApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.userProfile.onboardingCompleted {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(appState)
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var userProfile: UserProfile {
        didSet { saveProfile() }
    }
    @Published var selectedAvatar: Avatar
    @Published var lessons: [Lesson] = ItalianContent.lessons

    init() {
        let profile = Self.loadProfile()
        self.userProfile = profile
        self.selectedAvatar = Avatar.all.first { $0.id == profile.selectedAvatarID } ?? .default
        setupFSRS()
    }

    func selectAvatar(_ avatar: Avatar) {
        selectedAvatar = avatar
        userProfile.selectedAvatarID = avatar.id
    }

    func completeOnboarding(level: LanguageLevel, goals: [LearningGoal], avatar: Avatar) {
        userProfile.level = level
        userProfile.goals = goals
        userProfile.selectedAvatarID = avatar.id
        userProfile.onboardingCompleted = true
        selectedAvatar = avatar
    }

    private func setupFSRS() {
        // Add all vocabulary cards to FSRS on first launch
        if FSRSManager.shared.allCards.isEmpty {
            for card in ItalianContent.vocabulary {
                FSRSManager.shared.addCard(for: card.id)
            }
        }
    }

    private func saveProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(data, forKey: "user_profile_v1")
        }
    }

    private static func loadProfile() -> UserProfile {
        guard let data = UserDefaults.standard.data(forKey: "user_profile_v1"),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data)
        else { return .new }
        return profile
    }
}
