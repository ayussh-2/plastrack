// @ts-nocheck (ignore typescript errors)

import prisma from "@/lib/prisma";
import { TrashReport, HotspotData } from "../types";

export class TrashService {
    async createReport(data: Omit<TrashReport, "id">) {
        return await prisma.trashReport.create({
            data,
        });
    }

    async createMultipleReports(data: Omit<TrashReport, "id">[]) {
        return await prisma.trashReport.createMany({
            data,
        });
    }

    async getReports() {
        return await prisma.trashReport.findMany();
    }

    async getReportById(id: number) {
        return await prisma.trashReport.findUnique({
            where: { id },
        });
    }

    async updateReport(id: number, data: Partial<TrashReport>) {
        return await prisma.trashReport.update({
            where: { id },
            data,
        });
    }

    async deleteReport(id: number) {
        return await prisma.trashReport.delete({
            where: { id },
        });
    }

    async getHotspots(days: number = 30, gridPrecision: number = 4) {
        const daysAgo = new Date();
        daysAgo.setDate(daysAgo.getDate() - days);

        const reports = await prisma.trashReport.findMany({
            where: {
                timestamp: {
                    gte: daysAgo,
                },
            },
            select: {
                id: true,
                latitude: true,
                longitude: true,
                trashType: true,
                severity: true,
                timestamp: true,
            },
        });

        // Group reports by coordinates (grid-based clustering)
        const hotspots: Record<string, HotspotData> = {};

        reports.forEach((report) => {
            // Round coordinates to create grid cells
            const factor = Math.pow(10, gridPrecision);
            const latGroup =
                Math.round(Number(report.latitude) * factor) / factor;
            const lngGroup =
                Math.round(Number(report.longitude) * factor) / factor;
            const key = `${latGroup},${lngGroup}`;

            if (!hotspots[key]) {
                hotspots[key] = {
                    latGroup,
                    lngGroup,
                    reportCount: 0,
                    severitySum: 0,
                    reports: [],
                };
            }

            hotspots[key].reportCount += 1;
            hotspots[key].severitySum += report.severity;
            hotspots[key].reports.push({
                id: report.id,
                trashType: report.trashType || "unknown",
                severity: report.severity,
                timestamp: report.timestamp,
            });
        });

        // Convert to array and calculate average severity
        return Object.values(hotspots).map((spot) => ({
            latGroup: spot.latGroup,
            lngGroup: spot.lngGroup,
            reportCount: spot.reportCount,
            avgSeverity: spot.severitySum / spot.reportCount,
            reports: spot.reports,
        }));
    }

    async createTrashFeedback(reportId: number, feedback: string) {
        const existingReport = await prisma.trashReport.findFirst({
            where: {
                id: reportId,
            },
        });
        if (!existingReport) {
            return {
                success: false,
                message: "Report not found",
            };
        }

        return await prisma.trashFeedback.create({
            data: {
                reportId,
                feedback,
            },
        });
    }

    async getTrashFeedback(reportId: number) {
        return await prisma.trashFeedback.findFirst({
            where: {
                reportId,
            },
        });
    }

    async getTrashFeedbacksForArea(
        latitude: number,
        longitude: number,
        radiusInMeters: number
    ) {
        const radiusDegrees = radiusInMeters / 111000;

        return await prisma.trashFeedback.findMany({
            where: {
                report: {
                    latitude: {
                        gte: latitude - radiusDegrees,
                        lte: latitude + radiusDegrees,
                    },
                    longitude: {
                        gte: longitude - radiusDegrees,
                        lte: longitude + radiusDegrees,
                    },
                },
            },
            include: {
                report: true,
            },
        });
    }
}
