import { Request, Response, NextFunction } from "express";

// Define a type for controller functions
type ControllerFunction = (req: Request, res: Response) => Promise<any>;

// StandardResponse for success responses
export interface StandardResponse {
    success: boolean;
    message?: string;
    data?: any;
    meta?: any;
}

// Standardized error class
export class AppError extends Error {
    statusCode: number;
    isOperational: boolean;

    constructor(
        message: string,
        statusCode: number,
        isOperational: boolean = true
    ) {
        super(message);
        this.statusCode = statusCode;
        this.isOperational = isOperational;

        Error.captureStackTrace(this, this.constructor);
    }
}

// Handle success responses
export const handleSuccess = (
    res: Response,
    data: any = null,
    message: string = "Success",
    statusCode: number = 200,
    meta: any = null
): Response => {
    const response: StandardResponse = {
        success: true,
        message,
    };

    if (data !== null) {
        response.data = data;
    }

    if (meta !== null) {
        response.meta = meta;
    }

    return res.status(statusCode).json(response);
};

// Handle error responses
export const handleError = (err: any, res: Response): Response => {
    // If it's our custom error
    if (err instanceof AppError) {
        return res.status(err.statusCode).json({
            success: false,
            message: err.message,
            error: err.isOperational
                ? { errorCode: err.statusCode }
                : undefined,
        });
    }

    // If it's a Prisma error
    if (err.code && err.code.startsWith("P")) {
        return res.status(400).json({
            success: false,
            message: "Database error",
            error: {
                errorCode: err.code,
                detail:
                    process.env.NODE_ENV === "development"
                        ? err.message
                        : "An error occurred",
            },
        });
    }

    // Log unexpected errors
    console.error("UNEXPECTED ERROR:", err);

    // Default error response
    return res.status(500).json({
        success: false,
        message: "Internal server error",
        error:
            process.env.NODE_ENV === "development"
                ? { stack: err.stack }
                : undefined,
    });
};

export const asyncHandler = (fn: ControllerFunction) => {
    return async (req: Request, res: Response, next: NextFunction) => {
        try {
            await fn(req, res);
        } catch (err) {
            handleError(err, res);
        }
    };
};
