// @ts-nocheck (ignore typescript errors)

import prisma from "@/lib/prisma";
import { TrashReport, HotspotData } from "../types";
import { cleanJsonResponse, validateFeedback } from "@/utils/validateFeedback";
import { ImageAnnotatorClient } from "@google-cloud/vision";
import { getGeminiResponse } from "@/lib/gemini";
import { GameService } from "./game-service";
import { env } from "@/config";

const client = new ImageAnnotatorClient({
  credentials: env.visionAPI,
});

export class TrashService {
    private gameService: GameService;

    constructor() {
        this.gameService = new GameService();
    }

    async createReport(data: Omit<TrashReport, "id">) {
        const aiResponse = await this.classifyTrash(data);
        const parsedResponse = JSON.parse(aiResponse);
        const report = await prisma.trashReport.create({
            data: {
                ...data,
                aiResponse,
                severity: Number(data.severity),
                trashType: parsedResponse.material || "unknown",
            },
        });

        if (data.firebaseId) {
            await this.gameService.awardPointsForReport(data.firebaseId);
        }

        return { ...parsedResponse, image: report.image, id: report.id };
    }

    async classifyTrash(data: { image: string }) {
        const { image } = data;
        const [result] = await client.labelDetection(image);
        const [safeSearchResult] = await client.safeSearchDetection(image);
        const labels = result.labelAnnotations || [];
        const safeSearch = safeSearchResult.safeSearchAnnotation || {};
        const visionData = {
            labelAnnotations: labels,
            safeSearchAnnotation: safeSearch,
        };
        const geminiResponse = await getGeminiResponse(visionData);
        const strigifiedResponse = cleanJsonResponse(geminiResponse);
        return strigifiedResponse;
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

        const feedbackReview = await validateFeedback(
            existingReport.trashType,
            feedback
        );

        if (!feedbackReview.isValid) {
            return {
                isInvalid: true,
                message:
                    "The feedback you provided seems not correct for the given trash." +
                    feedbackReview.explanation,
            };
        }

        const validFeedback = await prisma.trashFeedback.create({
            data: {
                reportId,
                feedback,
            },
        });

        // Award points for valid feedback
        if (existingReport.firebaseId) {
            await this.gameService.awardPointsForFeedback(
                existingReport.firebaseId
            );
        }

        return {
            isInValid: false,
            feedback: validFeedback,
            message: "Feedback successfully submitted",
        };
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

    async getMyTrashReportsAndFeedbacks(firebaseId: string) {
        const reportsAndFeedbacks = await prisma.trashReport.findMany({
            where: {
                firebaseId,
            },
            include: {
                TrashFeedback: {
                    select: {
                        feedback: true,
                    },
                },
            },
        });

        const transformedReports = reportsAndFeedbacks.map((report) => {
            const feedback =
                report.TrashFeedback && report.TrashFeedback.length > 0
                    ? report.TrashFeedback[0].feedback
                    : null;

            const { TrashFeedback, ...reportData } = report;

            return {
                ...reportData,
                feedback,
            };
        });

        return transformedReports;
    }
}
