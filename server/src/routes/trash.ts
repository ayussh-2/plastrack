import { Router } from "express";
import { trashController } from "@/controllers/trash-controller";

const router = Router();
const trash = trashController;

router.get("/hotspots", trash.getHotspots);
router.post("/generate", trash.createTrashReport);
router.post("/generate-many", trash.createMultipleReports);

export default router;
