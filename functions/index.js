const functions = require("firebase-functions");
const cors = require("cors")({ origin: "https://trpgclarendal.web.app" });

exports.getSupabaseConfig = functions.https.onRequest((request, response) => {
  return cors(request, response, () => {
    const supabaseUrl = functions.config().supabase.url;
    const supabaseAnonKey = functions.config().supabase.anon_key;
    response.json({ supabaseUrl, supabaseAnonKey });
  });
});
