-- PreSave.in Database Schema
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS & AUTHENTICATION
-- ============================================

-- User profiles (extends Supabase auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  phone TEXT,
  
  -- Account type
  account_type TEXT NOT NULL DEFAULT 'artist' CHECK (account_type IN ('artist', 'label', 'curator')),
  
  -- Subscription
  plan TEXT NOT NULL DEFAULT 'free' CHECK (plan IN ('free', 'artist', 'pro', 'label')),
  plan_expires_at TIMESTAMP,
  stripe_customer_id TEXT,
  
  -- For labels
  label_name TEXT,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- CURATOR SYSTEM
-- ============================================

-- Curator profiles (for users who are also curators)
CREATE TABLE curators (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  -- Profile
  display_name TEXT NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  
  -- Verification
  verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMP,
  
  -- Stats
  rating DECIMAL(2,1) DEFAULT 5.0,
  total_reviews INT DEFAULT 0,
  total_pitches_received INT DEFAULT 0,
  total_pitches_accepted INT DEFAULT 0,
  total_earnings DECIMAL(10,2) DEFAULT 0,
  
  -- Tier (based on total followers across playlists)
  tier TEXT DEFAULT 'starter' CHECK (tier IN ('starter', 'pro', 'elite')),
  commission_percent INT DEFAULT 80, -- They keep 80%, we take 20%
  
  -- Settings
  weekly_review_capacity INT DEFAULT 20, -- How many pitches they'll review per week
  weekly_accept_limit INT DEFAULT 5, -- Max songs they'll accept per week
  auto_close_when_full BOOLEAN DEFAULT TRUE,
  
  -- Payout
  payout_upi TEXT,
  payout_bank_account TEXT,
  payout_bank_ifsc TEXT,
  payout_bank_name TEXT,
  min_payout_amount DECIMAL(10,2) DEFAULT 500,
  
  -- Status
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'suspended', 'banned')),
  suspended_until TIMESTAMP,
  suspension_reason TEXT,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(user_id)
);

-- Curator's playlists
CREATE TABLE playlists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  curator_id UUID NOT NULL REFERENCES curators(id) ON DELETE CASCADE,
  
  -- Platform info
  platform TEXT NOT NULL CHECK (platform IN ('spotify', 'youtube')),
  external_id TEXT NOT NULL, -- spotify:playlist:xxx or youtube:playlist:xxx
  external_url TEXT,
  
  -- Details
  name TEXT NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  
  -- Stats (synced from platform)
  followers INT DEFAULT 0,
  track_count INT DEFAULT 0,
  last_synced_at TIMESTAMP,
  
  -- Genres
  genres TEXT[] DEFAULT '{}',
  
  -- 4-Tier Pricing (curator sets these)
  price_top50 DECIMAL(10,2) NOT NULL, -- Anywhere in playlist
  price_top20 DECIMAL(10,2) NOT NULL, -- Guaranteed top 20
  price_top10 DECIMAL(10,2) NOT NULL, -- Guaranteed top 10
  price_top5 DECIMAL(10,2) NOT NULL,  -- Guaranteed top 5
  
  -- Queue info
  current_queue_size INT DEFAULT 0,
  avg_review_days DECIMAL(3,1) DEFAULT 3,
  
  -- This week's stats
  week_start_date DATE,
  pitches_this_week INT DEFAULT 0,
  accepts_this_week INT DEFAULT 0,
  
  -- OAuth for Spotify (to auto-add songs)
  spotify_access_token TEXT, -- Encrypted
  spotify_refresh_token TEXT, -- Encrypted
  spotify_token_expires_at TIMESTAMP,
  
  -- Status
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'closed', 'unverified')),
  verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(platform, external_id)
);

-- ============================================
-- PITCH SYSTEM
-- ============================================

-- Pitches from artists to playlists
CREATE TABLE pitches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Who's pitching
  artist_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  artist_plan TEXT NOT NULL, -- Captured at time of pitch for priority
  
  -- Where they're pitching
  playlist_id UUID NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
  curator_id UUID NOT NULL REFERENCES curators(id) ON DELETE CASCADE,
  
  -- What they're pitching
  track_name TEXT NOT NULL,
  track_artist TEXT NOT NULL,
  track_url TEXT NOT NULL, -- Spotify/Apple Music URL
  track_uri TEXT, -- spotify:track:xxx (extracted)
  track_cover_url TEXT,
  
  -- Pitch details
  tier TEXT NOT NULL CHECK (tier IN ('top50', 'top20', 'top10', 'top5')),
  price DECIMAL(10,2) NOT NULL, -- Price at time of pitch
  message TEXT, -- Optional message from artist
  
  -- Queue position (calculated)
  queue_position INT,
  estimated_review_date DATE,
  priority_score INT DEFAULT 0, -- Higher = reviewed first (Pro users get boost)
  
  -- Status
  status TEXT DEFAULT 'pending' CHECK (status IN (
    'pending',      -- Waiting in queue
    'under_review', -- Curator is reviewing
    'accepted',     -- Accepted, waiting for placement
    'placed',       -- Song added to playlist
    'rejected',     -- Curator rejected
    'refunded',     -- No response in 7 days, refunded
    'expired',      -- Pitch expired
    'cancelled'     -- Artist cancelled
  )),
  
  -- Review
  reviewed_at TIMESTAMP,
  rejection_reason TEXT,
  curator_feedback TEXT, -- Private feedback to artist
  
  -- Payment
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN (
    'pending',    -- Not paid yet
    'paid',       -- Paid, held in escrow
    'released',   -- Released to curator
    'refunded'    -- Refunded to artist
  )),
  payment_id TEXT, -- Razorpay payment ID
  paid_at TIMESTAMP,
  released_at TIMESTAMP,
  refunded_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- PLACEMENT TRACKING (The Core of Option B)
-- ============================================

-- Track where songs are placed and monitor position
CREATE TABLE placements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pitch_id UUID NOT NULL REFERENCES pitches(id) ON DELETE CASCADE,
  playlist_id UUID NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
  curator_id UUID NOT NULL REFERENCES curators(id) ON DELETE CASCADE,
  
  -- Track info
  track_uri TEXT NOT NULL, -- spotify:track:xxx
  track_name TEXT NOT NULL,
  
  -- Tier commitment
  tier TEXT NOT NULL CHECK (tier IN ('top50', 'top20', 'top10', 'top5')),
  max_allowed_position INT NOT NULL, -- 5, 10, 20, or 50
  
  -- Actual placement
  position_when_placed INT NOT NULL,
  placed_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Commitment period
  commitment_days INT DEFAULT 7,
  committed_until TIMESTAMP NOT NULL, -- placed_at + 7 days
  
  -- Current status (updated by monitoring job)
  current_position INT,
  last_checked_at TIMESTAMP,
  is_in_playlist BOOLEAN DEFAULT TRUE,
  is_position_valid BOOLEAN DEFAULT TRUE, -- Is within max_allowed_position?
  
  -- Completion
  status TEXT DEFAULT 'active' CHECK (status IN (
    'active',       -- Currently in playlist, being monitored
    'completed',    -- 7 days passed, commitment fulfilled
    'violated',     -- Removed or moved down before 7 days
    'disputed'      -- Under dispute
  )),
  completed_at TIMESTAMP,
  
  -- If violated
  violation_detected_at TIMESTAMP,
  violation_type TEXT, -- 'removed', 'position_violation'
  violation_notified BOOLEAN DEFAULT FALSE,
  violation_resolved BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(pitch_id)
);

-- Placement check history (every 6 hours)
CREATE TABLE placement_checks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  placement_id UUID NOT NULL REFERENCES placements(id) ON DELETE CASCADE,
  
  checked_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- What we found
  found_in_playlist BOOLEAN NOT NULL,
  position_found INT, -- NULL if not found
  
  -- Was it valid at this check?
  position_valid BOOLEAN, -- Within max_allowed_position?
  
  -- Playlist snapshot
  playlist_track_count INT,
  
  -- Any issues?
  issue_detected BOOLEAN DEFAULT FALSE,
  issue_type TEXT -- 'not_found', 'position_violation'
);

-- Curator violations history
CREATE TABLE curator_violations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  curator_id UUID NOT NULL REFERENCES curators(id) ON DELETE CASCADE,
  placement_id UUID REFERENCES placements(id) ON DELETE SET NULL,
  
  violation_type TEXT NOT NULL CHECK (violation_type IN (
    'early_removal',      -- Removed song before commitment ended
    'position_violation', -- Moved song below committed position
    'no_placement',       -- Accepted but never placed
    'fake_playlist',      -- Playlist has fake followers
    'other'
  )),
  
  -- Details
  description TEXT,
  
  -- Severity
  severity TEXT DEFAULT 'warning' CHECK (severity IN ('warning', 'minor', 'major', 'critical')),
  
  -- Action taken
  action_taken TEXT, -- 'warning_sent', 'rating_penalty', 'suspended', 'banned'
  rating_penalty DECIMAL(2,1) DEFAULT 0, -- How much rating was reduced
  
  -- Resolution
  resolved BOOLEAN DEFAULT FALSE,
  resolved_at TIMESTAMP,
  resolution_notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- NOTIFICATIONS
-- ============================================

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  -- Type
  type TEXT NOT NULL, -- 'pitch_accepted', 'pitch_rejected', 'violation_warning', etc.
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  
  -- Related entities
  related_pitch_id UUID REFERENCES pitches(id) ON DELETE SET NULL,
  related_placement_id UUID REFERENCES placements(id) ON DELETE SET NULL,
  
  -- Delivery
  channels TEXT[] DEFAULT '{in_app}', -- 'in_app', 'email', 'whatsapp'
  email_sent BOOLEAN DEFAULT FALSE,
  email_sent_at TIMESTAMP,
  whatsapp_sent BOOLEAN DEFAULT FALSE,
  whatsapp_sent_at TIMESTAMP,
  
  -- Status
  read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- PAYOUTS
-- ============================================

CREATE TABLE payouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  curator_id UUID NOT NULL REFERENCES curators(id) ON DELETE CASCADE,
  
  -- Amount
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'INR',
  
  -- Payout method
  method TEXT NOT NULL CHECK (method IN ('upi', 'bank_transfer')),
  payout_details JSONB, -- UPI ID or bank details
  
  -- Status
  status TEXT DEFAULT 'pending' CHECK (status IN (
    'pending',    -- Requested
    'processing', -- Being processed
    'completed',  -- Money sent
    'failed'      -- Failed, needs retry
  )),
  
  -- Processing
  processed_at TIMESTAMP,
  transaction_id TEXT, -- Bank/UPI reference
  failure_reason TEXT,
  
  -- Timestamps
  requested_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Pitches
CREATE INDEX idx_pitches_playlist ON pitches(playlist_id);
CREATE INDEX idx_pitches_artist ON pitches(artist_id);
CREATE INDEX idx_pitches_status ON pitches(status);
CREATE INDEX idx_pitches_queue ON pitches(playlist_id, status, priority_score DESC, created_at);

-- Placements
CREATE INDEX idx_placements_playlist ON placements(playlist_id);
CREATE INDEX idx_placements_status ON placements(status);
CREATE INDEX idx_placements_active ON placements(status, committed_until) WHERE status = 'active';

-- Placement checks
CREATE INDEX idx_placement_checks_placement ON placement_checks(placement_id);
CREATE INDEX idx_placement_checks_time ON placement_checks(checked_at DESC);

-- Playlists
CREATE INDEX idx_playlists_curator ON playlists(curator_id);
CREATE INDEX idx_playlists_platform ON playlists(platform);
CREATE INDEX idx_playlists_status ON playlists(status);

-- Curators
CREATE INDEX idx_curators_user ON curators(user_id);
CREATE INDEX idx_curators_status ON curators(status);

-- Notifications
CREATE INDEX idx_notifications_user ON notifications(user_id, read, created_at DESC);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_curators_updated_at BEFORE UPDATE ON curators FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_playlists_updated_at BEFORE UPDATE ON playlists FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_pitches_updated_at BEFORE UPDATE ON pitches FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_placements_updated_at BEFORE UPDATE ON placements FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Calculate priority score for pitches
-- Pro/Label users get higher priority
CREATE OR REPLACE FUNCTION calculate_pitch_priority()
RETURNS TRIGGER AS $$
BEGIN
  NEW.priority_score = CASE NEW.artist_plan
    WHEN 'label' THEN 100
    WHEN 'pro' THEN 80
    WHEN 'artist' THEN 50
    ELSE 0
  END;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_pitch_priority BEFORE INSERT ON pitches FOR EACH ROW EXECUTE FUNCTION calculate_pitch_priority();

-- Update queue positions when a new pitch is added
CREATE OR REPLACE FUNCTION update_queue_positions()
RETURNS TRIGGER AS $$
BEGIN
  -- Recalculate queue positions for all pending pitches in this playlist
  WITH ranked AS (
    SELECT id, ROW_NUMBER() OVER (
      ORDER BY priority_score DESC, created_at ASC
    ) as new_position
    FROM pitches
    WHERE playlist_id = NEW.playlist_id
    AND status = 'pending'
  )
  UPDATE pitches p
  SET queue_position = r.new_position
  FROM ranked r
  WHERE p.id = r.id;
  
  -- Update playlist queue size
  UPDATE playlists
  SET current_queue_size = (
    SELECT COUNT(*) FROM pitches
    WHERE playlist_id = NEW.playlist_id AND status = 'pending'
  )
  WHERE id = NEW.playlist_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER recalculate_queue AFTER INSERT OR UPDATE ON pitches FOR EACH ROW EXECUTE FUNCTION update_queue_positions();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE curators ENABLE ROW LEVEL SECURITY;
ALTER TABLE playlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE pitches ENABLE ROW LEVEL SECURITY;
ALTER TABLE placements ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can read/update their own profile
CREATE POLICY profiles_select ON profiles FOR SELECT USING (true);
CREATE POLICY profiles_update ON profiles FOR UPDATE USING (auth.uid() = id);

-- Curators: Public read, owner update
CREATE POLICY curators_select ON curators FOR SELECT USING (true);
CREATE POLICY curators_update ON curators FOR UPDATE USING (auth.uid() = user_id);

-- Playlists: Public read, curator owner update
CREATE POLICY playlists_select ON playlists FOR SELECT USING (true);
CREATE POLICY playlists_update ON playlists FOR UPDATE USING (
  auth.uid() IN (SELECT user_id FROM curators WHERE id = curator_id)
);

-- Pitches: Artist or curator can see
CREATE POLICY pitches_select ON pitches FOR SELECT USING (
  auth.uid() = artist_id OR
  auth.uid() IN (SELECT user_id FROM curators WHERE id = curator_id)
);
CREATE POLICY pitches_insert ON pitches FOR INSERT WITH CHECK (auth.uid() = artist_id);

-- Placements: Involved parties can see
CREATE POLICY placements_select ON placements FOR SELECT USING (
  auth.uid() IN (SELECT user_id FROM curators WHERE id = curator_id) OR
  auth.uid() IN (SELECT artist_id FROM pitches WHERE id = pitch_id)
);

-- Notifications: Users see their own
CREATE POLICY notifications_select ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY notifications_update ON notifications FOR UPDATE USING (auth.uid() = user_id);
