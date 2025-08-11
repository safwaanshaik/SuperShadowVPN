import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Switch, Alert } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import VPNService from '../services/VPNService';

export default function SettingsScreen() {
  const [autoConnect, setAutoConnect] = useState(false);
  const [killSwitch, setKillSwitch] = useState(true);
  const [stealthMode, setStealthMode] = useState(true);
  const [servers, setServers] = useState([]);

  useEffect(() => {
    loadSettings();
    loadServers();
  }, []);

  const loadSettings = async () => {
    try {
      const settings = await AsyncStorage.getItem('vpnSettings');
      if (settings) {
        const parsed = JSON.parse(settings);
        setAutoConnect(parsed.autoConnect || false);
        setKillSwitch(parsed.killSwitch || true);
        setStealthMode(parsed.stealthMode || true);
      }
    } catch (error) {
      console.log('Failed to load settings:', error);
    }
  };

  const saveSettings = async (key, value) => {
    try {
      const currentSettings = await AsyncStorage.getItem('vpnSettings');
      const settings = currentSettings ? JSON.parse(currentSettings) : {};
      settings[key] = value;
      await AsyncStorage.setItem('vpnSettings', JSON.stringify(settings));
    } catch (error) {
      console.log('Failed to save settings:', error);
    }
  };

  const loadServers = async () => {
    try {
      const serverList = await VPNService.getServerList();
      setServers(serverList);
    } catch (error) {
      console.log('Failed to load servers:', error);
    }
  };

  const clearAllData = () => {
    Alert.alert(
      'Clear All Data',
      'This will remove all VPN configurations and settings. Are you sure?',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Clear', 
          style: 'destructive',
          onPress: async () => {
            try {
              await AsyncStorage.clear();
              Alert.alert('Success', 'All data cleared');
            } catch (error) {
              Alert.alert('Error', 'Failed to clear data');
            }
          }
        }
      ]
    );
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>⚙️ Settings</Text>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Connection</Text>
        
        <View style={styles.settingRow}>
          <Text style={styles.settingText}>Auto-Connect on App Start</Text>
          <Switch
            value={autoConnect}
            onValueChange={(value) => {
              setAutoConnect(value);
              saveSettings('autoConnect', value);
            }}
            trackColor={{ false: '#666', true: '#00ff88' }}
          />
        </View>

        <View style={styles.settingRow}>
          <Text style={styles.settingText}>Kill Switch</Text>
          <Switch
            value={killSwitch}
            onValueChange={(value) => {
              setKillSwitch(value);
              saveSettings('killSwitch', value);
            }}
            trackColor={{ false: '#666', true: '#00ff88' }}
          />
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Security</Text>
        
        <View style={styles.settingRow}>
          <Text style={styles.settingText}>Stealth Mode</Text>
          <Switch
            value={stealthMode}
            onValueChange={(value) => {
              setStealthMode(value);
              saveSettings('stealthMode', value);
            }}
            trackColor={{ false: '#666', true: '#00ff88' }}
          />
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Servers</Text>
        {servers.map((server, index) => (
          <View key={index} style={styles.serverItem}>
            <Text style={styles.serverName}>{server.name}</Text>
            <Text style={styles.serverLocation}>{server.location}</Text>
            <View style={styles.serverFeatures}>
              {server.features.map((feature, idx) => (
                <Text key={idx} style={styles.serverFeature}>{feature}</Text>
              ))}
            </View>
          </View>
        ))}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Data</Text>
        
        <TouchableOpacity style={styles.dangerButton} onPress={clearAllData}>
          <Text style={styles.dangerButtonText}>🗑️ Clear All Data</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.footer}>
        <Text style={styles.footerText}>SuperShadowVPN v1.0.0</Text>
        <Text style={styles.footerText}>Military-Grade Security</Text>
      </View>
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
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#00ff88',
    marginBottom: 15,
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#1a1a2e',
    padding: 15,
    borderRadius: 10,
    marginBottom: 10,
  },
  settingText: {
    color: '#fff',
    fontSize: 16,
  },
  serverItem: {
    backgroundColor: '#1a1a2e',
    padding: 15,
    borderRadius: 10,
    marginBottom: 10,
  },
  serverName: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  serverLocation: {
    color: '#999',
    fontSize: 14,
    marginBottom: 10,
  },
  serverFeatures: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  serverFeature: {
    backgroundColor: '#0f2027',
    color: '#00ff88',
    fontSize: 10,
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 8,
    marginRight: 5,
    marginBottom: 5,
  },
  dangerButton: {
    backgroundColor: '#ff4757',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
  },
  dangerButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  footer: {
    alignItems: 'center',
    marginTop: 30,
  },
  footerText: {
    color: '#666',
    fontSize: 12,
    marginBottom: 5,
  },
});