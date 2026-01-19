import { createContext, useContext, useState, useEffect } from "react";
import type { ReactNode } from "react";
import api from "../services/api";
import type { User, AuthContextType, LoginResponse } from "../types/auth";

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
	children: ReactNode;
}

export const AuthProvider = ({ children }: AuthProviderProps) => {
	const [user, setUser] = useState<User | null>(null);
	const [token, setToken] = useState<string | null>(null);
	const [loading, setLoading] = useState(true);

	// Load user from localStorage on mount
	useEffect(() => {
		const storedToken = localStorage.getItem("auth_token");
		const storedUser = localStorage.getItem("user");

		if (storedToken && storedUser) {
			setToken(storedToken);
			setUser(JSON.parse(storedUser));
		}
		setLoading(false);
	}, []);

	const login = async (email: string, password: string) => {
		try {
			const response = await api.post<LoginResponse>("/auth/login", {
				email,
				password,
			});

			const { token: newToken, user: newUser } = response.data;

			// Save to localStorage
			localStorage.setItem("auth_token", newToken);
			localStorage.setItem("user", JSON.stringify(newUser));

			// Update state
			setToken(newToken);
			setUser(newUser);
		} catch (error) {
			console.error("Login failed:", error);
			throw error;
		}
	};

	const logout = () => {
		// Clear localStorage
		localStorage.removeItem("auth_token");
		localStorage.removeItem("user");

		// Clear state
		setToken(null);
		setUser(null);
	};

	const value: AuthContextType = {
		user,
		token,
		loading,
		login,
		logout,
		isAuthenticated: !!token && !!user,
	};

	return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

// Custom hook to use auth context
export const useAuth = () => {
	const context = useContext(AuthContext);
	if (context === undefined) {
		throw new Error("useAuth must be used within an AuthProvider");
	}
	return context;
};
