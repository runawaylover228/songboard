# Songboard — Supabase Setup Guide

This guide sets up real user accounts and a shared feed. Takes about 20 minutes.

---

## Step 1 — Create a Supabase account

1. Go to **https://supabase.com** and click **Start your project**
2. Sign up with GitHub (easiest) or email
3. Click **New project** and fill in:
   - **Name:** songboard
   - **Database password:** pick a strong one and save it
   - **Region:** pick the one closest to you
4. Click **Create new project** — wait ~2 minutes for setup

---

## Step 2 — Run the database schema

1. In your Supabase dashboard, click **SQL Editor** in the left sidebar
2. Click **New query**
3. Copy the entire contents of `schema.sql` and paste it in
4. Click **Run** (or Ctrl+Enter)
5. You should see "Success. No rows returned"

---

## Step 3 — Disable email confirmation (recommended for launch)

By default Supabase requires users to confirm their email before logging in.
To skip this during early testing:

1. In the dashboard, go to **Authentication → Providers → Email**
2. Turn off **Confirm email**
3. Click **Save**

You can turn this back on later once you have a real email domain.

---

## Step 4 — Get your API keys

1. Go to **Project Settings** (gear icon, bottom left)
2. Click **API**
3. Copy two values:
   - **Project URL** — looks like `https://abcdefgh.supabase.co`
   - **anon public** key — long string starting with `eyJ...`

---

## Step 5 — Add your keys to the app

1. Open `index.html` in your songboard folder
2. Near the top of the `<script>` section, find these two lines:
   ```
   const SUPABASE_URL  = 'YOUR_SUPABASE_URL';
   const SUPABASE_ANON = 'YOUR_SUPABASE_ANON_KEY';
   ```
3. Replace both placeholder values with your real keys
4. Save the file

---

## Step 6 — Push to GitHub

Open PowerShell and run:

```
cd C:\Users\Robyn\Desktop\songboard
git add index.html schema.sql
git commit -m "Connect Supabase — enable real accounts"
git push
```

---

## Step 7 — Verify it's working

1. Open **https://runawaylover228.github.io/songboard**
2. Pass the age gate
3. You should see a **Sign Up / Log In** screen
4. Create an account — you should be taken straight into the app
5. Post a song — it should appear in the feed

To verify data is reaching Supabase:
- Dashboard → **Table Editor** → **profiles** → your profile should be there
- Dashboard → **Table Editor** → **posts** → your post should be there

---

## What each table does

| Table | Purpose |
|---|---|
| `profiles` | User profiles (username, display name, colour) |
| `posts` | All posts, reblogs, and listening rooms |
| `likes` | Which users liked which posts |
| `comments` | Comments on posts |
| `safety_reports` | Reports submitted via the safety modal — review regularly |
| `age_verification_log` | COPPA audit trail |

---

## Viewing safety reports

Whenever you want to check for safety reports:

1. Go to **https://supabase.com** → your project
2. Click **Table Editor** → **safety_reports**
3. For serious reports (especially `child_safety`), escalate immediately:
   - **NCMEC CyberTipline:** https://www.cybertipline.org
   - **FBI Tips:** https://www.fbi.gov/tips

---

## Next steps

- **Email alerts for safety reports:** Supabase → Database → Webhooks → connect to Make.com or Zapier → email yourself
- **Custom domain:** point a domain at GitHub Pages in repo Settings → Pages
- **Production hosting:** migrate to Vercel + Supabase Pro when traffic grows
