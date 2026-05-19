-- ============================================================
-- Songboard — Supabase Database Schema
-- Run this entire file in your Supabase SQL Editor
-- (Dashboard → SQL Editor → New query → paste → Run)
-- ============================================================

-- ── Safety Reports ──────────────────────────────────────────
-- Stores reports submitted by users about harmful content.
create table if not exists safety_reports (
  id            uuid primary key default gen_random_uuid(),
  created_at    timestamptz not null default now(),
  report_type   text not null check (report_type in (
                  'child_safety', 'harassment', 'hate_speech',
                  'spam', 'illegal_content', 'other'
                )),
  description   text not null check (char_length(description) <= 2000),
  reporter_name text,           -- optional, from profile
  status        text not null default 'open'
                  check (status in ('open', 'reviewed', 'resolved', 'escalated')),
  admin_notes   text            -- for internal use only
);

-- Only allow inserts from the public (anon) role.
-- Nobody can read, update, or delete their own reports via the API.
alter table safety_reports enable row level security;

create policy "Anyone can submit a report"
  on safety_reports for insert
  to anon
  with check (true);

-- Admins read via the Supabase dashboard (service role), not the public API.

-- ── Age Verification Log ────────────────────────────────────
-- Audit trail of age checks — required for COPPA compliance records.
-- We never store the actual birth year, only the outcome.
create table if not exists age_verification_log (
  id            uuid primary key default gen_random_uuid(),
  created_at    timestamptz not null default now(),
  outcome       text not null check (outcome in ('verified', 'blocked')),
  age_bracket   text not null check (age_bracket in ('under_13', '13_to_17', '18_plus')),
  -- No PII stored — we log the age bracket, not the exact year or identity
  session_id    text          -- random ID generated client-side per browser session
);

alter table age_verification_log enable row level security;

create policy "Anyone can log an age check"
  on age_verification_log for insert
  to anon
  with check (true);

-- ── Parental Consent Requests ───────────────────────────────
-- When an under-13 user attempts to sign up, we log the attempt
-- and (optionally) email their parent. The parent email is hashed
-- after the notification is sent so we do not retain PII.
create table if not exists parental_consent_requests (
  id              uuid primary key default gen_random_uuid(),
  created_at      timestamptz not null default now(),
  token           text unique not null,  -- secure random token for the consent link
  status          text not null default 'pending'
                    check (status in ('pending', 'consented', 'denied', 'expired')),
  parent_email    text,   -- set to NULL after notification is sent (privacy)
  notified_at     timestamptz,
  responded_at    timestamptz,
  session_id      text
);

alter table parental_consent_requests enable row level security;

create policy "Anyone can create a consent request"
  on parental_consent_requests for insert
  to anon
  with check (true);

create policy "Token holder can update their own request"
  on parental_consent_requests for update
  to anon
  using (token = current_setting('request.jwt.claims', true)::json->>'token');

-- ── Indexes ──────────────────────────────────────────────────
create index if not exists idx_safety_reports_status     on safety_reports (status, created_at desc);
create index if not exists idx_age_log_created           on age_verification_log (created_at desc);
create index if not exists idx_consent_token             on parental_consent_requests (token);
create index if not exists idx_consent_status            on parental_consent_requests (status, created_at desc);
