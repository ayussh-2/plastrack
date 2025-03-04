import { getAuth, onAuthStateChanged, type User } from "firebase/auth";

export const useFirebaseAuth = () => {
    const nuxtApp = useNuxtApp();

    const getAuthInstance = () => {
        return nuxtApp.$firebaseAuth || getAuth();
    };

    const watchAuthState = (callback: (user: User | null) => void) => {
        const auth = getAuthInstance();
        return onAuthStateChanged(auth, callback);
    };

    return {
        getAuthInstance,
        watchAuthState,
    };
};
