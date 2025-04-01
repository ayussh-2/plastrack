import prisma from "@/lib/prisma";

const POINTS_FOR_REPORT = 10;
const POINTS_FOR_FEEDBACK = 10;

export class GameService {
    async awardPointsForReport(firebaseId: string): Promise<void> {
        await prisma.user.update({
            where: { firebaseId },
            data: {
                points: {
                    increment: POINTS_FOR_REPORT,
                },
            },
        });
    }

    async awardPointsForFeedback(firebaseId: string): Promise<void> {
        await prisma.user.update({
            where: { firebaseId },
            data: {
                points: {
                    increment: POINTS_FOR_FEEDBACK,
                },
            },
        });
    }

    async getUserPoints(firebaseId: string): Promise<number> {
        const user = await prisma.user.findUnique({
            where: { firebaseId },
            select: { points: true },
        });
        return user?.points ?? 0;
    }

    async getLeaderboard(page: number = 1, limit: number = 8) {
        const skip = (page - 1) * limit;

        const [users, total] = await Promise.all([
            prisma.user.findMany({
                skip,
                take: limit,
                orderBy: {
                    points: "desc",
                },
                select: {
                    name: true,
                    points: true,
                    profilePicture: true,
                    city: true,
                    state: true,
                },
            }),
            prisma.user.count(),
        ]);

        return {
            users,
            totalPages: Math.ceil(total / limit),
            currentPage: page,
        };
    }

    async getUserRank(firebaseId: string) {
        const currentUser = await prisma.user.findUnique({
            where: { firebaseId },
            select: { points: true },
        });

        if (!currentUser) {
            return null;
        }

        const usersWithHigherScore = await prisma.user.count({
            where: {
                points: {
                    gt: currentUser.points,
                },
            },
        });

        return {
            rank: usersWithHigherScore + 1,
            points: currentUser.points,
        };
    }

    async deductPoints(firebaseId: string, points: number) {
        // Get current user points
        const user = await prisma.user.findUnique({
            where: { firebaseId },
            select: { points: true },
        });

        if (!user) {
            throw new Error("User not found");
        }

        // Ensure user has enough points
        if (user.points < points) {
            throw new Error("User doesn't have enough points");
        }

        // Deduct points
        return await prisma.user.update({
            where: { firebaseId },
            data: {
                points: {
                    decrement: points,
                },
            },
        });
    }
}
