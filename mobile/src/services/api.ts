import axios from "axios";

const API_BASE_URL = process.env.API_URL || "http://localhost:8080/api/v1";

// Create axios instance
const api = axios.create({
	baseURL: API_BASE_URL,
	timeout: 10000,
	headers: {
		"Content-Type": "application/json",
	},
});

// Request interceptor - add auth token
api.interceptors.request.use(
	async (config) => {
		// TODO: Get token from secure storage (e.g., AsyncStorage or Keychain)
		// const token = await SecureStore.getItemAsync('auth_token');
		// if (token) {
		//   config.headers.Authorization = `Bearer ${token}`;
		// }
		return config;
	},
	(error) => {
		return Promise.reject(error);
	},
);

// Response interceptor
api.interceptors.response.use(
	(response) => response,
	async (error) => {
		if (error.response?.status === 401) {
			// TODO: Handle unauthorized - clear token and navigate to login
			// await SecureStore.deleteItemAsync('auth_token');
			// NavigationService.navigate('Login');
		}
		return Promise.reject(error);
	},
);

export default api;
