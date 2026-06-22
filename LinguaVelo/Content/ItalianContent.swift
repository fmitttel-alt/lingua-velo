import Foundation

// MARK: - Italian Content for Cyclists (A0–B1)
// Alle Inhalte von einem Muttersprachler zu prüfen vor Veröffentlichung

struct ItalianContent {

    // MARK: Vocabulary

    static let vocabulary: [VocabCard] = [

        // GREETINGS
        VocabCard(italian: "Ciao", german: "Hallo / Tschüss",
                  pronunciation: "tschao",
                  exampleSentence: "Ciao, come stai?",
                  exampleTranslation: "Hallo, wie geht's dir?",
                  category: .greetings),
        VocabCard(italian: "Buongiorno", german: "Guten Morgen / Guten Tag",
                  pronunciation: "buon-dschor-no",
                  exampleSentence: "Buongiorno, ho una prenotazione.",
                  exampleTranslation: "Guten Tag, ich habe eine Reservierung.",
                  category: .greetings),
        VocabCard(italian: "Buonasera", german: "Guten Abend",
                  pronunciation: "buona-sera",
                  exampleSentence: "Buonasera, una camera per favore.",
                  exampleTranslation: "Guten Abend, ein Zimmer bitte.",
                  category: .greetings),
        VocabCard(italian: "Grazie", german: "Danke",
                  pronunciation: "graa-tsje",
                  exampleSentence: "Grazie mille!",
                  exampleTranslation: "Vielen Dank!",
                  category: .greetings),
        VocabCard(italian: "Prego", german: "Bitte / Gern geschehen",
                  pronunciation: "preh-go",
                  exampleSentence: "Prego, si accomodi.",
                  exampleTranslation: "Bitte, nehmen Sie Platz.",
                  category: .greetings),
        VocabCard(italian: "Scusi", german: "Entschuldigung",
                  pronunciation: "skuu-si",
                  exampleSentence: "Scusi, dov'è la stazione?",
                  exampleTranslation: "Entschuldigung, wo ist der Bahnhof?",
                  category: .greetings),

        // FOOD & DRINK
        VocabCard(italian: "Un caffè, per favore", german: "Einen Kaffee, bitte",
                  pronunciation: "un kaf-feh per fa-vo-re",
                  exampleSentence: "Un caffè e un cornetto, per favore.",
                  exampleTranslation: "Einen Kaffee und ein Croissant, bitte.",
                  category: .food),
        VocabCard(italian: "Acqua", german: "Wasser",
                  pronunciation: "ak-kwa",
                  exampleSentence: "Un litro d'acqua frizzante, per favore.",
                  exampleTranslation: "Ein Liter Sprudelwasser, bitte.",
                  category: .food),
        VocabCard(italian: "Il menu", german: "Die Speisekarte",
                  pronunciation: "il me-nuu",
                  exampleSentence: "Posso avere il menù?",
                  exampleTranslation: "Kann ich die Speisekarte haben?",
                  category: .food),
        VocabCard(italian: "Il conto", german: "Die Rechnung",
                  pronunciation: "il kon-to",
                  exampleSentence: "Il conto, per favore.",
                  exampleTranslation: "Die Rechnung, bitte.",
                  category: .food),
        VocabCard(italian: "Una pizza", german: "Eine Pizza",
                  pronunciation: "una pits-tsa",
                  exampleSentence: "Una pizza margherita, per favore.",
                  exampleTranslation: "Eine Margherita-Pizza, bitte.",
                  category: .food),
        VocabCard(italian: "Sono vegetariano", german: "Ich bin Vegetarier",
                  pronunciation: "sono ve-dsche-ta-rja-no",
                  exampleSentence: "Sono vegetariano, cosa consiglia?",
                  exampleTranslation: "Ich bin Vegetarier, was empfehlen Sie?",
                  category: .food),

        // DIRECTIONS
        VocabCard(italian: "Dov'è...?", german: "Wo ist...?",
                  pronunciation: "do-veh",
                  exampleSentence: "Dov'è la fermata dell'autobus?",
                  exampleTranslation: "Wo ist die Bushaltestelle?",
                  category: .directions),
        VocabCard(italian: "A destra", german: "Nach rechts",
                  pronunciation: "a des-tra",
                  exampleSentence: "Giri a destra al semaforo.",
                  exampleTranslation: "Biegen Sie an der Ampel rechts ab.",
                  category: .directions),
        VocabCard(italian: "A sinistra", german: "Nach links",
                  pronunciation: "a si-nis-tra",
                  exampleSentence: "Prenda a sinistra dopo il ponte.",
                  exampleTranslation: "Nehmen Sie nach der Brücke links.",
                  category: .directions),
        VocabCard(italian: "Sempre dritto", german: "Geradeaus",
                  pronunciation: "sem-pre drit-to",
                  exampleSentence: "Vada sempre dritto per due chilometri.",
                  exampleTranslation: "Fahren Sie zwei Kilometer geradeaus.",
                  category: .directions),
        VocabCard(italian: "Quanti chilometri?", german: "Wie viele Kilometer?",
                  pronunciation: "kwan-ti ki-lo-me-tri",
                  exampleSentence: "Quanti chilometri mancano al paese?",
                  exampleTranslation: "Wie viele Kilometer sind es noch bis zum Ort?",
                  category: .directions),

        // CYCLING
        VocabCard(italian: "La bicicletta / La bici", german: "Das Fahrrad",
                  pronunciation: "la bi-tschic-let-ta",
                  exampleSentence: "Ho una foratura sulla bici.",
                  exampleTranslation: "Ich habe einen Platten am Fahrrad.",
                  category: .cycling),
        VocabCard(italian: "Una foratura", german: "Ein Platten (Reifenpanne)",
                  pronunciation: "una fo-ra-tu-ra",
                  exampleSentence: "Ho bisogno di riparare una foratura.",
                  exampleTranslation: "Ich muss einen Platten reparieren.",
                  category: .cycling),
        VocabCard(italian: "Il negozio di biciclette", german: "Der Fahrradladen",
                  pronunciation: "il ne-go-tsjo di bi-tschic-let-te",
                  exampleSentence: "C'è un negozio di biciclette vicino?",
                  exampleTranslation: "Gibt es einen Fahrradladen in der Nähe?",
                  category: .cycling),
        VocabCard(italian: "La salita / Il passo", german: "Die Steigung / Der Pass",
                  pronunciation: "la sa-li-ta / il pas-so",
                  exampleSentence: "Quanto è ripida la salita?",
                  exampleTranslation: "Wie steil ist die Steigung?",
                  category: .cycling),
        VocabCard(italian: "La discesa", german: "Die Abfahrt",
                  pronunciation: "la di-sche-sa",
                  exampleSentence: "Attenzione in discesa!",
                  exampleTranslation: "Vorsicht bei der Abfahrt!",
                  category: .cycling),
        VocabCard(italian: "La pompa", german: "Die Fahrradpumpe",
                  pronunciation: "la pom-pa",
                  exampleSentence: "Ha una pompa per le bici?",
                  exampleTranslation: "Haben Sie eine Fahrradpumpe?",
                  category: .cycling),
        VocabCard(italian: "Il percorso ciclabile", german: "Der Radweg",
                  pronunciation: "il per-kor-so tschic-la-bi-le",
                  exampleSentence: "C'è un percorso ciclabile per il centro?",
                  exampleTranslation: "Gibt es einen Radweg zur Innenstadt?",
                  category: .cycling),

        // ACCOMMODATION
        VocabCard(italian: "Una camera", german: "Ein Zimmer",
                  pronunciation: "una ka-me-ra",
                  exampleSentence: "Vorrei una camera singola.",
                  exampleTranslation: "Ich hätte gerne ein Einzelzimmer.",
                  category: .accommodation),
        VocabCard(italian: "La colazione", german: "Das Frühstück",
                  pronunciation: "la ko-la-tsjo-ne",
                  exampleSentence: "La colazione è inclusa?",
                  exampleTranslation: "Ist das Frühstück inbegriffen?",
                  category: .accommodation),
        VocabCard(italian: "A che ora?", german: "Um wie viel Uhr?",
                  pronunciation: "a ke o-ra",
                  exampleSentence: "A che ora è il check-out?",
                  exampleTranslation: "Um wie viel Uhr ist der Check-out?",
                  category: .accommodation),
        VocabCard(italian: "C'è un box per le bici?", german: "Gibt es einen abschließbaren Fahrradraum?",
                  pronunciation: "tscheh un boks per le bi-tschi",
                  exampleSentence: "C'è un posto sicuro per parcheggiare la bici?",
                  exampleTranslation: "Gibt es einen sicheren Platz, um das Fahrrad abzustellen?",
                  category: .accommodation),

        // EMERGENCY
        VocabCard(italian: "Aiuto!", german: "Hilfe!",
                  pronunciation: "a-ju-to",
                  exampleSentence: "Aiuto, sono caduto!",
                  exampleTranslation: "Hilfe, ich bin gestürzt!",
                  category: .emergency),
        VocabCard(italian: "Ho bisogno di un medico", german: "Ich brauche einen Arzt",
                  pronunciation: "o bi-so-njo di un me-di-ko",
                  exampleSentence: "Ho bisogno di un medico urgentemente.",
                  exampleTranslation: "Ich brauche dringend einen Arzt.",
                  category: .emergency),
        VocabCard(italian: "Mi fa male qui", german: "Hier tut es weh",
                  pronunciation: "mi fa ma-le kwi",
                  exampleSentence: "Mi fa male il ginocchio.",
                  exampleTranslation: "Mein Knie tut weh.",
                  category: .emergency),
        VocabCard(italian: "Il numero di emergenza", german: "Die Notrufnummer",
                  pronunciation: "il nuu-me-ro di e-mer-dschen-tsa",
                  exampleSentence: "Qual è il numero di emergenza?",
                  exampleTranslation: "Was ist die Notrufnummer?",
                  category: .emergency),

        // WEATHER
        VocabCard(italian: "Che tempo fa?", german: "Wie ist das Wetter?",
                  pronunciation: "ke tem-po fa",
                  exampleSentence: "Che tempo farà domani?",
                  exampleTranslation: "Wie wird das Wetter morgen?",
                  category: .weather),
        VocabCard(italian: "Piove", german: "Es regnet",
                  pronunciation: "pjo-ve",
                  exampleSentence: "Piove, meglio aspettare.",
                  exampleTranslation: "Es regnet, besser warten.",
                  category: .weather),
        VocabCard(italian: "Il vento", german: "Der Wind",
                  pronunciation: "il ven-to",
                  exampleSentence: "C'è molto vento oggi.",
                  exampleTranslation: "Heute ist es sehr windig.",
                  category: .weather),
    ]

    // MARK: - Lessons

    static let lessons: [Lesson] = [
        makeLessonGreetings(),
        makeLessonCafe(),
        makeLessonDirections(),
        makeLessonCycling(),
        makeLessonAccommodation(),
        makeLessonEmergency(),
    ]

    // MARK: - Lesson Builders

    private static func makeLessonGreetings() -> Lesson {
        let cards = vocabulary.filter { $0.category == .greetings }
        return Lesson(
            id: "greetings-1",
            title: "Ciao Italia!",
            subtitle: "Erste Worte für die Reise",
            level: .a0,
            category: .greetings,
            exercises: cards.flatMap { exercisesFor(card: $0) }
        )
    }

    private static func makeLessonCafe() -> Lesson {
        let cards = vocabulary.filter { $0.category == .food }
        return Lesson(
            id: "cafe-1",
            title: "Al Bar",
            subtitle: "Im Café & Restaurant bestellen",
            level: .a0,
            category: .food,
            exercises: cards.flatMap { exercisesFor(card: $0) }
        )
    }

    private static func makeLessonDirections() -> Lesson {
        let cards = vocabulary.filter { $0.category == .directions }
        return Lesson(
            id: "directions-1",
            title: "Dove Vado?",
            subtitle: "Nach dem Weg fragen",
            level: .a1,
            category: .directions,
            exercises: cards.flatMap { exercisesFor(card: $0) }
        )
    }

    private static func makeLessonCycling() -> Lesson {
        let cards = vocabulary.filter { $0.category == .cycling }
        return Lesson(
            id: "cycling-1",
            title: "In Bici!",
            subtitle: "Alles rund ums Radfahren",
            level: .a1,
            category: .cycling,
            exercises: cards.flatMap { exercisesFor(card: $0) }
        )
    }

    private static func makeLessonAccommodation() -> Lesson {
        let cards = vocabulary.filter { $0.category == .accommodation }
        return Lesson(
            id: "accommodation-1",
            title: "All'Albergo",
            subtitle: "Im Hotel & bei der Unterkunft",
            level: .a1,
            category: .accommodation,
            exercises: cards.flatMap { exercisesFor(card: $0) }
        )
    }

    private static func makeLessonEmergency() -> Lesson {
        let cards = vocabulary.filter { $0.category == .emergency }
        return Lesson(
            id: "emergency-1",
            title: "Emergenza!",
            subtitle: "Im Notfall — wichtige Sätze",
            level: .a0,
            category: .emergency,
            exercises: cards.flatMap { exercisesFor(card: $0) }
        )
    }

    // MARK: - Exercise Generator

    private static func exercisesFor(card: VocabCard) -> [Exercise] {
        [
            // 1. Listen and repeat
            Exercise(
                type: .listenAndRepeat,
                prompt: "Hör zu und wiederhole: \(card.german)",
                promptItalian: card.italian,
                correctAnswer: card.italian,
                hint: card.pronunciation,
                vocabularyID: card.id
            ),
            // 2. Translate DE→IT
            Exercise(
                type: .translate,
                prompt: "Wie sagt man auf Italienisch: \"\(card.german)\"?",
                correctAnswer: card.italian,
                alternatives: makeAlternatives(correct: card.italian, from: vocabulary.map { $0.italian }),
                hint: card.pronunciation,
                vocabularyID: card.id
            ),
            // 3. Example sentence — listen only
            Exercise(
                type: .listenOnly,
                prompt: card.exampleTranslation,
                promptItalian: card.exampleSentence,
                correctAnswer: card.exampleSentence,
                vocabularyID: card.id
            ),
        ]
    }

    private static func makeAlternatives(correct: String, from pool: [String]) -> [String] {
        pool.filter { $0 != correct }.shuffled().prefix(3).map { $0 }
    }
}
