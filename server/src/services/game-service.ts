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
}
