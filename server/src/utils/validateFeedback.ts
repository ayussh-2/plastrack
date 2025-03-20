import { getGeminiResponse } from "@/lib/gemini";

async function validateFeedback(
    originalClassification: string,
    userFeedback: string,
    imageData?: any
): Promise<{ isValid: boolean; confidence: number; explanation: string }> {
    try {
        const validationPrompt = `
I need to validate user feedback about waste classification. 

Original AI Classification: "${originalClassification}"

User Feedback: "${userFeedback}"

Is the user's feedback accurate, reasonable, and helpful for waste classification? 
Provide your assessment in the following JSON format only, without any additional text:
{
  "isValid": true/false,
  "confidence": [number between 0-100],
  "explanation": "Brief explanation of why the feedback is valid or invalid"
}
`;

        let validationResponse = await getGeminiResponse(validationPrompt);

        try {
            validationResponse = cleanJsonResponse(validationResponse);

            const result = JSON.parse(validationResponse);
            return {
                isValid: result.isValid,
                confidence: result.confidence,
                explanation: result.explanation,
            };
        } catch (parseError) {
            console.error("Failed to parse validation response:", parseError);
            console.error("Raw response:", validationResponse);

            return {
                isValid:
                    validationResponse.toLowerCase().includes("valid") ||
                    validationResponse.toLowerCase().includes("accurate"),
                confidence: 60,
                explanation:
                    "Validation response could not be parsed properly.",
            };
        }
    } catch (error) {
        console.error("Feedback validation error:", error);
        throw new Error(`Failed to validate feedback: ${error}`);
    }
}

function cleanJsonResponse(response: string): string {
    let cleaned = response.replace(/```json\s*/g, "").replace(/```\s*$/g, "");

    cleaned = cleaned.replace(/```\s*/g, "");

    cleaned = cleaned.trim();

    const startIndex = cleaned.indexOf("{");
    const endIndex = cleaned.lastIndexOf("}");

    if (startIndex !== -1 && endIndex !== -1 && endIndex > startIndex) {
        cleaned = cleaned.substring(startIndex, endIndex + 1);
    }

    return cleaned;
}

export { validateFeedback,cleanJsonResponse };
