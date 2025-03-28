import prisma from "../lib/prisma";
import { AppError } from "../utils/asyncHandler";

export class ComplaintService {
  async createComplaint(data: {
    latitude: number;
    longitude: number;
    trashType: string;
    severity: number;
    image: string;
    firebaseId: string;
  }) {
    return await prisma.trashReport.create({
      data: {
        latitude: data.latitude,
        longitude: data.longitude,
        trashType: data.trashType,
        severity: data.severity,
        image: data.image,
        user: {
          connect: { firebaseId: data.firebaseId },
        },
      },
    });
  }

  async getUserComplaints(firebaseId: string) {
    return await prisma.trashReport.findMany({
      where: {
        firebaseId,
      },
      orderBy: {
        timestamp: "desc",
      },
    });
  }

  async getComplaintById(id: number) {
    return await prisma.complaint.findUnique({
      where: { id },
      include: {
        report: {
          include: {
            user: {
              select: {
                name: true,
                email: true,
                phone: true,
              },
            },
          },
        },
      },
    });
  }

  async updateComplaint(id: number, data: any) {
    return await prisma.trashReport.update({
      where: { id },
      data,
    });
  }

  async resolveComplaint(id: number, feedback: string) {
    // Create feedback entry
    await prisma.trashFeedback.create({
      data: {
        reportId: id,
        feedback,
      },
    });

    // Update the report
    return await prisma.trashReport.update({
      where: { id },
      data: {
        aiResponse: "Resolved",
      },
    });
  }

  async getComplaintTypes() {
    // For now return hard-coded types since no table exists
    return [
      { id: 1, type: "Garbage Overflow" },
      { id: 2, type: "Illegal Dumping" },
      { id: 3, type: "Missed Collection" },
      { id: 4, type: "Hazardous Waste" },
      { id: 5, type: "Other" },
    ];
  }

  async submitComplaint(reportId: number, complaint: string) {
    // First check if report exists
    const report = await prisma.trashReport.findUnique({
      where: { id: reportId },
    });

    if (!report) {
      throw new AppError("Trash report not found", 404);
    }

    // Create complaint for existing report
    return await prisma.complaint.create({
      data: {
        reportId,
        complaint,
      },
    });
  }

  async getComplaintsByReportId(reportId: number) {
    return await prisma.complaint.findMany({
      where: { reportId },
      orderBy: { timestamp: "desc" },
    });
  }

  async updateComplaintStatus(id: number, status: string) {
    return await prisma.complaint.update({
      where: { id },
      data: { status },
    });
  }

  async getAllComplaints(
    page: number = 1,
    limit: number = 10,
    status?: string
  ) {
    const skip = (page - 1) * limit;

    const where: any = {};
    if (status) {
      where.status = status;
    }

    const [complaints, total] = await Promise.all([
      prisma.complaint.findMany({
        skip,
        take: limit,
        where,
        orderBy: { timestamp: "desc" },
        include: {
          report: {
            include: {
              user: {
                select: {
                  name: true,
                  email: true,
                  phone: true,
                },
              },
            },
          },
        },
      }),
      prisma.complaint.count({ where }),
    ]);

    return {
      complaints,
      pagination: {
        total,
        pages: Math.ceil(total / limit),
        current: page,
        limit,
      },
    };
  }
}
