// src/routes/ordemServico.router.ts
import { Router, Request, Response } from "express";
import sql from "mssql";
import { getDbPool } from "../config/db.js";

export const ordemServicoRouter = Router();

/**
 * GET /ordem-servico
 */
ordemServicoRouter.get("/", async (req: Request, res: Response) => {
    try {
        const pool = await getDbPool();
        const result = await pool.request().query("SELECT * FROM OrdemServico");
        res.json(result.recordset);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erro ao buscar ordens de serviço." });
    }
});

/**
 * GET /ordem-servico/:id
 */
ordemServicoRouter.get("/:id", async (req: Request, res: Response) => {
    const { id } = req.params;

    try {
        const pool = await getDbPool();
        const result = await pool
            .request()
            .input("id_os", sql.Int, Number(id))
            .query("SELECT * FROM OrdemServico WHERE id_os = @id_os");

        if (!result.recordset[0]) {
            return res.status(404).json({ error: "Ordem de serviço não encontrada." });
        }

        res.json(result.recordset[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erro ao buscar ordem de serviço." });
    }
});

/**
 * POST /ordem-servico
 */
ordemServicoRouter.post("/", async (req: Request, res: Response) => {
    const { id_veiculo, id_mecanico, data_entrada, data_saida, status, observacoes } = req.body;

    if (!id_veiculo || !id_mecanico) {
        return res.status(400).json({ error: "id_veiculo e id_mecanico são obrigatórios." });
    }

    try {
        const pool = await getDbPool();

        const query = `
            INSERT INTO OrdemServico (id_veiculo, id_mecanico, data_entrada, data_saida, status, observacoes)
            VALUES (@id_veiculo, @id_mecanico, @data_entrada, @data_saida, @status, @observacoes)
            SELECT SCOPE_IDENTITY() AS id_os
        `;

        const result = await pool
            .request()
            .input("id_veiculo", sql.Int, id_veiculo)
            .input("id_mecanico", sql.Int, id_mecanico)
            .input("data_entrada", sql.Date, data_entrada ?? null)
            .input("data_saida", sql.Date, data_saida ?? null)
            .input("status", sql.VarChar(20), status ?? null)
            .input("observacoes", sql.Text, observacoes ?? null)
            .query(query);

        res.status(201).json({
            message: "Ordem de serviço criada com sucesso.",
            id_os: result.recordset[0].id_os
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erro ao criar ordem de serviço." });
    }
});

/**
 * PUT /ordem-servico/:id
 */
ordemServicoRouter.put("/:id", async (req: Request, res: Response) => {
    const { id } = req.params;
    const { id_veiculo, id_mecanico, data_entrada, data_saida, status, observacoes } = req.body;

    try {
        const pool = await getDbPool();

        const query = `
            UPDATE OrdemServico
            SET 
                id_veiculo = @id_veiculo,
                id_mecanico = @id_mecanico,
                data_entrada = @data_entrada,
                data_saida = @data_saida,
                status = @status,
                observacoes = @observacoes
            WHERE id_os = @id_os
        `;

        const result = await pool
            .request()
            .input("id_os", sql.Int, Number(id))
            .input("id_veiculo", sql.Int, id_veiculo)
            .input("id_mecanico", sql.Int, id_mecanico)
            .input("data_entrada", sql.Date, data_entrada ?? null)
            .input("data_saida", sql.Date, data_saida ?? null)
            .input("status", sql.VarChar(20), status ?? null)
            .input("observacoes", sql.Text, observacoes ?? null)
            .query(query);

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: "Ordem de serviço não encontrada." });
        }

        res.json({ message: "Ordem de serviço atualizada com sucesso." });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erro ao atualizar ordem de serviço." });
    }
});

/**
 * DELETE /ordem-servico/:id
 */
ordemServicoRouter.delete("/:id", async (req: Request, res: Response) => {
    const { id } = req.params;

    try {
        const pool = await getDbPool();

        const result = await pool
            .request()
            .input("id_os", sql.Int, Number(id))
            .query("DELETE FROM OrdemServico WHERE id_os = @id_os");

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: "Ordem de serviço não encontrada." });
        }

        res.json({ message: "Ordem de serviço deletada com sucesso." });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erro ao deletar ordem de serviço." });
    }
});