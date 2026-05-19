// ── Supabase configuration ────────────────────────────────────
// Replace these two values with your own from:
// Supabase Dashboard → Project Settings → API
const SUPABASE_URL  = 'YOUR_SUPABASE_URL';   // e.g. https://xyzxyz.supabase.co
const SUPABASE_ANON = 'YOUR_SUPABASE_ANON_KEY';

// ── Client (loaded via CDN in each HTML file) ─────────────────
// Returns null if credentials haven't been filled in yet — app still works.
const SUPABASE_CONFIGURED = SUPABASE_URL !== 'YOUR_SUPABASE_URL' && SUPABASE_ANON !== 'YOUR_SUPABASE_ANON_KEY';
const sb = SUPABASE_CONFIGURED ? supabase.createClient(SUPABASE_URL, SUPABASE_ANON) : null;

// ── Safety Reports ────────────────────────────────────────────
async function submitSafetyReport({ type, description, reporterName }) {
  if (!sb) throw new Error('Supabase not configured yet — see SETUP.md.');
  if (!type || !description?.trim()) throw new Error('Type and description are required.');
  const { error } = await sb.from('safety_reports').insert({
    report_type:   type,
    description:   description.trim().slice(0, 2000),
    reporter_name: reporterName ? reporterName.slice(0, 50) : null,
  });
  if (error) throw error;
}

// ── Age Verification Logging ──────────────────────────────────
// Logs the OUTCOME only — no birth year, no identity.
async function logAgeVerification({ outcome, ageBracket }) {
  if (!sb) return;
  const sessionId = getSessionId();
  await sb.from('age_verification_log').insert({
    outcome, age_bracket: ageBracket, session_id: sessionId,
  }).then(({ error }) => {
    if (error) console.warn('Age log failed (non-critical):', error.message);
  });
}

// ── Parental Consent ──────────────────────────────────────────
// Creates a consent request and triggers a parent notification email
// via a Supabase Edge Function (see /supabase/functions/notify-parent/).
async function requestParentalConsent({ parentEmail, sessionId }) {
  if (!sb) throw new Error('Supabase not configured yet — see SETUP.md.');
  const token = crypto.randomUUID();
  const { error } = await sb.from('parental_consent_requests').insert({
    token, parent_email: parentEmail, session_id: sessionId || getSessionId(),
  });
  if (error) throw error;

  // Trigger Edge Function to email the parent
  // (Deploy the Edge Function separately — see SETUP.md)
  try {
    await sb.functions.invoke('notify-parent', {
      body: { token, parentEmail },
    });
  } catch(e) {
    console.warn('Parent notification email failed:', e.message);
  }
  return token;
}

// ── Session ID ────────────────────────────────────────────────
// A random ID per browser session — not linked to identity.
function getSessionId() {
  let id = sessionStorage.getItem('sb_session_id');
  if (!id) { id = crypto.randomUUID(); sessionStorage.setItem('sb_session_id', id); }
  return id;
}
