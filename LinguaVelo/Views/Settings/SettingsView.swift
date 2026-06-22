import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAvatarPicker = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                List {
                    // Profile
                    Section {
                        profileRow
                    }
                    .listRowBackground(AppTheme.Colors.backgroundCard)

                    // Avatar
                    Section("Dein Tutor") {
                        Button(action: { showAvatarPicker = true }) {
                            HStack(spacing: AppTheme.Spacing.md) {
                                AvatarBadge(avatar: appState.selectedAvatar, size: 44)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(appState.selectedAvatar.name)
                                        .font(AppTheme.Font.headline)
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    Text(appState.selectedAvatar.subtitle)
                                        .font(AppTheme.Font.caption)
                                        .foregroundColor(AppTheme.Colors.textMuted)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppTheme.Colors.textMuted)
                            }
                        }
                    }
                    .listRowBackground(AppTheme.Colors.backgroundCard)

                    // Level
                    Section("Sprachniveau") {
                        ForEach(LanguageLevel.allCases, id: \.self) { level in
                            HStack {
                                Text(level.displayName)
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Spacer()
                                if appState.userProfile.level == level {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.Colors.salmon)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { appState.userProfile.level = level }
                        }
                    }
                    .listRowBackground(AppTheme.Colors.backgroundCard)

                    // Info
                    Section("App") {
                        settingsRow(icon: "info.circle", text: "Version \(Config.appVersion)")
                        settingsRow(icon: "bicycle", text: "Lingua Velo — Italiano per ciclisti")
                    }
                    .listRowBackground(AppTheme.Colors.backgroundCard)
                }
                .scrollContentBackground(.hidden)
                .background(AppTheme.Colors.background)
            }
            .navigationTitle("Impostazioni")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showAvatarPicker) {
            AvatarPickerSheet()
        }
    }

    private var profileRow: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Circle()
                .fill(AppTheme.Colors.sage.opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(AppTheme.Colors.sage)
                        .font(.system(size: 24))
                )
            VStack(alignment: .leading, spacing: 2) {
                Text("Ciclista")
                    .font(AppTheme.Font.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text(appState.userProfile.level.rawValue + " · \(appState.userProfile.totalVocabLearned) Vokabeln")
                    .font(AppTheme.Font.caption)
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
        }
    }

    private func settingsRow(icon: String, text: String) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.sage)
                .frame(width: 24)
            Text(text)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
}

struct AvatarPickerSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(Avatar.all) { avatar in
                            AvatarRow(avatar: avatar, isSelected: appState.selectedAvatar.id == avatar.id) {
                                appState.selectAvatar(avatar)
                                dismiss()
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                }
            }
            .navigationTitle("Tutor wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") { dismiss() }
                        .foregroundColor(AppTheme.Colors.salmon)
                }
            }
        }
    }
}

struct ProgressoDashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var fsrs = FSRSManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        statsGrid
                        fsrsSection
                        Spacer(minLength: AppTheme.Spacing.xl)
                    }
                    .padding(AppTheme.Spacing.md)
                }
            }
            .navigationTitle("Progresso")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.md) {
            ProgressTile(
                value: "\(appState.userProfile.totalVocabLearned)",
                label: "Vokabeln gelernt",
                icon: "book.fill",
                color: AppTheme.Colors.sage
            )
            ProgressTile(
                value: "\(appState.userProfile.totalSessionsCompleted)",
                label: "Lektionen",
                icon: "checkmark.seal.fill",
                color: AppTheme.Colors.salmon
            )
            ProgressTile(
                value: "\(appState.userProfile.currentStreak)",
                label: "Tage-Streak",
                icon: "flame.fill",
                color: AppTheme.Colors.rose
            )
            ProgressTile(
                value: fsrs.dueCards.count.description,
                label: "Wiederholungen",
                icon: "brain.head.profile",
                color: AppTheme.Colors.deepSage
            )
        }
    }

    private var fsrsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Spaced Repetition")
                .font(AppTheme.Font.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)

            HStack {
                CardStatPill(value: fsrs.allCards.filter { $0.state == .new }.count, label: "Neu", color: AppTheme.Colors.sage)
                CardStatPill(value: fsrs.allCards.filter { $0.state == .learning }.count, label: "Lernen", color: AppTheme.Colors.rose)
                CardStatPill(value: fsrs.allCards.filter { $0.state == .review }.count, label: "Review", color: AppTheme.Colors.salmon)
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

struct ProgressTile: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            Text(value)
                .font(AppTheme.Font.title)
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text(label)
                .font(AppTheme.Font.caption)
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

struct CardStatPill: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(AppTheme.Font.headline)
                .foregroundColor(color)
            Text(label)
                .font(AppTheme.Font.caption)
                .foregroundColor(AppTheme.Colors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(AppTheme.Radius.sm)
    }
}
