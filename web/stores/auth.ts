import { defineStore } from "pinia";
import {
    createUserWithEmailAndPassword,
    signInWithEmailAndPassword,
    signOut,
    updateProfile,
    type User,
    onAuthStateChanged,
    setPersistence,
    browserLocalPersistence,
} from "firebase/auth";

export const useAuthStore = defineStore("auth", {
    state: () => ({
        user: null as User | null,
        isAuthenticated: false,
        loading: false,
        error: null as string | null,
        initialized: false,
    }),

    actions: {
        async initAuth() {
            return new Promise<void>((resolve) => {
                console.log("Initializing auth store");

                const { getAuthInstance } = useFirebaseAuth();

                const auth = getAuthInstance();
                setPersistence(auth, browserLocalPersistence).catch((error) => {
                    console.error("Auth persistence error:", error);
                });
                onAuthStateChanged(auth, (user) => {
                    if (user) {
                        this.user = user;
                        this.isAuthenticated = true;
                    } else {
                        this.user = null;
                        this.isAuthenticated = false;
                    }
                    this.initialized = true;
                    resolve();
                });
            });
        },
        setInitialized(value: boolean) {
            this.initialized = value;
        },

        async login(email: string, password: string) {
            this.loading = true;
            this.error = null;

            try {
                const { getAuthInstance } = useFirebaseAuth();
                const auth = getAuthInstance();

                const userCredential = await signInWithEmailAndPassword(
                    auth,
                    email,
                    password
                );

                this.user = userCredential.user;
                this.isAuthenticated = true;

                return userCredential.user;
            } catch (error: any) {
                this.error = this.formatErrorMessage(error);
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async register(email: string, password: string, displayName?: string) {
            this.loading = true;
            this.error = null;

            try {
                const { getAuthInstance } = useFirebaseAuth();
                const auth = getAuthInstance();

                const userCredential = await createUserWithEmailAndPassword(
                    auth,
                    email,
                    password
                );

                if (displayName && userCredential.user) {
                    await updateProfile(userCredential.user, { displayName });
                }

                this.user = userCredential.user;
                this.isAuthenticated = true;

                return userCredential.user;
            } catch (error: any) {
                this.error = this.formatErrorMessage(error);
                this.isAuthenticated = false;
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async logout() {
            this.loading = true;
            this.error = null;

            try {
                const { getAuthInstance } = useFirebaseAuth();
                const auth = getAuthInstance();

                await signOut(auth);

                this.user = null;
                this.isAuthenticated = false;
            } catch (error: any) {
                this.error = this.formatErrorMessage(error);
                throw error;
            } finally {
                this.loading = false;
            }
        },

        formatErrorMessage(error: any): string {
            switch (error.code) {
                case "auth/user-not-found":
                    return "No user found with this email.";
                case "auth/wrong-password":
                    return "Incorrect password.";
                case "auth/email-already-in-use":
                    return "Email is already registered.";
                case "auth/invalid-email":
                    return "Invalid email address.";
                case "auth/weak-password":
                    return "Password is too weak.";
                default:
                    return error.message || "An unexpected error occurred.";
            }
        },
    },

    getters: {
        currentUser(): User | null {
            return this.user;
        },

        isUserAuthenticated(): boolean {
            return this.isAuthenticated;
        },
    },
});
