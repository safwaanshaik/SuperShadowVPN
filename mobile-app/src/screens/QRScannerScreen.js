import React, { useState } from 'react';
import { View, Text, StyleSheet, Alert, TouchableOpacity, TextInput } from 'react-native';
import VPNService from '../services/VPNService';

export default function QRScannerScreen({ navigation }) {
  const [manualConfig, setManualConfig] = useState('');
  const [isScanning, setIsScanning] = useState(false);

  const handleQRScan = async (data) => {
    try {
      setIsScanning(false);
      const config = VPNService.parseQRConfig(data);
      await VPNService.saveConfig(config);
      
      Alert.alert(
        'Configuration Added',
        `Server: ${config.name || 'SuperShadowVPN'}\nEndpoint: ${config.endpoint}`,
        [
          { text: 'OK', onPress: () => navigation.goBack() }
        ]
      );
    } catch (error) {
      Alert.alert('Error', error.message);
    }
  };

  const handleManualConfig = async () => {
    if (!manualConfig.trim()) {
      Alert.alert('Error', 'Please enter configuration');
      return;
    }

    try {
      const config = VPNService.parseQRConfig(manualConfig);
      await VPNService.saveConfig(config);
      
      Alert.alert(
        'Configuration Added',
        'Manual configuration saved successfully!',
        [
          { text: 'OK', onPress: () => navigation.goBack() }
        ]
      );
    } catch (error) {
      Alert.alert('Error', error.message);
    }
  };

  const sampleConfig = `# Name = SuperShadowVPN-MILITARY-GRADE
[Interface]
PrivateKey = wBv4MnknVE3sgvLwwN+XYS6oiFX+7O+HI+4wk5Mr/lM=
Address = 10.0.0.99/24
DNS = 1.1.1.1, 1.0.0.1
MTU = 1280

[Peer]
PublicKey = Q+MAI9lrhZZWUshYyT0s8r1jAKNHOphN11MDqqPo0gw=
Endpoint = 4.240.39.197:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25`;

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Add VPN Configuration</Text>
      
      <TouchableOpacity 
        style={styles.scanButton}
        onPress={() => setIsScanning(!isScanning)}
      >
        <Text style={styles.buttonText}>
          {isScanning ? '📷 Scanning...' : '📱 Scan QR Code'}
        </Text>
      </TouchableOpacity>

      {isScanning && (
        <View style={styles.scannerPlaceholder}>
          <Text style={styles.scannerText}>
            📷 Camera Scanner Would Appear Here
          </Text>
          <Text style={styles.scannerSubText}>
            Point camera at SuperShadowVPN QR code
          </Text>
          <TouchableOpacity 
            style={styles.testButton}
            onPress={() => handleQRScan(sampleConfig)}
          >
            <Text style={styles.testButtonText}>Use Sample Config (Test)</Text>
          </TouchableOpacity>
        </View>
      )}

      <Text style={styles.orText}>OR</Text>

      <Text style={styles.manualTitle}>Manual Configuration:</Text>
      <TextInput
        style={styles.textInput}
        multiline
        numberOfLines={10}
        placeholder="Paste WireGuard configuration here..."
        placeholderTextColor="#666"
        value={manualConfig}
        onChangeText={setManualConfig}
      />

      <TouchableOpacity 
        style={styles.addButton}
        onPress={handleManualConfig}
      >
        <Text style={styles.buttonText}>✅ Add Configuration</Text>
      </TouchableOpacity>

      <TouchableOpacity 
        style={styles.sampleButton}
        onPress={() => setManualConfig(sampleConfig)}
      >
        <Text style={styles.sampleButtonText}>📋 Use Sample Config</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0f0f23',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    textAlign: 'center',
    marginBottom: 30,
  },
  scanButton: {
    backgroundColor: '#00ff88',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginBottom: 20,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#fff',
  },
  scannerPlaceholder: {
    backgroundColor: '#1a1a2e',
    padding: 40,
    borderRadius: 10,
    alignItems: 'center',
    marginBottom: 20,
  },
  scannerText: {
    fontSize: 18,
    color: '#fff',
    marginBottom: 10,
  },
  scannerSubText: {
    fontSize: 14,
    color: '#999',
    marginBottom: 20,
  },
  testButton: {
    backgroundColor: '#ff6b6b',
    padding: 10,
    borderRadius: 5,
  },
  testButtonText: {
    color: '#fff',
    fontSize: 12,
  },
  orText: {
    textAlign: 'center',
    color: '#666',
    fontSize: 16,
    marginVertical: 20,
  },
  manualTitle: {
    fontSize: 18,
    color: '#fff',
    marginBottom: 10,
  },
  textInput: {
    backgroundColor: '#1a1a2e',
    color: '#fff',
    padding: 15,
    borderRadius: 10,
    textAlignVertical: 'top',
    marginBottom: 20,
    fontSize: 12,
  },
  addButton: {
    backgroundColor: '#4834d4',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginBottom: 10,
  },
  sampleButton: {
    backgroundColor: '#2c2c54',
    padding: 10,
    borderRadius: 5,
    alignItems: 'center',
  },
  sampleButtonText: {
    color: '#999',
    fontSize: 14,
  },
});