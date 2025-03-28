import { Router, Request, Response } from "express";
import { analyticsController } from "../controllers/analytics-controller";

const router = Router();

// Analytics routes
router.get("/collection", analyticsController.getCollectionStatistics);
router.get("/complaints", analyticsController.getComplaintStatistics);
router.get("/segregation", analyticsController.getWasteSegregationData);
router.get("/areas", analyticsController.getAreaAnalytics);

export default router;
