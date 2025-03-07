import { Router } from "express";
import userRoutes from "@/routes/user";
import geminiRoutes from "@/routes/gemini";

const router = Router();

router.use("/users", userRoutes);
router.use("/gemini", geminiRoutes);

export default router;
