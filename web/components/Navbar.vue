<template>
    <nav class="bg-[#0a2540] shadow-md py-4">
        <div class="container mx-auto px-4 flex items-center justify-between">
            <router-link to="/" class="font-bold">
                <span class="text-[#38bdf8] text-2xl">Trash2Way</span>
            </router-link>
            <button
                class="lg:hidden text-white bg-[#38bdf8] p-2 rounded"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#navbarNav"
                aria-controls="navbarNav"
                aria-expanded="false"
                aria-label="Toggle navigation"
            >
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-6 w-6"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                >
                    <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M4 6h16M4 12h16M4 18h16"
                    />
                </svg>
            </button>
            <div class="hidden lg:flex items-center">
                <ul class="flex space-x-4">
                    <li>
                        <router-link
                            to="/"
                            class="text-white hover:text-[#38bdf8] px-3 py-2 rounded hover:bg-[#38bdf8]/10"
                            >Home</router-link
                        >
                    </li>
                    <li>
                        <router-link
                            to="/login"
                            class="text-white hover:text-[#38bdf8] px-3 py-2 rounded hover:bg-[#38bdf8]/10"
                            >Login</router-link
                        >
                    </li>
                    <li>
                        <router-link
                            to="/register"
                            class="text-white hover:text-[#38bdf8] px-3 py-2 rounded hover:bg-[#38bdf8]/10"
                            >Signup</router-link
                        >
                    </li>
                    <li>
                        <router-link
                            to="/dashboard"
                            class="text-white hover:text-[#38bdf8] px-3 py-2 rounded hover:bg-[#38bdf8]/10"
                            >Dashboard</router-link
                        >
                    </li>
                    <li>
                        <router-link
                            to="/hotspot"
                            class="text-white hover:text-[#38bdf8] px-3 py-2 rounded hover:bg-[#38bdf8]/10"
                            >Hotspots</router-link
                        >
                    </li>
                </ul>
            </div>
        </div>
    </nav>
</template>
