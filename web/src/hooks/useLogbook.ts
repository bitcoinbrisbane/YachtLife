import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import api from "../services/api";
import type { LogbookEntry, CreateLogbookEntryRequest } from "../types/logbook";

export const useLogbookEntries = (filters?: {
	yacht_id?: string;
	user_id?: string;
	entry_type?: string;
}) => {
	const params = new URLSearchParams();
	if (filters?.yacht_id) params.append("yacht_id", filters.yacht_id);
	if (filters?.user_id) params.append("user_id", filters.user_id);
	if (filters?.entry_type) params.append("entry_type", filters.entry_type);

	const queryString = params.toString();

	return useQuery({
		queryKey: ["logbook", filters],
		queryFn: async () => {
			const response = await api.get<LogbookEntry[]>(
				`/logbook${queryString ? `?${queryString}` : ""}`
			);
			return response.data;
		},
	});
};

export const useLogbookEntry = (id: string) => {
	return useQuery({
		queryKey: ["logbook", id],
		queryFn: async () => {
			const response = await api.get<LogbookEntry>(`/logbook/${id}`);
			return response.data;
		},
		enabled: !!id,
	});
};

export const useCreateLogbookEntry = () => {
	const queryClient = useQueryClient();

	return useMutation({
		mutationFn: async (data: CreateLogbookEntryRequest) => {
			const response = await api.post<LogbookEntry>("/logbook", data);
			return response.data;
		},
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["logbook"] });
		},
	});
};
