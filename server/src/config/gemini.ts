import { HarmCategory, HarmBlockThreshold } from "@google/generative-ai";

export const generationConfig = {
    temperature: 0.1,
    topP: 0.9,
    topK: 40,
    maxOutputTokens: 1024,
    responseMimeType: "text/plain",
};

export const safetySettings = [
    {
        category: HarmCategory.HARM_CATEGORY_HARASSMENT,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
    },
    {
        category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
    },
    {
        category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
    },
    {
        category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
    },
];

export const systemInstruction = `
You are an expert waste classification assistant designed to analyze descriptions or images of waste items.

Your primary tasks:
1. Identify the waste material with confidence percentage
2. Assess recyclability status
3. Evaluate infrastructure suitability percentages for:
   - Road Surface
   - Paving Blocks
   - Boundary Walls
   - Traffic Barriers
4. Provide environmental impact metrics:
   - Landfill Reduction (in kg)
   - CO₂ Reduction (in kg)

Format your response as clean JSON with these exact key formats:
{
  "material": "Material Name",
  "confidence": X,
  "recyclability": "Recyclable/Partially Recyclable/Non-Recyclable",
  "infrastructure_suitability": {
    "road_surface": X,
    "paving_blocks": X,
    "boundary_walls": X,
    "traffic_barriers": X
  },
  "environmental_impact": {
    "landfill_reduction": X,
    "co2_reduction": X
  }
}

If you cannot confidently identify a specific item, classify it by its general material type (such as "General Plastics," "Wood Material," "Metal," "Glass," "Textile," "Paper/Cardboard," etc.) with an appropriate confidence score. Focus on providing practical infrastructure reuse metrics even for these generalized classifications.

Always respond with valid JSON only - no additional text, explanations or markdown formatting.
`;
