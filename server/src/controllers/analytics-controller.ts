import { Request, Response } from "express";
import { AnalyticsService } from "../services/analytics-service";
import {
  asyncHandler,
  handleSuccess,
  handleError,
  AppError,
} from "../utils/asyncHandler";

const analyticsService = new AnalyticsService();

export const analyticsController = {
  getCollectionStatistics: asyncHandler(async (req: Request, res: Response) => {
    const { period } = req.query;
    const stats = await analyticsService.getCollectionStatistics(
      period as "day" | "week" | "month"
    );
    return handleSuccess(
      res,
      stats,
      "Collection statistics retrieved successfully"
    );
  }),

  getComplaintStatistics: asyncHandler(async (req: Request, res: Response) => {
    const { period } = req.query;
    const stats = await analyticsService.getComplaintStatistics(
      period as "day" | "week" | "month"
    );
    return handleSuccess(
      res,
      stats,
      "Complaint statistics retrieved successfully"
    );
  }),

  getWasteSegregationData: asyncHandler(async (req: Request, res: Response) => {
    const stats = await analyticsService.getWasteSegregationData();
    return handleSuccess(
      res,
      stats,
      "Waste segregation data retrieved successfully"
    );
  }),

  getAreaAnalytics: asyncHandler(async (req: Request, res: Response) => {
    const areas = await analyticsService.getAreaAnalytics();
    return handleSuccess(res, areas, "Area analytics retrieved successfully");
  }),
};
