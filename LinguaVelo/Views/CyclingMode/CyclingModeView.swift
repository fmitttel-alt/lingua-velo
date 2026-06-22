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
                    cyclingLandingContent
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $activeSession) {
            if let lesson = selectedLesson {
                CyclingSessionView(lesson: lesson, avatar: appState.selectedAvatar)
            }
        }
    }

    private var cyclingLandingContent: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            // Hero
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "bicycle")
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(AppTheme.Colors.salmon)
                    .glow(AppTheme.Colors.salmon, radius: 16)

                Text("Fahrmodus")
                    .font(AppTheme.Font.title)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Hände am Lenker, Augen auf die Straße.\nDein Tutor spricht — du antwortest.")
                    .font(AppTheme.Font.callout)
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppTheme.Spacing.xl)

            Spacer()

            // Wake word hint
            wakeWordHint

            // Lesson picker
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Wähle eine Lektion")
                    .font(AppTheme.Font.subhead)
                    .foregroundColor(AppTheme.Colors.textMuted)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(appState.lessons) { lesson in
                            CyclingLessonChip(
                                lesson: lesson,
                                isSelected: selectedLesson?.id == lesson.id
                            ) {
                                selectedLesson = lesson
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                }
            }

            // Start button
            Button(action: { activeSession = true }) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 22))
                    Text("Fahrmodus starten")
                        .font(AppTheme.Font.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(AppTheme.Spacing.md)
                .background(
                    selectedLesson != nil ? AppTheme.Colors.salmon : AppTheme.Colors.gray700
                )
                .foregroundColor(AppTheme.Colors.white)
                .cornerRadius(AppTheme.Radius.md)
                .glow(AppTheme.Colors.salmon, radius: selectedLesson != nil ? 10 : 0)
            }
            .disabled(selectedLesson == nil)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
    }

    private var wakeWordHint: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "waveform")
                .foregroundColor(AppTheme.Colors.sage)
            Text("Sag \"\(appState.selectedAvatar.fullWakeWord)\" um zu beginnen")
                .font(AppTheme.Font.subhead)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.sage.opacity(0.1))
        .cornerRadius(AppTheme.Radius.full)
    }
}

// MARK: - Safety Warning

struct SafetyWarningView: View {
    let onAccept: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.rose)

            Text("Sicherheitshinweis")
                .font(AppTheme.Font.title)
                .foregroundColor(AppTheme.Colors.textPrimary)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                SafetyPoint(text: "Achte stets auf den Straßenverkehr.")
                SafetyPoint(text: "Beachte die lokalen Gesetze zur Kopfhörernutzung beim Radfahren.")
                SafetyPoint(text: "Nutze nur einen Ohrhörer oder Knochenschall-KH.")
                SafetyPoint(text: "Bei hoher Geschwindigkeit wechselt die App automatisch in den Zuhör-Modus.")
                SafetyPoint(text: "Das Display ist Zusatzinfo — du musst nicht auf den Bildschirm schauen.")
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.backgroundCard)
            .cornerRadius(AppTheme.Radius.md)
            .padding(.horizontal, AppTheme.Spacing.md)

            Spacer()

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

struct CyclingLessonChip: View {
    let lesson: Lesson
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: lesson.category.icon)
                    .font(.system(size: 18))
                Text(lesson.title)
                    .font(AppTheme.Font.caption)
                    .lineLimit(1)
            }
            .frame(width: 80)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isSelected ? AppTheme.Colors.salmon : AppTheme.Colors.backgroundCard)
            .foregroundColor(isSelected ? AppTheme.Colors.white : AppTheme.Colors.textSecondary)
            .cornerRadius(AppTheme.Radius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                    .stroke(isSelected ? AppTheme.Colors.salmon : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Cycling Session (the core differentiation screen)

struct CyclingSessionView: View {
    let lesson: Lesson
    let avatar: Avatar
    @Environment(\.dismiss) var dismiss
    @StateObject private var engine = LearningEngine.shared
    @StateObject private var stt = SpeechRecognizer.shared
    @StateObject private var tts = ElevenLabsTTS.shared
    @StateObject private var wakeWord = WakeWordDetector()

    @State private var transcriptLines: [TranscriptLine] = []
    @State private var showEndConfirm = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                cyclingHeader
                transcriptArea
                bottomControls
            }
        }
        .onAppear {
            engine.startSession(lesson: lesson, avatar: avatar, mode: .cycling, level: .a0)
            wakeWord.start()
        }
        .onDisappear {
            _ = engine.endSession()
            wakeWord.stop()
        }
        .onChange(of: stt.transcript) { text in
            updateTranscript(text: text, source: .user)
        }
        .onChange(of: tts.isSpeaking) { speaking in
            if !speaking, let exercise = engine.currentExercise {
                updateTranscript(text: exercise.prompt, source: .tutor)
            }
        }
        .alert("Fahrmodus beenden?", isPresented: $showEndConfirm) {
            Button("Beenden", role: .destructive) { dismiss() }
            Button("Weiter", role: .cancel) {}
        }
    }

    // MARK: Header

    private var cyclingHeader: some View {
        HStack {
            // Speed indicator
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.0f km/h", engine.currentSpeed))
                    .font(AppTheme.Font.cyclingStatus)
                    .foregroundColor(engine.isHighSpeed ? AppTheme.Colors.rose : AppTheme.Colors.sage)
                Text(engine.isHighSpeed ? "Zuhör-Modus" : "Vollmodus")
                    .font(AppTheme.Font.caption)
                    .foregroundColor(AppTheme.Colors.textMuted)
            }

            Spacer()

            // Listening indicator
            ListeningIndicator(isListening: engine.isListeningForAnswer, isSpeaking: tts.isSpeaking)

            Spacer()

            // Avatar + close
            HStack(spacing: AppTheme.Spacing.sm) {
                AvatarBadge(avatar: avatar, size: 36)
                Button(action: { showEndConfirm = true }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundCard)
    }

    // MARK: Transcript Area (the key visual — always on)

    private var transcriptArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Spacer(minLength: AppTheme.Spacing.md)

                    ForEach(transcriptLines) { line in
                        TranscriptLineView(line: line)
                            .id(line.id)
                    }

                    // Live input line
                    if engine.isListeningForAnswer && !stt.transcript.isEmpty {
                        TranscriptLineView(
                            line: TranscriptLine(
                                id: UUID(),
                                text: stt.transcript,
                                source: .user,
                                isLive: true,
                                timestamp: Date()
                            )
                        )
                        .id("live")
                    }

                    Spacer(minLength: AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
            .onChange(of: transcriptLines.count) { _ in
                withAnimation { proxy.scrollTo(transcriptLines.last?.id, anchor: .bottom) }
            }
        }
        .background(AppTheme.Colors.background)
    }

    // MARK: Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Progress
            ProgressView(value: engine.sessionProgress, total: 1.0)
                .tint(AppTheme.Colors.salmon)
                .background(AppTheme.Colors.backgroundElevated)

            HStack(spacing: AppTheme.Spacing.md) {
                // Skip
                Button(action: engine.skip) {
                    HStack(spacing: 4) {
                        Image(systemName: "forward.fill")
                        Text("Überspringen")
                    }
                    .font(AppTheme.Font.subhead)
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.backgroundCard)
                    .cornerRadius(AppTheme.Radius.full)
                }

                Spacer()

                // Mic button — large touch target
                Button(action: engine.startListeningForAnswer) {
                    ZStack {
                        Circle()
                            .fill(engine.isListeningForAnswer ? AppTheme.Colors.salmon : AppTheme.Colors.deepSage)
                            .frame(width: 64, height: 64)
                            .glow(engine.isListeningForAnswer ? AppTheme.Colors.salmon : AppTheme.Colors.deepSage, radius: 10)

                        Image(systemName: engine.isListeningForAnswer ? "waveform" : "mic.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(AppTheme.Colors.white)
                    }
                }
                .disabled(engine.isListeningForAnswer || tts.isSpeaking)

                Spacer()

                // Repeat
                Button(action: { engine.advanceToNextExercise() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Wiederholen")
                    }
                    .font(AppTheme.Font.subhead)
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.backgroundCard)
                    .cornerRadius(AppTheme.Radius.full)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.backgroundCard)
    }

    // MARK: Helpers

    private func updateTranscript(text: String, source: TranscriptLine.Source) {
        let line = TranscriptLine(id: UUID(), text: text, source: source, isLive: false, timestamp: Date())
        withAnimation { transcriptLines.append(line) }
    }
}

// MARK: - Transcript Models

struct TranscriptLine: Identifiable {
    let id: UUID
    let text: String
    let source: Source
    let isLive: Bool
    let timestamp: Date

    enum Source { case tutor, user }
}

struct TranscriptLineView: View {
    let line: TranscriptLine

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
            if line.source == .tutor {
                tutorLine
                Spacer(minLength: 40)
            } else {
                Spacer(minLength: 40)
                userLine
            }
        }
    }

    private var tutorLine: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(line.text)
                .font(AppTheme.Font.cyclingTranscript)
                .foregroundColor(line.isLive ? AppTheme.Colors.sage.opacity(0.7) : AppTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.backgroundCard)
        .cornerRadius(AppTheme.Radius.md)
        .cornerRadius(AppTheme.Radius.sm, corners: .topLeft)
    }

    private var userLine: some View {
        Text(line.text)
            .font(AppTheme.Font.cyclingTranscript)
            .foregroundColor(line.isLive ? AppTheme.Colors.salmon.opacity(0.7) : AppTheme.Colors.white)
            .padding(AppTheme.Spacing.sm)
            .background(line.isLive ? AppTheme.Colors.salmon.opacity(0.2) : AppTheme.Colors.salmon)
            .cornerRadius(AppTheme.Radius.md)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Listening Indicator

struct ListeningIndicator: View {
    let isListening: Bool
    let isSpeaking: Bool
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .scaleEffect(pulse ? 1.4 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulse)
            Text(label)
                .font(AppTheme.Font.cyclingStatus)
                .foregroundColor(color)
        }
        .onAppear { pulse = true }
    }

    private var label: String {
        if isSpeaking  { return "Tutor spricht" }
        if isListening { return "Ich höre zu..." }
        return "Bereit"
    }

    private var color: Color {
        if isSpeaking  { return AppTheme.Colors.sage }
        if isListening { return AppTheme.Colors.salmon }
        return AppTheme.Colors.textMuted
    }
}

// MARK: - Corner radius helper

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
