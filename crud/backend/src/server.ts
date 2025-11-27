import express from 'express';
import dotenv from 'dotenv';
import { ordemServicoRouter } from './routers/app.controller.js';
import { getDbPool } from './config/db.js';
import cors from 'cors';

dotenv.config();

const app = express();
app.use(express.json());

app.use(cors());

// test the DB connection early
getDbPool().catch(() => {
  console.error("Failed to connect to the database on startup.");
  process.exit(1);
});

app.get("/", (_, res) => res.send("API is running"));

app.use("/ordem-servico", ordemServicoRouter);

const PORT = Number(process.env.HTTP_PORT) || 3000;
const HOST = process.env.HTTP_HOST || "localhost";

app.listen(PORT, HOST, () => {
    console.log(`Server running at http://${HOST}:${PORT}`);
});
