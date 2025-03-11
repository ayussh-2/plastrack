import { config } from "dotenv";
config();

export const env = {
    firebase: {
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
    },
    port: process.env.PORT || 4000,
    jwtSecret: process.env.JWT_SECRET,
    geminiKey: process.env.GEMINI_KEY,
};
