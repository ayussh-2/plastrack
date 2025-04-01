import { Router } from "express";
import { cleanupController } from "@/controllers/cleanup-controller";
import { authMiddleware } from "@/middleware/auth";

const router = Router();

router.get("/monitor", authMiddleware, cleanupController.monitorHotspots);
router.get("/tasks", cleanupController.getCleanupTasks);
router.patch(
    "/tasks/:id",
    authMiddleware,
    cleanupController.updateCleanupTaskStatus
);

export default router;
