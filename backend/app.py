from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

recommendations = {
    "senang": ["Tulis jurnal syukur", "Ajak teman ngobrol", "Meditasi ringan"],
    "sedih": ["Dengar musik santai", "Berjalan kaki", "Tulis perasaanmu"],
    "stres": ["Latihan pernapasan 4-7-8", "Olahraga ringan", "Curhat ke teman"],
    "cemas": ["Latihan mindfulness", "Baca buku singkat", "Batasi waktu layar"],
    "biasa": ["Cari podcast positif", "Lihat foto keluarga", "Tonton video lucu"]
}

@app.route("/mood", methods=["POST"])
def receive_mood():
    data = request.get_json()
    mood = data.get("mood", "biasa").lower()
    rec = recommendations.get(mood, recommendations["biasa"])
    return jsonify({
        "status": "success",
        "message": f"Mood '{mood}' diterima",
        "recommendations": rec
    })

if __name__ == "__main__":
    app.run(debug=True)
