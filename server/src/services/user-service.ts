import prisma from "@/lib/prisma";
import { IUser, PaginationParams, UserUpdateInput } from "../types";
import { AppError } from "../utils/asyncHandler";

export class UserService {
    async findUserByFirebaseId(firebaseId: string): Promise<IUser | null> {
        const user = await prisma.user.findUnique({
            where: { firebaseId },
        });

        if (!user) {
            return null;
        }

        return user;
    }

    async updateUser(
        firebaseId: string,
        data: UserUpdateInput
    ): Promise<IUser> {
        const user = await prisma.user.update({
            where: { firebaseId },
            data,
        });

        return user;
    }

    async getAllUsers(
        params: PaginationParams = {}
    ): Promise<{ users: IUser[]; total: number; page: number; limit: number }> {
        const page = Number(params.page) || 1;
        const limit = Number(params.limit) || 10;
        const skip = (page - 1) * limit;

        const [users, total] = await Promise.all([
            prisma.user.findMany({
                skip,
                take: limit,
                orderBy: { createdAt: "desc" },
            }),
            prisma.user.count(),
        ]);

        return {
            users,
            total,
            page,
            limit,
        };
    }

    async getUserById(id: string): Promise<IUser> {
        const user = await prisma.user.findUnique({
            where: { id },
        });

        if (!user) {
            throw new AppError("User not found", 404);
        }

        return user;
    }

    async createUser(
        firebaseId: string,
        email: string,
        name: string,
        phone: string,
        city: string,
        state: string
    ): Promise<IUser> {
        const existingUser = await prisma.user.findUnique({
            where: { firebaseId },
        });

        if (existingUser) {
            return existingUser;
        }

        return prisma.user.create({
            data: {
                firebaseId,
                email,
                name,
                phone,
                city,
                state,
            },
        });
    }
}
