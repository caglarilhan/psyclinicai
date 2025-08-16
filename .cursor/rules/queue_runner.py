#!/usr/bin/env python3
"""
Task Queue Runner - FSM sistemini kuyruk ile çalıştırır
"""

import os
import sys
from fsm_runner import fsm_run

def read_tasks(queue_file="task_queue.txt"):
    """Task queue dosyasından görevleri okur"""
    try:
        with open(queue_file, 'r', encoding='utf-8') as f:
            tasks = [line.strip() for line in f if line.strip() and not line.startswith('#')]
        return tasks
    except FileNotFoundError:
        print(f"❌ Queue dosyası bulunamadı: {queue_file}")
        return []

def process_queue():
    """Tüm görevleri sırayla işler"""
    tasks = read_tasks()
    
    if not tasks:
        print("📭 Queue boş!")
        return
    
    print(f"🚀 {len(tasks)} görev bulundu, işlem başlıyor...")
    print("=" * 60)
    
    for i, task in enumerate(tasks, 1):
        print(f"\n📋 GÖREV {i}/{len(tasks)}")
        print(f"🎯 {task}")
        print("-" * 40)
        
        try:
            fsm_run(task)
            print(f"✅ Görev {i} tamamlandı")
        except Exception as e:
            print(f"❌ Görev {i} hatası: {e}")
        
        print("=" * 60)
    
    print(f"\n🎉 Tüm görevler tamamlandı! ({len(tasks)} görev)")

if __name__ == "__main__":
    process_queue()
