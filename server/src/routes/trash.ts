import { Router } from "express";
import { trashController } from "@/controllers/trash-controller";

const router = Router();

const {
    createMultipleReports,
    createTrashFeedback,
    createTrashReport,
    getHotspots,
    getTrashFeedBack,
    getTrashFeedbackForArea,
    getMyTrashReportsAndFeedbacks,
    classifyTrash
} = trashController;

router.get("/hotspots", getHotspots);
router.post("/generate", createTrashReport);
router.post("/generate-many", createMultipleReports);
router.post("/feedback", createTrashFeedback);
router.get("/feedback", getTrashFeedBack);
router.get("/feedbacks", getTrashFeedbackForArea);
router.post("/my-reports", getMyTrashReportsAndFeedbacks);
router.post("/classify", classifyTrash);

export default router;
