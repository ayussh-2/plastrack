import { Request, Response } from "express";
import { asyncHandler, handleSuccess } from "../utils/asyncHandler";
import { TreeService } from "@/services/tree-service";

const treeService = new TreeService();

export const treeController = {
    exchangeTokensForTree: asyncHandler(async (req: Request, res: Response) => {
        const { firebaseId, tokens } = req.body;
        if (!firebaseId || !tokens) {
            return res.status(400).json({
                success: false,
                message: "Firebase ID and tokens are required",
            });
        }

        const result = await treeService.exchangeTokensForTree(
            firebaseId,
            Number(tokens)
        );
        return handleSuccess(res, result, result.message);
    }),

    getTotalVirtualTrees: asyncHandler(async (_req: Request, res: Response) => {
        const totalTrees = await treeService.getTotalVirtualTrees();
        return handleSuccess(
            res,
            { totalTrees },
            "Total virtual trees retrieved successfully"
        );
    }),
};
