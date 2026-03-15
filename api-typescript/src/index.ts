import { PrismaClient } from '@prisma/client';
import express, { Request, Response } from 'express';

const prisma = new PrismaClient();
const app = express();

// Middleware para aceitar JSON no corpo das requisições
app.use(express.json());

// Rota de Health Check (para o Google Cloud saber que a API está viva)
app.get('/', (req: Request, res: Response) => {
  res.json({ status: 'ok', message: 'API CRUD TypeScript está online!' });
});

// CREATE: Criar um novo produto
app.post('/products', async (req: Request, res: Response) => {
  try {
    const { name, price, description } = req.body;
    const newProduct = await prisma.product.create({
      data: {
        name,
        price: parseFloat(price),
        description,
      },
    });
    res.status(201).json(newProduct);
  } catch (error) {
    console.error('Erro ao criar produto:', error);
    res.status(500).json({ error: 'Erro ao criar produto no banco de dados.' });
  }
});

// READ: Listar todos os produtos
app.get('/products', async (req: Request, res: Response) => {
  try {
    const products = await prisma.product.findMany({
      orderBy: { createdAt: 'desc' },
    });
    res.json(products);
  } catch (error) {
    console.error('Erro ao buscar produtos:', error);
    res.status(500).json({ error: 'Erro ao buscar produtos.' });
  }
});

// DELETE: Remover um produto (útil para limpar testes)
app.delete('/products/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await prisma.product.delete({
      where: { id: Number(id) },
    });
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: 'Erro ao deletar produto.' });
  }
});

// Configuração da Porta e Host para o Cloud Run
const PORT = process.env.PORT || 8080;

// IMPORTANTE: Ouvir em '0.0.0.0' é o que evita o erro 503
app.listen(Number(PORT), '0.0.0.0', () => {
  console.log(`🚀 Servidor pronto em http://0.0.0.0:${PORT}`);
});