const functions = require("firebase-functions");

exports.getSupabaseConfig = functions.https.onRequest((request, response) => {
  const supabaseUrl = functions.config().supabase.url;
  const supabaseAnonKey = functions.config().supabase.anon_key;
  response.json({ supabaseUrl, supabaseAnonKey });
});
