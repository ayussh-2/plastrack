import { Request, Response } from "express";
import { AdminService } from "../services/admin-service";
import {
  asyncHandler,
  handleSuccess,
  handleError,
  AppError,
} from "../utils/asyncHandler";

const adminService = new AdminService();

export const adminController = {
  getDashboard: asyncHandler(async (req: Request, res: Response) => {
    const stats = await adminService.getDashboardStats();
    return handleSuccess(res, stats, "Dashboard stats retrieved successfully");
  }),

  getAllComplaints: asyncHandler(async (req: Request, res: Response) => {
    const { page, limit, status } = req.query;
    const complaints = await adminService.getAllComplaints(
      Number(page) || 1,
      Number(limit) || 10,
      status as string
    );
    return handleSuccess(res, complaints, "Complaints retrieved successfully");
  }),

  updateComplaintStatus: asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const { feedback } = req.body;
    const complaint = await adminService.updateComplaintStatus(
      Number(id),
      feedback
    );
    return handleSuccess(
      res,
      complaint,
      "Complaint status updated successfully"
    );
  }),

  getServiceAreas: asyncHandler(async (req: Request, res: Response) => {
    const areas = await adminService.getServiceAreas();
    return handleSuccess(res, areas, "Service areas retrieved successfully");
  }),
};
