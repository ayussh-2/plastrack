import { Router } from "express";
import { adminController } from "../controllers/admin-controller";

const router = Router();

// Admin routes
router.get("/dashboard", adminController.getDashboard);
router.get("/complaints", adminController.getAllComplaints);
router.put("/complaints/:id", adminController.updateComplaintStatus);
router.get("/areas", adminController.getServiceAreas);

export default router;
