import Foundation

// MARK: - Avatar Model

struct Avatar: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let subtitle: String
    let bio: String
    let voiceID: String
    let accent: ItalianAccent
    let personality: Personality
    let wakeWord: String       // "Senti Luigi", "Senti Biciclista", etc.
    let colorHex: String       // avatar accent color

    enum ItalianAccent: String, Codable {
        case northern   = "Norditalienisch"
        case roman      = "Römisch"
        case southern   = "Süditalienisch"
        case neutral    = "Neutral"
    }

    enum Personality: String, Codable {
        case enthusiastic = "Begeistert & motivierend"
        case cool         = "Cool & entspannt"
        case classic      = "Klassisch & geduldig"
        case legendary    = "Legendär & inspirierend"
    }

    var fullWakeWord: String { "Senti \(name)" }
}

// MARK: - Avatar Roster

extension Avatar {
    static let all: [Avatar] = [
        Avatar(
            id: "luigi",
            name: "Luigi",
            subtitle: "Il Professore",
            bio: "Luigi liebt Pasta, Berge und gute Aussprache. Er erklärt alles mit Geduld und einem Lächeln.",
            voiceID: Config.VoiceIDs.luigi,
            accent: .northern,
            personality: .classic,
            wakeWord: "Senti Luigi",
            colorHex: "#9FB89A"
        ),
        Avatar(
            id: "biciclista",
            name: "Biciclista",
            subtitle: "La Velocità",
            bio: "Biciclista kennt jeden Pass der Alpen. Ihre Lernmethode ist schnell, direkt und macht Spaß.",
            voiceID: Config.VoiceIDs.biciclista,
            accent: .neutral,
            personality: .enthusiastic,
            wakeWord: "Senti Biciclista",
            colorHex: "#E8847A"
        ),
        Avatar(
            id: "supermario",
            name: "SuperMario",
            subtitle: "Il Campione",
            bio: "SuperMario bringt Energie und Humor. Mit ihm macht Sprache lernen doppelt so viel Spaß.",
            voiceID: Config.VoiceIDs.superMario,
            accent: .roman,
            personality: .enthusiastic,
            wakeWord: "Senti SuperMario",
            colorHex: "#F2B0A8"
        ),
        Avatar(
            id: "coppi",
            name: "Coppi",
            subtitle: "Il Campionissimo",
            bio: "Fausto Coppi — Der Campionissimo. Zweifacher Tour-de-France-Sieger. Coppi lehrt dich Eleganz in Sprache und Pedalschlag.",
            voiceID: Config.VoiceIDs.coppi,
            accent: .northern,
            personality: .legendary,
            wakeWord: "Senti Coppi",
            colorHex: "#5F7861"
        ),
        Avatar(
            id: "bartali",
            name: "Bartali",
            subtitle: "L'Uomo di Ferro",
            bio: "Gino Bartali — Il Vecchio. Dreifacher Giro-d'Italia-Sieger. Geduldig, stark, beharrlich. Wie gutes Sprachenlernen.",
            voiceID: Config.VoiceIDs.bartali,
            accent: .neutral,
            personality: .classic,
            wakeWord: "Senti Bartali",
            colorHex: "#9FB89A"
        ),
        Avatar(
            id: "pantani",
            name: "Pantani",
            subtitle: "Il Pirata",
            bio: "Marco Pantani — Il Pirata. Der schnellste Bergfahrer aller Zeiten. Mit Pantani fliegst du den Vokabeln entgegen.",
            voiceID: Config.VoiceIDs.pantani,
            accent: .roman,
            personality: .cool,
            wakeWord: "Senti Pantani",
            colorHex: "#E8847A"
        ),
    ]

    static let `default` = all[0]
}
