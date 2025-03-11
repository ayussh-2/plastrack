import { GoogleGenerativeAI } from "@google/generative-ai";
import {
    generationConfig,
    safetySettings,
    systemInstruction,
} from "@/config/gemini";
import { env } from "@/config";

const genAI = new GoogleGenerativeAI(env.geminiKey!);

/**
 * Gets a response from Gemini based on image analysis data from Google Cloud Vision API
 * @param input - String prompt or Google Cloud Vision API response object
 * @returns Promise with the generated classification response
 */
async function getGeminiResponse(input: string | any) {
    try {
        let prompt = "";

        if (typeof input === "string") {
            if (!input) {
                throw new Error("Prompt is required");
            }
            prompt = input;
        } else {
            // If input is Google Cloud Vision API response data
            // Extract relevant information for waste classification
            prompt =
                "Analyze this waste material based on the following image data:\n\n";

            // Extract label annotations (what objects were detected)
            if (input.labelAnnotations && input.labelAnnotations.length > 0) {
                prompt += "Detected objects:\n";
                input.labelAnnotations.forEach((label: any) => {
                    prompt += `- ${label.description} (confidence: ${Math.round(
                        label.score * 100
                    )}%)\n`;
                });
                prompt += "\n";
            }

            // Extract localized object annotations (objects with positions)
            if (
                input.localizedObjectAnnotations &&
                input.localizedObjectAnnotations.length > 0
            ) {
                prompt += "Detected objects with positions:\n";
                input.localizedObjectAnnotations.forEach((obj: any) => {
                    prompt += `- ${obj.name} (confidence: ${Math.round(
                        obj.score * 100
                    )}%)\n`;
                });
                prompt += "\n";
            }

            // Add text found in the image
            if (input.fullTextAnnotation && input.fullTextAnnotation.text) {
                prompt += `Text found in image: "${input.fullTextAnnotation.text}"\n\n`;
            }

            // Add information about dominant colors
            if (input.imagePropertiesAnnotation?.dominantColors?.colors) {
                prompt += "Dominant colors:\n";
                const colors =
                    input.imagePropertiesAnnotation.dominantColors.colors;
                for (let i = 0; i < Math.min(3, colors.length); i++) {
                    const color = colors[i];
                    prompt += `- ${color.hex} (${color.percentRounded}%)\n`;
                }
                prompt += "\n";
            }

            prompt +=
                "Based on this information, classify the waste item according to the required format.";
        }

        const parts = [{ text: prompt }];

        const model = genAI.getGenerativeModel({
            model: "gemini-1.5-flash",
            systemInstruction: systemInstruction,
            generationConfig,
            safetySettings,
        });

        let attempts = 0;
        const maxAttempts = 6;
        let result: any = null;

        while (attempts < maxAttempts) {
            try {
                result = await model.generateContent({
                    contents: [{ role: "user", parts: parts || [] }],
                    safetySettings,
                    generationConfig,
                });

                if (result.response) {
                    break;
                }
            } catch (error: any) {
                console.log(
                    `Attempt ${attempts + 1} failed:`,
                    error.message || error
                );

                if (error.status === 429) {
                    const retryAfter = Math.pow(2, attempts) * 2000;
                    console.log(`Retrying in ${retryAfter / 1000} seconds...`);
                    await new Promise((resolve) =>
                        setTimeout(resolve, retryAfter)
                    );
                } else {
                    throw error;
                }
            }

            attempts++;
        }

        if (!result || !result.response) {
            throw new Error(
                "Max attempts exceeded or no response from the server"
            );
        }

        return result.response.text();
    } catch (e: any) {
        console.error("Gemini API error:", e);
        const errorDetails = e.toString();
        throw new Error(`Failed to get AI response: ${errorDetails}`);
    }
}

export { getGeminiResponse };
