import { Request, Response } from "express";
import {
    AppError,
    asyncHandler,
    handleError,
    handleSuccess,
} from "../utils/asyncHandler";
import { UserService } from "@/services/user-service";

const userService = new UserService();

export const userController = {
    getMe: asyncHandler(async (req: Request, res: Response) => {
        const userId = req.user!.id;
        console.log(userId);
        const user = await userService.findUserByFirebaseId(userId);

        if (!user) {
            const error = new AppError("User not found", 404);
            return handleError(error, res);
        }
        return handleSuccess(res, user, "User profile retrieved successfully");
    }),

    updateMe: asyncHandler(async (req: Request, res: Response) => {
        const userId = req.user!.id;
        const { name, phone, city, state, firebaseId, email } = req.body;
        const user = await userService.updateUser(userId, {
            name,
            phone,
            city,
            state,
            firebaseId,
            email,
            updatedAt: new Date(),
        });

        return handleSuccess(res, user, "User profile updated successfully");
    }),

    getAllUsers: asyncHandler(async (req: Request, res: Response) => {
        const { page, limit } = req.query;
        const result = await userService.getAllUsers({
            page: page ? Number(page) : undefined,
            limit: limit ? Number(limit) : undefined,
        });

        return handleSuccess(
            res,
            result.users,
            "Users retrieved successfully",
            200,
            {
                pagination: {
                    total: result.total,
                    page: result.page,
                    limit: result.limit,
                    pages: Math.ceil(result.total / result.limit),
                },
            }
        );
    }),

    getUserById: asyncHandler(async (req: Request, res: Response) => {
        const userId = req.params.id;
        const user = await userService.getUserById(userId);

        return handleSuccess(res, user, "User retrieved successfully");
    }),

    createUser: asyncHandler(async (req: Request, res: Response) => {
        const { firebaseId, email, name, phone, city, state } = req.body;
        const user = await userService.createUser(
            firebaseId,
            email,
            name,
            String(phone),
            city,
            state
        );

        return handleSuccess(res, user, "User created successfully", 201);
    }),
};
