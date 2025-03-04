import type { Auth } from "firebase/auth";

declare module "@vue/runtime-core" {
    interface ComponentCustomProperties {
        $firebaseAuth: Auth;
    }
}

export const useFirebaseAuth = () => {
    const nuxtApp = useNuxtApp();
    return nuxtApp.$firebaseAuth;
};
