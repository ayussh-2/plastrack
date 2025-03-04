import type { FetchOptions } from "ofetch";

type ApiResponse<T> = Promise<T>;

interface ApiRequestOptions<T = any> extends Omit<FetchOptions, "body"> {
    body?: T | BodyInit | Record<string, any> | null;
    method?:
        | "options"
        | "POST"
        | "GET"
        | "HEAD"
        | "PATCH"
        | "PUT"
        | "DELETE"
        | "CONNECT"
        | "OPTIONS"
        | "TRACE"
        | "post"
        | "get"
        | "head"
        | "patch"
        | "put"
        | "delete"
        | "connect"
        | "trace";
}

export const useApi = () => {
    const authStore = useAuthStore();
    const config = useRuntimeConfig();

    const baseURL: string = `${config.public.apiBaseUrl}/api`;

    const api = $fetch.create({
        baseURL,
        headers: {
            "Content-Type": "application/json",
        },
        async onRequest({ options }) {
            if (authStore.currentUser) {
                const token = await authStore.currentUser.getIdToken();
                options.headers = options.headers || {};
                options.headers.set("Authorization", `Bearer ${token}`);
            }
        },
    });

    return {
        get: <T = any>(
            endpoint: string,
            options?: ApiRequestOptions
        ): ApiResponse<T> => api<T>(endpoint, options),

        post: <
            T = any,
            D extends BodyInit | Record<string, any> | null | undefined = any
        >(
            endpoint: string,
            data?: D,
            options?: Omit<ApiRequestOptions, "body">
        ): ApiResponse<T> =>
            api<T>(endpoint, { ...options, method: "POST", body: data }),

        put: <
            T = any,
            D extends BodyInit | Record<string, any> | null | undefined = any
        >(
            endpoint: string,
            data?: D,
            options?: Omit<ApiRequestOptions, "body">
        ): ApiResponse<T> =>
            api<T>(endpoint, { ...options, method: "PUT", body: data }),

        delete: <T = any>(
            endpoint: string,
            options?: ApiRequestOptions
        ): ApiResponse<T> => api<T>(endpoint, { ...options, method: "DELETE" }),
    };
};
