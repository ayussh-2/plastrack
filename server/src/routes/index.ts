import { Router } from "express";
import userRoutes from "@/routes/user";
import geminiRoutes from "@/routes/gemini";
import trashRoutes from "@/routes/trash";
import { authMiddleware } from "@/middleware/auth";

const router = Router();

router.use("/users", authMiddleware, userRoutes);
router.use("/gemini", geminiRoutes);
router.use("/trash", trashRoutes);

export default router;
