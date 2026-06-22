import Foundation

// MARK: - Structured Italian Curriculum (A0 → A2)
// Organized like a school textbook: Units → Lessons → Exercises

struct ItalianContent {

    // MARK: - All Lessons (ordered by curriculum)

    static let lessons: [Lesson] = [
        // === UNIT 1: Erste Schritte / A0 ===
        lessonGreetings(),
        lessonNumbers1to10(),
        lessonColors(),
        lessonArticles(),

        // === UNIT 2: Ich und du / A0–A1 ===
        lessonEssereHavere(),
        lessonFamily(),
        lessonNumbers11to100(),

        // === UNIT 3: Fragen stellen / A1 ===
        lessonQuestions(),
        lessonDaysMonths(),
        lessonTime(),

        // === UNIT 4: Unterwegs / A1 ===
        lessonDirections(),
        lessonPrepositions(),
        lessonTransport(),

        // === UNIT 5: Essen & Reisen / A1–A2 ===
        lessonCafe(),
        lessonRestaurant(),
        lessonAccommodation(),

        // === UNIT 6: Radreise spezial / A1–A2 ===
        lessonCycling(),
        lessonWeather(),
        lessonEmergency(),
    ]

    // MARK: - Vocabulary Pool (for FSRS cards)

    static let vocabulary: [VocabCard] = allVocab()

    // =========================================================
    // MARK: UNIT 1 — Erste Schritte
    // =========================================================

    private static func lessonGreetings() -> Lesson {
        let exercises: [Exercise] = [
            // Intro
            ex(.listenOnly, "Willkommen! Hör die Begrüßungen und lies mit.",
               italian: "Benvenuto! Ascoltiamo i saluti.", answer: "ok"),
            // Core vocab
            mc("Was bedeutet „Ciao"?", answer: "Hallo / Tschüss",
               wrong: ["Danke", "Bitte", "Entschuldigung"]),
            repeat_("Ciao", german: "Hallo"),
            mc("Was bedeutet „Buongiorno"?", answer: "Guten Morgen / Guten Tag",
               wrong: ["Guten Abend", "Auf Wiedersehen", "Entschuldigung"]),
            repeat_("Buongiorno", german: "Guten Morgen"),
            mc("Was bedeutet „Buonasera"?", answer: "Guten Abend",
               wrong: ["Guten Morgen", "Gute Nacht", "Hallo"]),
            repeat_("Buonasera", german: "Guten Abend"),
            mc("Was bedeutet „Arrivederci"?", answer: "Auf Wiedersehen",
               wrong: ["Hallo", "Danke", "Bitte"]),
            repeat_("Arrivederci", german: "Auf Wiedersehen"),
            mc("Was bedeutet „Grazie"?", answer: "Danke",
               wrong: ["Bitte", "Hallo", "Entschuldigung"]),
            repeat_("Grazie", german: "Danke"),
            mc("Was bedeutet „Prego"?", answer: "Bitte / Gern geschehen",
               wrong: ["Danke", "Entschuldigung", "Hallo"]),
            repeat_("Prego", german: "Bitte"),
            mc("Was bedeutet „Scusi"?", answer: "Entschuldigung",
               wrong: ["Danke", "Bitte", "Guten Morgen"]),
            repeat_("Scusi", german: "Entschuldigung"),
            mc("Wie sagst du „Wie geht es dir?" auf Italienisch?", answer: "Come stai?",
               wrong: ["Chi sei?", "Dove sei?", "Cosa fai?"]),
            repeat_("Come stai?", german: "Wie geht es dir?"),
            mc("Was antwortest du, wenn es dir gut geht?", answer: "Sto bene, grazie!",
               wrong: ["Non lo so.", "Sono stanco.", "Arrivederci."]),
            repeat_("Sto bene, grazie!", german: "Mir geht es gut, danke!"),
            mc("Wie heißt du? — Wie sagst du das auf Italienisch?", answer: "Come ti chiami?",
               wrong: ["Dove abiti?", "Quanti anni hai?", "Come stai?"]),
            repeat_("Mi chiamo Luigi.", german: "Ich heiße Luigi."),
        ]
        return Lesson(
            id: "greetings-1",
            title: "Ciao Italia!",
            subtitle: "Erste Begrüßungen & Vorstellung",
            level: .a0,
            category: .greetings,
            exercises: exercises,
            introText: "In dieser Lektion lernst du die wichtigsten Begrüßungen: Ciao, Buongiorno, Buonasera und wie du dich vorstellst. Damit kannst du jeden Italiener herzlich ansprechen."
        )
    }

    private static func lessonNumbers1to10() -> Lesson {
        let pairs: [(String, String)] = [
            ("uno", "1 — eins"), ("due", "2 — zwei"), ("tre", "3 — drei"),
            ("quattro", "4 — vier"), ("cinque", "5 — fünf"),
            ("sei", "6 — sechs"), ("sette", "7 — sieben"), ("otto", "8 — acht"),
            ("nove", "9 — neun"), ("dieci", "10 — zehn")
        ]
        var exercises: [Exercise] = [
            ex(.listenOnly, "Zahlen 1–10 auf Italienisch.", italian: "I numeri da 1 a 10.", answer: "ok")
        ]
        let allIT = pairs.map { $0.0 }
        let allDE = pairs.map { $0.1 }
        for (it, de) in pairs {
            exercises.append(mc("Welche Zahl bedeutet „\(it)"?", answer: de,
                                wrong: allDE.filter { $0 != de }.shuffled().prefix(3).map { $0 }))
            exercises.append(repeat_(it, german: de))
        }
        exercises.append(mc("Wie sagt man „fünf" auf Italienisch?", answer: "cinque",
                            wrong: ["quattro", "sei", "sette"]))
        exercises.append(mc("Wie sagt man „zehn" auf Italienisch?", answer: "dieci",
                            wrong: ["nove", "sette", "otto"]))
        exercises.append(mc("Uno + due = ?", answer: "tre",
                            wrong: ["quattro", "due", "cinque"]))
        return Lesson(
            id: "numbers-1-10",
            title: "Uno, Due, Tre…",
            subtitle: "Zahlen 1 bis 10",
            level: .a0,
            category: .numbers,
            exercises: exercises,
            introText: "Die Zahlen 1–10 sind die Grundlage für alles: Preise, Mengen, Telefonnummern. Lern sie auswendig — sie kommen überall vor."
        )
    }

    private static func lessonColors() -> Lesson {
        let colors: [(String, String)] = [
            ("rosso", "rot"), ("blu", "blau"), ("verde", "grün"),
            ("giallo", "gelb"), ("bianco", "weiß"), ("nero", "schwarz"),
            ("arancione", "orange"), ("rosa", "rosa/pink"), ("grigio", "grau")
        ]
        var exercises: [Exercise] = [
            ex(.listenOnly, "Farben auf Italienisch.", italian: "I colori.", answer: "ok")
        ]
        let allDE = colors.map { $0.1 }
        for (it, de) in colors {
            exercises.append(mc("Was bedeutet „\(it)"?", answer: de,
                                wrong: allDE.filter { $0 != de }.shuffled().prefix(3).map { $0 }))
            exercises.append(repeat_(it, german: de))
        }
        exercises.append(mc("Die Flagge Italiens ist rot, weiß und …?", answer: "verde",
                            wrong: ["blu", "giallo", "nero"]))
        return Lesson(
            id: "colors-1",
            title: "I Colori",
            subtitle: "Farben auf Italienisch",
            level: .a0,
            category: .phrases,
            exercises: exercises,
            introText: "Mit Farben kannst du beschreiben was du siehst — wichtig beim Einkaufen, Beschreiben von Orten oder deinem Fahrrad."
        )
    }

    private static func lessonArticles() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly,
               "Grammatik: Artikel\n\nIm Italienischen haben alle Nomen ein Geschlecht (maskulin/feminin).\n\n• il / un = der / ein (maskulin)\n• la / una = die / eine (feminin)\n• i / le = die (Plural)\n\nBeispiele: il ragazzo (der Junge), la ragazza (das Mädchen)",
               italian: "L'articolo determinativo e indeterminativo.",
               answer: "ok"),
            mc("Was ist der Artikel für ein männliches Wort (singular)?", answer: "il / un",
               wrong: ["la / una", "i / le", "gli / degli"]),
            mc("Was ist der Artikel für ein weibliches Wort (singular)?", answer: "la / una",
               wrong: ["il / un", "i / le", "lo / uno"]),
            mc("Wie heißt „der Kaffee" auf Italienisch?", answer: "il caffè",
               wrong: ["la caffè", "un caffè", "le caffè"]),
            mc("Wie heißt „die Pizza" auf Italienisch?", answer: "la pizza",
               wrong: ["il pizza", "un pizza", "i pizza"]),
            mc("Was ist der maskuline Pluralartikel?", answer: "i",
               wrong: ["le", "la", "il"]),
            mc("Was ist der feminine Pluralartikel?", answer: "le",
               wrong: ["i", "il", "la"]),
            mc("„eine Flasche" auf Italienisch?", answer: "una bottiglia",
               wrong: ["il bottiglia", "un bottiglia", "le bottiglie"]),
            mc("„ein Fahrrad" — La bici oder Il bici?", answer: "La bici (feminin)",
               wrong: ["Il bici (maskulin)", "I bici (Plural)", "Un bici (maskulin)"]),
            repeat_("il ragazzo", german: "der Junge"),
            repeat_("la ragazza", german: "das Mädchen"),
            repeat_("il caffè", german: "der Kaffee"),
            repeat_("la pizza", german: "die Pizza"),
            repeat_("la bici", german: "das Fahrrad"),
        ]
        return Lesson(
            id: "articles-1",
            title: "Il e La",
            subtitle: "Artikel & Genus",
            level: .a0,
            category: .phrases,
            exercises: exercises,
            introText: "Der wichtigste Grammatikunterschied zu Deutsch: Im Italienischen haben Wörter nur zwei Geschlechter — maskulin (il/un) und feminin (la/una). Das Neutrum gibt es nicht. Diese Lektion zeigt dir das System."
        )
    }

    // =========================================================
    // MARK: UNIT 2 — Ich und du
    // =========================================================

    private static func lessonEssereHavere() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly,
               "Die zwei wichtigsten Verben: essere (sein) & avere (haben)\n\nessere: sono / sei / è / siamo / siete / sono\navere: ho / hai / ha / abbiamo / avete / hanno",
               italian: "Essere e avere — i verbi fondamentali.",
               answer: "ok"),
            mc("„Ich bin" auf Italienisch?", answer: "Sono", wrong: ["Ho", "Sei", "È"]),
            mc("„Du bist" auf Italienisch?", answer: "Sei", wrong: ["Sono", "È", "Siamo"]),
            mc("„Er/Sie ist" auf Italienisch?", answer: "È", wrong: ["Sei", "Sono", "Siete"]),
            mc("„Ich habe" auf Italienisch?", answer: "Ho", wrong: ["Hai", "Ha", "Abbiamo"]),
            mc("„Du hast" auf Italienisch?", answer: "Hai", wrong: ["Ho", "Ha", "Avete"]),
            mc("„Er/Sie hat" auf Italienisch?", answer: "Ha", wrong: ["Ho", "Hai", "Hanno"]),
            repeat_("Sono italiano.", german: "Ich bin Italiener."),
            repeat_("Sono tedesco.", german: "Ich bin Deutscher."),
            repeat_("Ho una bici.", german: "Ich habe ein Fahrrad."),
            repeat_("Ha una camera?", german: "Haben Sie ein Zimmer?"),
            mc("„Wir sind" auf Italienisch?", answer: "Siamo", wrong: ["Sono", "Siete", "Sei"]),
            mc("„Sie haben" (Plural) auf Italienisch?", answer: "Hanno", wrong: ["Ho", "Ha", "Avete"]),
            mc("Welcher Satz bedeutet „Ich bin müde"?", answer: "Sono stanco.",
               wrong: ["Ho fame.", "Sei stanco.", "È stanco."]),
            mc("Welcher Satz bedeutet „Ich habe Hunger"?", answer: "Ho fame.",
               wrong: ["Sono stanco.", "Hai fame.", "Ha sete."]),
        ]
        return Lesson(
            id: "essere-avere",
            title: "Essere & Avere",
            subtitle: "Sein und Haben — die Grundverben",
            level: .a0,
            category: .phrases,
            exercises: exercises,
            introText: "„essere" (sein) und „avere" (haben) sind die zwei wichtigsten Verben im Italienischen — sie kommen in fast jedem Satz vor. Ohne diese geht nichts."
        )
    }

    private static func lessonFamily() -> Lesson {
        let pairs: [(String, String)] = [
            ("la madre / la mamma", "die Mutter"),
            ("il padre / il papà", "der Vater"),
            ("il fratello", "der Bruder"),
            ("la sorella", "die Schwester"),
            ("il figlio", "der Sohn"),
            ("la figlia", "die Tochter"),
            ("il nonno", "der Großvater"),
            ("la nonna", "die Großmutter"),
            ("il marito", "der Ehemann"),
            ("la moglie", "die Ehefrau"),
        ]
        var exercises: [Exercise] = [
            ex(.listenOnly, "Familie auf Italienisch.", italian: "La famiglia.", answer: "ok")
        ]
        let allDE = pairs.map { $0.1 }
        for (it, de) in pairs {
            exercises.append(mc("Was bedeutet „\(it)"?", answer: de,
                                wrong: allDE.filter { $0 != de }.shuffled().prefix(3).map { $0 }))
            exercises.append(repeat_(it, german: de))
        }
        return Lesson(
            id: "family-1",
            title: "La Famiglia",
            subtitle: "Familienmitglieder",
            level: .a1,
            category: .phrases,
            exercises: exercises,
            introText: "Familienvokabular hilft dir, über dich zu erzählen und Gespräche zu führen. In Italien ist die Familie sehr wichtig — man spricht viel darüber."
        )
    }

    private static func lessonNumbers11to100() -> Lesson {
        let pairs: [(String, String)] = [
            ("undici", "11"), ("dodici", "12"), ("tredici", "13"),
            ("quattordici", "14"), ("quindici", "15"), ("sedici", "16"),
            ("diciassette", "17"), ("diciotto", "18"), ("diciannove", "19"),
            ("venti", "20"), ("trenta", "30"), ("quaranta", "40"),
            ("cinquanta", "50"), ("sessanta", "60"), ("settanta", "70"),
            ("ottanta", "80"), ("novanta", "90"), ("cento", "100"),
        ]
        var exercises: [Exercise] = [
            ex(.listenOnly, "Zahlen 11–100.", italian: "I numeri da 11 a 100.", answer: "ok"),
            ex(.listenOnly,
               "Tipp: ventiuno = 21, ventitré = 23, trentadue = 32 (einfach zusammensetzen!)",
               italian: "Composti: ventiuno, trentadue, quarantatré…",
               answer: "ok")
        ]
        let allDE = pairs.map { $0.1 }
        for (it, de) in pairs {
            exercises.append(mc("Was bedeutet „\(it)"?", answer: de,
                                wrong: allDE.filter { $0 != de }.shuffled().prefix(3).map { $0 }))
        }
        exercises.append(repeat_("venti", german: "20"))
        exercises.append(repeat_("cento", german: "100"))
        exercises.append(mc("Wie sagt man „55" auf Italienisch?", answer: "cinquantacinque",
                            wrong: ["sessantacinque", "quarantacinque", "cinquantasei"]))
        exercises.append(mc("Quanti chilometri? — 30 km", answer: "trenta chilometri",
                            wrong: ["venti chilometri", "quaranta chilometri", "tredici chilometri"]))
        return Lesson(
            id: "numbers-11-100",
            title: "Venti, Trenta, Cento…",
            subtitle: "Zahlen 11 bis 100",
            level: .a1,
            category: .numbers,
            exercises: exercises,
            introText: "Mit den Zahlen bis 100 kannst du Preise, Distanzen und Mengen verstehen. Wichtig beim Einkaufen, im Restaurant und wenn jemand fragt: „Quanti chilometri?""
        )
    }

    // =========================================================
    // MARK: UNIT 3 — Fragen stellen
    // =========================================================

    private static func lessonQuestions() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly,
               "Fragewörter auf Italienisch:\n\nChi? = Wer?\nCosa? / Che? = Was?\nDove? = Wo?\nQuando? = Wann?\nCome? = Wie?\nQuanto/a? = Wie viel?\nPerché? = Warum?",
               italian: "Le parole interrogative.", answer: "ok"),
            mc("Was bedeutet „Dove?"", answer: "Wo?", wrong: ["Wer?", "Wann?", "Warum?"]),
            mc("Was bedeutet „Come?"", answer: "Wie?", wrong: ["Wann?", "Wo?", "Was?"]),
            mc("Was bedeutet „Chi?"", answer: "Wer?", wrong: ["Was?", "Wo?", "Wie?"]),
            mc("Was bedeutet „Quando?"", answer: "Wann?", wrong: ["Wo?", "Wie viel?", "Warum?"]),
            mc("Was bedeutet „Quanto?"", answer: "Wie viel?", wrong: ["Wie?", "Wann?", "Wer?"]),
            mc("Was bedeutet „Perché?"", answer: "Warum?", wrong: ["Wo?", "Wann?", "Was?"]),
            repeat_("Dove sei?", german: "Wo bist du?"),
            repeat_("Come stai?", german: "Wie geht es dir?"),
            repeat_("Chi sei?", german: "Wer bist du?"),
            repeat_("Quanto costa?", german: "Wie viel kostet das?"),
            repeat_("Quando apre?", german: "Wann öffnet es?"),
            mc("Wie fragst du nach dem Preis?", answer: "Quanto costa?",
               wrong: ["Dove vai?", "Come stai?", "Chi sei?"]),
            mc("Wie fragst du nach dem Weg?", answer: "Dove si trova...?",
               wrong: ["Quanto costa?", "Come ti chiami?", "Quando apre?"]),
            mc("„Warum?" auf Italienisch?", answer: "Perché?",
               wrong: ["Come mai?", "Cosa?", "Quando?"]),
            ex(.listenOnly,
               "Satzstruktur von Fragen:\n\nIm Italienischen kannst du Fragen oft durch Tonfall bilden — wie im Deutschen:\n„Vai a Roma?" = „Du fährst nach Rom?"\nOder umstellen: „Quando vai a Roma?"",
               italian: "La struttura della domanda.",
               answer: "ok"),
        ]
        return Lesson(
            id: "questions-1",
            title: "Chi? Cosa? Dove?",
            subtitle: "Fragewörter & Satzstruktur",
            level: .a1,
            category: .phrases,
            exercises: exercises,
            introText: "Mit den Fragewörtern kannst du jede Information erfragen. „Dove?" ist vielleicht das nützlichste Wort auf Reisen — du wirst es ständig brauchen."
        )
    }

    private static func lessonDaysMonths() -> Lesson {
        let days: [(String, String)] = [
            ("lunedì", "Montag"), ("martedì", "Dienstag"), ("mercoledì", "Mittwoch"),
            ("giovedì", "Donnerstag"), ("venerdì", "Freitag"),
            ("sabato", "Samstag"), ("domenica", "Sonntag"),
        ]
        let months: [(String, String)] = [
            ("gennaio", "Januar"), ("febbraio", "Februar"), ("marzo", "März"),
            ("aprile", "April"), ("maggio", "Mai"), ("giugno", "Juni"),
            ("luglio", "Juli"), ("agosto", "August"), ("settembre", "September"),
            ("ottobre", "Oktober"), ("novembre", "November"), ("dicembre", "Dezember"),
        ]
        var exercises: [Exercise] = [
            ex(.listenOnly, "Wochentage und Monate.", italian: "I giorni e i mesi.", answer: "ok")
        ]
        let allDaysDE = days.map { $0.1 }
        for (it, de) in days {
            exercises.append(mc("Was bedeutet „\(it)"?", answer: de,
                                wrong: allDaysDE.filter { $0 != de }.shuffled().prefix(3).map { $0 }))
        }
        let allMonthsDE = months.map { $0.1 }
        for (it, de) in months {
            exercises.append(mc("Was bedeutet „\(it)"?", answer: de,
                                wrong: allMonthsDE.filter { $0 != de }.shuffled().prefix(3).map { $0 }))
        }
        exercises.append(repeat_("Che giorno è oggi?", german: "Welcher Tag ist heute?"))
        exercises.append(repeat_("Oggi è lunedì.", german: "Heute ist Montag."))
        return Lesson(
            id: "days-months",
            title: "Giorni e Mesi",
            subtitle: "Wochentage & Monate",
            level: .a1,
            category: .phrases,
            exercises: exercises,
            introText: "Wochentage und Monate brauchst du für Reservierungen, Öffnungszeiten und wenn du planst. Im August — agosto — ist in Italien übrigens fast alles zu!"
        )
    }

    private static func lessonTime() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly,
               "Uhrzeit auf Italienisch:\n\nSono le tre. = Es ist 3 Uhr.\nÈ l'una. = Es ist 1 Uhr.\nSono le dieci e mezza. = Es ist halb elf.\nSono le nove e un quarto. = Es ist Viertel nach neun.\nSono le otto meno un quarto. = Es ist Viertel vor acht.",
               italian: "Che ore sono?",
               answer: "ok"),
            mc("Wie fragst du nach der Uhrzeit?", answer: "Che ore sono?",
               wrong: ["Che giorno è?", "Come stai?", "Dove sei?"]),
            mc("„Es ist 3 Uhr" auf Italienisch?", answer: "Sono le tre.",
               wrong: ["È le tre.", "Sono tre.", "Sono le tré."]),
            mc("„Es ist 1 Uhr" — Sono le uno oder È l'una?", answer: "È l'una.",
               wrong: ["Sono le uno.", "Sono l'uno.", "È le una."]),
            mc("„halb" auf Italienisch?", answer: "mezza",
               wrong: ["mezzo", "metà", "mezzogiorno"]),
            repeat_("Che ore sono?", german: "Wie viel Uhr ist es?"),
            repeat_("Sono le otto e mezza.", german: "Es ist halb neun."),
            repeat_("A che ora parte?", german: "Um wie viel Uhr fährt es ab?"),
            mc("Wie sagt man „Es ist Mittag"?", answer: "È mezzogiorno.",
               wrong: ["È mezzanotte.", "Sono le dodici e mezza.", "È l'una."]),
            mc("„Am Morgen" auf Italienisch?", answer: "di mattina",
               wrong: ["di sera", "di notte", "di pomeriggio"]),
            repeat_("Apre alle nove di mattina.", german: "Es öffnet um 9 Uhr morgens."),
        ]
        return Lesson(
            id: "time-1",
            title: "Che Ore Sono?",
            subtitle: "Uhrzeit & Tageszeiten",
            level: .a1,
            category: .phrases,
            exercises: exercises,
            introText: "Die Uhrzeit ist essenziell für Züge, Restaurants und Öffnungszeiten. In Italien ist Pünktlichkeit bei manchen Dingen wichtig — beim Mittagessen sowieso."
        )
    }

    // =========================================================
    // MARK: UNIT 4 — Unterwegs
    // =========================================================

    private static func lessonDirections() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly, "Wegbeschreibungen auf Italienisch.", italian: "Le direzioni.", answer: "ok"),
            mc("„Wo ist…?" auf Italienisch?", answer: "Dov'è…?",
               wrong: ["Cos'è…?", "Chi è…?", "Com'è…?"]),
            mc("„nach rechts" auf Italienisch?", answer: "a destra",
               wrong: ["a sinistra", "dritto", "indietro"]),
            mc("„nach links" auf Italienisch?", answer: "a sinistra",
               wrong: ["a destra", "dritto", "in fondo"]),
            mc("„geradeaus" auf Italienisch?", answer: "sempre dritto",
               wrong: ["a sinistra", "a destra", "indietro"]),
            repeat_("Dov'è la stazione?", german: "Wo ist der Bahnhof?"),
            repeat_("Giri a destra.", german: "Biegen Sie rechts ab."),
            repeat_("Vada sempre dritto.", german: "Fahren Sie immer geradeaus."),
            mc("Was bedeutet „al semaforo"?", answer: "an der Ampel",
               wrong: ["am Bahnhof", "an der Kreuzung", "am Ende"]),
            mc("Was bedeutet „all'incrocio"?", answer: "an der Kreuzung",
               wrong: ["an der Ampel", "am Bahnhof", "in der Mitte"]),
            repeat_("Al semaforo, giri a sinistra.", german: "An der Ampel links abbiegen."),
            mc("„in der Nähe" auf Italienisch?", answer: "vicino",
               wrong: ["lontano", "in fondo", "accanto"]),
            mc("„weit weg" auf Italienisch?", answer: "lontano",
               wrong: ["vicino", "accanto", "dietro"]),
            repeat_("È vicino?", german: "Ist es in der Nähe?"),
            repeat_("Quanti chilometri mancano?", german: "Wie viele Kilometer fehlen noch?"),
        ]
        return Lesson(
            id: "directions-1",
            title: "Dove Vado?",
            subtitle: "Nach dem Weg fragen",
            level: .a1,
            category: .directions,
            exercises: exercises,
            introText: "„Dov'è…?" ist einer der nützlichsten Sätze auf Reisen. Mit dieser Lektion findest du immer deinen Weg — auch ohne GPS."
        )
    }

    private static func lessonPrepositions() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly,
               "Präpositionen — kleine Wörter, große Wirkung:\n\ndi = von / aus\na = nach / zu / an\nda = von (Herkunft) / seit\nin = in / nach\ncon = mit\nsu = auf\nper = für / durch\ntra/fra = zwischen / in (Zeit)",
               italian: "Le preposizioni italiane.",
               answer: "ok"),
            mc("„mit" auf Italienisch?", answer: "con",
               wrong: ["di", "per", "su"]),
            mc("„für" auf Italienisch?", answer: "per",
               wrong: ["con", "di", "da"]),
            mc("„auf" auf Italienisch?", answer: "su",
               wrong: ["in", "a", "per"]),
            mc("„von / aus" auf Italienisch?", answer: "di",
               wrong: ["da", "a", "con"]),
            mc("„nach / zu" auf Italienisch?", answer: "a",
               wrong: ["in", "da", "per"]),
            repeat_("Vengo da Monaco.", german: "Ich komme aus München."),
            repeat_("Vado a Roma.", german: "Ich fahre nach Rom."),
            repeat_("La bici è su per la salita.", german: "Das Fahrrad ist den Berg hoch."),
            mc("„in 10 Minuten" auf Italienisch?", answer: "tra dieci minuti",
               wrong: ["per dieci minuti", "di dieci minuti", "con dieci minuti"]),
            mc("„auf dem Tisch" auf Italienisch?", answer: "sul tavolo",
               wrong: ["nel tavolo", "al tavolo", "del tavolo"]),
            repeat_("Ho bisogno di aiuto.", german: "Ich brauche Hilfe."),
            repeat_("Sono qui per due giorni.", german: "Ich bin für zwei Tage hier."),
            ex(.listenOnly,
               "Kombinierte Präpositionen:\ndel = di + il\nal = a + il\ndal = da + il\nnel = in + il\nSul = su + il",
               italian: "Preposizioni articolate.",
               answer: "ok"),
        ]
        return Lesson(
            id: "prepositions-1",
            title: "Con, Per, Su…",
            subtitle: "Präpositionen & ihre Verwendung",
            level: .a1,
            category: .phrases,
            exercises: exercises,
            introText: "Präpositionen verbinden Satzteile. Ohne „con", „per", „di" und „a" klingt kein Satz richtig. Diese Lektion erklärt die wichtigsten — mit praktischen Beispielen."
        )
    }

    private static func lessonTransport() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly, "Transportmittel und Reisen.", italian: "I mezzi di trasporto.", answer: "ok"),
            mc("„der Zug" auf Italienisch?", answer: "il treno",
               wrong: ["il bus", "la macchina", "l'aereo"]),
            mc("„das Flugzeug" auf Italienisch?", answer: "l'aereo",
               wrong: ["il treno", "il bus", "la nave"]),
            mc("„der Bus" auf Italienisch?", answer: "il bus / l'autobus",
               wrong: ["il treno", "la metro", "il tram"]),
            mc("„das Auto" auf Italienisch?", answer: "la macchina / l'auto",
               wrong: ["il treno", "il bus", "la moto"]),
            repeat_("Un biglietto per Roma, per favore.", german: "Eine Fahrkarte nach Rom, bitte."),
            repeat_("A che ora parte il treno?", german: "Um wie viel Uhr fährt der Zug ab?"),
            repeat_("Dov'è la stazione dei treni?", german: "Wo ist der Bahnhof?"),
            mc("„der Bahnsteig" auf Italienisch?", answer: "il binario",
               wrong: ["la fermata", "il treno", "il biglietto"]),
            mc("„die Fahrkarte" auf Italienisch?", answer: "il biglietto",
               wrong: ["il binario", "la stazione", "l'orario"]),
            repeat_("È in ritardo?", german: "Hat es Verspätung?"),
            repeat_("Dov'è la fermata dell'autobus?", german: "Wo ist die Bushaltestelle?"),
        ]
        return Lesson(
            id: "transport-1",
            title: "In Treno!",
            subtitle: "Transport & Reisen",
            level: .a1,
            category: .directions,
            exercises: exercises,
            introText: "Züge, Busse, Tickets — damit kommst du in Italien überall hin. „Un biglietto, per favore" ist einer der wichtigsten Sätze für Reisende."
        )
    }

    // =========================================================
    // MARK: UNIT 5 — Essen & Reisen
    // =========================================================

    private static func lessonCafe() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly, "Im Café bestellen.", italian: "Al bar.", answer: "ok"),
            mc("„einen Kaffee, bitte" auf Italienisch?", answer: "Un caffè, per favore.",
               wrong: ["Un tè, per favore.", "Un succo, per favore.", "Una birra, per favore."]),
            repeat_("Un caffè, per favore.", german: "Einen Kaffee, bitte."),
            mc("Was ist ein „cappuccino"?", answer: "Kaffee mit aufgeschäumter Milch",
               wrong: ["Starker Espresso", "Kaffee mit Eis", "Kaffee mit Sahne"]),
            repeat_("Un cappuccino e un cornetto.", german: "Einen Cappuccino und ein Croissant."),
            mc("„Wasser" auf Italienisch?", answer: "l'acqua",
               wrong: ["il vino", "il succo", "il latte"]),
            mc("„Sprudelwasser" auf Italienisch?", answer: "acqua frizzante",
               wrong: ["acqua naturale", "acqua calda", "acqua fredda"]),
            repeat_("Un litro d'acqua frizzante.", german: "Ein Liter Sprudelwasser."),
            mc("„die Rechnung" auf Italienisch?", answer: "il conto",
               wrong: ["il menù", "il piatto", "il prezzo"]),
            repeat_("Il conto, per favore.", german: "Die Rechnung, bitte."),
            mc("Wie rufst du den Kellner?", answer: "Scusi!",
               wrong: ["Prego!", "Grazie!", "Aiuto!"]),
            repeat_("Scusi, posso avere il menù?", german: "Entschuldigung, kann ich die Speisekarte haben?"),
            mc("„Ich nehme…" auf Italienisch?", answer: "Prendo…",
               wrong: ["Voglio…", "Ho…", "Sono…"]),
            repeat_("Prendo la pizza margherita.", german: "Ich nehme die Margherita-Pizza."),
        ]
        return Lesson(
            id: "cafe-1",
            title: "Al Bar",
            subtitle: "Im Café & bestellen",
            level: .a1,
            category: .food,
            exercises: exercises,
            introText: "Der Bar ist das Herzstück des italienischen Alltags. Morgens einen Espresso stehend an der Theke — das ist Pflicht! Mit dieser Lektion bestellst du wie ein Einheimischer."
        )
    }

    private static func lessonRestaurant() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly, "Im Restaurant.", italian: "Al ristorante.", answer: "ok"),
            repeat_("Buonasera, ho una prenotazione.", german: "Guten Abend, ich habe eine Reservierung."),
            mc("„einen Tisch für zwei" auf Italienisch?", answer: "un tavolo per due",
               wrong: ["un tavolo per uno", "due tavoli", "un posto"]),
            repeat_("Un tavolo per due, per favore.", german: "Einen Tisch für zwei, bitte."),
            mc("„der Vorspeise" auf Italienisch?", answer: "l'antipasto",
               wrong: ["il primo", "il secondo", "il dolce"]),
            mc("„das Hauptgericht" (Pasta/Suppe) auf Italienisch?", answer: "il primo",
               wrong: ["il secondo", "l'antipasto", "il contorno"]),
            mc("„das Hauptgericht" (Fleisch/Fisch) auf Italienisch?", answer: "il secondo",
               wrong: ["il primo", "l'antipasto", "il dolce"]),
            mc("„die Nachspeise" auf Italienisch?", answer: "il dolce / il dessert",
               wrong: ["il secondo", "il contorno", "l'antipasto"]),
            repeat_("Cosa mi consiglia?", german: "Was empfehlen Sie mir?"),
            mc("Wie sagst du „Ich bin Vegetarier"?", answer: "Sono vegetariano/a.",
               wrong: ["Non mangio carne.", "Ho fame.", "Sono stanco."]),
            repeat_("Sono allergico alle noci.", german: "Ich bin allergisch gegen Nüsse."),
            repeat_("Era ottimo, grazie!", german: "Es war ausgezeichnet, danke!"),
            mc("Was bedeutet „senza glutine"?", answer: "glutenfrei",
               wrong: ["laktosefrei", "vegan", "scharf"]),
        ]
        return Lesson(
            id: "restaurant-1",
            title: "Al Ristorante",
            subtitle: "Im Restaurant",
            level: .a2,
            category: .food,
            exercises: exercises,
            introText: "Ein italienisches Restaurant hat mehrere Gänge: Antipasto, Primo, Secondo, Dolce. Mit dieser Lektion bestellst du selbstsicher — und kannst auch Empfehlungen erfragen."
        )
    }

    private static func lessonAccommodation() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly, "Im Hotel.", italian: "All'albergo.", answer: "ok"),
            mc("„ein Zimmer" auf Italienisch?", answer: "una camera",
               wrong: ["una stanza", "un posto", "un appartamento"]),
            mc("„Einzelzimmer" auf Italienisch?", answer: "camera singola",
               wrong: ["camera doppia", "camera matrimoniale", "camera tripla"]),
            mc("„Doppelzimmer" auf Italienisch?", answer: "camera doppia / matrimoniale",
               wrong: ["camera singola", "camera tripla", "camera con vista"]),
            repeat_("Vorrei una camera singola per due notti.", german: "Ich hätte gerne ein Einzelzimmer für zwei Nächte."),
            mc("„Frühstück" auf Italienisch?", answer: "la colazione",
               wrong: ["il pranzo", "la cena", "lo spuntino"]),
            repeat_("La colazione è inclusa?", german: "Ist das Frühstück inbegriffen?"),
            mc("„Schlüssel" auf Italienisch?", answer: "la chiave",
               wrong: ["il conto", "la camera", "il documento"]),
            repeat_("A che ora è il check-out?", german: "Um wie viel Uhr ist der Check-out?"),
            mc("Wie fragst du nach WLAN?", answer: "C'è il Wi-Fi?",
               wrong: ["C'è la TV?", "C'è il minibar?", "C'è il parking?"]),
            repeat_("C'è un posto sicuro per la bici?", german: "Gibt es einen sicheren Platz für das Fahrrad?"),
            repeat_("Posso avere un'altra coperta?", german: "Kann ich eine weitere Decke haben?"),
        ]
        return Lesson(
            id: "accommodation-1",
            title: "All'Albergo",
            subtitle: "Im Hotel einchecken",
            level: .a1,
            category: .accommodation,
            exercises: exercises,
            introText: "Ein Hotelzimmer buchen, Fragen stellen, den Check-out erkundigen — diese Lektion gibt dir alles, was du für eine Übernachtung in Italien brauchst."
        )
    }

    // =========================================================
    // MARK: UNIT 6 — Radreise
    // =========================================================

    private static func lessonCycling() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly, "Alles rund ums Radfahren.", italian: "In bici!", answer: "ok"),
            mc("„Fahrrad" auf Italienisch?", answer: "la bicicletta / la bici",
               wrong: ["la moto", "la macchina", "lo scooter"]),
            mc("„Reifenpanne" auf Italienisch?", answer: "una foratura",
               wrong: ["una caduta", "un guasto", "una perdita"]),
            repeat_("Ho una foratura!", german: "Ich habe eine Reifenpanne!"),
            mc("„Fahrradpumpe" auf Italienisch?", answer: "la pompa",
               wrong: ["il gonfiatore", "il casco", "il cambio"]),
            repeat_("Ha una pompa per le bici?", german: "Haben Sie eine Fahrradpumpe?"),
            mc("„Fahrradladen" auf Italienisch?", answer: "il negozio di biciclette",
               wrong: ["la farmacia", "il meccanico", "la stazione"]),
            repeat_("C'è un negozio di biciclette vicino?", german: "Gibt es einen Fahrradladen in der Nähe?"),
            mc("„die Steigung / der Pass" auf Italienisch?", answer: "la salita / il passo",
               wrong: ["la discesa", "il pianoro", "la valle"]),
            mc("„die Abfahrt" auf Italienisch?", answer: "la discesa",
               wrong: ["la salita", "il passo", "la curva"]),
            repeat_("Quanti chilometri mancano al paese?", german: "Wie viele Kilometer bis zum Ort?"),
            mc("„der Radweg" auf Italienisch?", answer: "la pista ciclabile",
               wrong: ["la strada", "il sentiero", "il vialetto"]),
            repeat_("C'è una pista ciclabile?", german: "Gibt es einen Radweg?"),
            mc("„Helm" auf Italienisch?", answer: "il casco",
               wrong: ["la pompa", "i guanti", "gli occhiali"]),
            repeat_("Attenzione in discesa!", german: "Vorsicht bei der Abfahrt!"),
            repeat_("Sto cercando un'officina.", german: "Ich suche eine Werkstatt."),
        ]
        return Lesson(
            id: "cycling-1",
            title: "In Bici!",
            subtitle: "Fahrrad-Vokabular für Radreisen",
            level: .a1,
            category: .cycling,
            exercises: exercises,
            introText: "Die Speziallektion für Radreisende: Reifenpanne, Werkstatt, Steigungen, Radwege. Mit diesem Vokabular bist du vorbereitet — egal was auf der Strecke passiert."
        )
    }

    private static func lessonWeather() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly, "Das Wetter auf Italienisch.", italian: "Il tempo.", answer: "ok"),
            mc("„Wie ist das Wetter?" auf Italienisch?", answer: "Che tempo fa?",
               wrong: ["Che ore sono?", "Come stai?", "Dove sei?"]),
            repeat_("Che tempo fa oggi?", german: "Wie ist das Wetter heute?"),
            mc("„Es regnet" auf Italienisch?", answer: "Piove.",
               wrong: ["Nevica.", "C'è vento.", "Fa caldo."]),
            mc("„Es schneit" auf Italienisch?", answer: "Nevica.",
               wrong: ["Piove.", "Fa freddo.", "C'è nebbia."]),
            mc("„Es ist heiß" auf Italienisch?", answer: "Fa caldo.",
               wrong: ["Fa freddo.", "C'è sole.", "È nuvoloso."]),
            mc("„Es ist kalt" auf Italienisch?", answer: "Fa freddo.",
               wrong: ["Fa caldo.", "C'è vento.", "Piove."]),
            repeat_("C'è molto vento oggi.", german: "Heute ist es sehr windig."),
            mc("„die Sonne" auf Italienisch?", answer: "il sole",
               wrong: ["la pioggia", "il vento", "la neve"]),
            mc("„der Regen" auf Italienisch?", answer: "la pioggia",
               wrong: ["il sole", "il vento", "la neve"]),
            repeat_("Domani pioverà?", german: "Wird es morgen regnen?"),
            mc("Was bedeutet „temporale"?", answer: "Gewitter",
               wrong: ["Nebel", "Schnee", "Sturm"]),
        ]
        return Lesson(
            id: "weather-1",
            title: "Che Tempo Fa?",
            subtitle: "Wetter verstehen & beschreiben",
            level: .a1,
            category: .weather,
            exercises: exercises,
            introText: "Das Wetter ist für Radreisende besonders wichtig. „Piove" (Es regnet) kann über eine Etappe entscheiden — und in Italien ändert sich das Wetter schnell."
        )
    }

    private static func lessonEmergency() -> Lesson {
        let exercises: [Exercise] = [
            ex(.listenOnly,
               "Notfall-Sätze — hoffentlich brauchst du sie nie!\n\nNotruf Italien: 112 (allgemein) / 118 (Krankenwagen)",
               italian: "In caso di emergenza.",
               answer: "ok"),
            mc("„Hilfe!" auf Italienisch?", answer: "Aiuto!", wrong: ["Attenzione!", "Scusi!", "Pronto!"]),
            repeat_("Aiuto! Ho bisogno di aiuto!", german: "Hilfe! Ich brauche Hilfe!"),
            mc("„Ich brauche einen Arzt" auf Italienisch?", answer: "Ho bisogno di un medico.",
               wrong: ["Ho bisogno di aiuto.", "Chiami la polizia.", "Ho una foratura."]),
            repeat_("Ho bisogno di un medico, per favore!", german: "Ich brauche bitte einen Arzt!"),
            mc("Die Notrufnummer in Italien ist:", answer: "112",
               wrong: ["110", "113", "999"]),
            mc("„Krankenwagen" auf Italienisch?", answer: "l'ambulanza",
               wrong: ["la polizia", "i pompieri", "il medico"]),
            repeat_("Chiami un'ambulanza!", german: "Rufen Sie einen Krankenwagen!"),
            mc("„Hier tut es weh" auf Italienisch?", answer: "Mi fa male qui.",
               wrong: ["Sono stanco.", "Ho fame.", "Non capisco."]),
            repeat_("Mi fa male il ginocchio.", german: "Mein Knie tut weh."),
            repeat_("Sono caduto/a dalla bici.", german: "Ich bin vom Fahrrad gestürzt."),
            mc("„Polizei" auf Italienisch?", answer: "la polizia",
               wrong: ["i pompieri", "il medico", "l'ambulanza"]),
            repeat_("Dov'è l'ospedale più vicino?", german: "Wo ist das nächste Krankenhaus?"),
        ]
        return Lesson(
            id: "emergency-1",
            title: "Emergenza!",
            subtitle: "Notfall-Sätze — wichtig & lebensrettend",
            level: .a0,
            category: .emergency,
            exercises: exercises,
            introText: "Diese Sätze hoffentlich nie brauchen — aber auswendig kennen! Notruf in Italien: 112. „Aiuto!" und „Ho bisogno di un medico" können Leben retten."
        )
    }

    // =========================================================
    // MARK: Exercise Helpers
    // =========================================================

    private static func mc(_ prompt: String, answer: String, wrong: [String]) -> Exercise {
        Exercise(
            type: .multipleChoice,
            prompt: prompt,
            correctAnswer: answer,
            alternatives: wrong
        )
    }

    private static func repeat_(_ italian: String, german: String) -> Exercise {
        Exercise(
            type: .listenAndRepeat,
            prompt: "Hör zu und wiederhole: \(german)",
            promptItalian: italian,
            correctAnswer: italian
        )
    }

    private static func ex(_ type: ExerciseType, _ prompt: String, italian: String? = nil, answer: String) -> Exercise {
        Exercise(
            type: type,
            prompt: prompt,
            promptItalian: italian,
            correctAnswer: answer
        )
    }

    // MARK: - All Vocabulary (for FSRS)

    private static func allVocab() -> [VocabCard] {
        return [
            VocabCard(italian: "Ciao", german: "Hallo / Tschüss", pronunciation: "tschao",
                      exampleSentence: "Ciao, come stai?", exampleTranslation: "Hallo, wie geht's?", category: .greetings),
            VocabCard(italian: "Buongiorno", german: "Guten Morgen / Guten Tag", pronunciation: "buon-dshor-no",
                      exampleSentence: "Buongiorno, come posso aiutarla?", exampleTranslation: "Guten Tag, wie kann ich Ihnen helfen?", category: .greetings),
            VocabCard(italian: "Grazie", german: "Danke", pronunciation: "graa-tsje",
                      exampleSentence: "Grazie mille!", exampleTranslation: "Vielen Dank!", category: .greetings),
            VocabCard(italian: "Scusi", german: "Entschuldigung", pronunciation: "skuu-si",
                      exampleSentence: "Scusi, dov'è la stazione?", exampleTranslation: "Entschuldigung, wo ist der Bahnhof?", category: .greetings),
            VocabCard(italian: "Un caffè, per favore", german: "Einen Kaffee, bitte", pronunciation: "un kaf-feh",
                      exampleSentence: "Un caffè e un cornetto, per favore.", exampleTranslation: "Einen Kaffee und ein Croissant, bitte.", category: .food),
            VocabCard(italian: "Il conto", german: "Die Rechnung", pronunciation: "il kon-to",
                      exampleSentence: "Il conto, per favore.", exampleTranslation: "Die Rechnung, bitte.", category: .food),
            VocabCard(italian: "Dov'è…?", german: "Wo ist…?", pronunciation: "do-veh",
                      exampleSentence: "Dov'è la stazione?", exampleTranslation: "Wo ist der Bahnhof?", category: .directions),
            VocabCard(italian: "A destra", german: "Nach rechts", pronunciation: "a des-tra",
                      exampleSentence: "Giri a destra.", exampleTranslation: "Biegen Sie rechts ab.", category: .directions),
            VocabCard(italian: "A sinistra", german: "Nach links", pronunciation: "a si-nis-tra",
                      exampleSentence: "Giri a sinistra.", exampleTranslation: "Biegen Sie links ab.", category: .directions),
            VocabCard(italian: "La bici", german: "Das Fahrrad", pronunciation: "la bi-tschi",
                      exampleSentence: "Ho una foratura sulla bici.", exampleTranslation: "Ich habe eine Reifenpanne.", category: .cycling),
            VocabCard(italian: "Aiuto!", german: "Hilfe!", pronunciation: "a-ju-to",
                      exampleSentence: "Aiuto, sono caduto!", exampleTranslation: "Hilfe, ich bin gestürzt!", category: .emergency),
        ]
    }
}
