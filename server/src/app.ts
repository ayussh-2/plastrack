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

app.use("/api/", apiRoutes);

app.use(errorHandler);

app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: "API endpoint not found",
    });
});

export default app;
