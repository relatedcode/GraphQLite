import { serverErrors } from "app";
import Postgres from "db/postgres";
import del from "del";
import fs from "fs";
import path from "path";
import SequelizeAuto from "sequelize-auto";

export default async function createTables() {
  try {
    // SYSTEM TABLES
    const systemSchema = fs
      .readFileSync(path.resolve(__dirname, "../../system-schema.sql"))
      .toString();
    await Postgres.query(systemSchema);

    // CUSTOM SCHEMA TABLES
    const sqlPath = path.resolve(__dirname, "../../config/schema.sql");
    const sequelizePath = path.resolve(__dirname, "../../config/sequelize.js");
    try {
      if (fs.existsSync(sqlPath) && !fs.existsSync(sequelizePath)) {
        const customSchema = fs.readFileSync(sqlPath).toString();
        await Postgres.query(customSchema);
      }
    } catch (err: any) {
      console.error(err.message);
      serverErrors.push(err.message);
    }

    const sequelizeModelFolder = path.resolve(__dirname, "../../models-auto");
    if (fs.existsSync(sequelizeModelFolder)) {
      await del(sequelizeModelFolder);
      console.log("Old models-auto folder deleted.");
    }

    const auto = new SequelizeAuto(
      process.env.DB_DATABASE as string,
      process.env.DB_USER as string,
      process.env.DB_PASSWORD as string,
      {
        host: process.env.DB_HOST as string,
        port: process.env.DB_PORT as string,
        dialect: "postgres",
        directory: sequelizeModelFolder,
        logging: false,
        ...(!fs.existsSync(sqlPath) &&
          fs.existsSync(sequelizePath) && {
            tables: ["gql_users", "gql_admins"],
          }),
      } as any
    );
    await auto.run();
    console.log("✅ Sequelize config files created.");

    const initModels = require(`${sequelizeModelFolder}/init-models.js`);
    initModels(Postgres);
    console.log("✅ Sequelize models initialized.");
  } catch (err: any) {
    console.error(err.message);
    serverErrors.push(err.message);
  }
}
