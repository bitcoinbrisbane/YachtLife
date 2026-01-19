import {useState, useEffect, useCallback} from 'react';
import api from '../services/api';
import type {LogbookEntry, CreateLogbookEntryRequest} from '../types';

export const useLogbook = () => {
  const [entries, setEntries] = useState<LogbookEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchEntries = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<LogbookEntry[]>('/logbook');
      setEntries(response.data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch logbook entries');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchEntries();
  }, [fetchEntries]);

  const createEntry = async (data: CreateLogbookEntryRequest) => {
    try {
      const response = await api.post<LogbookEntry>('/logbook', data);
      await fetchEntries(); // Refresh the list
      return response.data;
    } catch (err) {
      throw new Error(err instanceof Error ? err.message : 'Failed to create logbook entry');
    }
  };

  return {
    entries,
    loading,
    error,
    refresh: fetchEntries,
    createEntry,
  };
};
