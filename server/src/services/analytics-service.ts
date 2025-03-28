import  prisma  from "../lib/prisma";

export class AnalyticsService {
  async getCollectionStatistics(period: 'day' | 'week' | 'month' = 'month') {
    let startDate = new Date();
    
    if (period === 'day') {
      startDate.setDate(startDate.getDate() - 1);
    } else if (period === 'week') {
      startDate.setDate(startDate.getDate() - 7);
    } else {
      startDate.setMonth(startDate.getMonth() - 1);
    }

    const reports = await prisma.trashReport.findMany({
      where: {
        timestamp: {
          gte: startDate
        }
      },
      include: {
        user: {
          select: {
            city: true,
            state: true
          }
        }
      }
    });

    // Group by trash type
    const byTrashType = reports.reduce((acc, report) => {
      const type = report.trashType || 'Unspecified';
      acc[type] = (acc[type] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    // Group by area (city)
    const byArea = reports.reduce((acc, report) => {
      const area = report.user?.city || 'Unknown';
      acc[area] = (acc[area] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    // Group by severity
    const bySeverity = reports.reduce((acc, report) => {
      const severity = report.severity.toString();
      acc[severity] = (acc[severity] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    return {
      totalReports: reports.length,
      byTrashType,
      byArea,
      bySeverity
    };
  }

  async getComplaintStatistics(period: 'day' | 'week' | 'month' = 'month') {
    let startDate = new Date();
    
    if (period === 'day') {
      startDate.setDate(startDate.getDate() - 1);
    } else if (period === 'week') {
      startDate.setDate(startDate.getDate() - 7);
    } else {
      startDate.setMonth(startDate.getMonth() - 1);
    }

    const [reports, feedback] = await Promise.all([
      prisma.trashReport.findMany({
        where: {
          timestamp: {
            gte: startDate
          }
        }
      }),
      prisma.trashFeedback.findMany({
        where: {
          timestamp: {
            gte: startDate
          }
        }
      })
    ]);

    const totalReports = reports.length;
    const resolvedReports = reports.filter(r => r.aiResponse !== null).length;
    const pendingReports = totalReports - resolvedReports;
    const totalFeedback = feedback.length;

    // Get trend data (reports per day)
    const trend = reports.reduce((acc, report) => {
      const date = new Date(report.timestamp);
      const dateKey = `${date.getMonth()+1}/${date.getDate()}`;
      acc[dateKey] = (acc[dateKey] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    return {
      total: totalReports,
      resolved: resolvedReports,
      pending: pendingReports,
      feedback: totalFeedback,
      resolution_rate: totalReports > 0 
        ? (resolvedReports / totalReports * 100).toFixed(2) 
        : 0,
      trend
    };
  }

  async getWasteSegregationData() {
    // Since the schema doesn't have specific waste segregation data,
    // we'll create an approximation based on trash types
    const reports = await prisma.trashReport.findMany();
    
    // Count reports by type
    const byType = reports.reduce((acc, report) => {
      const type = report.trashType || 'Unspecified';
      acc[type] = (acc[type] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);
    
    // Estimate segregation rate (placeholder logic)
    const total = reports.length;
    const segregatedCount = reports.filter(r => r.trashType !== null).length;
    const segregationRate = total > 0 ? (segregatedCount / total * 100).toFixed(1) : '0';
    
    return {
      segregationRate: `${segregationRate}%`,
      byType
    };
  }

  async getAreaAnalytics() {
    // Get all city/state combinations
    const areas = await prisma.user.findMany({
      select: {
        city: true,
        state: true
      },
      distinct: ['city', 'state']
    });
    
    // Get detailed analytics for each area
    const areaStats = await Promise.all(
      areas.map(async (area) => {
        const [totalReports, resolvedReports, totalUsers] = await Promise.all([
          prisma.trashReport.count({
            where: {
              user: {
                city: area.city,
                state: area.state
              }
            }
          }),
          prisma.trashReport.count({
            where: {
              aiResponse: { not: null },
              user: {
                city: area.city,
                state: area.state
              }
            }
          }),
          prisma.user.count({
            where: {
              city: area.city,
              state: area.state
            }
          })
        ]);
        
        return {
          city: area.city,
          state: area.state,
          totalReports,
          resolvedReports,
          pendingReports: totalReports - resolvedReports,
          totalUsers,
          resolution_rate: totalReports > 0 
            ? (resolvedReports / totalReports * 100).toFixed(1) 
            : '0'
        };
      })
    );
    
    return areaStats;
  }
}