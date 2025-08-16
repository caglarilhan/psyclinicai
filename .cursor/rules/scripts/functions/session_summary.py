import os
import io
from flask import Flask, request, jsonify
import requests
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from datetime import datetime

app = Flask(__name__)

OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434/api/generate")
DEFAULT_MODEL = "mistral:latest"

def call_ollama(prompt: str, model: str = DEFAULT_MODEL, retries: int = 3) -> str:
    payload = {"model": model, "prompt": prompt, "stream": False}
    for attempt in range(retries):
        try:
            r = requests.post(OLLAMA_URL, json=payload, timeout=120)
            r.raise_for_status()
            return r.json().get("response", "").strip()
        except Exception as e:
            if attempt == retries - 1:
                raise
    return ""

@app.route("/summarize_and_export", methods=["POST"])
def summarize_and_export():
    data = request.get_json(force=True)
    notes = data.get("notes", "")
    patient = data.get("patient", "Unknown")
    therapist = data.get("therapist", "Unknown")

    # LLM prompt (PRD'ye uygun)
    prompt = f"""You are a clinical AI assistant analyzing therapy session notes. Please provide a structured summary with the following fields:

1. **Affect**: Describe the patient's emotional state and mood during the session
2. **Theme**: Identify the main themes, topics, or issues discussed
3. **ICD Suggestion**: Suggest relevant ICD-10 codes based on the session content

Format your response as:
- Affect: [description]
- Theme: [description] 
- ICD Suggestion: [code] - [description]

Session notes:
\"\"\"{notes}\"\"\""""

    summary = call_ollama(prompt)

    # PDF oluştur
    buffer = io.BytesIO()
    c = canvas.Canvas(buffer, pagesize=letter)
    c.setFont("Helvetica-Bold", 16)
    c.drawString(72, 750, "PsyClinic AI - Seans Özeti")
    c.setFont("Helvetica", 12)
    c.drawString(72, 730, f"Danışan: {patient}")
    c.drawString(72, 715, f"Terapist: {therapist}")
    c.drawString(72, 700, f"Tarih: {datetime.utcnow().strftime('%Y-%m-%d')}")
    c.drawString(72, 680, "AI Özet:")
    text = c.beginText(72, 660)
    for line in summary.splitlines():
        text.textLine(line)
    c.drawText(text)
    c.showPage()
    c.save()
    buffer.seek(0)

    os.makedirs("outputs", exist_ok=True)
    pdf_name = f"session_summary_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.pdf"
    pdf_path = os.path.join("outputs", pdf_name)
    with open(pdf_path, "wb") as f:
        f.write(buffer.read())

    return jsonify({
        "summary": summary,
        "pdf_path": pdf_path
    })

if __name__ == "__main__":
    app.run(port=5002, debug=True) 