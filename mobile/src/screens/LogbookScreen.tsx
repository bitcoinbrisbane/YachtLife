import React, {useState} from 'react';
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  RefreshControl,
  TouchableOpacity,
  ActivityIndicator,
  useColorScheme,
} from 'react-native';
import {useLogbook} from '../hooks/useLogbook';
import {CreateLogModal} from '../components/CreateLogModal';
import {format} from 'date-fns';
import type {LogbookEntry} from '../types';

const getEntryTypeColor = (type: string) => {
  switch (type) {
    case 'departure':
      return '#2E7D32';
    case 'return':
      return '#0277BD';
    case 'fuel':
      return '#ED6C02';
    case 'maintenance':
      return '#9C27B0';
    case 'incident':
      return '#D32F2F';
    default:
      return '#757575';
  }
};

const getEntryTypeLabel = (type: string) => {
  switch (type) {
    case 'departure':
      return 'Departure';
    case 'return':
      return 'Return';
    case 'fuel':
      return 'Fuel';
    case 'maintenance':
      return 'Maintenance';
    case 'incident':
      return 'Incident';
    default:
      return 'General';
  }
};

export const LogbookScreen = () => {
  const {entries, loading, error, refresh} = useLogbook();
  const [modalVisible, setModalVisible] = useState(false);
  const isDarkMode = useColorScheme() === 'dark';

  const theme = {
    bg: isDarkMode ? '#1a1a1a' : '#f5f5f5',
    cardBg: isDarkMode ? '#2a2a2a' : '#ffffff',
    text: isDarkMode ? '#ffffff' : '#000000',
    textSecondary: isDarkMode ? '#aaaaaa' : '#666666',
    border: isDarkMode ? '#3a3a3a' : '#e0e0e0',
  };

  const renderEntry = ({item}: {item: LogbookEntry}) => (
    <View style={[styles.card, {backgroundColor: theme.cardBg, borderColor: theme.border}]}>
      <View style={styles.cardHeader}>
        <View
          style={[
            styles.typeIndicator,
            {backgroundColor: `${getEntryTypeColor(item.entry_type)}20`},
          ]}>
          <Text
            style={[
              styles.typeText,
              {color: getEntryTypeColor(item.entry_type)},
            ]}>
            {getEntryTypeLabel(item.entry_type)}
          </Text>
        </View>
        <Text style={[styles.dateText, {color: theme.textSecondary}]}>
          {format(new Date(item.created_at), 'MMM dd, yyyy HH:mm')}
        </Text>
      </View>

      <Text style={[styles.vesselName, {color: theme.text}]}>
        {item.yacht?.name || 'Unknown Vessel'}
      </Text>

      {item.notes && (
        <Text style={[styles.notes, {color: theme.textSecondary}]}>
          {item.notes}
        </Text>
      )}

      <View style={styles.details}>
        {item.fuel_liters && (
          <View style={[styles.detailChip, {borderColor: theme.border}]}>
            <Text style={[styles.detailText, {color: theme.textSecondary}]}>
              {item.fuel_liters}L fuel
            </Text>
          </View>
        )}
        {item.fuel_cost && (
          <View style={[styles.detailChip, {borderColor: theme.border}]}>
            <Text style={[styles.detailText, {color: theme.textSecondary}]}>
              ${item.fuel_cost}
            </Text>
          </View>
        )}
        {item.hours_operated && (
          <View style={[styles.detailChip, {borderColor: theme.border}]}>
            <Text style={[styles.detailText, {color: theme.textSecondary}]}>
              {item.hours_operated}h
            </Text>
          </View>
        )}
      </View>

      {item.user && (
        <Text style={[styles.userText, {color: theme.textSecondary}]}>
          Logged by {item.user.first_name} {item.user.last_name}
        </Text>
      )}
    </View>
  );

  if (error) {
    return (
      <View style={[styles.container, {backgroundColor: theme.bg}]}>
        <Text style={[styles.errorText, {color: '#D32F2F'}]}>{error}</Text>
        <TouchableOpacity style={styles.retryButton} onPress={refresh}>
          <Text style={styles.retryButtonText}>Retry</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={[styles.container, {backgroundColor: theme.bg}]}>
      <View style={styles.header}>
        <View>
          <Text style={[styles.title, {color: theme.text}]}>Logbook</Text>
          <Text style={[styles.subtitle, {color: theme.textSecondary}]}>
            {entries.length} {entries.length === 1 ? 'entry' : 'entries'}
          </Text>
        </View>
        <TouchableOpacity
          style={styles.createButton}
          onPress={() => setModalVisible(true)}>
          <Text style={styles.createButtonText}>+ New Log</Text>
        </TouchableOpacity>
      </View>

      {loading && entries.length === 0 ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#1976D2" />
        </View>
      ) : (
        <FlatList
          data={entries}
          renderItem={renderEntry}
          keyExtractor={item => item.id}
          refreshControl={
            <RefreshControl refreshing={loading} onRefresh={refresh} />
          }
          contentContainerStyle={styles.listContent}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Text style={[styles.emptyText, {color: theme.textSecondary}]}>
                No logbook entries yet
              </Text>
              <Text style={[styles.emptySubtext, {color: theme.textSecondary}]}>
                Create your first log entry
              </Text>
            </View>
          }
        />
      )}

      <CreateLogModal
        visible={modalVisible}
        onClose={() => setModalVisible(false)}
        onSuccess={() => {
          setModalVisible(false);
          refresh();
        }}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    paddingTop: 60,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
  },
  subtitle: {
    fontSize: 14,
    marginTop: 4,
  },
  createButton: {
    backgroundColor: '#1976D2',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
  },
  createButtonText: {
    color: '#ffffff',
    fontWeight: '600',
    fontSize: 14,
  },
  listContent: {
    padding: 16,
    paddingTop: 8,
  },
  card: {
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  typeIndicator: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 6,
  },
  typeText: {
    fontSize: 12,
    fontWeight: '600',
  },
  dateText: {
    fontSize: 12,
  },
  vesselName: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
  },
  notes: {
    fontSize: 14,
    marginBottom: 12,
    lineHeight: 20,
  },
  details: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 12,
  },
  detailChip: {
    borderWidth: 1,
    borderRadius: 6,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  detailText: {
    fontSize: 12,
  },
  userText: {
    fontSize: 12,
    fontStyle: 'italic',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorText: {
    fontSize: 16,
    textAlign: 'center',
    marginTop: 100,
    paddingHorizontal: 32,
  },
  retryButton: {
    backgroundColor: '#1976D2',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
    marginTop: 16,
    alignSelf: 'center',
  },
  retryButtonText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  emptyContainer: {
    paddingVertical: 60,
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
  },
});
