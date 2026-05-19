-- ============================================================
-- Songboard — Supabase Database Schema
-- Safe to run multiple times (idempotent).
-- (Dashboard → SQL Editor → New query → paste → Run)
-- ============================================================

-- ── Profiles ─────────────────────────────────────────────────
create table if not exists profiles (
  id           uuid references auth.users primary key,
  username     text unique not null check (char_length(username) >= 2),
  display_name text not null,
  bio          text not null default '',
  avatar_color text not null default '#7c3aed',
  created_at   timestamptz not null default now()
);
alter table profiles enable row level security;
drop policy if exists "Anyone can view profiles"     on profiles;
drop policy if exists "Users can insert own profile" on profiles;
drop policy if exists "Users can update own profile" on profiles;
create policy "Anyone can view profiles"     on profiles for select using (true);
create policy "Users can insert own profile" on profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);

-- ── Posts ────────────────────────────────────────────────────
create table if not exists posts (
  id                    uuid primary key default gen_random_uuid(),
  user_id               uuid references auth.users not null,
  post_type             text not null check (post_type in ('post', 'reblog', 'room')),
  song_name             text not null,
  song_artist           text,
  song_album            text,
  song_art              text,
  song_embed_url        text,
  caption               text,
  tags                  text[],
  original_post_id      uuid references posts(id) on delete set null,
  original_author_name  text,
  original_author_color text,
  room_id               text,
  room_name             text,
  created_at            timestamptz not null default now()
);
alter table posts enable row level security;
drop policy if exists "Anyone can view posts"       on posts;
drop policy if exists "Auth users can insert posts" on posts;
drop policy if exists "Users can delete own posts"  on posts;
create policy "Anyone can view posts"       on posts for select using (true);
create policy "Auth users can insert posts" on posts for insert with check (auth.uid() = user_id);
create policy "Users can delete own posts"  on posts for delete using (auth.uid() = user_id);

-- ── Likes ────────────────────────────────────────────────────
create table if not exists likes (
  user_id uuid references auth.users,
  post_id uuid references posts(id) on delete cascade,
  primary key (user_id, post_id)
);
alter table likes enable row level security;
drop policy if exists "Anyone can view likes" on likes;
drop policy if exists "Auth users can like"   on likes;
drop policy if exists "Users can unlike"      on likes;
create policy "Anyone can view likes" on likes for select using (true);
create policy "Auth users can like"   on likes for insert with check (auth.uid() = user_id);
create policy "Users can unlike"      on likes for delete using (auth.uid() = user_id);

-- ── Comments ─────────────────────────────────────────────────
create table if not exists comments (
  id           uuid primary key default gen_random_uuid(),
  post_id      uuid references posts(id) on delete cascade,
  user_id      uuid references auth.users,
  author_name  text,
  author_color text,
  body         text not null check (char_length(body) > 0 and char_length(body) <= 300),
  created_at   timestamptz not null default now()
);
alter table comments enable row level security;
drop policy if exists "Anyone can view comments"      on comments;
drop policy if exists "Auth users can comment"        on comments;
drop policy if exists "Users can delete own comments" on comments;
create policy "Anyone can view comments"      on comments for select using (true);
create policy "Auth users can comment"        on comments for insert with check (auth.uid() = user_id);
create policy "Users can delete own comments" on comments for delete using (auth.uid() = user_id);

-- ── Safety Reports ───────────────────────────────────────────
create table if not exists safety_reports (
  id            uuid primary key default gen_random_uuid(),
  created_at    timestamptz not null default now(),
  report_type   text not null check (report_type in (
                  'child_safety', 'harassment', 'hate_speech',
                  'spam', 'illegal_content', 'other'
                )),
  description   text not null check (char_length(description) <= 2000),
  reporter_name text,
  status        text not null default 'open'
                  check (status in ('open', 'reviewed', 'resolved', 'escalated')),
  admin_notes   text
);
alter table safety_reports enable row level security;
drop policy if exists "Anyone can submit a report" on safety_reports;
create policy "Anyone can submit a report" on safety_reports for insert to anon with check (true);

-- ── Age Verification Log ─────────────────────────────────────
create table if not exists age_verification_log (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  outcome     text not null check (outcome in ('verified', 'blocked')),
  age_bracket text not null check (age_bracket in ('under_13', '13_to_17', '18_plus')),
  session_id  text
);
alter table age_verification_log enable row level security;
drop policy if exists "Anyone can log an age check" on age_verification_log;
create policy "Anyone can log an age check" on age_verification_log for insert to anon with check (true);

-- ── Indexes ──────────────────────────────────────────────────
create index if not exists idx_posts_user    on posts (user_id, created_at desc);
create index if not exists idx_posts_created on posts (created_at desc);
create index if not exists idx_likes_post    on likes (post_id);
create index if not exists idx_comments_post on comments (post_id, created_at asc);
create index if not exists idx_safety_status on safety_reports (status, created_at desc);
