<template>
    <div>
        <Head>
            <title>Plastrack</title>
            <meta
                name="description"
                content="Track and report waste hotspots"
            />
            <meta property="og:title" content="Plastrack" />
            <meta
                property="og:description"
                content="Track and report waste hotspots"
            />
            <meta property="og:image" :content="ogImageUrl" />
            <meta property="og:image:width" content="1200" />
            <meta property="og:image:height" content="630" />
            <meta property="og:type" content="website" />
            <meta property="og:url" :content="baseUrl" />
        </Head>
        <Navbar />
        <NuxtPage />
    </div>
</template>

<script setup>
const route = useRoute();
const config = useRuntimeConfig();
const baseUrl = computed(() => {
    const protocol = process.client ? window.location.protocol : "https:";
    const host = process.client
        ? window.location.host
        : new URL(config.public.apiBaseUrl).host;
    return `${protocol}//${host}`;
});

const lat = computed(() => route.query.lat || "22.2526567");
const lng = computed(() => route.query.lng || "84.913171");

const ogImageUrl = computed(() => {
    return `${baseUrl.value}/api/og-image?lat=${lat.value}&lng=${lng.value}`;
});
</script>
