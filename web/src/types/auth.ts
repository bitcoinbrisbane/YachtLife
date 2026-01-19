export type UserRole = "admin" | "manager" | "owner";

export interface User {
	id: string;
	email: string;
	name: string;
	role: UserRole;
	phone?: string;
	created_at: string;
}

export interface LoginRequest {
	email: string;
	password: string;
}

export interface LoginResponse {
	token: string;
	user: User;
}

export interface AuthContextType {
	user: User | null;
	token: string | null;
	loading: boolean;
	login: (email: string, password: string) => Promise<void>;
	logout: () => void;
	isAuthenticated: boolean;
}
