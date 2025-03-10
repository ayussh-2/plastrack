import { getGeminiResponse } from "@/lib/gemini";
import { Router } from "express";
const router = Router();

async function getGeminiData(req: any, res: any) {
    try {
        const { prompt } = req.body;
        const response = await getGeminiResponse(prompt);
        res.json({ response });
    } catch (error) {
        console.error("Gemini API error:", error);
    }
}

router.post("/generate", getGeminiData);
export default router;
