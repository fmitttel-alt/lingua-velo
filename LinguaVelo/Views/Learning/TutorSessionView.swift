import SwiftUI

// MARK: - Tutor Session View (AI Private Teacher)

struct TutorSessionView: View {
    let lesson: Lesson
    let previousLesson: Lesson?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var tutor = TutorSession()
    @State private var showSummary = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            if showSummary {
                LessonCompletedView(lessonTitle: lesson.title) {
                    appState.userProfile.totalSessionsCompleted += 1
                    dismiss()
                }
            } else {
                VStack(spacing: 0) {
                    tutorHeader
                    chatArea
                    inputArea
                }
            }
        }
        .onAppear {
            tutor.startLesson(lesson: lesson, previousLesson: previousLesson, level: appState.userProfile.level)
        }
        .onChange(of: tutor.isFinished) { finished in
            if finished {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showSummary = true
                }
            }
        }
        .interactiveDismissDisabled(true)
    }

    // MARK: Header

    private var tutorHeader: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .font(.system(size: 16))
                    .frame(width: 36, height: 36)
                    .background(AppTheme.Colors.backgroundCard)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.title)
                    .font(AppTheme.Font.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text(tutor.phase.rawValue)
                    .font(AppTheme.Font.caption)
                    .foregroundColor(AppTheme.Colors.salmon)
            }

            Spacer()

            // Luigi avatar
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.salmon.opacity(0.2))
                    .frame(width: 40, height: 40)
                Text("L")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.salmon)
            }
            .overlay(Circle().stroke(AppTheme.Colors.salmon.opacity(0.4), lineWidth: 1.5))
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.backgroundCard)
    }

    // MARK: Chat Area

    private var chatArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: AppTheme.Spacing.sm) {
                    // Hero image at top
                    heroImage

                    ForEach(tutor.messages) { msg in
                        ChatBubble(message: msg)
                            .id(msg.id)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    if tutor.isThinking {
                        ThinkingBubble()
                            .id("thinking")
                    }

                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.md)
            }
            .onChange(of: tutor.messages.count) { _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: tutor.isThinking) { _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }

    private var heroImage: some View {
        Image("cycling_hero")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 200)
            .opacity(0.15)
            .padding(.vertical, AppTheme.Spacing.sm)
    }

    // MARK: Input Area (options or free text)

    @ViewBuilder
    private var inputArea: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            if !tutor.inputOptions.isEmpty {
                // Multiple choice options
                VStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(tutor.inputOptions, id: \.self) { option in
                        Button(action: { tutor.userReplied(option) }) {
                            Text(option)
                                .font(AppTheme.Font.callout)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, AppTheme.Spacing.md)
                                .padding(.vertical, AppTheme.Spacing.sm)
                                .background(AppTheme.Colors.backgroundCard)
                                .cornerRadius(AppTheme.Radius.sm)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                        .stroke(AppTheme.Colors.salmon.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(tutor.isThinking)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }

            // Free text input always available
            FreeTextInput(isDisabled: tutor.isThinking) { text in
                tutor.userReplied(text)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.backgroundCard)
    }
}

// MARK: - Chat Bubble

struct ChatBubble: View {
    let message: TutorMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: AppTheme.Spacing.sm) {
            if message.role == .tutor {
                tutorAvatar
                tutorBubble
                Spacer(minLength: 48)
            } else {
                Spacer(minLength: 48)
                userBubble
            }
        }
    }

    private var tutorAvatar: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.salmon.opacity(0.2))
                .frame(width: 30, height: 30)
            Text("L")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.Colors.salmon)
        }
    }

    private var tutorBubble: some View {
        Text(message.text)
            .font(AppTheme.Font.bodyText)
            .foregroundColor(AppTheme.Colors.textPrimary)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.backgroundCard)
            .cornerRadius(AppTheme.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(AppTheme.Colors.salmon.opacity(0.2), lineWidth: 1)
            )
    }

    private var userBubble: some View {
        Text(message.text)
            .font(AppTheme.Font.bodyText)
            .foregroundColor(AppTheme.Colors.white)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.salmon)
            .cornerRadius(AppTheme.Radius.md)
    }
}

// MARK: - Thinking Bubble

struct ThinkingBubble: View {
    @State private var dotOffset: CGFloat = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: AppTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.salmon.opacity(0.2))
                    .frame(width: 30, height: 30)
                Text("L")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.salmon)
            }
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(AppTheme.Colors.textMuted)
                        .frame(width: 7, height: 7)
                        .offset(y: dotOffset)
                        .animation(
                            .easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15),
                            value: dotOffset
                        )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm + 4)
            .background(AppTheme.Colors.backgroundCard)
            .cornerRadius(AppTheme.Radius.md)
            .onAppear { dotOffset = -5 }
            Spacer(minLength: 48)
        }
    }
}

// MARK: - Free Text Input

struct FreeTextInput: View {
    let isDisabled: Bool
    let onSend: (String) -> Void
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            TextField("Deine Antwort…", text: $text)
                .font(AppTheme.Font.bodyText)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(AppTheme.Colors.backgroundElevated)
                .cornerRadius(AppTheme.Radius.full)
                .focused($focused)
                .disabled(isDisabled)
                .onSubmit { sendText() }

            Button(action: sendText) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(text.isEmpty || isDisabled ? AppTheme.Colors.textMuted : AppTheme.Colors.salmon)
            }
            .disabled(text.isEmpty || isDisabled)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func sendText() {
        guard !text.isEmpty, !isDisabled else { return }
        let sent = text
        text = ""
        focused = false
        onSend(sent)
    }
}

// MARK: - Lesson Completed View

struct LessonCompletedView: View {
    let lessonTitle: String
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            Image("cycling_hero")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220)
                .opacity(0.9)

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Lezione completata!")
                    .font(AppTheme.Font.title)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(lessonTitle)
                    .font(AppTheme.Font.headline)
                    .foregroundColor(AppTheme.Colors.salmon)

                Text("Bravissimo! Du hast diese Lektion erfolgreich abgeschlossen.")
                    .font(AppTheme.Font.callout)
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }

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
    }
}
