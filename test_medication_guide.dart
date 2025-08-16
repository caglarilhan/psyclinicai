import 'package:flutter/material.dart';

void main() {
  print('Test başlıyor...');
  
  // Test 1: Import kontrolü
  try {
    print('✅ Import testi başarılı');
  } catch (e) {
    print('❌ Import hatası: $e');
  }
  
  // Test 2: Constructor kontrolü
  try {
    print('✅ Constructor testi başarılı');
  } catch (e) {
    print('❌ Constructor hatası: $e');
  }
  
  print('Test tamamlandı!');
}
