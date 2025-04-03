::: mermaid

flowchart TD
%% User Authentication
Start([User Starts App]) --> Auth{Authenticated?}
Auth -->|No| Login[Login/Register Screen]
Login --> Firebase[Firebase Authentication]
Firebase --> Auth

    %% Main Flows
    Auth -->|Yes| Dashboard[User Dashboard]
    Dashboard --> ReportFlow[Report Waste]
    Dashboard --> ViewMap[View Waste Map]
    Dashboard --> CheckLeaderboard[View Leaderboard]
    Dashboard --> Profile[User Profile]

    %% Waste Reporting Flow
    ReportFlow --> CaptureImage[Capture Waste Image]
    CaptureImage --> GetLocation[Get GPS Location]
    GetLocation --> UploadData[Upload to Server]
    UploadData --> CloudStorage[(Cloudinary Storage)]
    UploadData --> Server[Backend Server]

    %% AI Analysis Flow
    Server --> AIAnalysis{AI Analysis}
    AIAnalysis --> CloudVision[Google Cloud Vision API]
    AIAnalysis --> GeminiAI[Gemini AI]
    CloudVision --> WasteClassification[Classify Waste Type]
    GeminiAI --> RecyclingInstructions[Generate Instructions]
    WasteClassification --> UpdateDatabase[Update Database]
    RecyclingInstructions --> UpdateDatabase

    %% Database Updates
    UpdateDatabase --> Database[(PostgreSQL Database)]
    Database --> UpdatePoints[Update User Points]
    UpdatePoints --> NotifyUser[Notify User]

    %% Map View Flow
    ViewMap --> FetchHotspots[Fetch Waste Hotspots]
    FetchHotspots --> Database
    Database --> RenderMap[Render Google Map]

    %% Leaderboard Flow
    CheckLeaderboard --> FetchLeaderboard[Fetch Top Users]
    FetchLeaderboard --> Database
    Database --> DisplayLeaderboard[Display Leaderboard]

    %% Admin Flow
    Admin([Admin User]) --> AdminDashboard[Admin Dashboard]
    AdminDashboard --> ManageUsers[Manage Users]
    AdminDashboard --> ReviewReports[Review Waste Reports]
    AdminDashboard --> ViewStatistics[View Statistics]
    ManageUsers --> Database
    ReviewReports --> Database
    ViewStatistics --> Database

    %% Styling
    classDef userAction fill:#d4f1f9,stroke:#05a,stroke-width:2px,color:black
    classDef serverProcess fill:#ffe6cc,stroke:#d79b00,stroke-width:2px,color:black
    classDef aiProcess fill:#e1d5e7,stroke:#9673a6,stroke-width:2px,color:black
    classDef database fill:#f8cecc,stroke:#b85450,stroke-width:2px,color:black
    classDef auth fill:#fff2cc,stroke:#d6b656,stroke-width:2px,color:black

    class Start,Dashboard,ReportFlow,ViewMap,CheckLeaderboard,Profile,CaptureImage,GetLocation userAction
    class Server,UpdateDatabase,FetchHotspots,FetchLeaderboard,UploadData serverProcess
    class AIAnalysis,CloudVision,GeminiAI,WasteClassification,RecyclingInstructions aiProcess
    class Database,CloudStorage database
    class Auth,Login,Firebase auth

:::
