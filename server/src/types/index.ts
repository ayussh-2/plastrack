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
