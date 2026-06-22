import SwiftUI

// MARK: - Cycling Mode Entry

struct CyclingModeEntryView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingWarning = true
    @State private var activeSession = false
    @State private var selectedLesson: Lesson?

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                if showingWarning {
                    SafetyWarningView(onAccept: { showingWarning = false })
                } else {
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.lg) {
                            Spacer(minLength: AppTheme.Spacing.xl)

                            VStack(spacing: AppTheme.Spacing.sm) {
                                Image(systemName: "bicycle")
                                    .font(.system(size: 64, weight: .light))
                                    .foregroundColor(AppTheme.Colors.salmon)
                                    .glow(AppTheme.Colors.salmon, radius: 16)

                                Text("Fahrmodus")
                                    .font(AppTheme.Font.title)
                                    .foregroundColor(AppTheme.Colors.textPrimary)

                                Text("Wähle eine Lektion und übe\nauch unterwegs.")
                                    .font(AppTheme.Font.callout)
                                    .foregroundColor(AppTheme.Colors.textMuted)
                                    .multilineTextAlignment(.center)
                            }

                            // Lesson picker
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                                Text("Lektion auswählen")
                                    .font(AppTheme.Font.headline)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .padding(.horizontal, AppTheme.Spacing.md)

                                ForEach(appState.lessons.prefix(6)) { lesson in
                                    CyclingLessonRow(lesson: lesson, isSelected: selectedLesson?.id == lesson.id) {
                                        selectedLesson = lesson
                                    }
                                    .padding(.horizontal, AppTheme.Spacing.md)
                                }
                            }

                            Button(action: { activeSession = true }) {
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    Image(systemName: "play.circle.fill").font(.system(size: 22))
                                    Text("Fahrmodus starten")
                                }
                                .font(AppTheme.Font.headline)
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.Spacing.md)
                                .background(selectedLesson != nil ? AppTheme.Colors.salmon : AppTheme.Colors.backgroundElevated)
                                .foregroundColor(selectedLesson != nil ? AppTheme.Colors.white : AppTheme.Colors.textMuted)
                                .cornerRadius(AppTheme.Radius.md)
                            }
                            .disabled(selectedLesson == nil)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.bottom, AppTheme.Spacing.xl)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $activeSession) {
            if let lesson = selectedLesson {
                LearningSessionView(lesson: lesson, mode: .cycling)
            }
        }
    }
}

// MARK: - Cycling Lesson Row

struct CyclingLessonRow: View {
    let lesson: Lesson
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: lesson.category.icon)
                    .foregroundColor(isSelected ? AppTheme.Colors.white : AppTheme.Colors.salmon)
                    .frame(width: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.title)
                        .font(AppTheme.Font.headline)
                        .foregroundColor(isSelected ? AppTheme.Colors.white : AppTheme.Colors.textPrimary)
                    Text(lesson.level.rawValue)
                        .font(AppTheme.Font.caption)
                        .foregroundColor(isSelected ? AppTheme.Colors.white.opacity(0.7) : AppTheme.Colors.textMuted)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.white)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(isSelected ? AppTheme.Colors.salmon : AppTheme.Colors.backgroundCard)
            .cornerRadius(AppTheme.Radius.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Safety Warning

struct SafetyWarningView: View {
    let onAccept: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                Spacer(minLength: AppTheme.Spacing.xl)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.Colors.rose)

                Text("Sicherheitshinweis")
                    .font(AppTheme.Font.title)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    SafetyPoint(text: "Achte stets auf den Straßenverkehr.")
                    SafetyPoint(text: "Beachte die lokalen Gesetze zur Kopfhörernutzung.")
                    SafetyPoint(text: "Nutze nur einen Ohrhörer oder Knochenschall-KH.")
                    SafetyPoint(text: "Das Display ist Zusatzinfo — nicht auf den Bildschirm starren.")
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.backgroundCard)
                .cornerRadius(AppTheme.Radius.md)
                .padding(.horizontal, AppTheme.Spacing.md)

                Button(action: onAccept) {
                    Text("Verstanden — Fahrmodus öffnen")
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
        }
        .background(AppTheme.Colors.background)
    }
}

struct SafetyPoint: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.Colors.sage)
                .font(.system(size: 16))
            Text(text)
                .font(AppTheme.Font.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
}
