import { Router } from "express";
import userRoutes from "@/routes/user";
import trashRoutes from "@/routes/trash";
import gameRoutes from "@/routes/game";
import complaintRoutes from "@/routes/complaint-routes";
import adminRoutes from "@/routes/admin-routes";
import analyticsRoutes from "@/routes/analytics-routes";
import { authMiddleware } from "@/middleware/auth";

const router = Router();

router.use("/users", authMiddleware, userRoutes);
router.use("/trash", trashRoutes);
router.use("/game", gameRoutes);
router.use("/complaints", complaintRoutes);
router.use("/admin", adminRoutes);
router.use("/analytics", analyticsRoutes);

export default router;
