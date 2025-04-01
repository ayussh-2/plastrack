import { Router } from "express";
import userRoutes from "@/routes/user";
import trashRoutes from "@/routes/trash";
import gameRoutes from "@/routes/game";
import treeRoutes from "@/routes/tree";
import cleanupRoutes from "@/routes/cleanup";
import { authMiddleware } from "@/middleware/auth";

const router = Router();

router.use("/users", authMiddleware, userRoutes);
router.use("/trash", trashRoutes);
router.use("/game", gameRoutes);
router.use("/trees", treeRoutes);
router.use("/cleanup", cleanupRoutes);

export default router;
