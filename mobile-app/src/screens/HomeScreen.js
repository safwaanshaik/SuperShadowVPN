import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import VPNService from '../services/VPNService';
import ConnectionStatus from '../components/ConnectionStatus';
import ServerInfo from '../components/ServerInfo';

export default function HomeScreen({ navigation }) {
  const [isConnected, setIsConnected] = useState(false);
  const [serverInfo, setServerInfo] = useState(null);
  const [connectionTime, setConnectionTime] = useState(0);

  useEffect(() => {
    checkVPNStatus();
    const interval = setInterval(() => {
      if (isConnected) {
        setConnectionTime(prev => prev + 1);
      }
    }, 1000);
    return () => clearInterval(interval);
  }, [isConnected]);

  const checkVPNStatus = async () => {
    try {
      const status = await VPNService.getConnectionStatus();
      setIsConnected(status.connected);
      setServerInfo(status.serverInfo);
    } catch (error) {
      console.log('Status check failed:', error);
    }
  };

  const toggleVPN = async () => {
    try {
      if (isConnected) {
        await VPNService.disconnect();
        setIsConnected(false);
        setConnectionTime(0);
        Alert.alert('Disconnected', 'SuperShadowVPN disconnected');
      } else {
        await VPNService.connect();
        setIsConnected(true);
        Alert.alert('Connected', 'SuperShadowVPN connected successfully!');
      }
    } catch (error) {
      Alert.alert('Error', error.message);
    }
  };

  return (
    <View style={styles.container}>
      <ConnectionStatus 
        isConnected={isConnected}
        connectionTime={connectionTime}
      />
      
      <ServerInfo serverInfo={serverInfo} />
      
      <TouchableOpacity 
        style={[styles.connectButton, isConnected ? styles.disconnectButton : styles.connectButtonActive]}
        onPress={toggleVPN}
      >
        <Text style={styles.buttonText}>
          {isConnected ? '🔴 DISCONNECT' : '🟢 CONNECT'}
        </Text>
      </TouchableOpacity>

      <View style={styles.actionButtons}>
        <TouchableOpacity 
          style={styles.actionButton}
          onPress={() => navigation.navigate('QRScanner')}
        >
          <Text style={styles.actionButtonText}>📱 Scan QR</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={styles.actionButton}
          onPress={() => navigation.navigate('Settings')}
        >
          <Text style={styles.actionButtonText}>⚙️ Settings</Text>
        </TouchableOpacity>
      </View>

      <Text style={styles.footer}>
        Military-Grade Security • Zero Logs • AI Protection
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0f0f23',
    padding: 20,
    justifyContent: 'center',
  },
  connectButton: {
    padding: 20,
    borderRadius: 15,
    marginVertical: 30,
    alignItems: 'center',
  },
  connectButtonActive: {
    backgroundColor: '#00ff88',
  },
  disconnectButton: {
    backgroundColor: '#ff4757',
  },
  buttonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
  },
  actionButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: 20,
  },
  actionButton: {
    backgroundColor: '#1a1a2e',
    padding: 15,
    borderRadius: 10,
    flex: 0.4,
    alignItems: 'center',
  },
  actionButtonText: {
    color: '#fff',
    fontSize: 16,
  },
  footer: {
    textAlign: 'center',
    color: '#666',
    marginTop: 40,
    fontSize: 12,
  },
});