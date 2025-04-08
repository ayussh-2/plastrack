<template>
    <footer
        class="py-4 text-white bg-gradient-to-b from-waste2way-dark to-waste2way-dark/95"
    >
        <div class="container px-4 mx-auto">
            <div class="flex flex-col items-center justify-between md:flex-row">
                <div class="flex items-center mb-4 space-x-2 md:mb-0">
                    <NuxtLink to="/" class="flex items-center space-x-2">
                        <Icon
                            name="lucide:recycle"
                            class="scale-150 text-waste2way-teal"
                        />
                        <span class="font-sans text-xl font-bold"
                            >Plastrack</span
                        >
                    </NuxtLink>
                </div>
                <div class="flex items-center space-x-4">
                    <p class="font-sans text-sm text-white/60">
                        Made with ❤️ by devRejects
                    </p>
                    <a
                        href="https://github.com/ayussh-2/plastrack"
                        class="transition-colors text-white/60 hover:text-waste2way-teal"
                        target="_blank"
                        rel="noopener noreferrer"
                    >
                        <Icon name="mdi:github" class="w-5 h-5" />
                    </a>
                </div>
            </div>
        </div>
    </footer>
</template>

<script>
export default {
    name: "Footer",
};
</script>
