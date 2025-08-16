// cursor-sprint-runner.ts
import { exec } from "child_process";
import { promisify } from "util";
import * as path from "path";
import * as fs from "fs";

const execP = promisify(exec);

// Basit CLI/extension stub: seçili sprint satırını alıp run_sprint.sh'ı çalıştırır, ardından çıkan dosyaları bildirir.
export async function runSprintLine(sprintLine: string, modelOverride?: string) {
  try {
    const scriptDir = path.resolve(".cursor/rules/scripts");
    const runScript = path.join(scriptDir, "run_sprint.sh");

    if (!fs.existsSync(runScript)) {
      console.error("run_sprint.sh bulunamadı:", runScript);
      return;
    }

    const quoted = `"${sprintLine.replace(/"/g, '\\"')}"`;
    const modelArg = modelOverride ? ` ${modelOverride}` : "";
    const cmd = `${runScript} ${quoted}${modelOverride ? ` ${modelOverride}` : ""}`;

    console.log("🚀 Sprint çalıştırılıyor:", cmd);
    const { stdout, stderr } = await execP(cmd, { cwd: scriptDir, maxBuffer: 1024 * 1024 * 3 });

    console.log("📝 Çıktı:\n", stdout);
    if (stderr) {
      console.warn("📦 Hata/uyarı:\n", stderr);
    }

    // Son output dosyasını oku (last_sprint_output.txt)
    const outputPath = path.join(scriptDir, "last_sprint_output.txt");
    if (fs.existsSync(outputPath)) {
      const content = fs.readFileSync(outputPath, "utf-8");
      // Burada istersen UI içinde parse edip preview verebilirsin.
      console.log("✅ Bridge çıktısı alındı, post-processing zaten yapılmış.");
    } else {
      console.warn("⚠️ Bridge çıktı dosyası bulunamadı:", outputPath);
    }

    // Kısaca kullanıcıya bildir
    // (Cursor extension API'sine göre notification gösterme kodu buraya gelir)
  } catch (e) {
    console.error("❌ Sprint çalıştırma başarısız oldu:", e);
  }
}

// Cursor Command Palette için basit wrapper
export async function runSelectedSprintLine() {
  // Bu fonksiyon Cursor'un seçili metni alıp sprint çalıştırması için
  // Cursor extension API'sine göre implement edilmeli
  const selectedText = ""; // Cursor API'den alınacak
  if (selectedText) {
    await runSprintLine(selectedText);
  }
} 