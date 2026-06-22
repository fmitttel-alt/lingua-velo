import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var step: OnboardingStep = .welcome

    enum OnboardingStep: Int, CaseIterable {
        case welcome, level, goals, avatar, cyclingIntro, done
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            backgroundGradient

            VStack(spacing: 0) {
                progressDots
                stepContent
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    // MARK: Progress

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingStep.allCases, id: \.rawValue) { s in
                Circle()
                    .fill(s.rawValue <= step.rawValue ? AppTheme.Colors.salmon : AppTheme.Colors.backgroundCard)
                    .frame(width: s == step ? 10 : 6, height: s == step ? 10 : 6)
                    .animation(.spring(), value: step)
            }
        }
        .padding(.top, AppTheme.Spacing.lg)
    }

    // MARK: Steps

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .welcome:     WelcomeStep { advance() }
        case .level:       LevelStep { advance() }
        case .goals:       GoalsStep { advance() }
        case .avatar:      AvatarSelectionStep { advance() }
        case .cyclingIntro: CyclingIntroStep { advance() }
        case .done:        DoneStep()
        }
    }

    private func advance() {
        if let next = OnboardingStep(rawValue: step.rawValue + 1) {
            withAnimation { step = next }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                AppTheme.Colors.deepSage.opacity(0.15),
                AppTheme.Colors.background,
                AppTheme.Colors.salmon.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Welcome Step

struct WelcomeStep: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            // Logo
            VStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.salmon.opacity(0.15))
                        .frame(width: 120, height: 120)
                    Image(systemName: "bicycle")
                        .font(.system(size: 52, weight: .light))
                        .foregroundColor(AppTheme.Colors.salmon)
                }
                .glow(AppTheme.Colors.salmon, radius: 20)

                Text("Lingua Velo")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Italiano per ciclisti")
                    .font(AppTheme.Font.title2)
                    .foregroundColor(AppTheme.Colors.sage)
            }

            Spacer()

            VStack(spacing: AppTheme.Spacing.md) {
                FeaturePill(icon: "waveform", text: "Voice-First — Hände am Lenker")
                FeaturePill(icon: "brain.head.profile", text: "Intelligente Wiederholung (FSRS)")
                FeaturePill(icon: "map.fill", text: "Reise-Italiano für Radler")
            }
            .padding(.horizontal, AppTheme.Spacing.md)

            Spacer()

            Button(action: onNext) {
                Text("Cominciamo! — Starten wir!")
                    .font(AppTheme.Font.headline)
                    .frame(maxWidth: .infinity)
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.salmon)
                    .foregroundColor(AppTheme.Colors.white)
                    .cornerRadius(AppTheme.Radius.md)
                    .glow(AppTheme.Colors.salmon, radius: 10)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
    }
}

// MARK: - Level Step

struct LevelStep: View {
    @EnvironmentObject var appState: AppState
    @State private var selected: LanguageLevel = .a0
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            stepHeader(
                title: "Il tuo livello?",
                subtitle: "Wie gut sprichst du schon Italienisch?"
            )

            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(LanguageLevel.allCases, id: \.self) { level in
                    LevelRow(level: level, isSelected: selected == level) {
                        selected = level
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)

            Spacer()

            nextButton("Avanti →") {
                appState.userProfile.level = selected
                onNext()
            }
        }
    }
}

struct LevelRow: View {
    let level: LanguageLevel
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.rawValue)
                        .font(AppTheme.Font.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Text(level.displayName)
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.salmon)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(isSelected ? AppTheme.Colors.salmon.opacity(0.15) : AppTheme.Colors.backgroundCard)
            .cornerRadius(AppTheme.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(isSelected ? AppTheme.Colors.salmon.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Goals Step

struct GoalsStep: View {
    @EnvironmentObject var appState: AppState
    @State private var selected: Set<LearningGoal> = [.cycling]
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            stepHeader(
                title: "I tuoi obiettivi?",
                subtitle: "Was möchtest du auf Italienisch können?"
            )

            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(LearningGoal.allCases) { goal in
                    GoalRow(goal: goal, isSelected: selected.contains(goal)) {
                        if selected.contains(goal) { selected.remove(goal) }
                        else { selected.insert(goal) }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)

            Spacer()

            nextButton("Avanti →") {
                appState.userProfile.goals = Array(selected)
                onNext()
            }
            .disabled(selected.isEmpty)
        }
    }
}

struct GoalRow: View {
    let goal: LearningGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: goal.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? AppTheme.Colors.salmon : AppTheme.Colors.textMuted)
                    .frame(width: 28)
                Text(goal.rawValue)
                    .font(AppTheme.Font.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.salmon)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(isSelected ? AppTheme.Colors.salmon.opacity(0.15) : AppTheme.Colors.backgroundCard)
            .cornerRadius(AppTheme.Radius.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Avatar Selection Step

struct AvatarSelectionStep: View {
    @EnvironmentObject var appState: AppState
    @State private var selected: Avatar = .default
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            stepHeader(
                title: "Il tuo tutor?",
                subtitle: "Wähle deinen persönlichen Sprachtutor"
            )

            ScrollView {
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(Avatar.all) { avatar in
                        AvatarRow(avatar: avatar, isSelected: selected.id == avatar.id) {
                            selected = avatar
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }

            nextButton("Avanti →") {
                appState.selectAvatar(selected)
                onNext()
            }
        }
    }
}

struct AvatarRow: View {
    let avatar: Avatar
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                AvatarBadge(avatar: avatar, size: 52)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(avatar.name)
                            .font(AppTheme.Font.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text("·")
                            .foregroundColor(AppTheme.Colors.textMuted)
                        Text(avatar.subtitle)
                            .font(AppTheme.Font.caption)
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                    Text(avatar.accent.rawValue)
                        .font(AppTheme.Font.caption)
                        .foregroundColor(Color(hex: avatar.colorHex))
                    Text(avatar.bio)
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Colors.textMuted)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.salmon)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(isSelected ? AppTheme.Colors.salmon.opacity(0.1) : AppTheme.Colors.backgroundCard)
            .cornerRadius(AppTheme.Radius.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Cycling Intro Step

struct CyclingIntroStep: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            stepHeader(
                title: "Il Fahrmodus",
                subtitle: "Was passiert, wenn du auf dem Rad lernst"
            )

            VStack(spacing: AppTheme.Spacing.md) {
                CyclingFeatureCard(
                    icon: "waveform",
                    color: AppTheme.Colors.sage,
                    title: "Wake Word",
                    description: "Sag \"Senti [Name]\" und dein Tutor hört zu — ohne Knopfdruck."
                )
                CyclingFeatureCard(
                    icon: "text.bubble.fill",
                    color: AppTheme.Colors.salmon,
                    title: "Live-Transkript",
                    description: "Alles Gesprochene erscheint als Text auf dem Bildschirm. Groß, kontraststark, aus 50 cm lesbar."
                )
                CyclingFeatureCard(
                    icon: "speedometer",
                    color: AppTheme.Colors.rose,
                    title: "Automatischer Sicherheitsmodus",
                    description: "Bei hoher Geschwindigkeit wechselt die App in den Zuhör-Modus. Kein Sprechen nötig."
                )
            }
            .padding(.horizontal, AppTheme.Spacing.md)

            Spacer()

            nextButton("Iniziamo! — Los geht's!") { onNext() }
        }
    }
}

struct CyclingFeatureCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Font.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text(description)
                    .font(AppTheme.Font.callout)
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Done Step

struct DoneStep: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.sage)
                .glow(AppTheme.Colors.sage, radius: 20)

            Text("Pronto!")
                .font(AppTheme.Font.largeTitle)
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text("Lingua Velo ist startklar.\nBuona fortuna e buona pedalata!")
                .font(AppTheme.Font.title2)
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)

            Spacer()

            Button(action: {
                appState.completeOnboarding(
                    level: appState.userProfile.level,
                    goals: appState.userProfile.goals,
                    avatar: appState.selectedAvatar
                )
            }) {
                Text("Lingua Velo öffnen")
                    .font(AppTheme.Font.headline)
                    .frame(maxWidth: .infinity)
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.salmon)
                    .foregroundColor(AppTheme.Colors.white)
                    .cornerRadius(AppTheme.Radius.md)
                    .glow(AppTheme.Colors.salmon, radius: 12)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
    }
}

// MARK: - Shared Helpers

private func stepHeader(title: String, subtitle: String) -> some View {
    VStack(spacing: AppTheme.Spacing.sm) {
        Text(title)
            .font(AppTheme.Font.title)
            .foregroundColor(AppTheme.Colors.textPrimary)
            .multilineTextAlignment(.center)
        Text(subtitle)
            .font(AppTheme.Font.callout)
            .foregroundColor(AppTheme.Colors.textMuted)
            .multilineTextAlignment(.center)
    }
    .padding(.top, AppTheme.Spacing.lg)
    .padding(.horizontal, AppTheme.Spacing.xl)
}

private func nextButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text(title)
            .font(AppTheme.Font.headline)
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.salmon)
            .foregroundColor(AppTheme.Colors.white)
            .cornerRadius(AppTheme.Radius.md)
    }
    .padding(.horizontal, AppTheme.Spacing.md)
    .padding(.bottom, AppTheme.Spacing.xl)
}

struct FeaturePill: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.salmon)
                .frame(width: 20)
            Text(text)
                .font(AppTheme.Font.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}
