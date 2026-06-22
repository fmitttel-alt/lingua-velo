# Lingua Velo 🚴 Italiano per Ciclisti

> Voice-First Italienisch-Lern-App für Radreisende.  
> Hände am Lenker, Augen auf die Straße — Italiano nel vento.

---

## Setup in 5 Schritten

### 1. Voraussetzungen

- Mac mit Xcode 15+ installiert
- Apple Developer Account (kostenlos für Tests auf eigenem iPhone)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — `brew install xcodegen`

### 2. API Keys eintragen

Öffne `LinguaVelo/Config.swift` und trage deine Keys ein:

| Key | Wo bekommen? |
|-----|-------------|
| `ELEVENLABS_API_KEY` | elevenlabs.io → Profile → API Keys |
| `SUPABASE_URL` | supabase.com → Projekt → Settings → API |
| `SUPABASE_ANON_KEY` | supabase.com → Projekt → Settings → API |
| `ANTHROPIC_API_KEY` | console.anthropic.com → API Keys |

Alternativ: als Environment Variables in Xcode Scheme setzen.

### 3. ElevenLabs Stimmen auswählen

1. Gehe zu elevenlabs.io → Voice Library
2. Suche nach **Italian** / **Italian Male** / **Italian Female**
3. Kopiere die Voice ID (unter jedem Voice-Eintrag)
4. Trage sie in `Config.VoiceIDs` ein (Luigi, Biciclista etc.)

**Empfehlung:** Suche nach „Luca" oder „Marco" (native Italian voices) für männliche Tutoren.

### 4. Supabase einrichten

1. Neues Projekt auf [supabase.com](https://supabase.com) anlegen
2. SQL Editor öffnen
3. Inhalt von `supabase/migrations/001_initial.sql` einfügen und ausführen
4. URL + Anon Key aus Settings → API in Config.swift eintragen

### 5. Xcode-Projekt generieren & starten

```bash
cd /pfad/zu/LinguaVelo
xcodegen generate
open LinguaVelo.xcodeproj
```

In Xcode:
- Signing & Capabilities → Team auswählen
- Target: dein iPhone
- ▶ Run

---

## App-Architektur

```
LinguaVelo/
├── LinguaVeloApp.swift        # App-Einstieg, AppState
├── Config.swift               # API Keys, Feature Flags
├── Theme/
│   └── AppTheme.swift         # Farben, Fonts, Design System
├── Models/
│   ├── Avatar.swift           # Luigi, Coppi, Pantani etc.
│   └── LearningModels.swift   # Vokabeln, Lektionen, Übungen
├── Core/
│   ├── FSRS/
│   │   └── FSRSAlgorithm.swift    # Spaced Repetition v5
│   ├── Voice/
│   │   ├── SpeechRecognizer.swift # Apple on-device STT + Wake Word
│   │   └── ElevenLabsTTS.swift    # TTS + Claude Tutor-Dialog
│   ├── Learning/
│   │   └── LearningEngine.swift   # Session-Logik, Speed-Monitor
│   └── Supabase/
│       └── SupabaseManager.swift  # Backend-Sync
├── Content/
│   └── ItalianContent.swift       # 40+ Vokabeln, 6 Lektionen
└── Views/
    ├── Onboarding/                # Willkommen → Level → Ziele → Avatar
    ├── Dashboard/                 # Home, Lektionen-Liste
    ├── Learning/                  # Stationäre Lernsession
    ├── CyclingMode/               # Fahrmodus (Kerndifferenzierung)
    └── Settings/                  # Avatar, Level, Fortschritt
```

---

## Farbpalette

| Farbe | Hex | Verwendung |
|-------|-----|-----------|
| Salbei | `#9FB89A` | Texte, Icons, Erfolg |
| Salbei Tief | `#5F7861` | Hintergründe, Muted |
| Lachs | `#E8847A` | CTA, Akzente, Fehler |
| Rosé | `#F2B0A8` | Soft-Hinweise, Warnungen |

---

## Avatare

| Avatar | Typ | Akzent | Wake Word |
|--------|-----|--------|-----------|
| Luigi | Il Professore | Norditalienisch | „Senti Luigi" |
| Biciclista | La Velocità | Neutral | „Senti Biciclista" |
| SuperMario | Il Campione | Römisch | „Senti SuperMario" |
| Coppi | Il Campionissimo | Norditalienisch | „Senti Coppi" |
| Bartali | L'Uomo di Ferro | Neutral | „Senti Bartali" |
| Pantani | Il Pirata | Römisch | „Senti Pantani" |

---

## Fahrmodus — Was macht ihn besonders

1. **Wake Word on-device** — Apple Speech, kein Cloud-Roundtrip
2. **Live-Transkript** — Alle Äußerungen erscheinen als große Untertitel
3. **Speed-Monitor** — GPS-Geschwindigkeit → automatisch Listen-Only über 35 km/h
4. **Große Touch-Ziele** — Mic-Button 64×64pt, mit Handschuh bedienbar
5. **Screen always-on** — Background Audio Mode + Location aktiv
6. **Sicherheitswarnung** beim ersten Start

---

## Offene Punkte (nächste Phase)

- [ ] Wake-Word-Engine ersetzen: Picovoice Porcupine (robuster als Apple STT für Wake Words)
- [ ] ElevenLabs Voice IDs mit echten italienischen Stimmen befüllen
- [ ] Supabase Auth UI (Email-Login Screen)
- [ ] Fotos aus dem GranSasso-Ordner als Background-Assets einbauen (mit Sage-Overlay)
- [ ] Muttersprachler-Review der Lerninhalte
- [ ] App Store Listing, Screenshots

---

## Nächste Lerninhalte

- Zahlen & Preise
- Wetterbeschreibungen
- Körperteile / beim Arzt
- Öffentliche Verkehrsmittel
- Unterwegs einkaufen
- B1: Meinungen ausdrücken

---

*Lingua Velo — Italiano nel vento. 🚴🇮🇹*
