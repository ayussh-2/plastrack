<h1 align="center">Plastrack</h1>

<!-- <p align="center">
    <img src="https://via.placeholder.com/150?text=W2W" alt="Plastrack" width="150" height="150">
</p> -->

<p align="center">
    A comprehensive waste management and infrastructure solution that uses AI to identify, classify, and suggest sustainable reuse of waste materials.
</p>

<br>

## 📖 Project Overview

Plastrack is an innovative solution addressing the global waste management crisis through technology. The project combines AI-powered waste identification with community engagement to:

-   **Identify waste materials** with high accuracy using computer vision
-   **Suggest sustainable disposal methods** appropriate for each waste type
-   **Map waste hotspots** to help municipalities prioritize cleanup efforts
-   **Engage communities** through gamification and educational content
-   **Connect waste generators** with recycling facilities and upcycling opportunities

Our platform serves various stakeholders including individuals, waste management companies, municipalities, and environmental organizations.

## 📋 Technologies Used

### Backend

-   **Runtime**: Node.js + Bun
-   **Framework**: Express.js
-   **Database**: PostgreSQL
-   **ORM**: Prisma
-   **AI Services**: Google Cloud Vision API, Gemini AI
-   **Authentication**: Firebase Auth
-   **Containerization**: Docker
-   **Hosting**: Google Cloud Run

### Web Frontend

-   **Framework**: Vue.js (Nuxt.js)
-   **Styling**: Tailwind CSS v4.0.9
-   **State Management**: Pinia
-   **Authentication**: Firebase Auth
-   **Storage**: Cloudinary
-   **Maps**: Google Maps API
-   **Hosting**: Vercel

### Mobile App

-   **Framework**: Flutter
-   **Authentication**: Firebase Auth
-   **Maps**: Google Maps Flutter
-   **Image Upload**: Cloudinary
-   **Storage**: Shared Preferences
-   **Location**: Flutter Location
-   **UI Animation**: Flutter Animate
-   **Analytics**: Firebase Analytics

## 🚀 Features

-   **AI-powered Waste Identification**: 90%+ accuracy in waste classification
-   **Infrastructure Suitability Analysis**: Determine best reuse applications
-   **Waste Hotspot Mapping**: Geographic visualization of waste concentration
-   **Community Gamification**: Points system and leaderboard
-   **Cross-platform Access**: Mobile app for on-site reporting, web interface for analysis
-   **Offline Functionality**: Continue using the app without internet connection
-   **Multilingual Support**: Available in English, Spanish, French, and German
-   **Detailed Analytics**: Track waste patterns and community engagement
-   **Educational Content**: Learn about proper waste disposal and recycling methods

## 🔧 Installation & Setup

### Prerequisites

-   Node.js 18+ and Bun runtime
-   PostgreSQL database
-   Firebase account
-   Google Cloud account (for Vision API)
-   Cloudinary account
-   Flutter SDK (for mobile app)

### Setup

```bash
git clone https://github.com/ayussh-2/plastrack.git
```

```bash

cd plastrack/server
# Install dependencies
bun install

# Set up environment variables
cp .env.example .env
# Fill in the required values in .env

# Run database migrations
bunx prisma migrate dev

# Start the development server
bun dev
```

### Web Frontend Setup

```bash

# Navigate to the web directory
cd plastrack/web

# Install dependencies
bun install

# Set up environment variables
cp .env.example .env
# Fill in the required values in .env

# Start the development server
bun dev

```

### Flutter Setup

```bash
# Navigate to the mobile directory
cd plastrack/mobile

# Install dependencies
flutter pub get

# Run the app in development mode
flutter run
```

## 📱 Usage Guide

-   Register an account via the mobile app
-   Report waste by taking a photo through the mobile app
-   Review analysis of waste type and disposal recommendations
-   Earn points for each verified waste report
-   View hotspots on the interactive map
-   Track your impact through the personal dashboard
-   Compete with other users on the leaderboard

## 🏆 System Architecture

Our system follows a microservices architecture with three main components:

-   **API Server**: Handles authentication, database operations, and business logic
-   **AI Service**: Processes waste images and generates recommendations
-   **Client Applications**: Web and mobile interfaces for user interaction

Check out our architecture diagram for more details.
