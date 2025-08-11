import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function ConnectionStatus({ isConnected, connectionTime }) {
  const formatTime = (seconds) => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <View style={styles.container}>
      <View style={[styles.statusIndicator, isConnected ? styles.connected : styles.disconnected]}>
        <Text style={styles.statusIcon}>
          {isConnected ? '🛡️' : '⚠️'}
        </Text>
      </View>
      
      <Text style={styles.statusText}>
        {isConnected ? 'PROTECTED' : 'UNPROTECTED'}
      </Text>
      
      <Text style={styles.subText}>
        {isConnected ? 'SuperShadowVPN Active' : 'Tap Connect to Secure'}
      </Text>
      
      {isConnected && (
        <Text style={styles.timeText}>
          Connected: {formatTime(connectionTime)}
        </Text>
      )}
      
      <View style={styles.features}>
        <Text style={[styles.feature, isConnected && styles.featureActive]}>
          🥷 Stealth Mode
        </Text>
        <Text style={[styles.feature, isConnected && styles.featureActive]}>
          🔮 Quantum-Resistant
        </Text>
        <Text style={[styles.feature, isConnected && styles.featureActive]}>
          🤖 AI Protection
        </Text>
        <Text style={[styles.feature, isConnected && styles.featureActive]}>
          🔒 Zero Logs
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    marginBottom: 30,
  },
  statusIndicator: {
    width: 120,
    height: 120,
    borderRadius: 60,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
  },
  connected: {
    backgroundColor: '#00ff88',
  },
  disconnected: {
    backgroundColor: '#ff4757',
  },
  statusIcon: {
    fontSize: 40,
  },
  statusText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 5,
  },
  subText: {
    fontSize: 16,
    color: '#999',
    marginBottom: 10,
  },
  timeText: {
    fontSize: 14,
    color: '#00ff88',
    marginBottom: 20,
  },
  features: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
  },
  feature: {
    fontSize: 12,
    color: '#666',
    margin: 5,
    padding: 5,
    borderRadius: 5,
    backgroundColor: '#1a1a2e',
  },
  featureActive: {
    color: '#00ff88',
    backgroundColor: '#0f2027',
  },
});