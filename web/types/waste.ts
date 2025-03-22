export interface WasteClassificationResponse {
  success: boolean;
  message: string;
  data: {
    error: any;
    material: string;
    confidence: number;
    recyclability: string;
    infrastructure_suitability: {
      road_surface: number;
      paving_blocks: number;
      boundary_walls: number;
      traffic_barriers: number;
    };
    environmental_impact: {
      landfill_reduction: number;
      co2_reduction: number;
    };
  };
}

export interface AnalysisResult {
  error?: string;
  type?: string;
  confidence?: number;
  recyclable?: boolean;
  recyclabilityScore?: number;
  suitability?: Array<{
    purpose: string;
    score: number;
  }>;
  impacts?: {
    landfillReduction: number;
    co2Reduction: number;
  };
}
