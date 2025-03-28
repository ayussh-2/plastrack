import prisma from "../lib/prisma";

export class AdminService {
  async getDashboardStats() {
    const [totalReports, resolvedReports, totalUsers, recentReports] =
      await Promise.all([
        prisma.trashReport.count(),
        prisma.trashReport.count({
          where: {
            aiResponse: {
              not: null,
            },
          },
        }),
        prisma.user.count(),
        prisma.trashReport.findMany({
          take: 5,
          orderBy: { timestamp: "desc" },
          include: { user: { select: { name: true } } },
        }),
      ]);

    return {
      reports: {
        total: totalReports,
        resolved: resolvedReports,
        pending: totalReports - resolvedReports,
        resolution_rate:
          totalReports > 0
            ? ((resolvedReports / totalReports) * 100).toFixed(2)
            : 0,
      },
      users: totalUsers,
      recentReports,
    };
  }

  async getAllComplaints(
    page: number = 1,
    limit: number = 10,
    status?: string
  ) {
    const skip = (page - 1) * limit;

    const where: any = {};
    if (status === "resolved") {
      where.aiResponse = { not: null };
    } else if (status === "pending") {
      where.aiResponse = null;
    }

    const [reports, total] = await Promise.all([
      prisma.trashReport.findMany({
        skip,
        take: limit,
        where,
        orderBy: { timestamp: "desc" },
        include: {
          user: {
            select: {
              name: true,
              email: true,
              phone: true,
            },
          },
          TrashFeedback: true,
        },
      }),
      prisma.trashReport.count({ where }),
    ]);

    return {
      reports,
      pagination: {
        total,
        pages: Math.ceil(total / limit),
        current: page,
        limit,
      },
    };
  }

  async updateComplaintStatus(id: number, feedback: string) {
    // Create feedback entry for this report
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
        aiResponse: "Manually resolved by admin",
      },
    });
  }

  async getServiceAreas() {
    // Get all city/state combinations from users
    const areas = await prisma.user.findMany({
      select: {
        city: true,
        state: true,
      },
      distinct: ["city", "state"],
    });

    // Get report counts for each area
    const areasWithCounts = await Promise.all(
      areas.map(async (area) => {
        const count = await prisma.trashReport.count({
          where: {
            user: {
              city: area.city,
              state: area.state,
            },
          },
        });

        return {
          ...area,
          reportCount: count,
        };
      })
    );

    return areasWithCounts;
  }
}
