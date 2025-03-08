import prisma from "@/lib/prisma";
import { TrashReport, HotspotData } from "../types";

export class TrashService {
    async createReport(data: Omit<TrashReport, "id" | "timestamp">) {
        return await prisma.trashReport.create({
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

    async getHotspotsOptimized(days: number = 30, gridPrecision: number = 4) {
        const roundingFactor = Math.pow(10, gridPrecision);

        return await prisma.$queryRaw`
            SELECT 
                ROUND(latitude::numeric * ${roundingFactor}) / ${roundingFactor} AS "latGroup",
                ROUND(longitude::numeric * ${roundingFactor}) / ${roundingFactor} AS "lngGroup",
                COUNT(*) AS "reportCount",
                AVG(severity) AS "avgSeverity",
                jsonb_agg(
                    jsonb_build_object(
                        'id', id, 
                        'trashType', "trashType", 
                        'severity', severity,
                        'timestamp', timestamp
                    )
                ) AS reports
            FROM "TrashReport"
            WHERE timestamp > NOW() - INTERVAL '${days} day'
            GROUP BY "latGroup", "lngGroup"
            ORDER BY "reportCount" DESC
        `;
    }

    async getReportsByCoordinates(
        latitude: number,
        longitude: number,
        radiusInMeters: number = 100
    ) {
        // Convert radius from meters to approximate decimal degrees
        // This is a simple approximation (1 degree ≈ 111km at equator)
        const radiusDegrees = radiusInMeters / 111000;

        return await prisma.trashReport.findMany({
            where: {
                AND: [
                    {
                        latitude: {
                            gte: latitude - radiusDegrees,
                            lte: latitude + radiusDegrees,
                        },
                    },
                    {
                        longitude: {
                            gte: longitude - radiusDegrees,
                            lte: longitude + radiusDegrees,
                        },
                    },
                ],
            },
        });
    }

    async getReportsInBoundingBox(
        southWestLat: number,
        southWestLng: number,
        northEastLat: number,
        northEastLng: number
    ) {
        return await prisma.trashReport.findMany({
            where: {
                AND: [
                    {
                        latitude: {
                            gte: southWestLat,
                            lte: northEastLat,
                        },
                    },
                    {
                        longitude: {
                            gte: southWestLng,
                            lte: northEastLng,
                        },
                    },
                ],
            },
        });
    }

    async getHotspotsByCoordinates(
        latitude: number,
        longitude: number,
        radiusInKm: number = 5,
        days: number = 30
    ) {
        const radiusDegrees = radiusInKm / 111;

        const daysAgo = new Date();
        daysAgo.setDate(daysAgo.getDate() - days);

        return await prisma.trashReport.findMany({
            where: {
                AND: [
                    {
                        latitude: {
                            gte: latitude - radiusDegrees,
                            lte: latitude + radiusDegrees,
                        },
                    },
                    {
                        longitude: {
                            gte: longitude - radiusDegrees,
                            lte: longitude + radiusDegrees,
                        },
                    },
                    {
                        timestamp: {
                            gte: daysAgo,
                        },
                    },
                ],
            },
        });
    }
}
