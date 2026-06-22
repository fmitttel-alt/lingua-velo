import SwiftUI

// MARK: - Stationary Learning Session

struct LearningSessionView: View {
    let lesson: Lesson
    let mode: LearningMode
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var engine = LearningEngine.shared
    @StateObject private var stt = SpeechRecognizer.shared
    @StateObject private var tts = ElevenLabsTTS.shared

    @State private var showResult = false
    @State private var result: SessionResult?

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            if showResult, let r = result {
                SessionResultView(result: r, lesson: lesson) {
                    dismiss()
                }
            } else {
                VStack(spacing: 0) {
                    sessionHeader
                    exerciseContent
                    answerArea
                }
            }
        }
        .onAppear {
            engine.startSession(lesson: lesson, avatar: appState.selectedAvatar, mode: mode, level: appState.userProfile.level)
        }
    }

    // MARK: Header

    private var sessionHeader: some View {
        HStack {
            Button(action: { endSession() }) {
                Image(systemName: "xmark")
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .font(.system(size: 18, weight: .medium))
            }
            .padding(.trailing, AppTheme.Spacing.sm)

            ProgressView(value: engine.sessionProgress)
                .tint(AppTheme.Colors.salmon)
                .frame(maxWidth: .infinity)

            Text("\(Int(engine.sessionProgress * Double(lesson.exercises.count)))/\(lesson.exercises.count)")
                .font(AppTheme.Font.caption)
                .foregroundColor(AppTheme.Colors.textMuted)
                .padding(.leading, AppTheme.Spacing.sm)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundCard)
    }

    // MARK: Exercise Content

    @ViewBuilder
    private var exerciseContent: some View {
        if let exercise = engine.currentExercise {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Avatar speaking
                    AvatarSpeakingCard(
                        avatar: appState.selectedAvatar,
                        text: exercise.prompt,
                        isSpeaking: tts.isSpeaking
                    )

                    // Exercise type badge
                    Text(exercise.type.rawValue)
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Colors.textMuted)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.backgroundElevated)
                        .cornerRadius(AppTheme.Radius.full)

                    // Feedback if available
                    if let feedback = engine.feedback {
                        FeedbackCard(feedback: feedback)
                    }

                    // Multiple choice options
                    if exercise.type == .multipleChoice || exercise.type == .translate {
                        let options = ([exercise.correctAnswer] + exercise.alternatives).shuffled()
                        MultipleChoiceView(options: options, correctAnswer: exercise.correctAnswer) { chosen in
                            engine.submitAnswer(chosen)
                        }
                    }
                }
                .padding(AppTheme.Spacing.md)
            }
        } else {
            Spacer()
        }
    }

    // MARK: Answer Area

    private var answerArea: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Transcript
            if engine.isListeningForAnswer || !stt.transcript.isEmpty {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundColor(AppTheme.Colors.salmon)
                    Text(stt.transcript.isEmpty ? "Hör zu..." : stt.transcript)
                        .font(AppTheme.Font.headline)
                        .foregroundColor(stt.transcript.isEmpty ? AppTheme.Colors.textMuted : AppTheme.Colors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.backgroundCard)
                .cornerRadius(AppTheme.Radius.md)
                .padding(.horizontal, AppTheme.Spacing.md)
            }

            // Speak / Continue button
            HStack(spacing: AppTheme.Spacing.md) {
                Button(action: engine.skip) {
                    Text("Überspringen")
                        .font(AppTheme.Font.subhead)
                        .foregroundColor(AppTheme.Colors.textMuted)
                }

                Spacer()

                Button(action: {
                    if engine.feedback != nil {
                        // advance
                    } else {
                        engine.startListeningForAnswer()
                    }
                }) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: engine.isListeningForAnswer ? "waveform" : "mic.fill")
                            .font(.system(size: 20))
                        Text(engine.isListeningForAnswer ? "Zuhören..." : "Antworten")
                    }
                    .font(AppTheme.Font.headline)
                    .foregroundColor(AppTheme.Colors.white)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(engine.isListeningForAnswer ? AppTheme.Colors.rose : AppTheme.Colors.salmon)
                    .cornerRadius(AppTheme.Radius.md)
                    .glow(AppTheme.Colors.salmon, radius: engine.isListeningForAnswer ? 12 : 0)
                }
                .disabled(tts.isSpeaking)
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.backgroundCard)
    }

    private func endSession() {
        let r = engine.endSession()
        result = r
        showResult = true
    }
}

// MARK: - Avatar Speaking Card

struct AvatarSpeakingCard: View {
    let avatar: Avatar
    let text: String
    let isSpeaking: Bool
    @State private var waveScale: CGFloat = 1.0

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            ZStack {
                AvatarBadge(avatar: avatar, size: 56)
                if isSpeaking {
                    Circle()
                        .stroke(Color(hex: avatar.colorHex).opacity(0.4), lineWidth: 2)
                        .frame(width: 66, height: 66)
                        .scaleEffect(waveScale)
                        .opacity(2 - waveScale)
                        .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: waveScale)
                        .onAppear { waveScale = 1.8 }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(avatar.name)
                    .font(AppTheme.Font.caption)
                    .foregroundColor(Color(hex: avatar.colorHex))
                Text(text)
                    .font(AppTheme.Font.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Feedback Card

struct FeedbackCard: View {
    let feedback: ExerciseFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
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

// MARK: - Multiple Choice

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
                        Spacer()
                        if let s = selected {
                            if s == option || option == correctAnswer {
                                Image(systemName: option == correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(colorFor(option))
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
        if option == s            { return AppTheme.Colors.salmon }
        return AppTheme.Colors.textMuted
    }

    private func backgroundFor(_ option: String) -> Color {
        guard let s = selected else { return AppTheme.Colors.backgroundCard }
        if option == correctAnswer { return AppTheme.Colors.sage.opacity(0.15) }
        if option == s            { return AppTheme.Colors.salmon.opacity(0.15) }
        return AppTheme.Colors.backgroundCard
    }

    private func borderFor(_ option: String) -> Color {
        guard let s = selected else { return AppTheme.Colors.backgroundElevated }
        if option == correctAnswer { return AppTheme.Colors.sage.opacity(0.5) }
        if option == s            { return AppTheme.Colors.salmon.opacity(0.5) }
        return Color.clear
    }
}

// MARK: - Session Result View

struct SessionResultView: View {
    let result: SessionResult
    let lesson: Lesson
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            // Score circle
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

            Text(resultSubtitle)
                .font(AppTheme.Font.callout)
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)

            // Stats
            HStack(spacing: AppTheme.Spacing.md) {
                StatTile(value: "\(result.exercisesCorrect)", label: "Richtig")
                StatTile(value: "\(result.exercisesTotal - result.exercisesCorrect)", label: "Falsch")
                StatTile(value: String(format: "%.0f s", result.duration), label: "Zeit")
            }
            .padding(.horizontal, AppTheme.Spacing.md)

            Spacer()

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
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }

    private var resultTitle: String {
        if result.accuracy >= 0.9 { return "Perfetto! 🏆" }
        if result.accuracy >= 0.7 { return "Bravissimo! 🎉" }
        if result.accuracy >= 0.5 { return "Bene! Übung macht den Meister." }
        return "Non fa niente — weiter üben!"
    }

    private var resultSubtitle: String {
        "\(result.exercisesCorrect) von \(result.exercisesTotal) Aufgaben richtig gelöst."
    }
}
