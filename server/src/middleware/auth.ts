import { Request, Response, NextFunction } from "express";
import { AppError } from "../utils/asyncHandler";
import { verifyIdToken } from "@/firebase";

declare global {
    namespace Express {
        interface Request {
            user?: { id: string };
        }
    }
}

export const authMiddleware = async (
    req: Request,
    res: Response,
    next: NextFunction
) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            throw new AppError("Unauthorized - No token provided", 401);
        }

        const token = authHeader.split("Bearer ")[1];
        const decodedToken = await verifyIdToken(token);

        console.log(decodedToken);

        if (!decodedToken) {
            throw new AppError("Unauthorized - Invalid token", 401);
        }

        req.user = { id: decodedToken.uid };

        next();
    } catch (error) {
        next(error);
    }
};
