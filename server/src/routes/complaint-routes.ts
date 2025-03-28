import { Router } from "express";
import { complaintController } from "../controllers/complaint-controller";

const router = Router();

// Complaint routes
router.post("/", complaintController.submitComplaint);
router.get("/all", complaintController.getAllComplaints);
router.get("/:id", complaintController.getComplaintById);
router.get("/report/:reportId", complaintController.getComplaintsByReportId);
router.patch("/:id/status", complaintController.updateComplaintStatus);

export default router;
