import SwiftUI

struct LessonsListView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedLesson: Lesson?
    @State private var showSession = false

    private var previousLesson: Lesson? {
        guard let sel = selectedLesson,
              let idx = appState.lessons.firstIndex(where: { $0.id == sel.id }),
              idx > 0 else { return nil }
        return appState.lessons[idx - 1]
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        ForEach(VocabCategory.allCases, id: \.self) { cat in
                            let filtered = appState.lessons.filter { $0.category == cat }
                            if !filtered.isEmpty {
                                CategorySection(category: cat, lessons: filtered) { lesson in
                                    selectedLesson = lesson
                                    showSession = true
                                }
                            }
                        }
                        Spacer(minLength: AppTheme.Spacing.xl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)
                }
            }
            .navigationTitle("Lezioni")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showSession) {
            if let lesson = selectedLesson {
                TutorSessionView(lesson: lesson, previousLesson: previousLesson)
            }
        }
    }
}

struct CategorySection: View {
    let category: VocabCategory
    let lessons: [Lesson]
    let onSelect: (Lesson) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: category.icon)
                    .foregroundColor(AppTheme.Colors.sage)
                Text(category.rawValue)
                    .font(AppTheme.Font.headline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            ForEach(lessons) { lesson in
                LessonCard(lesson: lesson) { onSelect(lesson) }
            }
        }
    }
}

struct LessonCard: View {
    let lesson: Lesson
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                        .fill(AppTheme.Colors.salmon.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: lesson.category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.Colors.salmon)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(AppTheme.Font.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Text(lesson.subtitle)
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Colors.textMuted)
                    Text("\(lesson.totalExercises) Übungen · \(lesson.level.rawValue)")
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Colors.deepSage)
                }

                Spacer()

                Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(lesson.isCompleted ? AppTheme.Colors.sage : AppTheme.Colors.salmon)
            }
            .padding(AppTheme.Spacing.md)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
