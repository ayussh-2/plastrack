import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth } from "firebase/auth";

export default defineNuxtPlugin((nuxtApp) => {
    const config = useRuntimeConfig();

    const firebaseApp = !getApps().length
        ? initializeApp({
              apiKey: config.public.firebaseApiKey,
              authDomain: config.public.firebaseAuthDomain,
              projectId: config.public.firebaseProjectId,
              storageBucket: config.public.firebaseStorageBucket,
              messagingSenderId: config.public.firebaseMessagingSenderId,
              appId: config.public.firebaseAppId,
              measurementId: config.public.firebaseMeasurementId,
          })
        : getApp();

    const auth = getAuth(firebaseApp);

    return {
        provide: {
            firebaseApp,
            firebaseAuth: auth,
        },
    };
});
