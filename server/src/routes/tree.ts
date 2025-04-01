import { Router } from "express";
import { treeController } from "@/controllers/tree-controller";
import { authMiddleware } from "@/middleware/auth";

const router = Router();

router.post("/exchange", authMiddleware, treeController.exchangeTokensForTree);
router.get("/total", treeController.getTotalVirtualTrees);

export default router;
