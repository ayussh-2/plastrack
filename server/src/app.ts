import express from "express";
import cors from "cors";
import helmet from "helmet";
import compression from "compression";
import morgan from "morgan";
import rateLimit from "express-rate-limit";
import apiRoutes from "@/routes";
import { errorHandler } from "./middleware/errorHandler";

const app = express();

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100,
});

app.use(cors());
app.use(helmet());
app.use(compression());
app.use(morgan("dev"));
app.use(limiter);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Define the root path first
app.get("/", (req, res) => {
    res.status(200).json({ status: "ok", message: "Ocean Beacon Server" });
});

// Then API routes
app.use("/api", apiRoutes);

// Method not allowed handler for routes that exist but with wrong method
app.use("/api", (req, res, next) => {
    res.status(405).json({
        success: false,
        message: "Method not allowed",
    });
});

// Finally 404 handler for undefined routes
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: "API endpoint not found",
    });
});

// Error handler should be last
app.use(errorHandler);

export default app;
