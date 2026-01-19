import React, {useState} from 'react';
import {
  Modal,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  useColorScheme,
  Alert,
} from 'react-native';
import {useYachts} from '../hooks/useYachts';
import {useLogbook} from '../hooks/useLogbook';
import type {LogbookEntryType} from '../types';

interface CreateLogModalProps {
  visible: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

const ENTRY_TYPES: {value: LogbookEntryType; label: string}[] = [
  {value: 'fuel', label: 'Fuel'},
  {value: 'maintenance', label: 'Maintenance'},
  {value: 'incident', label: 'Incident'},
  {value: 'general', label: 'General'},
];

export const CreateLogModal: React.FC<CreateLogModalProps> = ({
  visible,
  onClose,
  onSuccess,
}) => {
  const {yachts, loading: yachtsLoading, error: yachtsError} = useYachts();
  const {createEntry} = useLogbook();
  const isDarkMode = useColorScheme() === 'dark';

  const [selectedYacht, setSelectedYacht] = useState<string>('');
  const [entryType, setEntryType] = useState<LogbookEntryType | ''>('');
  const [fuelLiters, setFuelLiters] = useState('');
  const [fuelCost, setFuelCost] = useState('');
  const [hoursOperated, setHoursOperated] = useState('');
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const theme = {
    bg: isDarkMode ? '#1a1a1a' : '#ffffff',
    cardBg: isDarkMode ? '#2a2a2a' : '#f5f5f5',
    text: isDarkMode ? '#ffffff' : '#000000',
    textSecondary: isDarkMode ? '#aaaaaa' : '#666666',
    border: isDarkMode ? '#3a3a3a' : '#e0e0e0',
    inputBg: isDarkMode ? '#2a2a2a' : '#ffffff',
  };

  const resetForm = () => {
    setSelectedYacht('');
    setEntryType('');
    setFuelLiters('');
    setFuelCost('');
    setHoursOperated('');
    setNotes('');
  };

  const handleSubmit = async () => {
    if (!selectedYacht) {
      Alert.alert('Error', 'Please select a vessel');
      return;
    }

    try {
      setSubmitting(true);
      await createEntry({
        yacht_id: selectedYacht,
        entry_type: entryType || undefined,
        fuel_liters: fuelLiters ? parseFloat(fuelLiters) : undefined,
        fuel_cost: fuelCost ? parseFloat(fuelCost) : undefined,
        hours_operated: hoursOperated ? parseFloat(hoursOperated) : undefined,
        notes: notes || undefined,
      });
      resetForm();
      onSuccess();
      Alert.alert('Success', 'Log entry created successfully');
    } catch (error) {
      Alert.alert('Error', error instanceof Error ? error.message : 'Failed to create log entry');
    } finally {
      setSubmitting(false);
    }
  };

  const handleClose = () => {
    if (!submitting) {
      resetForm();
      onClose();
    }
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent
      onRequestClose={handleClose}>
      <View style={styles.modalOverlay}>
        <View style={[styles.modalContent, {backgroundColor: theme.bg}]}>
          <View style={styles.modalHeader}>
            <Text style={[styles.modalTitle, {color: theme.text}]}>
              Create Log Entry
            </Text>
            <TouchableOpacity onPress={handleClose} disabled={submitting}>
              <Text style={styles.closeButton}>✕</Text>
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.formContainer}>
            <Text style={[styles.label, {color: theme.text}]}>
              Vessel <Text style={{color: '#D32F2F'}}>*</Text>
            </Text>
            {yachtsLoading ? (
              <ActivityIndicator />
            ) : yachtsError ? (
              <View style={styles.errorContainer}>
                <Text style={styles.errorText}>{yachtsError}</Text>
                <Text style={[styles.errorHelperText, {color: theme.textSecondary}]}>
                  Make sure the backend is running at http://localhost:8080
                </Text>
              </View>
            ) : yachts.length === 0 ? (
              <Text style={[styles.emptyText, {color: theme.textSecondary}]}>
                No vessels available
              </Text>
            ) : (
              <ScrollView
                horizontal
                showsHorizontalScrollIndicator={false}
                style={styles.vesselScroll}>
                {yachts.map(yacht => (
                  <TouchableOpacity
                    key={yacht.id}
                    style={[
                      styles.vesselChip,
                      {
                        backgroundColor:
                          selectedYacht === yacht.id ? '#1976D2' : theme.cardBg,
                        borderColor: theme.border,
                      },
                    ]}
                    onPress={() => setSelectedYacht(yacht.id)}>
                    <Text
                      style={[
                        styles.vesselChipText,
                        {
                          color:
                            selectedYacht === yacht.id
                              ? '#ffffff'
                              : theme.text,
                        },
                      ]}>
                      {yacht.name}
                    </Text>
                  </TouchableOpacity>
                ))}
              </ScrollView>
            )}

            <Text style={[styles.label, {color: theme.text}]}>
              Entry Type
            </Text>
            <Text style={[styles.helperText, {color: theme.textSecondary}]}>
              Leave blank for automatic detection
            </Text>
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              style={styles.typeScroll}>
              <TouchableOpacity
                style={[
                  styles.typeChip,
                  {
                    backgroundColor: entryType === '' ? '#1976D2' : theme.cardBg,
                    borderColor: theme.border,
                  },
                ]}
                onPress={() => setEntryType('')}>
                <Text
                  style={[
                    styles.typeChipText,
                    {color: entryType === '' ? '#ffffff' : theme.text},
                  ]}>
                  Auto-detect
                </Text>
              </TouchableOpacity>
              {ENTRY_TYPES.map(type => (
                <TouchableOpacity
                  key={type.value}
                  style={[
                    styles.typeChip,
                    {
                      backgroundColor:
                        entryType === type.value ? '#1976D2' : theme.cardBg,
                      borderColor: theme.border,
                    },
                  ]}
                  onPress={() => setEntryType(type.value)}>
                  <Text
                    style={[
                      styles.typeChipText,
                      {
                        color:
                          entryType === type.value ? '#ffffff' : theme.text,
                      },
                    ]}>
                    {type.label}
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>

            <Text style={[styles.label, {color: theme.text}]}>
              Fuel (Liters)
            </Text>
            <TextInput
              style={[
                styles.input,
                {
                  backgroundColor: theme.inputBg,
                  borderColor: theme.border,
                  color: theme.text,
                },
              ]}
              keyboardType="decimal-pad"
              placeholder="0.0"
              placeholderTextColor={theme.textSecondary}
              value={fuelLiters}
              onChangeText={setFuelLiters}
            />

            <Text style={[styles.label, {color: theme.text}]}>
              Fuel Cost ($)
            </Text>
            <TextInput
              style={[
                styles.input,
                {
                  backgroundColor: theme.inputBg,
                  borderColor: theme.border,
                  color: theme.text,
                },
              ]}
              keyboardType="decimal-pad"
              placeholder="0.00"
              placeholderTextColor={theme.textSecondary}
              value={fuelCost}
              onChangeText={setFuelCost}
            />

            <Text style={[styles.label, {color: theme.text}]}>
              Hours Operated
            </Text>
            <TextInput
              style={[
                styles.input,
                {
                  backgroundColor: theme.inputBg,
                  borderColor: theme.border,
                  color: theme.text,
                },
              ]}
              keyboardType="decimal-pad"
              placeholder="0.0"
              placeholderTextColor={theme.textSecondary}
              value={hoursOperated}
              onChangeText={setHoursOperated}
            />

            <Text style={[styles.label, {color: theme.text}]}>Notes</Text>
            <TextInput
              style={[
                styles.input,
                styles.textArea,
                {
                  backgroundColor: theme.inputBg,
                  borderColor: theme.border,
                  color: theme.text,
                },
              ]}
              multiline
              numberOfLines={4}
              placeholder="Add notes..."
              placeholderTextColor={theme.textSecondary}
              value={notes}
              onChangeText={setNotes}
            />
          </ScrollView>

          <View style={styles.modalFooter}>
            <TouchableOpacity
              style={[styles.button, styles.cancelButton]}
              onPress={handleClose}
              disabled={submitting}>
              <Text style={styles.cancelButtonText}>Cancel</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[
                styles.button,
                styles.submitButton,
                submitting && styles.submitButtonDisabled,
              ]}
              onPress={handleSubmit}
              disabled={submitting}>
              {submitting ? (
                <ActivityIndicator color="#ffffff" />
              ) : (
                <Text style={styles.submitButtonText}>Create</Text>
              )}
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    maxHeight: '90%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  closeButton: {
    fontSize: 24,
    color: '#666666',
  },
  formContainer: {
    padding: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    marginTop: 16,
    marginBottom: 8,
  },
  helperText: {
    fontSize: 12,
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  textArea: {
    height: 100,
    textAlignVertical: 'top',
  },
  vesselScroll: {
    marginBottom: 8,
  },
  vesselChip: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
    marginRight: 8,
    borderWidth: 1,
  },
  vesselChipText: {
    fontSize: 14,
    fontWeight: '500',
  },
  typeScroll: {
    marginBottom: 8,
  },
  typeChip: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
    marginRight: 8,
    borderWidth: 1,
  },
  typeChipText: {
    fontSize: 14,
    fontWeight: '500',
  },
  modalFooter: {
    flexDirection: 'row',
    padding: 20,
    gap: 12,
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
  },
  button: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  cancelButton: {
    backgroundColor: '#f5f5f5',
  },
  cancelButtonText: {
    color: '#666666',
    fontWeight: '600',
    fontSize: 16,
  },
  submitButton: {
    backgroundColor: '#1976D2',
  },
  submitButtonDisabled: {
    backgroundColor: '#90CAF9',
  },
  submitButtonText: {
    color: '#ffffff',
    fontWeight: '600',
    fontSize: 16,
  },
  errorContainer: {
    padding: 12,
    backgroundColor: '#FFEBEE',
    borderRadius: 8,
    marginBottom: 8,
  },
  errorText: {
    color: '#D32F2F',
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 4,
  },
  errorHelperText: {
    fontSize: 12,
  },
  emptyText: {
    fontSize: 14,
    fontStyle: 'italic',
    marginBottom: 8,
  },
});
