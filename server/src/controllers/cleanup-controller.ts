import { Request, Response } from "express";
import { asyncHandler, handleSuccess } from "../utils/asyncHandler";
import { CleanupService } from "@/services/cleanup-service";

const cleanupService = new CleanupService();

export const cleanupController = {
    monitorHotspots: asyncHandler(async (_req: Request, res: Response) => {
        const result = await cleanupService.monitorHotspots();
        return handleSuccess(res, result, "Hotspot monitoring completed");
    }),

    getCleanupTasks: asyncHandler(async (req: Request, res: Response) => {
        const { status } = req.query;
        const tasks = await cleanupService.getCleanupTasks(status as string);
        return handleSuccess(
            res,
            tasks,
            "Cleanup tasks retrieved successfully"
        );
    }),

    updateCleanupTaskStatus: asyncHandler(
        async (req: Request, res: Response) => {
            const { id } = req.params;
            const { status, materialData } = req.body;

            if (!status) {
                return res.status(400).json({
                    success: false,
                    message: "Status is required",
                });
            }

            const result = await cleanupService.updateCleanupTaskStatus(
                Number(id),
                status,
                materialData
            );

            return handleSuccess(res, result, result.message);
        }
    ),
};
