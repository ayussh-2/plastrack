import { Request, Response, NextFunction } from "express";
import { handleError } from "../utils/asyncHandler";

export const errorHandler = (
    err: any,
    req: Request,
    res: Response,
    next: NextFunction
) => {
    handleError(err, res);
};
