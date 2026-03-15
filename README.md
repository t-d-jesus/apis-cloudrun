🚀 Full Stack Data Pipeline: Cloud Run, TypeScript & Python

Este repositório contém uma arquitetura de microserviços implantada no Google Cloud Platform (GCP). Ele utiliza uma API TypeScript para ingestão de dados e uma API Python para processamento analítico, ambas compartilhando um banco de dados Cloud SQL (PostgreSQL).

📁 Estrutura do Projeto

```text
meu-projeto-gcp/
├── api-typescript/    # API de Ingestão (Node.js, Express, Prisma)
├── analise-python/    # API de Análise (Python, Flask, Pandas, Gunicorn)
├── deploy.sh          # Script de automação de deploy
└── README.md          # Documentação do projeto
```

🛠️ 1. Preparação do Ambiente GCP

Habilitar APIs

Abra o Cloud Shell e execute:
```
gcloud services enable \
    run.googleapis.com \
    sqladmin.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com
```

Criar Repositório de Imagens (Artifact Registry)
```
gcloud artifacts repositories create cloud-run-source-deploy \
    --repository-format=docker \
    --location=us-east1
```

Criar Instância Cloud SQL (PostgreSQL)
```
gcloud sql instances create meu-banco-crud \
    --database-version=POSTGRES_15 \
    --tier=db-f1-micro \
    --region=us-east1 \
    --root-password=SUA_SENHA_AQUI
```


🔑 2. Configuração de Permissões (IAM)

O Cloud Run precisa de permissão para "enxergar" o SQL. Substitua [PROJECT_NUMBER] pelo número do seu projeto:
```
gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
    --member="serviceAccount:[PROJECT_NUMBER]-compute@developer.gserviceaccount.com" \
    --role="roles/cloudsql.client"
```


🚀 3. Comandos de Deploy Manual

Serviço TypeScript (Ingestão)
```
cd api-typescript
docker build --platform linux/amd64 -t us-east1-docker.pkg.dev/$(gcloud config get-value project)/cloud-run-source-deploy/my-api-typescript:latest .
docker push us-east1-docker.pkg.dev/$(gcloud config get-value project)/cloud-run-source-deploy/my-api-typescript:latest

gcloud run deploy my-api-typescript \
  --image us-east1-docker.pkg.dev/$(gcloud config get-value project)/cloud-run-source-deploy/my-api-typescript:latest \
  --region us-east1 \
  --allow-unauthenticated \
  --add-cloudsql-instances $(gcloud config get-value project):us-east1:meu-banco-crud \
  --set-env-vars DATABASE_URL="postgresql://postgres:SENHA@localhost/postgres?host=/cloudsql/$(gcloud config get-value project):us-east1:meu-banco-crud"
```

Serviço Python (Análise)
```
cd ../analise-python
docker build --platform linux/amd64 -t us-east1-docker.pkg.dev/$(gcloud config get-value project)/cloud-run-source-deploy/api-analise-python:latest .
docker push us-east1-docker.pkg.dev/$(gcloud config get-value project)/cloud-run-source-deploy/api-analise-python:latest

gcloud run deploy api-analise-python \
  --image us-east1-docker.pkg.dev/$(gcloud config get-value project)/cloud-run-source-deploy/api-analise-python:latest \
  --region us-east1 \
  --allow-unauthenticated \
  --add-cloudsql-instances $(gcloud config get-value project):us-east1:meu-banco-crud \
  --set-env-vars DATABASE_URL="postgresql://postgres:SENHA@localhost/postgres?host=/cloudsql/$(gcloud config get-value project):us-east1:meu-banco-crud"
```


🤖 4. Automação com deploy.sh

Crie o arquivo deploy.sh na raiz do projeto para simplificar o processo:
```
#!/bin/bash
PROJECT_ID=$(gcloud config get-value project)
REGION="us-east1"
DB_INST="$PROJECT_ID:$REGION:meu-banco-crud"
DB_URL="postgresql://postgres:SENHA@localhost/postgres?host=/cloudsql/$DB_INST"

case "$1" in
    ts)
        cd api-typescript && docker build --platform linux/amd64 -t us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/my-api-typescript:latest .
        docker push us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/my-api-typescript:latest
        gcloud run deploy my-api-typescript --image us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/my-api-typescript:latest --region $REGION --allow-unauthenticated --add-cloudsql-instances $DB_INST --set-env-vars DATABASE_URL="$DB_URL"
        ;;
    py)
        cd analise-python && docker build --platform linux/amd64 -t us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/api-analise-python:latest .
        docker push us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/api-analise-python:latest
        gcloud run deploy api-analise-python --image us-east1-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/api-analise-python:latest --region $REGION --allow-unauthenticated --add-cloudsql-instances $DB_INST --set-env-vars DATABASE_URL="$DB_URL"
        ;;
    all)
        $0 ts && $0 py
        ;;
    *)
        echo "Uso: ./deploy.sh [ts|py|all]"
        ;;
esac
```


🧪 5. Como Testar

1. Criar Produto (TS):
```
curl -X POST https://URL-DA-API-TS.run.app/products \
     -H "Content-Type: application/json" \
     -d '{"name": "Monitor", "price": 1200.00, "description": "4K"}'
```

2. Deletar Produto (TS):
```
curl -X DELETE https://URL-DA-API-TS.run.app/products/1
```

3. Ver Análise (Python):
```
curl https://URL-DA-API-PYTHON.run.app/analise
```

