import { Request, Response } from "express";
import { ComplaintService } from "../services/complaint-service";
import {
  asyncHandler,
  handleSuccess,
  handleError,
  AppError,
} from "../utils/asyncHandler";

const complaintService = new ComplaintService();

export const complaintController = {
  submitComplaint: asyncHandler(async (req: Request, res: Response) => {
    const { reportId, complaint } = req.body;

    if (!reportId || !complaint) {
      throw new AppError("Report ID and complaint text are required", 400);
    }

    const newComplaint = await complaintService.submitComplaint(
      Number(reportId),
      complaint
    );

    return handleSuccess(
      res,
      newComplaint,
      "Complaint submitted successfully",
      201
    );
  }),

  getComplaintById: asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const complaint = await complaintService.getComplaintById(Number(id));

    if (!complaint) {
      throw new AppError("Complaint not found", 404);
    }

    return handleSuccess(res, complaint, "Complaint retrieved successfully");
  }),

  getComplaintsByReportId: asyncHandler(async (req: Request, res: Response) => {
    const { reportId } = req.params;
    const complaints = await complaintService.getComplaintsByReportId(
      Number(reportId)
    );
    return handleSuccess(res, complaints, "Complaints retrieved successfully");
  }),

  updateComplaintStatus: asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const { status } = req.body;

    if (!status || !["pending", "resolved", "rejected"].includes(status)) {
      throw new AppError(
        "Valid status required (pending, resolved, rejected)",
        400
      );
    }

    const complaint = await complaintService.updateComplaintStatus(
      Number(id),
      status
    );

    return handleSuccess(
      res,
      complaint,
      "Complaint status updated successfully"
    );
  }),

  getAllComplaints: asyncHandler(async (req: Request, res: Response) => {
    const page = req.query.page ? Number(req.query.page) : 1;
    const limit = req.query.limit ? Number(req.query.limit) : 10;
    const status = req.query.status as string | undefined;

    const complaints = await complaintService.getAllComplaints(
      page,
      limit,
      status
    );
    return handleSuccess(res, complaints, "Complaints retrieved successfully");
  }),
};
