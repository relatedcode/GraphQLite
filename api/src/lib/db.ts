import { Sequelize } from "sequelize/types";

export async function removeAllTables(database: Sequelize, op = "TRUNCATE") {
  let tables: any = await database.query(
    "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;",
    { type: "SELECT" }
  );
  tables = tables.map((table: any) => table[0]);

  await Promise.all(
    tables.map(async (table: string) => {
      await database.query(`${op} TABLE "${table}" CASCADE;`);
    })
  );
}
