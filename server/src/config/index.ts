import { config } from "dotenv";
config();

export const env = {
  firebase: {
    type: process.env.FIREBASE_TYPE,
    project_id: process.env.FIREBASE_PROJECT_ID,
    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
    private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
    client_id: process.env.FIREBASE_CLIENT_ID,
    auth_uri: process.env.FIREBASE_AUTH_URI,
    token_uri: process.env.FIREBASE_TOKEN_URI,
    auth_provider_x509_cert_url:
      process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
    client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL,
    universe_domain: process.env.FIREBASE_UNIVERSE_DOMAIN,
  },
  visionAPI: {
    type: process.env.VISION_TYPE,
    project_id: process.env.VISION_PROJECT_ID,
    private_key_id: process.env.VISION_PRIVATE_KEY_ID,
    private_key: process.env.VISION_PRIVATE_KEY?.replace(/\\n/g, "\n"),
    client_email: process.env.VISION_CLIENT_EMAIL,
    client_id: process.env.VISION_CLIENT_ID,
    auth_uri: process.env.VISION_AUTH_URI,
    token_uri: process.env.VISION_TOKEN_URI,
    auth_provider_x509_cert_url: process.env.VISION_AUTH_PROVIDER_X509_CERT_URL,
    client_x509_cert_url: process.env.VISION_CLIENT_X509_CERT_URL,
    universe_domain: process.env.VISION_UNIVERSE_DOMAIN,
  },
  port: process.env.PORT || 4000,
  jwtSecret: process.env.JWT_SECRET,
  geminiKey: process.env.GEMINI_KEY,
};
