import prisma from "@/lib/prisma";
import { TrashService } from "./trash-service";

export class CleanupService {
    private trashService: TrashService;
    private HOTSPOT_THRESHOLD = 5; // Number of reports to trigger action

    constructor() {
        this.trashService = new TrashService();
    }

    async monitorHotspots() {
        // Get active hotspots
        const hotspots = await this.trashService.getHotspots(30, 4);

        // Filter for hotspots above threshold
        const criticalHotspots = hotspots.filter(
            (hotspot) => hotspot.reportCount >= this.HOTSPOT_THRESHOLD
        );

        // Check for existing cleanup tasks for these hotspots
        for (const hotspot of criticalHotspots) {
            const existingTask = await prisma.cleanupTask.findFirst({
                where: {
                    latitude: hotspot.latGroup,
                    longitude: hotspot.lngGroup,
                    status: {
                        in: ["ASSIGNED", "IN_PROGRESS"],
                    },
                },
            });

            if (!existingTask) {
                // Create new cleanup task
                await this.createCleanupTask(hotspot);
            }
        }

        return {
            monitoredHotspots: hotspots.length,
            criticalHotspots: criticalHotspots.length,
        };
    }

    private async createCleanupTask(hotspot: any) {
        // Find available truck
        const availableTruck = await prisma.truck.findFirst({
            where: {
                status: "AVAILABLE",
            },
        });

        if (!availableTruck) {
            // Log that no trucks are available
            return null;
        }

        // Mark truck as assigned
        await prisma.truck.update({
            where: {
                id: availableTruck.id,
            },
            data: {
                status: "ASSIGNED",
            },
        });

        // Create cleanup task
        return await prisma.cleanupTask.create({
            data: {
                latitude: hotspot.latGroup,
                longitude: hotspot.lngGroup,
                truckId: availableTruck.id,
                reportCount: hotspot.reportCount,
                avgSeverity: hotspot.avgSeverity,
                status: "ASSIGNED",
                reportIds: hotspot.reports.map((r: any) => r.id),
            },
        });
    }

    async getCleanupTasks(status?: string) {
        const where = status ? { status } : {};

        return await prisma.cleanupTask.findMany({
            where,
            include: {
                truck: true,
            },
        });
    }

    async updateCleanupTaskStatus(
        taskId: number,
        status: string,
        materialData?: any
    ) {
        const task = await prisma.cleanupTask.findUnique({
            where: { id: taskId },
        });

        if (!task) {
            return {
                success: false,
                message: "Cleanup task not found",
            };
        }

        // Update task status
        const updatedTask = await prisma.cleanupTask.update({
            where: { id: taskId },
            data: { status },
        });

        // If status is COMPLETED, update truck status and record materials
        if (status === "COMPLETED" && materialData) {
            // Free up the truck
            await prisma.truck.update({
                where: { id: task.truckId },
                data: { status: "AVAILABLE" },
            });

            // Record materials for recycling
            await prisma.recyclingMaterial.create({
                data: {
                    cleanupTaskId: taskId,
                    plasticWeight: materialData.plasticWeight || 0,
                    paperWeight: materialData.paperWeight || 0,
                    glassWeight: materialData.glassWeight || 0,
                    metalWeight: materialData.metalWeight || 0,
                    organicWeight: materialData.organicWeight || 0,
                    otherWeight: materialData.otherWeight || 0,
                    destinationType:
                        materialData.destinationType || "RECYCLING_CENTER",
                },
            });

            // Mark all reports as resolved
            if (task.reportIds && task.reportIds.length > 0) {
                await prisma.trashReport.updateMany({
                    where: {
                        id: {
                            in: task.reportIds,
                        },
                    },
                    data: {
                        resolved: true,
                    },
                });
            }
        }

        return {
            success: true,
            task: updatedTask,
            message: `Cleanup task status updated to ${status}`,
        };
    }
}
