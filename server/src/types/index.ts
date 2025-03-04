export interface IUser {
    id: string;
    firebaseId: string;
    email: string;
    name: string | null;
    createdAt: Date;
    updatedAt: Date;
}

export interface PaginationParams {
    page?: number;
    limit?: number;
}
