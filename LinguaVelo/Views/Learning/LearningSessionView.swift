import SwiftUI

// MARK: - Learning Session View

struct LearningSessionView: View {
    let lesson: Lesson
    let mode: LearningMode
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var engine = LearningEngine.shared

    @State private var showResult = false
    @State private var result: SessionResult?
    @State private var showIntro = true

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            if showResult, let r = result {
                SessionResultView(result: r, lesson: lesson) { dismiss() }
            } else if showIntro {
                LessonIntroView(lesson: lesson, onStart: {
                    showIntro = false
                    engine.startSession(lesson: lesson, avatar: appState.selectedAvatar, mode: mode, level: appState.userProfile.level)
                }, onDismiss: { dismiss() })
            } else if engine.sessionFinished {
                let r = engine.endSession()
                Color.clear.onAppear {
                    result = r
                    showResult = true
                    appState.userProfile.totalSessionsCompleted += 1
                }
            } else {
                VStack(spacing: 0) {
                    sessionHeader
                    exerciseArea
                }
            }
        }
        .interactiveDismissDisabled(engine.sessionActive && !showIntro)
    }

    // MARK: Header

    private var sessionHeader: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Button(action: { endNow() }) {
                Image(systemName: "xmark")
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 36, height: 36)
                    .background(AppTheme.Colors.backgroundCard)
                    .clipShape(Circle())
            }

            ProgressView(value: engine.sessionProgress, total: 1.0)
                .tint(AppTheme.Colors.salmon)
                .frame(maxWidth: .infinity)

            Text("\(Int(engine.sessionProgress * Double(lesson.exercises.count)))/\(lesson.exercises.count)")
                .font(AppTheme.Font.caption)
                .foregroundColor(AppTheme.Colors.textMuted)
                .frame(minWidth: 36)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.backgroundCard)
    }

    // MARK: Exercise Area

    @ViewBuilder
    private var exerciseArea: some View {
        if let exercise = engine.currentExercise {
            ExerciseView(exercise: exercise, feedback: engine.feedback) { answer in
                engine.submitAnswer(answer)
            } onAdvance: {
                engine.advance()
            }
        } else {
            Spacer()
        }
    }

    private func endNow() {
        let r = engine.endSession()
        result = r
        showResult = true
    }
}

// MARK: - Lesson Intro View

struct LessonIntroView: View {
    let lesson: Lesson
    let onStart: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppTheme.Colors.textMuted)
                            .font(.system(size: 16))
                            .frame(width: 36, height: 36)
                            .background(AppTheme.Colors.backgroundCard)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.top, AppTheme.Spacing.sm)

                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.salmon.opacity(0.15))
                        .frame(width: 90, height: 90)
                    Image(systemName: lesson.category.icon)
                        .font(.system(size: 38))
                        .foregroundColor(AppTheme.Colors.salmon)
                }

                VStack(spacing: AppTheme.Spacing.sm) {
                    Text(lesson.title)
                        .font(AppTheme.Font.title)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    Text(lesson.subtitle)
                        .font(AppTheme.Font.callout)
                        .foregroundColor(AppTheme.Colors.textMuted)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: AppTheme.Spacing.md) {
                    InfoPill(icon: "list.bullet", text: "\(lesson.exercises.count) Übungen")
                    InfoPill(icon: "chart.bar", text: lesson.level.rawValue)
                    InfoPill(icon: "clock", text: "~\(max(2, lesson.exercises.count / 3)) Min")
                }

                if let intro = lesson.introText, !intro.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("Was du lernst")
                            .font(AppTheme.Font.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text(intro)
                            .font(AppTheme.Font.bodyText)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppTheme.Spacing.md)
                    .cardStyle()
                }

                Button(action: onStart) {
                    Text("Iniziamo! — Los geht's")
                        .font(AppTheme.Font.headline)
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.salmon)
                        .foregroundColor(AppTheme.Colors.white)
                        .cornerRadius(AppTheme.Radius.md)
                }
                .padding(.bottom, AppTheme.Spacing.xl)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }
}

struct InfoPill: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 12))
            Text(text).font(AppTheme.Font.caption)
        }
        .foregroundColor(AppTheme.Colors.textMuted)
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, 6)
        .background(AppTheme.Colors.backgroundElevated)
        .cornerRadius(AppTheme.Radius.full)
    }
}

// MARK: - Exercise View

struct ExerciseView: View {
    let exercise: Exercise
    let feedback: ExerciseFeedback?
    let onAnswer: (String) -> Void
    let onAdvance: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                exerciseCard
                if let fb = feedback {
                    FeedbackCard(feedback: fb)
                    advanceButton
                } else {
                    answerArea
                }
                Spacer(minLength: AppTheme.Spacing.xl)
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    private var exerciseCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text(exercise.type.rawValue)
                .font(AppTheme.Font.caption)
                .foregroundColor(AppTheme.Colors.textMuted)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.backgroundElevated)
                .cornerRadius(AppTheme.Radius.full)

            Text(exercise.prompt)
                .font(AppTheme.Font.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let italian = exercise.promptItalian {
                Text(italian)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.Colors.sage)
                    .multilineTextAlignment(.center)
            }

            if let hint = exercise.hint {
                Text("🔊 \(hint)")
                    .font(AppTheme.Font.caption)
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }

    @ViewBuilder
    private var answerArea: some View {
        switch exercise.type {
        case .multipleChoice, .translate:
            let opts = ([exercise.correctAnswer] + exercise.alternatives).shuffled()
            MultipleChoiceView(options: opts, correctAnswer: exercise.correctAnswer, onSelect: onAnswer)
        case .listenOnly:
            Button(action: { onAnswer(exercise.correctAnswer) }) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Verstanden — Weiter")
                }
                .font(AppTheme.Font.headline)
                .frame(maxWidth: .infinity)
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.sage)
                .foregroundColor(AppTheme.Colors.white)
                .cornerRadius(AppTheme.Radius.md)
            }
        default:
            // listenAndRepeat, pronunciation etc. → show as multiple choice if alternatives exist,
            // otherwise show a "Wiederholen & Weiter" button
            if !exercise.alternatives.isEmpty {
                let opts = ([exercise.correctAnswer] + exercise.alternatives).shuffled()
                MultipleChoiceView(options: opts, correctAnswer: exercise.correctAnswer, onSelect: onAnswer)
            } else {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text("Sprich nach: \(exercise.promptItalian ?? exercise.correctAnswer)")
                        .font(AppTheme.Font.headline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(AppTheme.Spacing.md)
                        .cardStyle()

                    Button(action: { onAnswer(exercise.correctAnswer) }) {
                        HStack {
                            Image(systemName: "mic.fill")
                            Text("Hab ich wiederholt!")
                        }
                        .font(AppTheme.Font.headline)
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.salmon)
                        .foregroundColor(AppTheme.Colors.white)
                        .cornerRadius(AppTheme.Radius.md)
                    }
                }
            }
        }
    }

    private var advanceButton: some View {
        Button(action: onAdvance) {
            Text("Weiter")
                .font(AppTheme.Font.headline)
                .frame(maxWidth: .infinity)
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.salmon)
                .foregroundColor(AppTheme.Colors.white)
                .cornerRadius(AppTheme.Radius.md)
        }
    }
}

// MARK: - Multiple Choice View

struct MultipleChoiceView: View {
    let options: [String]
    let correctAnswer: String
    let onSelect: (String) -> Void
    @State private var selected: String?

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    guard selected == nil else { return }
                    selected = option
                    onSelect(option)
                }) {
                    HStack {
                        Text(option)
                            .font(AppTheme.Font.bodyText)
                            .foregroundColor(colorFor(option))
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if let s = selected {
                            if option == correctAnswer {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(AppTheme.Colors.sage)
                            } else if option == s {
                                Image(systemName: "xmark.circle.fill").foregroundColor(AppTheme.Colors.salmon)
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(backgroundFor(option))
                    .cornerRadius(AppTheme.Radius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(borderFor(option), lineWidth: 1.5)
                    )
                }
                .disabled(selected != nil)
            }
        }
    }

    private func colorFor(_ option: String) -> Color {
        guard let s = selected else { return AppTheme.Colors.textPrimary }
        if option == correctAnswer { return AppTheme.Colors.sage }
        if option == s { return AppTheme.Colors.salmon }
        return AppTheme.Colors.textMuted
    }

    private func backgroundFor(_ option: String) -> Color {
        guard let s = selected else { return AppTheme.Colors.backgroundCard }
        if option == correctAnswer { return AppTheme.Colors.sage.opacity(0.15) }
        if option == s { return AppTheme.Colors.salmon.opacity(0.15) }
        return AppTheme.Colors.backgroundCard
    }

    private func borderFor(_ option: String) -> Color {
        guard let s = selected else { return AppTheme.Colors.backgroundElevated }
        if option == correctAnswer { return AppTheme.Colors.sage.opacity(0.5) }
        if option == s { return AppTheme.Colors.salmon.opacity(0.5) }
        return Color.clear
    }
}

// MARK: - Feedback Card

struct FeedbackCard: View {
    let feedback: ExerciseFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: feedback.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(feedback.isCorrect ? AppTheme.Colors.sage : AppTheme.Colors.salmon)
                    .font(.system(size: 20))
                Text(feedback.encouragement)
                    .font(AppTheme.Font.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            if !feedback.isCorrect {
                Text("Richtig: \(feedback.correctAnswer)")
                    .font(AppTheme.Font.callout)
                    .foregroundColor(AppTheme.Colors.sage)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.md)
        .background(feedback.isCorrect ? AppTheme.Colors.sage.opacity(0.15) : AppTheme.Colors.salmon.opacity(0.15))
        .cornerRadius(AppTheme.Radius.md)
    }
}

// MARK: - Session Result View

struct SessionResultView: View {
    let result: SessionResult
    let lesson: Lesson
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer(minLength: AppTheme.Spacing.xxl)

                ZStack {
                    Circle()
                        .stroke(AppTheme.Colors.backgroundCard, lineWidth: 12)
                        .frame(width: 160, height: 160)
                    Circle()
                        .trim(from: 0, to: result.accuracy)
                        .stroke(
                            result.accuracy > 0.7 ? AppTheme.Colors.sage : AppTheme.Colors.salmon,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.0), value: result.accuracy)

                    VStack(spacing: 4) {
                        Text("\(Int(result.accuracy * 100))%")
                            .font(AppTheme.Font.title)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text("Richtig")
                            .font(AppTheme.Font.caption)
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                }

                Text(resultTitle)
                    .font(AppTheme.Font.title)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("\(result.exercisesCorrect) von \(result.exercisesTotal) Aufgaben richtig gelöst.")
                    .font(AppTheme.Font.callout)
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .multilineTextAlignment(.center)

                HStack(spacing: AppTheme.Spacing.md) {
                    StatTile(value: "\(result.exercisesCorrect)", label: "Richtig")
                    StatTile(value: "\(result.exercisesTotal - result.exercisesCorrect)", label: "Falsch")
                    StatTile(value: String(format: "%.0fs", result.duration), label: "Zeit")
                }
                .padding(.horizontal, AppTheme.Spacing.md)

                Button(action: onContinue) {
                    Text("Weiter")
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
            .padding(.horizontal, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }

    private var resultTitle: String {
        if result.accuracy >= 0.9 { return "Perfetto! 🏆" }
        if result.accuracy >= 0.7 { return "Bravissimo! 🎉" }
        if result.accuracy >= 0.5 { return "Bene! Weiter so." }
        return "Non fa niente — übung macht den Meister!"
    }
}
