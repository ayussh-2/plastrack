import { Request, Response, NextFunction } from "express";
import { AppError } from "../utils/asyncHandler";
import { PrismaClient } from "@prisma/client";
import { verifyIdToken } from "@/firebase";

const prisma = new PrismaClient();

declare global {
    namespace Express {
        interface Request {
            user?: {
                id: string;
                firebaseId: string;
                email: string;
            };
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

        if (!decodedToken) {
            throw new AppError("Unauthorized - Invalid token", 401);
        }

        const user = await prisma.user.findUnique({
            where: { firebaseId: decodedToken.uid },
        });

        if (!user) {
            throw new AppError("User not found", 404);
        }

        req.user = {
            id: user.id,
            firebaseId: user.firebaseId,
            email: user.email,
        };

        next();
    } catch (error) {
        next(error);
    }
};
