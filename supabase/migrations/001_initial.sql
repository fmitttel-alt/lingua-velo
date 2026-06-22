-- Lingua Velo — Supabase Initial Schema
-- Run this in your Supabase SQL editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- USERS / PROFILES
-- ============================================================
CREATE TABLE IF NOT EXISTS user_profiles (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id         UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    level           TEXT NOT NULL DEFAULT 'A0' CHECK (level IN ('A0','A1','A2','B1')),
    goals           TEXT[] DEFAULT '{"cycling"}',
    selected_avatar TEXT NOT NULL DEFAULT 'luigi',
    total_sessions  INT NOT NULL DEFAULT 0,
    total_vocab     INT NOT NULL DEFAULT 0,
    current_streak  INT NOT NULL DEFAULT 0,
    last_session_at TIMESTAMPTZ,
    onboarding_done BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own profile"
    ON user_profiles FOR SELECT USING (auth.uid() = auth_id);
CREATE POLICY "Users can update own profile"
    ON user_profiles FOR UPDATE USING (auth.uid() = auth_id);
CREATE POLICY "Users can insert own profile"
    ON user_profiles FOR INSERT WITH CHECK (auth.uid() = auth_id);

-- ============================================================
-- FSRS CARDS
-- ============================================================
CREATE TABLE IF NOT EXISTS fsrs_cards (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    vocabulary_id   UUID NOT NULL,
    state           TEXT NOT NULL DEFAULT 'new' CHECK (state IN ('new','learning','review','relearning')),
    stability       FLOAT NOT NULL DEFAULT 0,
    difficulty      FLOAT NOT NULL DEFAULT 5,
    elapsed_days    INT NOT NULL DEFAULT 0,
    scheduled_days  INT NOT NULL DEFAULT 0,
    reps            INT NOT NULL DEFAULT 0,
    lapses          INT NOT NULL DEFAULT 0,
    last_review_at  TIMESTAMPTZ,
    next_review_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, vocabulary_id)
);

ALTER TABLE fsrs_cards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own cards"
    ON fsrs_cards FOR ALL USING (
        user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid())
    );

-- ============================================================
-- SESSION HISTORY
-- ============================================================
CREATE TABLE IF NOT EXISTS sessions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    lesson_id       TEXT NOT NULL,
    mode            TEXT NOT NULL DEFAULT 'stationary' CHECK (mode IN ('stationary','cycling','review')),
    started_at      TIMESTAMPTZ NOT NULL,
    completed_at    TIMESTAMPTZ NOT NULL,
    exercises_total INT NOT NULL DEFAULT 0,
    exercises_ok    INT NOT NULL DEFAULT 0,
    exercises_skip  INT NOT NULL DEFAULT 0,
    accuracy        FLOAT GENERATED ALWAYS AS (
        CASE WHEN exercises_total > 0
             THEN CAST(exercises_ok AS FLOAT) / exercises_total
             ELSE 0 END
    ) STORED,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own sessions"
    ON sessions FOR ALL USING (
        user_id IN (SELECT id FROM user_profiles WHERE auth_id = auth.uid())
    );

-- ============================================================
-- STREAK TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION update_streak()
RETURNS TRIGGER AS $$
DECLARE
    last_session DATE;
    today DATE := CURRENT_DATE;
    profile_id UUID;
BEGIN
    SELECT id, last_session_at::DATE INTO profile_id, last_session
    FROM user_profiles
    WHERE id = NEW.user_id;

    IF last_session IS NULL OR last_session < today - INTERVAL '1 day' THEN
        -- Broke streak or first session
        UPDATE user_profiles
        SET current_streak = 1,
            last_session_at = NOW(),
            total_sessions = total_sessions + 1,
            updated_at = NOW()
        WHERE id = NEW.user_id;
    ELSIF last_session = today - INTERVAL '1 day' THEN
        -- Continue streak
        UPDATE user_profiles
        SET current_streak = current_streak + 1,
            last_session_at = NOW(),
            total_sessions = total_sessions + 1,
            updated_at = NOW()
        WHERE id = NEW.user_id;
    ELSE
        -- Same day
        UPDATE user_profiles
        SET last_session_at = NOW(),
            total_sessions = total_sessions + 1,
            updated_at = NOW()
        WHERE id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_session_completed
    AFTER INSERT ON sessions
    FOR EACH ROW EXECUTE FUNCTION update_streak();

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_fsrs_user_next ON fsrs_cards(user_id, next_review_at);
CREATE INDEX idx_sessions_user   ON sessions(user_id, created_at DESC);
