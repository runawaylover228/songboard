# Supabase Backend Setup Guide

Follow these steps exactly. It takes about 15 minutes.

---

## Step 1 — Create a Supabase account

1. Go to **https://supabase.com** and click **Start your project**
2. Sign up with GitHub (easiest) or email
3. Click **New project**
4. Fill in:
   - **Name:** songboard
   - **Database password:** pick a strong password and save it somewhere safe
   - **Region:** pick the one closest to you
5. Click **Create new project** and wait ~2 minutes for it to set up

---

## Step 2 — Run the database schema

1. In your Supabase dashboard, click **SQL Editor** in the left sidebar
2. Click **New query**
3. Open the file `schema.sql` from your songboard folder
4. Copy the entire contents and paste it into the SQL editor
5. Click **Run** (or press Ctrl+Enter)
6. You should see "Success. No rows returned" — that means it worked

---

## Step 3 — Get your API keys

1. In the Supabase dashboard, click **Project Settings** (gear icon, bottom left)
2. Click **API**
3. Copy two values:
   - **Project URL** (looks like `https://abcdefgh.supabase.co`)
   - **anon public** key (long string starting with `eyJ...`)

---

## Step 4 — Add your keys to the app

1. Open `supabase.js` in your songboard folder
2. Replace the placeholders:
   ```
   const SUPABASE_URL  = 'YOUR_SUPABASE_URL';   ← paste Project URL here
   const SUPABASE_ANON = 'YOUR_SUPABASE_ANON_KEY';  ← paste anon key here
   ```
3. Save the file

---

## Step 5 — Push to GitHub

Open PowerShell, navigate to your songboard folder, and run:

```
cd C:\Users\Robyn\Desktop\songboard
git add .
git commit -m "Connect Supabase backend"
git push
```

---

## Step 6 — Verify it's working

1. Open your live site at **https://runawaylover228.github.io/songboard**
2. Click **Report a Safety Issue** in the footer
3. Submit a test report
4. Go to your Supabase dashboard → **Table Editor** → **safety_reports**
5. You should see your test report appear there

---

## Step 7 — View safety reports (ongoing)

Whenever you want to check for safety reports:

1. Go to **https://supabase.com** → your project
2. Click **Table Editor** → **safety_reports**
3. Reports are shown newest first
4. You can change the `status` column from `open` → `reviewed` → `resolved` or `escalated`

For serious reports (especially `child_safety` type), escalate immediately to:
- **NCMEC CyberTipline:** https://www.cybertipline.org
- **FBI Tips:** https://www.fbi.gov/tips

---

## What each table does

| Table | Purpose |
|---|---|
| `safety_reports` | Safety issues reported by users — review these regularly |
| `age_verification_log` | COPPA audit trail — proves you are checking ages |
| `parental_consent_requests` | Under-13 parent notification records (future use) |

---

## Next steps (future)

- **Set up email alerts** when a new safety report comes in (Supabase → Database → Webhooks → point to a free service like Make.com or Zapier → send yourself an email)
- **Deploy parental consent emails** using Supabase Edge Functions + Resend.com (free tier)
- **Add real user accounts** — replace localStorage profiles with Supabase Auth
