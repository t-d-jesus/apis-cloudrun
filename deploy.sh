#!/bin/bash

# Configurações Gerais
PROJECT_ID="<ID-PROJETO>"
REGION="us-east1"
DB_INSTANCE="<ID-INSTANCIA-DB>"
# A URL de conexão (ajuste a senha se necessário ou passe como variável de ambiente)
DATABASE_URL="postgresql://postgres:<SUA_SENHA>@localhost/postgres?host=/cloudsql/$DB_INSTANCE"

echo "🚀 Iniciando automação de deploy no Google Cloud..."

deploy_typescript() {
    echo "📦 [1/2] Fazendo deploy da API TypeScript..."
    cd api-typescript
    docker build --platform linux/amd64 -t us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/my-api-typescript:latest .
    docker push us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/my-api-typescript:latest
    gcloud run deploy my-api-typescript \
        --image us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/my-api-typescript:latest \
        --region $REGION \
        --allow-unauthenticated \
        --add-cloudsql-instances $DB_INSTANCE \
        --set-env-vars DATABASE_URL="$DATABASE_URL"
    cd ..
}

deploy_python() {
    echo "🐍 [2/2] Fazendo deploy da API de Análise Python..."
    cd analise-python
    docker build --platform linux/amd64 -t us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/api-analise-python:latest .
    docker push us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/api-analise-python:latest
    gcloud run deploy api-analise-python \
        --image us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/api-analise-python:latest \
        --region $REGION \
        --allow-unauthenticated \
        --add-cloudsql-instances $DB_INSTANCE \
        --set-env-vars DATABASE_URL="$DATABASE_URL"
    cd ..
}

# Lógica de escolha
case "$1" in
    ts)
        deploy_typescript
        ;;
    py)
        deploy_python
        ;;
    all)
        deploy_typescript
        deploy_python
        ;;
    *)
        echo "Uso: ./deploy.sh [ts|py|all]"
        exit 1
        ;;
esac

echo "✅ Processo concluído!"