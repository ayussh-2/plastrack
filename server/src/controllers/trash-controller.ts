import { Request, Response } from "express";
import { asyncHandler, handleSuccess } from "../utils/asyncHandler";
import { TrashService } from "@/services/trash-service";

const trashService = new TrashService();

export const trashController = {
    createTrashReport: asyncHandler(async (req: Request, res: Response) => {
        const report = await trashService.createReport(req.body);
        return handleSuccess(res, report, "Trash report created successfully");
    }),

    createMultipleReports: asyncHandler(async (req: Request, res: Response) => {
        const reports = await trashService.createMultipleReports(req.body);
        return handleSuccess(
            res,
            reports,
            "Module reports created successfully"
        );
    }),

    getHotspots: asyncHandler(async (req: Request, res: Response) => {
        const { days = 30, gridPrecision = 4 } = req.query;
        const hotspots = await trashService.getHotspots(
            Number(days),
            Number(gridPrecision)
        );
        return handleSuccess(res, hotspots, "Hotspots retrieved successfully");
    }),

    getTrashReports: asyncHandler(async (req: Request, res: Response) => {
        const reports = await trashService.getReports();
        return handleSuccess(
            res,
            reports,
            "Trash reports retrieved successfully"
        );
    }),

    updateTrashReport: asyncHandler(async (req: Request, res: Response) => {
        const { id } = req.params;
        const reportData = req.body;
        const updatedReport = await trashService.updateReport(
            Number(id),
            reportData
        );
        return handleSuccess(
            res,
            updatedReport,
            "Trash report updated successfully"
        );
    }),
};
