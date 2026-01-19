import axios from "axios";
import { Platform } from "react-native";

// For iOS simulator, localhost works fine
// For Android emulator, use 10.0.2.2 instead of localhost
const getApiBaseUrl = () => {
  if (__DEV__) {
    return Platform.OS === 'android'
      ? 'http://10.0.2.2:8080/api/v1'
      : 'http://localhost:8080/api/v1';
  }
  // Production API URL would go here
  return 'https://api.yachtlife.com/api/v1';
};

const API_BASE_URL = getApiBaseUrl();

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
		console.log(`[API] ${config.method?.toUpperCase()} ${config.baseURL}${config.url}`);
		// TODO: Get token from secure storage (e.g., AsyncStorage or Keychain)
		// const token = await SecureStore.getItemAsync('auth_token');
		// TEMPORARY: Hardcoded token for testing
		const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiM2MyOGFjZDAtMWI3OC00MTZjLWJiYzQtOTg5YzVkZmFiZmUyIiwiZW1haWwiOiJhZG1pbkB5YWNodGxpZmUuY29tIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzY4ODc3MzE3LCJuYmYiOjE3Njg3OTA5MTcsImlhdCI6MTc2ODc5MDkxN30.GZI9Pp3dtg529eeuJ1N9bBvB0XplVCWmG2sM6YMjx_E';
		if (token) {
		  config.headers.Authorization = `Bearer ${token}`;
		}
		return config;
	},
	(error) => {
		console.error('[API] Request error:', error);
		return Promise.reject(error);
	},
);

// Response interceptor
api.interceptors.response.use(
	(response) => {
		console.log(`[API] Response ${response.status} from ${response.config.url}`);
		return response;
	},
	async (error) => {
		console.error('[API] Response error:', {
			message: error.message,
			code: error.code,
			status: error.response?.status,
			data: error.response?.data,
			url: error.config?.url,
		});
		if (error.response?.status === 401) {
			// TODO: Handle unauthorized - clear token and navigate to login
			// await SecureStore.deleteItemAsync('auth_token');
			// NavigationService.navigate('Login');
		}
		return Promise.reject(error);
	},
);

export default api;
