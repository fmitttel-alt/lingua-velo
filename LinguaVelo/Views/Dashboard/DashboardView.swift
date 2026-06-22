import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var fsrs = FSRSManager.shared
    @State private var showingSession = false
    @State private var quickLesson: Lesson?

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        headerSection
                        todayCard
                        reviewBanner
                        featuredLessons
                        Spacer(minLength: AppTheme.Spacing.xl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSession) {
            if let lesson = quickLesson {
                LearningSessionView(lesson: lesson, mode: .stationary)
            }
        }
    }

    // MARK: Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(AppTheme.Font.caption)
                    .foregroundColor(AppTheme.Colors.textMuted)
                Text("Lingua Velo")
                    .font(AppTheme.Font.largeTitle)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            Spacer()
            AvatarBadge(avatar: appState.selectedAvatar, size: 52)
        }
        .padding(.top, AppTheme.Spacing.lg)
    }

    // MARK: Today Card

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Oggi")
                    .font(AppTheme.Font.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                StreakBadge(streak: appState.userProfile.currentStreak)
            }

            HStack(spacing: AppTheme.Spacing.md) {
                StatTile(value: "\(fsrs.dueCards.count)", label: "Wiederholungen")
                StatTile(value: "\(appState.userProfile.totalVocabLearned)", label: "Vokabeln")
                StatTile(value: "\(appState.userProfile.currentStreak)", label: "Tage-Streak")
            }

            Button(action: startTodaySession) {
                HStack {
                    Image(systemName: "play.fill")
                    Text(fsrs.dueCards.isEmpty ? "Neue Lektion starten" : "Wiederholungen starten")
                        .font(AppTheme.Font.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.salmon)
                .foregroundColor(AppTheme.Colors.white)
                .cornerRadius(AppTheme.Radius.md)
                .glow(AppTheme.Colors.salmon, radius: 8)
            }
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }

    // MARK: Review Banner

    @ViewBuilder
    private var reviewBanner: some View {
        if fsrs.dueCards.count > 0 {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(AppTheme.Colors.rose)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(fsrs.dueCards.count) Karten zur Wiederholung")
                        .font(AppTheme.Font.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Text("Perfetto — bleib am Ball!")
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.rose.opacity(0.15))
            .cornerRadius(AppTheme.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(AppTheme.Colors.rose.opacity(0.3), lineWidth: 1)
            )
            .onTapGesture { startReviewSession() }
        }
    }

    // MARK: Featured Lessons

    private var featuredLessons: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Lezioni")
                .font(AppTheme.Font.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)

            ForEach(appState.lessons.prefix(4)) { lesson in
                LessonRow(lesson: lesson) {
                    quickLesson = lesson
                    showingSession = true
                }
            }
        }
    }

    // MARK: Helpers

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Buongiorno 🌅"
        case 12..<18: return "Buon pomeriggio ☀️"
        default:      return "Buonasera 🌙"
        }
    }

    private func startTodaySession() {
        quickLesson = appState.lessons.first
        showingSession = true
    }

    private func startReviewSession() {
        quickLesson = appState.lessons.first
        showingSession = true
    }
}

// MARK: - Sub-Components

struct AvatarBadge: View {
    let avatar: Avatar
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: avatar.colorHex).opacity(0.2))
                .frame(width: size, height: size)
            Text(String(avatar.name.prefix(1)))
                .font(.system(size: size * 0.45, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: avatar.colorHex))
        }
        .overlay(Circle().stroke(Color(hex: avatar.colorHex).opacity(0.4), lineWidth: 1.5))
    }
}

struct StreakBadge: View {
    let streak: Int
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(AppTheme.Colors.salmon)
            Text("\(streak)")
                .font(AppTheme.Font.headline)
                .foregroundColor(AppTheme.Colors.salmon)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(AppTheme.Colors.salmon.opacity(0.15))
        .cornerRadius(AppTheme.Radius.full)
    }
}

struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTheme.Font.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text(label)
                .font(AppTheme.Font.caption)
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.backgroundElevated)
        .cornerRadius(AppTheme.Radius.sm)
    }
}

struct LessonRow: View {
    let lesson: Lesson
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                        .fill(AppTheme.Colors.sage.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: lesson.category.icon)
                        .foregroundColor(AppTheme.Colors.sage)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.title)
                        .font(AppTheme.Font.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Text(lesson.subtitle)
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Colors.textMuted)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text(lesson.level.rawValue)
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Colors.textMuted)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
            }
            .padding(AppTheme.Spacing.md)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
