export interface IUser {
    id: string;
    firebaseId: string;
    email: string;
    name: string | null;
    phone: string | null;
    city: string | null;
    state: string | null;
    createdAt: Date;
    updatedAt: Date;
}

export interface PaginationParams {
    page?: number;
    limit?: number;
}

export type TrashReport = {
    id: number;
    latitude: number;
    longitude: number;
    trashType?: string;
    severity: number;
    timestamp: Date;
    userId?: string;
};
export interface HotspotData {
    latGroup: number;
    lngGroup: number;
    reportCount: number;
    severitySum: number;
    reports: {
        id: number;
        trashType: string;
        severity: number;
        timestamp: Date;
    }[];
}
