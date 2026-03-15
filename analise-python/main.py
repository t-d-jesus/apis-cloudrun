import os
import pandas as pd
from sqlalchemy import create_engine
from flask import Flask, jsonify  

app = Flask(__name__)

DATABASE_URL = os.getenv("DATABASE_URL")

@app.route("/", methods=["GET"])
def home():
    return jsonify({"status": "Python Analysis API is running"})

@app.route("/analise", methods=["GET"])
def analisar_dados():
    try:
        if not DATABASE_URL:
            return jsonify({"error": "DATABASE_URL not found"}), 500

        url = DATABASE_URL.replace("postgresql://", "postgresql+psycopg2://")
        
        engine = create_engine(url)
        
        df = pd.read_sql('SELECT * FROM "Product"', engine)
        
        if df.empty:
            return jsonify({"message": "Nenhum dado para analisar."})

        # Cálculos com Pandas
        stats = {
            "total_produtos": int(len(df)),
            "preco_medio": round(float(df['price'].mean()), 2),
            "valor_total": round(float(df['price'].sum()), 2)
        }
        
        return jsonify(stats)

    except Exception as e:
        print(f"Erro interno: {e}") # Isso aparecerá nos logs do GCP
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)