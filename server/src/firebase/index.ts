import { initializeApp, cert, ServiceAccount } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import serviceAccountJSON from "./cert.json";

const app = initializeApp({
    credential: cert(serviceAccountJSON as ServiceAccount),
});

export const auth = getAuth(app);

export async function verifyIdToken(token: string) {
    try {
        const decodedToken = await auth.verifyIdToken(token);
        return decodedToken;
    } catch (error) {
        console.error("Error verifying token:", error);
        return null;
    }
}
