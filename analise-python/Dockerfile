FROM python:3.11-slim

# Instalar dependências de sistema para o PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev gcc && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# O Gunicorn lê a porta automaticamente da variável $PORT do Cloud Run
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app