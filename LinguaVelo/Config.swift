import Foundation

// MARK: - App Configuration
// Keys werden lokal eingetragen oder via GitHub Secrets injiziert.

enum Config {

    // MARK: App
    static let appName        = "Lingua Velo"
    static let bundleID       = "com.linguavelo.app"
    static let appVersion     = "1.0.0"

    // MARK: Wake Words (one per avatar)
    static let wakeWordPrefix = "senti"

    // MARK: ElevenLabs
    static let elevenLabsAPIKey = ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"] ?? "YOUR_ELEVENLABS_API_KEY"

    // Voice IDs — Italian voices from ElevenLabs voice library
    enum VoiceIDs {
        static let luigi       = "pNInz6obpgDQGcFmaJgB"
        static let biciclista  = "EXAVITQu4vr4xnSDxMaL"
        static let superMario  = "VR6AewLTigWG4xSOukaG"
        static let coppi       = "yoZ06aMxZJJ28mfd3POQ"
        static let bartali     = "onwK4e9ZLuTAKqWW03F9"
        static let pantani     = "N2lVS1w4EtoT3dr4eOWO"
    }

    // MARK: Supabase
    static let supabaseURL     = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "YOUR_SUPABASE_URL"
    static let supabaseAnonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "YOUR_SUPABASE_ANON_KEY"

    // MARK: Google Gemini API
    static let geminiAPIKey      = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? "YOUR_GEMINI_API_KEY"
    static let enableTutorDialog = true

    // MARK: Feature Flags
    static let enableCyclingMode    = true
    static let enableWakeWord       = true
    static let enableSpacedRep      = true
    static let enableOfflineSTT     = true
    static let maxCyclingSpeed      = 35.0
}
