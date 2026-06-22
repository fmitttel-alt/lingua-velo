import Foundation
import SwiftUI

// MARK: - Tutor Session (Gemini-powered private teacher)

@MainActor
class TutorSession: ObservableObject {

    @Published var messages: [TutorMessage] = []
    @Published var inputOptions: [String] = []
    @Published var isThinking: Bool = false
    @Published var isFinished: Bool = false
    @Published var phase: LessonPhase = .review

    private let session = URLSession.shared
    private var lessonTitle: String = ""
    private var lessonIntro: String = ""
    private var levelName: String = ""
    private var previousLessonTitle: String? = nil
    private var messageHistory: [[String: Any]] = []
    private var turnCount: Int = 0
    private let maxTurns = 20

    enum LessonPhase: String {
        case review = "Wiederholung"
        case teaching = "Einführung"
        case practice = "Übung"
        case hardExercises = "Vertiefung"
        case summary = "Abschluss"
    }

    // MARK: - Start

    func startLesson(lesson: Lesson, previousLesson: Lesson?, level: LanguageLevel) {
        lessonTitle = lesson.title
        lessonIntro = lesson.introText ?? lesson.subtitle
        levelName = level.displayName
        previousLessonTitle = previousLesson?.title
        messages = []
        messageHistory = []
        turnCount = 0
        isFinished = false
        phase = previousLesson != nil ? .review : .teaching

        Task {
            await sendTutorOpener()
        }
    }

    // MARK: - User Reply

    func userReplied(_ text: String) {
        guard !text.isEmpty else { return }
        addMessage(TutorMessage(role: .user, text: text))
        messageHistory.append(["role": "user", "parts": [["text": text]]])
        turnCount += 1

        if turnCount >= maxTurns {
            Task { await sendFinalSummary() }
        } else {
            Task { await sendTutorResponse() }
        }
    }

    // MARK: - Gemini Calls

    private func sendTutorOpener() async {
        isThinking = true
        let openerPrompt = buildOpenerPrompt()
        let reply = await callGemini(userMessage: openerPrompt, isSystem: true)
        isThinking = false
        processReply(reply)
    }

    private func sendTutorResponse() async {
        isThinking = true
        let reply = await callGemini(userMessage: nil, isSystem: false)
        isThinking = false
        processReply(reply)
    }

    private func sendFinalSummary() async {
        isThinking = true
        phase = .summary
        let summaryRequest = "Bitte gib jetzt eine kurze Zusammenfassung der heutigen Lektion (\(lessonTitle)) und verabschiede dich motivierend. Stelle am Ende KEINE Optionen mehr vor — schreibe nur: OPTIONS:[]"
        messageHistory.append(["role": "user", "parts": [["text": summaryRequest]]])
        let reply = await callGemini(userMessage: nil, isSystem: false)
        isThinking = false
        processReply(reply)
        isFinished = true
    }

    private func callGemini(userMessage: String?, isSystem: Bool) async -> String {
        guard !Config.geminiAPIKey.isEmpty, Config.geminiAPIKey != "YOUR_GEMINI_API_KEY" else {
            return "TUTOR:Gemini API Key fehlt. Bitte in Config.swift eintragen.\nOPTIONS:[]"
        }

        if let msg = userMessage {
            messageHistory.append(["role": "user", "parts": [["text": msg]]])
        }

        let model = "gemini-2.0-flash"
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(Config.geminiAPIKey)"
        guard let url = URL(string: urlString) else { return fallbackMessage() }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 20

        let body: [String: Any] = [
            "system_instruction": ["parts": [["text": systemPrompt]]],
            "contents": messageHistory,
            "generationConfig": ["maxOutputTokens": 400, "temperature": 0.7]
        ]

        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await session.data(for: req)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return fallbackMessage()
            }
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let candidates = json?["candidates"] as? [[String: Any]]
            let content = candidates?.first?["content"] as? [String: Any]
            let parts = content?["parts"] as? [[String: Any]]
            let text = parts?.first?["text"] as? String ?? fallbackMessage()
            messageHistory.append(["role": "model", "parts": [["text": text]]])
            return text
        } catch {
            return fallbackMessage()
        }
    }

    // MARK: - Parse Reply

    private func processReply(_ raw: String) {
        // Expected format:
        // TUTOR: <tutor text>
        // OPTIONS: ["Option A", "Option B", "Option C"]

        var tutorText = raw
        var options: [String] = []

        if let optionsRange = raw.range(of: "OPTIONS:") {
            tutorText = String(raw[raw.startIndex..<optionsRange.lowerBound])
                .replacingOccurrences(of: "TUTOR:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let optionsPart = String(raw[optionsRange.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)

            // Parse ["A", "B", "C"]
            if let data = optionsPart.data(using: .utf8),
               let arr = try? JSONSerialization.jsonObject(with: data) as? [String] {
                options = arr
            }
        } else {
            tutorText = raw
                .replacingOccurrences(of: "TUTOR:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if !tutorText.isEmpty {
            addMessage(TutorMessage(role: .tutor, text: tutorText))
        }
        inputOptions = options
        updatePhase()
    }

    private func updatePhase() {
        let progress = Double(turnCount) / Double(maxTurns)
        if progress < 0.15 { phase = previousLessonTitle != nil ? .review : .teaching }
        else if progress < 0.4 { phase = .teaching }
        else if progress < 0.7 { phase = .practice }
        else if progress < 0.9 { phase = .hardExercises }
        else { phase = .summary }
    }

    // MARK: - Prompts

    private var systemPrompt: String {
        """
        Du bist Luigi, ein freundlicher, geduldiger und motivierender italienischer Privatlehrer. Du unterrichtest Deutsch-Muttersprachler.

        AKTUELLER UNTERRICHTSSTIL:
        - Erkläre Schritt für Schritt, wie ein echter Privatlehrer
        - Stelle immer eine Frage oder Aufgabe am Ende deiner Nachricht
        - Gib sofort Feedback (richtig/falsch + Erklärung)
        - Korrigiere sanft aber klar
        - Nutze viel Ermutigung: "Bravissimo!", "Ottimo!", "Quasi richtig — versuch nochmal!"
        - Wechsle zwischen Deutsch und Italienisch — Erklärungen auf Deutsch, Übungen auf Italienisch
        - Steigere den Schwierigkeitsgrad im Laufe der Lektion
        - Gegen Ende: zusammenfassen und alles nochmal abfragen

        ANTWORTFORMAT (IMMER exakt so):
        TUTOR: <deine Nachricht als Lehrer — max. 3 kurze Sätze>
        OPTIONS: ["Option A", "Option B", "Option C", "Option D"]

        Wenn keine Multiple-Choice-Optionen sinnvoll sind (z.B. bei freier Übersetzung):
        OPTIONS: []

        AKTUELLE LEKTION: \(lessonTitle)
        THEMA: \(lessonIntro)
        NIVEAU DES SCHÜLERS: \(levelName)
        \(previousLessonTitle.map { "VORHERIGE LEKTION (kurz wiederholen am Anfang): \($0)" } ?? "")

        LEKTIONSSTRUKTUR:
        1. Kurze Wiederholung der letzten Lektion (2-3 Fragen)
        2. Neue Inhalte einführen — erkläre das Konzept
        3. Einfache Übungen
        4. Schwerere Übungen und Satzbildung
        5. Abschlusszusammenfassung

        Bleibe beim Thema \(lessonTitle). Sei konkret, lehrreich und motivierend.
        """
    }

    private func buildOpenerPrompt() -> String {
        if let prev = previousLessonTitle {
            return "Starte die Lektion. Begrüße mich kurz und fange mit der Wiederholung von '\(prev)' an — stelle mir 2 schnelle Fragen dazu."
        } else {
            return "Starte die erste Lektion '\(lessonTitle)'. Begrüße mich herzlich und beginne direkt mit der Einführung des Themas."
        }
    }

    private func fallbackMessage() -> String {
        "TUTOR: Entschuldigung, ich konnte keine Verbindung zu Gemini herstellen. Bitte überprüfe deine Internetverbindung und den API-Key.\nOPTIONS: [\"Nochmal versuchen\"]"
    }

    // MARK: - Helpers

    private func addMessage(_ msg: TutorMessage) {
        withAnimation(.easeIn(duration: 0.3)) {
            messages.append(msg)
        }
    }
}

// MARK: - Message Model

struct TutorMessage: Identifiable {
    let id = UUID()
    let role: Role
    let text: String
    let timestamp = Date()

    enum Role { case tutor, user }
}
