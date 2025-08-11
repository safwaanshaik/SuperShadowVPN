import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function ServerInfo({ serverInfo }) {
  if (!serverInfo) {
    return (
      <View style={styles.container}>
        <Text style={styles.noServerText}>No server configured</Text>
        <Text style={styles.instructionText}>Scan QR code to add server</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.serverName}>{serverInfo.name}</Text>
      <Text style={styles.endpoint}>📡 {serverInfo.endpoint}</Text>
      
      <View style={styles.featuresContainer}>
        {serverInfo.features.map((feature, index) => (
          <View key={index} style={styles.featureBadge}>
            <Text style={styles.featureText}>{feature}</Text>
          </View>
        ))}
      </View>
      
      <Text style={styles.keyInfo}>
        🔑 {serverInfo.publicKey.substring(0, 20)}...
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#1a1a2e',
    padding: 20,
    borderRadius: 15,
    marginBottom: 20,
    alignItems: 'center',
  },
  noServerText: {
    color: '#666',
    fontSize: 16,
    marginBottom: 5,
  },
  instructionText: {
    color: '#999',
    fontSize: 14,
  },
  serverName: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  endpoint: {
    color: '#00ff88',
    fontSize: 14,
    marginBottom: 15,
  },
  featuresContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    marginBottom: 15,
  },
  featureBadge: {
    backgroundColor: '#0f2027',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
    margin: 2,
  },
  featureText: {
    color: '#00ff88',
    fontSize: 10,
    fontWeight: 'bold',
  },
  keyInfo: {
    color: '#666',
    fontSize: 12,
    fontFamily: 'monospace',
  },
});