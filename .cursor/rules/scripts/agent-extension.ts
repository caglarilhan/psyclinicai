// src/agent-extension.ts
import { exec } from "child_process";
import path from "path";

// --- Bu kısmı Cursor extension SDK'sına göre adapte et ---
// Placeholder fonksiyon: seçili sprint satırını al ve shell script çalıştır.
export async function runGooseSprintLine(selectedText: string, workspaceRoot: string) {
  if (!selectedText || selectedText.trim() === "") {
    throw new Error("Önce sprint satırını seçmelisiniz.");
  }
  const sprintLine = selectedText.trim().replace(/"/g, '\\"');
  const model = "llama3:latest"; // isteğe göre kullanıcıdan al veya satırdan çıkarım yap

  const scriptPath = path.join(workspaceRoot, ".cursor/rules/scripts/run_sprint.sh");

  return new Promise<void>((resolve, reject) => {
    const cmd = `${scriptPath} "${sprintLine}" ${model}`;
    const child = exec(cmd, { cwd: workspaceRoot, env: process.env });

    child.stdout?.on("data", (d) => {
      console.log("[Sprint stdout]", d.toString());
    });
    child.stderr?.on("data", (d) => {
      console.error("[Sprint stderr]", d.toString());
    });

    child.on("close", (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Sprint script çıkış kodu: ${code}`));
      }
    });
  });
}

// Cursor Command Palette için wrapper
export async function runSelectedSprintLine() {
  // Bu fonksiyon Cursor'un seçili metni alıp sprint çalıştırması için
  // Cursor extension API'sine göre implement edilmeli
  const selectedText = ""; // Cursor API'den alınacak
  const workspaceRoot = ""; // Cursor API'den alınacak
  
  if (selectedText && workspaceRoot) {
    try {
      await runGooseSprintLine(selectedText, workspaceRoot);
      console.log("✅ Sprint başarıyla tamamlandı!");
    } catch (error) {
      console.error("❌ Sprint çalıştırma hatası:", error);
    }
  } else {
    console.error("❌ Seçili metin veya workspace root bulunamadı");
  }
}

// Not: Cursor'un extension API'si farklıysa createCommand / register gibi kendi entrypoint'ine bu fonksiyonu bağlaman gerekir. 
// Yukarıdaki kodu bir Node.js/TS modülü olarak koyup, seçili metni alıp runGooseSprintLine(...) çağıran bir command tanımla. 