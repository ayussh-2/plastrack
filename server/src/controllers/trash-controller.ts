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

    deleteTrashReport: asyncHandler(async (req: Request, res: Response) => {
        const { id } = req.params;
        await trashService.deleteReport(Number(id));
        return handleSuccess(res, null, "Trash report deleted successfully");
    }),

    createTrashFeedback: asyncHandler(async (req: Request, res: Response) => {
        const { trashId, feedback } = req.body;
        console.log(trashId, feedback);
        const response = await trashService.createTrashFeedback(
            trashId,
            feedback
        );
        return handleSuccess(res, response, "success");
    }),

    getTrashFeedBack: asyncHandler(async (req: Request, res: Response) => {
        const { reportId } = req.params;
        const feedback = await trashService.getTrashFeedback(Number(reportId));
        return handleSuccess(res, feedback, "Feedback retrieved successfully");
    }),

    getTrashFeedbackForArea: asyncHandler(
        async (req: Request, res: Response) => {
            const { latitude, longitude, radius } = req.query;
            const feedback = await trashService.getTrashFeedbacksForArea(
                Number(latitude),
                Number(longitude),
                Number(radius)
            );
            return handleSuccess(
                res,
                feedback,
                "Feedback for area retrieved successfully"
            );
        }
    ),
};
