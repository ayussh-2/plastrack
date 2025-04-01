import prisma from "@/lib/prisma";
import { GameService } from "./game-service";

export class TreeService {
    private gameService: GameService;

    constructor() {
        this.gameService = new GameService();
    }

    async exchangeTokensForTree(firebaseId: string, tokensToSpend: number) {
        // Verify user has enough tokens
        const userPoints = await this.gameService.getUserPoints(firebaseId);

        if (userPoints < tokensToSpend) {
            return {
                success: false,
                message: "Not enough tokens available",
            };
        }

        // Deduct tokens
        await this.gameService.deductPoints(firebaseId, tokensToSpend);

        // Calculate trees based on exchange rate (1 token = 1 tree in this example)
        const treesPlanted = tokensToSpend;

        // Record virtual tree planting
        const virtualTree = await prisma.virtualTree.create({
            data: {
                firebaseId,
                count: treesPlanted,
                tokensSpent: tokensToSpend,
            },
        });

        // Check if we've reached threshold for real tree planting
        const totalVirtualTrees = await this.getTotalVirtualTrees();
        const shouldPlantRealTree =
            Math.floor(totalVirtualTrees / 100) >
            Math.floor((totalVirtualTrees - treesPlanted) / 100);

        if (shouldPlantRealTree) {
            await this.triggerRealTreePlanting();
            await this.notifyContributors();
            await this.awardBadges();
        }

        return {
            success: true,
            virtualTree,
            treesPlanted,
            totalVirtualTrees,
            message: "Successfully exchanged tokens for virtual trees",
        };
    }

    async getTotalVirtualTrees() {
        const result = await prisma.virtualTree.aggregate({
            _sum: {
                count: true,
            },
        });

        return result._sum.count || 0;
    }

    private async triggerRealTreePlanting() {
        // Create record for real tree planting
        await prisma.realTreePlanting.create({
            data: {
                status: "SCHEDULED",
                treesPlanted: 0, // Will be updated after actual planting
                scheduledDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000), // 2 weeks from now
            },
        });

        // This would trigger notification to NGO partners in a real system
        // For now, we'll just log it
        console.log("Real tree planting triggered!");
    }

    private async notifyContributors() {
        // In a real system, you would query all contributors and send notifications
        // For now, we'll just create notification records
        const contributors = await prisma.virtualTree.findMany({
            select: {
                firebaseId: true,
            },
            distinct: ["firebaseId"],
        });

        for (const contributor of contributors) {
            await prisma.notification.create({
                data: {
                    firebaseId: contributor.firebaseId,
                    type: "TREE_PLANTING_EVENT",
                    message: "You're invited to our tree planting event!",
                    isRead: false,
                },
            });
        }
    }

    private async awardBadges() {
        // Award badges to contributors based on their contribution
        const contributors = await prisma.virtualTree.groupBy({
            by: ["firebaseId"],
            _sum: {
                count: true,
            },
        });

        for (const contributor of contributors) {
            const treeCount = contributor._sum.count || 0;
            let badgeType = null;

            if (treeCount >= 100) badgeType = "FOREST_CREATOR";
            else if (treeCount >= 50) badgeType = "GROVE_PLANTER";
            else if (treeCount >= 10) badgeType = "TREE_ENTHUSIAST";
            else if (treeCount >= 1) badgeType = "SEEDLING_STARTER";

            if (badgeType) {
                await prisma.badge.upsert({
                    where: {
                        firebaseId_type: {
                            firebaseId: contributor.firebaseId,
                            type: badgeType,
                        },
                    },
                    update: {},
                    create: {
                        firebaseId: contributor.firebaseId,
                        type: badgeType,
                        awardedAt: new Date(),
                    },
                });
            }
        }
    }
}
