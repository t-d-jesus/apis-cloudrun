# --- Estágio 1: Build ---
FROM node:20-slim AS builder

# Instalar OpenSSL (necessário para o Prisma engine)
RUN apt-get update -y && apt-get install -y openssl

WORKDIR /app

# Copiar arquivos de dependências
COPY package*.json ./
COPY prisma ./prisma/

# Instalar TODAS as dependências (incluindo dev)
RUN npm install

# Copiar o restante do código
COPY . .

# Gerar o Prisma Client 
RUN npx prisma generate

# Compilar TypeScript para JavaScript
RUN npm run build

# --- Estágio 2: Produção ---
FROM node:20-slim

# O Prisma precisa do openssl também em runtime
RUN apt-get update -y && apt-get install -y openssl

WORKDIR /app

# Copiar apenas o necessário do estágio de build
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

# Expor a porta que o Cloud Run exige
EXPOSE 8080

# Comando para rodar a aplicação
CMD ["npm", "start"]