import fs from "fs";
import sql from "mssql";
import 'dotenv/config';

async function init() {
  const dbName = process.env.DB_NAME!;
  const password = process.env.DB_PASSWORD!;
  const user = process.env.DB_USER!;
  const host = process.env.DB_HOST!;
  const port = Number(process.env.DB_PORT);

  console.log("Starting database initialization... Environment variables:", {
    DB_NAME: dbName,
    DB_PASSWORD: password,
    DB_USER: user,
    DB_HOST: host,
    DB_PORT: port
  });

  if (!dbName || !password || !user || !host || !port) {
    throw new Error("Missing one of the required environment variables: DB_NAME, DB_PASSWORD, DB_USER, DB_HOST, DB_PORT");
  }

  const masterPool = await sql.connect({
    user,
    password,
    server: host,
    port,
    database: "master",
    options: { trustServerCertificate: true, encrypt: false }
  });

  console.log("Connected to master.");

  const result = await masterPool
    .request()
    .query(`SELECT name FROM sys.databases WHERE name = '${dbName}'`);

  if (result.recordset.length === 0) {
    console.log(`Database '${dbName}' does not exist. Creating...`);
    await masterPool.request().query(`CREATE DATABASE [${dbName}]`);
    console.log("Database created.");
  } else {
    console.log(`Database '${dbName}' already exists.`);
  }

  await masterPool.close();

  const ddl = fs.readFileSync("src/db/init.sql", "utf8");

  const commands = ddl
    .split(/\bGO\b/g)
    .map(cmd => cmd.trim())
    .filter(cmd => cmd.length > 0);

  const appPool = await sql.connect({
    user,
    password,
    server: host,
    port,
    database: dbName,
    options: { trustServerCertificate: true, encrypt: false }
  });

  console.log("Connected to target database. Running DDL...");

  for (const command of commands) {
    await appPool.request().batch(command);
  }

  console.log("DDL completed successfully!");

  await appPool.close();
}

init().catch(err => {
  console.error("Init error:", err);
  process.exit(1);
});