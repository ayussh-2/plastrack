import { initializeApp, cert, ServiceAccount } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import prisma from "@/lib/prisma";
import { env } from "@/config";

const serviceAccount: ServiceAccount = {
    projectId: env.firebase.projectId,
    clientEmail: env.firebase.clientEmail,
    privateKey: env.firebase.privateKey,
};

const app = initializeApp({
    credential: cert(serviceAccount),
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

export async function syncFirebaseUser(firebaseUid: string): Promise<boolean> {
    try {
        const firebaseUser = await auth.getUser(firebaseUid);

        if (!firebaseUser.email) {
            console.error("Firebase user has no email");
            return false;
        }

        const existingUser = await prisma.user.findUnique({
            where: { firebaseId: firebaseUid },
        });

        if (!existingUser) {
            await prisma.user.create({
                data: {
                    firebaseId: firebaseUid,
                    email: firebaseUser.email,
                    name: firebaseUser.displayName || null,
                },
            });
            console.log(`Created new user for Firebase ID: ${firebaseUid}`);
        }

        return true;
    } catch (error) {
        console.error("Error syncing Firebase user:", error);
        return false;
    }
}
