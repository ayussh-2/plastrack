import { Request, Response } from "express";
import { GameService } from "../services/game-service";
import { asyncHandler, handleSuccess, AppError } from "../utils/asyncHandler";

class GameController {
  private gameService: GameService;

  constructor() {
    this.gameService = new GameService();
  }

  getLeaderboard = asyncHandler(async (req: Request, res: Response) => {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 8;

    const leaderboard = await this.gameService.getLeaderboard(page, limit);

    handleSuccess(res, leaderboard, "Leaderboard retrieved successfully", 200, {
      page,
      limit,
    });
  });

  getUserRank = asyncHandler(async (req: Request, res: Response) => {
    const { firebaseId } = req.params;
    const rank = await this.gameService.getUserRank(firebaseId);

    if (!rank) {
      throw new AppError("User not found", 404);
    }

    handleSuccess(res, rank, "User rank retrieved successfully");
  });
}

export const gameController = new GameController();
