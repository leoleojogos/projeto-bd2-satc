
import sql from "mssql";
import dotenv from "dotenv";

dotenv.config();

const config: sql.config = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    server: process.env.DB_HOST || "localhost",
    port: Number(process.env.DB_PORT) || 1433,
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

let pool: sql.ConnectionPool | null = null;

export async function getDbPool(): Promise<sql.ConnectionPool> {
    if (pool) {
        return pool;
    }

    try {
        pool = await sql.connect(config);
        console.log("SQL Server connected");
        return pool;
    } catch (err) {
        console.error("SQL Server connection failed:", err);
        throw err;
    }
}
