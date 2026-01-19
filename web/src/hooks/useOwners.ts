import { useQuery } from "@tanstack/react-query";
import api from "../services/api";
import type { Owner } from "../types/owner";

export const useOwners = () => {
	return useQuery({
		queryKey: ["owners"],
		queryFn: async () => {
			const response = await api.get<Owner[]>("/owners");
			return response.data;
		},
	});
};

export const useOwner = (id: string) => {
	return useQuery({
		queryKey: ["owners", id],
		queryFn: async () => {
			const response = await api.get<Owner>(`/owners/${id}`);
			return response.data;
		},
		enabled: !!id,
	});
};
