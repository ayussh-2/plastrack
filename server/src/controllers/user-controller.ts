import { Request, Response } from "express";
import { asyncHandler, handleSuccess } from "../utils/asyncHandler";
import { UserService } from "@/services/user-service";

const userService = new UserService();

export const userController = {
    getMe: asyncHandler(async (req: Request, res: Response) => {
        const userId = req.user!.id;
        const user = await userService.findUserByFirebaseId(userId);
        return handleSuccess(res, user, "User profile retrieved successfully");
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
