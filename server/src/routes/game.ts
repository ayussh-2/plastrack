import { Router } from "express";
import { gameController } from "../controllers/game-controller";

const router = Router();

const { getLeaderboard, getUserRank } = gameController;

router.get("/leaderboard", getLeaderboard);
router.get("/rank/:firebaseId", getUserRank);

export default router;
