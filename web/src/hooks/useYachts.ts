import { useQuery } from "@tanstack/react-query";
import api from "../services/api";
import type { Yacht } from "../types/yacht";

export const useYachts = () => {
	return useQuery({
		queryKey: ["yachts"],
		queryFn: async () => {
			const response = await api.get<Yacht[]>("/yachts");
			return response.data;
		},
	});
};

export const useYacht = (id: string) => {
	return useQuery({
		queryKey: ["yachts", id],
		queryFn: async () => {
			const response = await api.get<Yacht>(`/yachts/${id}`);
			return response.data;
		},
		enabled: !!id,
	});
};
