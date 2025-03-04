import { Router } from "express";
import { authMiddleware } from "../middleware/auth";
import { userController } from "@/controllers/user-controller";

const router = Router();

router.get("/me", authMiddleware, userController.getMe);
router.get("/", authMiddleware, userController.getAllUsers);
router.get("/:id", authMiddleware, userController.getUserById);
router.post("/", authMiddleware, userController.createUser);

export default router;
