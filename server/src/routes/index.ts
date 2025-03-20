import { Router } from "express";
import userRoutes from "@/routes/user";
import trashRoutes from "@/routes/trash";
import gameRoutes from "@/routes/game";
import { authMiddleware } from "@/middleware/auth";

const router = Router();

router.use("/users", authMiddleware, userRoutes);
router.use("/trash", trashRoutes);
router.use("/game", gameRoutes)

export default router;
