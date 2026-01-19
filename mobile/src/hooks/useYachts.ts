import {useState, useEffect, useCallback} from 'react';
import api from '../services/api';
import type {Yacht} from '../types';

export const useYachts = () => {
  const [yachts, setYachts] = useState<Yacht[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchYachts = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      console.log('Fetching yachts from API...');
      const response = await api.get<Yacht[]>('/yachts');
      console.log('Yachts fetched successfully:', response.data);
      setYachts(response.data);
    } catch (err) {
      console.error('Error fetching yachts:', err);
      const errorMessage = err instanceof Error ? err.message : 'Failed to fetch yachts';
      console.error('Error message:', errorMessage);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchYachts();
  }, [fetchYachts]);

  return {
    yachts,
    loading,
    error,
    refresh: fetchYachts,
  };
};
