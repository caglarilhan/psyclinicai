import json
import os
import subprocess
import time
from datetime import datetime
from nodes.plan_node import plan_task
from nodes.code_node import generate_code
from nodes.test_node import test_code
from nodes.eval_node import evaluate_output
from nodes.fix_node import fix_code

class EliteFSMRunner:
    def __init__(self, config_path="fsm_config_project.json"):
        self.config = self.load_config(config_path)
        self.project_root = self.config["project_root"]
        self.output_dir = self.config["output_dir"]
        self.file_prefix = self.config["file_prefix"]
        self.max_retries = self.config["max_retries"]
        self.auto_commit = self.config["auto_commit"]
        self.notify = self.config["notify"]
        self.test_commands = self.config["test_commands"]
        
        # Output dizinini oluştur
        os.makedirs(os.path.join(self.project_root, self.output_dir), exist_ok=True)
        
    def load_config(self, config_path):
        try:
            with open(config_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"⚠️  Config dosyası bulunamadı: {config_path}")
            return self.get_default_config()
    
    def get_default_config(self):
        return {
            "project_root": "/Users/caglarilhan/psyclinicai",
            "output_dir": "lib/widgets/generated",
            "file_prefix": "fsm_gen_",
            "plan_model": "mistral",
            "code_model": "deepseek-coder",
            "fix_model": "openai/gpt-oss-20b",
            "max_retries": 3,
            "auto_commit": False,
            "notify": False,
            "test_commands": [["flutter", "analyze"]]
        }
    
    def generate_filename(self):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        return f"{self.file_prefix}{timestamp}.dart"
    
    def write_code_to_file(self, code, filename):
        filepath = os.path.join(self.project_root, self.output_dir, filename)
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(code)
            print(f"💾 Kod dosyaya yazıldı: {filepath}")
            return filepath
        except Exception as e:
            print(f"❌ Dosya yazma hatası: {e}")
            return None
    
    def run_test_commands(self, filepath):
        print(f"🧪 Test komutları çalıştırılıyor...")
        
        # Güçlendirilmiş test node'u kullan
        from nodes.test_node import test_code
        
        # Dosyayı oku
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                code = f.read()
        except Exception as e:
            return False, f"Dosya okuma hatası: {e}"
        
        # Test node ile test et
        success, message = test_code(code, self.project_root)
        return success, message
    
    def auto_commit_if_enabled(self, filename):
        if not self.auto_commit:
            return
            
        try:
            subprocess.run(
                ["git", "add", os.path.join(self.output_dir, filename)],
                cwd=self.project_root,
                check=True
            )
            
            commit_msg = f"FSM Generated: {filename}"
            subprocess.run(
                ["git", "commit", "-m", commit_msg],
                cwd=self.project_root,
                check=True
            )
            
            print(f"🔒 Otomatik commit: {commit_msg}")
        except Exception as e:
            print(f"⚠️  Auto-commit hatası: {e}")
    
    def notify_if_enabled(self, success, filename):
        if not self.notify:
            return
            
        try:
            if success:
                title = "✅ FSM Başarılı"
                message = f"{filename} başarıyla oluşturuldu"
            else:
                title = "❌ FSM Hatası"
                message = f"{filename} oluşturulamadı"
            
            # macOS notification
            subprocess.run([
                "osascript", "-e",
                f'display notification "{message}" with title "{title}"'
            ])
        except Exception as e:
            print(f"⚠️  Bildirim hatası: {e}")
    
    def run(self, user_prompt):
        print(f"🚀 Elite FSM Runner Başlatıldı")
        print(f"📁 Proje: {self.project_root}")
        print(f"📂 Çıktı: {self.output_dir}")
        print(f"🎯 Görev: {user_prompt}")
        print("=" * 60)
        
        state = "PLAN"
        retries = 0
        task, code, test_result = "", "", ""
        filename = ""
        
        while True:
            print(f"\n🧭 Durum: {state}")
            
            if state == "PLAN":
                print("📋 Görev planlanıyor...")
                task = plan_task(user_prompt)
                print(f"📋 Planlanan Görev:\n{task}")
                state = "CODE"
                
            elif state == "CODE":
                print("💻 Kod üretiliyor...")
                code = generate_code(task)
                print(f"💻 Üretilen Kod:\n{code}")
                
                # Dosya adı oluştur
                filename = self.generate_filename()
                filepath = self.write_code_to_file(code, filename)
                
                if filepath:
                    state = "TEST"
                else:
                    print("❌ Kod dosyaya yazılamadı")
                    break
                    
            elif state == "TEST":
                print("🧪 Test ediliyor...")
                success, error_msg = self.run_test_commands(filepath)
                
                if success:
                    print("✅ Test başarılı!")
                    state = "SUCCESS"
                else:
                    print(f"❌ Test başarısız: {error_msg}")
                    state = "FIX"
                    
            elif state == "FIX":
                if retries < self.max_retries:
                    retries += 1
                    print(f"🔧 Fix #{retries} - Kod düzeltiliyor...")
                    print("🔧 Hata mesajı:", error_msg)
                    code = fix_code(code, error_msg)
                    print(f"🔧 Düzeltilen kod:\n{code}")
                    state = "CODE"
                else:
                    print(f"❌ Max retry ({self.max_retries}) aşıldı")
                    state = "FAILURE"
                    
            elif state == "SUCCESS":
                print("🎉 Görev başarıyla tamamlandı!")
                self.auto_commit_if_enabled(filename)
                self.notify_if_enabled(True, filename)
                break
                
            elif state == "FAILURE":
                print("💥 Görev başarısız!")
                self.notify_if_enabled(False, filename)
                break
                
            else:
                print(f"❓ Bilinmeyen durum: {state}")
                break

def fsm_run(user_prompt):
    runner = EliteFSMRunner()
    runner.run(user_prompt)

if __name__ == "__main__":
    user_input = input("📌 Görev Tanımı: ")
    fsm_run(user_input)