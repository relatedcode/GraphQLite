import { serverErrors } from "app";
import { s3 } from "controllers/storage";
import {
  autogenerateModel,
  convertGraphQLToSequelizeType,
  convertSequelizeToSwift,
  convertSequelizeType,
  getModelName,
} from "db/auto-generate";
import database from "db/postgres";
import { flushall } from "db/redis";
import { createGQLAdminDB, getGQLAdminDB } from "db/schema/GQLAdmin";
import express from "express";
import fs from "fs";
import { JWT_EXPIRES } from "lib/config";
import { removeAllTables } from "lib/db";
import path from "path";
import prettier from "prettier";
import { hashPassword, verifyPassword } from "utils/hash";
import { createToken } from "utils/jwt";
import {
  createRefreshToken,
  deleteRefreshToken,
  verifyRefreshToken,
} from "utils/refresh-token";
import { v4 as uuidv4 } from "uuid";

function generateDataForGraphQLType(type: string) {
  if (type === "String") return `"text"`;
  if (type === "Int") return 123;
  if (type === "Float") return 123.123;
  if (type === "Boolean") return true;
  if (type === "Date") return `"1970-01-01T01:01:01.000Z"`;
  if (type === "[String]") return `["text"]`;
  if (type === "[Int]") return `[123]`;
  if (type === "[Float]") return `[123.123]`;
  if (type === "[Boolean]") return `[true]`;
  if (type === "[Date]") return `["1970-01-01T01:01:01.000Z"]`;
  return `"text"`;
}

async function deleteBucketAndFiles(name: string) {
  const objects = await s3.listObjects({ Bucket: name }).promise();
  if (objects.Contents?.length) {
    // delete all s3 objects
    await s3
      .deleteObjects({
        Bucket: name,
        Delete: {
          Objects: objects.Contents.map((o) => ({ Key: o.Key! })),
        },
      })
      .promise();
  }
  // delete bucket
  await s3.deleteBucket({ Bucket: name }).promise();
}

function getSequelizeFieldsFilterConditions(
  timestamps: boolean,
  fieldName: string
) {
  return timestamps
    ? fieldName !== "createdAt" && fieldName !== "updatedAt"
    : true;
}

export function filterRequestAttributes(type: any, schema: any) {
  return schema.timestamps
    ? type.name !== schema.updatedAt && type.name !== schema.createdAt
    : true;
}

export const logout = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { uid } = res.locals;
    const { refreshToken } = req.body;

    await deleteRefreshToken(uid, refreshToken);

    res.locals.data = {
      success: true,
    };
    return next("router");
  } catch (err) {
    return next(err);
  }
};

export const refresh = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { refreshToken } = req.body;

    const id = await verifyRefreshToken(refreshToken);

    if (id === "superadmin") {
      const token = createToken({
        sub: id,
        admin: true,
        user: {
          uid: id,
          email: process.env.ADMIN_EMAIL,
        },
      });

      res.locals.data = {
        uid: id,
        idToken: token,
        refreshToken,
        expires: parseInt(JWT_EXPIRES),
      };
      return next("router");
    }

    const user = await getGQLAdminDB({ where: { objectId: id } });

    const token = createToken({
      sub: id,
      admin: true,
      user: {
        uid: id,
        email: user.email,
      },
    });

    res.locals.data = {
      uid: id,
      idToken: token,
      refreshToken,
      expires: parseInt(JWT_EXPIRES),
    };
    return next("router");
  } catch (err) {
    return next(err);
  }
};

export const create = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { email, password } = req.body;

    const id = uuidv4();
    await createGQLAdminDB({
      objectId: id,
      email,
      passwordHash: hashPassword(password),
    });

    const token = createToken({
      sub: id,
      admin: true,
      user: {
        uid: id,
        email,
      },
    });

    const refreshToken = await createRefreshToken(id);

    res.locals.data = {
      uid: id,
      idToken: token,
      refreshToken,
      expires: parseInt(JWT_EXPIRES),
    };
    return next("router");
  } catch (err: any) {
    if (err.message === "Validation error")
      err.message =
        "This email address is already associated with an existing user.";
    return next(err);
  }
};

export const login = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { email, password } = req.body;

    if (
      email === process.env.ADMIN_EMAIL &&
      password === process.env.ADMIN_PASSWORD
    ) {
      const id = "superadmin";
      const token = createToken({
        sub: id,
        admin: true,
        user: {
          uid: id,
          email: process.env.ADMIN_EMAIL,
        },
      });
      const refreshToken = await createRefreshToken(id);

      res.locals.data = {
        uid: id,
        idToken: token,
        refreshToken,
        expires: parseInt(JWT_EXPIRES),
      };
      return next("router");
    }

    const user = await getGQLAdminDB({ where: { email } });
    const id = user.objectId;

    if (!verifyPassword(password, user.passwordHash))
      throw new Error("Your password is invalid.");

    const token = createToken({
      sub: id,
      admin: true,
      user: {
        uid: id,
        email: user.email,
      },
    });
    const refreshToken = await createRefreshToken(id);

    res.locals.data = {
      uid: id,
      idToken: token,
      refreshToken,
      expires: parseInt(JWT_EXPIRES),
    };
    return next("router");
  } catch (err: any) {
    if (err.message === "Cannot read property 'dataValues' of null")
      err.message = "The email is not associated with an existing user.";
    return next(err);
  }
};

export const getSecretKey = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    res.locals.data = {
      key: process.env.SECRET_KEY,
    };
    return next("router");
  } catch (err: any) {
    return next(err);
  }
};

export const getConfigFiles = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    let resolvers = "";
    const resolversPath = path.resolve(__dirname, "../../config/resolvers.js");
    if (fs.existsSync(resolversPath))
      resolvers = fs.readFileSync(resolversPath).toString();

    let schemaSQL = "";
    const schemaSQLPath = path.resolve(__dirname, "../../config/schema.sql");
    if (fs.existsSync(schemaSQLPath))
      schemaSQL = fs.readFileSync(schemaSQLPath).toString();

    let schemaGraphQL = "";
    const schemaGraphQLPath = path.resolve(
      __dirname,
      "../../config/schema.graphql"
    );
    if (fs.existsSync(schemaGraphQLPath))
      schemaGraphQL = fs.readFileSync(schemaGraphQLPath).toString();

    let sequelize = "";
    const sequelizePath = path.resolve(__dirname, "../../config/sequelize.js");
    if (fs.existsSync(sequelizePath))
      sequelize = fs.readFileSync(sequelizePath).toString();

    res.locals.data = {
      resolvers,
      schemaSQL,
      schemaGraphQL,
      sequelize,
    };
    return next("router");
  } catch (err: any) {
    return next(err);
  }
};

export const getSchemaStatus = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    res.locals.data = {
      errors: serverErrors.length ? serverErrors : null,
    };
    return next("router");
  } catch (err: any) {
    return next(err);
  }
};

export const editConfigFiles = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { resolvers, schemaGraphQL, schemaSQL, sequelize } = req.body;

    // Get config files path
    const resolversPath = path.resolve(__dirname, "../../config/resolvers.js");
    const schemaGraphQLPath = path.resolve(
      __dirname,
      "../../config/schema.graphql"
    );
    const schemaSQLPath = path.resolve(__dirname, "../../config/schema.sql");
    const sequelizePath = path.resolve(__dirname, "../../config/sequelize.js");

    /*
    If sequelize input is provided, then delete all other config files and write the new sequelize file.
    Then when the server starts, it will read the new sequelize file and create from scratch all the config files.
    */
    if (sequelize) {
      if (fs.existsSync(resolversPath)) fs.unlinkSync(resolversPath);
      if (fs.existsSync(schemaGraphQLPath)) fs.unlinkSync(schemaGraphQLPath);
      if (fs.existsSync(schemaSQLPath)) fs.unlinkSync(schemaSQLPath);
      fs.writeFileSync(sequelizePath, sequelize);

      autogenerateModel(database, true);

      res.locals.data = {
        success: true,
      };
      return next("router");
    }

    if (resolvers) {
      fs.writeFileSync(resolversPath, resolvers);
    }

    if (schemaGraphQL) {
      fs.writeFileSync(schemaGraphQLPath, schemaGraphQL);
    }

    if (schemaSQL) {
      fs.writeFileSync(schemaSQLPath, schemaSQL);
    }

    res.locals.data = {
      success: true,
    };
    return next("router");
  } catch (err: any) {
    return next(err);
  }
};

export const exportSchema = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { origin, type = "graphql" } = req.query;

    const schemas: any[] = [];

    // Retrieve and build the schema
    Object.keys(database.models)
      .filter((s) => !["gql_users", "gql_admins"].includes(s))
      .forEach((modelName: string) => {
        const model = database.models[modelName];
        schemas.push({
          model: getModelName(model.name),
          timestamps: model.options.timestamps,
          createdAt: model.options.createdAt || "createdAt",
          updatedAt: model.options.updatedAt || "updatedAt",
          types: Object.keys(model.rawAttributes)
            .map((key) => {
              return {
                name: key,
                type: convertSequelizeType(
                  model.rawAttributes[key].type.toString({})
                ),
                swiftType: convertSequelizeToSwift(
                  model.rawAttributes[key].type.toString({})
                ),
                required: !model.rawAttributes[key].allowNull,
              };
            })
            .filter((type: any) => type.name !== "objectId"),
        });
      });

    let fileToExport: any;

    if (type === "graphql") {
      fileToExport = {
        title: "GraphQLite",
        requests: [],
      };

      schemas.forEach((schema) => {
        const getRequest = `
    query Get${schema.model}($objectId: String!) {
      get${schema.model}(objectId: $objectId) {
        objectId
        ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
      }
    }
    `;

        const listRequest = `
    query List${schema.model}s($filter: Table${schema.model}FilterInput) {
      list${schema.model}s(filter: $filter) {
        objectId
        ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
      }
    }
    `;

        const createMutation = `
    mutation Create${schema.model}($objectId: String!, ${schema.types
          .map((type: any) =>
            filterRequestAttributes(type, schema)
              ? `$${type.name}: ${type.type}${type.required ? "!" : ""}`
              : ""
          )
          .join(", ")}) {
      create${schema.model}(objectId: $objectId, ${schema.types
          .map((type: any) =>
            filterRequestAttributes(type, schema)
              ? `${type.name}: $${type.name}`
              : ""
          )
          .join(", ")}) {
          objectId
          ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
        }
      }
    `;

        const updateMutation = `
    mutation Update${schema.model}($objectId: String!, ${schema.types
          .map((type: any) =>
            filterRequestAttributes(type, schema)
              ? `$${type.name}: ${type.type}`
              : ""
          )
          .join(", ")}) {
        update${schema.model}(objectId: $objectId, ${schema.types
          .map((type: any) =>
            filterRequestAttributes(type, schema)
              ? `${type.name}: $${type.name}`
              : ""
          )
          .join(", ")}) {
            objectId
            ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
          }
        }
    `;

        const deleteMutation = `
    mutation Delete${schema.model}($objectId: String!) {
      delete${schema.model}(objectId: $objectId) {
        objectId
        ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
      }
    }
    `;

        const createSubscription = `
    subscription OnCreate${schema.model}($objectId: String, ${schema.types
          .map((type: any) => `$${type.name}: ${type.type}`)
          .join(", ")}) {
              onCreate${schema.model}(objectId: $objectId, ${schema.types
          .map((type: any) => `${type.name}: $${type.name}`)
          .join(", ")}) {
                objectId
                ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
              }
            }
    `;

        const updateSubscription = `
    subscription OnUpdate${schema.model}($objectId: String, ${schema.types
          .map((type: any) => `$${type.name}: ${type.type}`)
          .join(", ")}) {
              onUpdate${schema.model}(objectId: $objectId, ${schema.types
          .map((type: any) => `${type.name}: $${type.name}`)
          .join(", ")}) {
                objectId
                ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
              }
            }
    `;

        const deleteSubscription = `
    subscription OnDelete${schema.model}($objectId: String, ${schema.types
          .map((type: any) => `$${type.name}: ${type.type}`)
          .join(", ")}) {
              onDelete${schema.model}(objectId: $objectId, ${schema.types
          .map((type: any) => `${type.name}: $${type.name}`)
          .join(", ")}) {
                objectId
                ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
              }
            }
    `;

        const headers = JSON.stringify(
          {
            Authorization: `Bearer ${process.env.SECRET_KEY}`,
          },
          null,
          2
        );

        const link = `http://${origin}:4000/graphql`;

        fileToExport.requests = [
          ...fileToExport.requests,
          {
            title: `Get${schema.model}`,
            link,
            body: prettier.format(getRequest, { parser: "graphql" }),
            headers,
            variables: JSON.stringify({ objectId: "id123" }, null, 2),
            wsProtocol: "",
            appSyncKey: "",
          },
          {
            title: `List${schema.model}s`,
            link,
            body: prettier.format(listRequest, { parser: "graphql" }),
            headers,
            variables: JSON.stringify(
              {
                filter: {},
              },
              null,
              2
            ),
            wsProtocol: "",
            appSyncKey: "",
          },
          {
            title: `Create${schema.model}`,
            link,
            body: prettier.format(createMutation, { parser: "graphql" }),
            headers,
            variables: JSON.stringify(
              JSON.parse(`{
                "objectId": "id123", 
                ${schema.types
                  .filter((type: any) => filterRequestAttributes(type, schema))
                  .map(
                    (type: any) =>
                      `"${type.name}": ${generateDataForGraphQLType(type.type)}`
                  )
                  .join(",")}
              }`),
              null,
              2
            ),
            wsProtocol: "",
            appSyncKey: "",
          },
          {
            title: `Update${schema.model}`,
            link,
            body: prettier.format(updateMutation, { parser: "graphql" }),
            headers,
            variables: JSON.stringify(
              JSON.parse(`{
                "objectId": "id123", 
                ${schema.types
                  .filter((type: any) => filterRequestAttributes(type, schema))
                  .map(
                    (type: any) =>
                      `"${type.name}": ${generateDataForGraphQLType(type.type)}`
                  )
                  .join(",")}
              }`),
              null,
              2
            ),
            wsProtocol: "",
            appSyncKey: "",
          },
          {
            title: `Delete${schema.model}`,
            link,
            body: prettier.format(deleteMutation, { parser: "graphql" }),
            headers,
            variables: JSON.stringify({ objectId: "id123" }, null, 2),
            wsProtocol: "",
            appSyncKey: "",
          },
          {
            title: `OnCreate${schema.model}`,
            link: link.replace("http://", "ws://"),
            body: prettier.format(createSubscription, { parser: "graphql" }),
            headers,
            variables: JSON.stringify({}, null, 2),
            wsProtocol: "graphql-transport-ws",
            appSyncKey: "",
          },
          {
            title: `OnUpdate${schema.model}`,
            link: link.replace("http://", "ws://"),
            body: prettier.format(updateSubscription, { parser: "graphql" }),
            headers,
            variables: JSON.stringify({}, null, 2),
            wsProtocol: "graphql-transport-ws",
            appSyncKey: "",
          },
          {
            title: `OnDelete${schema.model}`,
            link: link.replace("http://", "ws://"),
            body: prettier.format(deleteSubscription, { parser: "graphql" }),
            headers,
            variables: JSON.stringify({}, null, 2),
            wsProtocol: "graphql-transport-ws",
            appSyncKey: "",
          },
        ];
      });
    } else if (type === "ios") {
      fileToExport = "";

      schemas.forEach((schema) => {
        // prettier-ignore
        fileToExport = `
${fileToExport}

class ${schema.model}: NSObject, GQLObject {
  @objc var objectId: String = ""
${schema.types.map((type: any) => `  @objc var ${type.name}: ${type.swiftType[0]} = ${type.swiftType[1]}`).join("\n")}

  class func primaryKey() -> String {
    return "objectId"
  }
}
`;
      });

      fileToExport = {
        data: `${fileToExport.trim()}\n`,
      };
    } else if (type === "client") {
      fileToExport = "";

      schemas.forEach((schema) => {
        const getRequest = `
    query Get${schema.model}($objectId: String!) {
      get${schema.model}(objectId: $objectId) {
        objectId
        ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
      }
    }
    `;

        const listRequest = `
    query List${schema.model}s($filter: Table${schema.model}FilterInput) {
      list${schema.model}s(filter: $filter) {
        objectId
        ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
      }
    }
    `;

        const createMutation = `
    mutation Create${schema.model}($objectId: String!, ${schema.types
          .map((type: any) =>
            filterRequestAttributes(type, schema)
              ? `$${type.name}: ${type.type}${type.required ? "!" : ""}`
              : ""
          )
          .join(", ")}) {
      create${schema.model}(objectId: $objectId, ${schema.types
          .map((type: any) =>
            filterRequestAttributes(type, schema)
              ? `${type.name}: $${type.name}`
              : ""
          )
          .join(", ")}) {
          objectId
          ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
        }
      }
    `;

        const updateMutation = `
    mutation Update${schema.model}($objectId: String!, ${schema.types
          .map((type: any) =>
            filterRequestAttributes(type, schema)
              ? `$${type.name}: ${type.type}`
              : ""
          )
          .join(", ")}) {
        update${schema.model}(objectId: $objectId, ${schema.types
          .map((type: any) =>
            filterRequestAttributes(type, schema)
              ? `${type.name}: $${type.name}`
              : ""
          )
          .join(", ")}) {
            objectId
            ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
          }
        }
    `;

        const deleteMutation = `
    mutation Delete${schema.model}($objectId: String!) {
      delete${schema.model}(objectId: $objectId) {
        objectId
        ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
      }
    }
    `;

        const createSubscription = `
    subscription OnCreate${schema.model}($objectId: String, ${schema.types
          .map((type: any) => `$${type.name}: ${type.type}`)
          .join(", ")}) {
              onCreate${schema.model}(objectId: $objectId, ${schema.types
          .map((type: any) => `${type.name}: $${type.name}`)
          .join(", ")}) {
                objectId
                ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
              }
            }
    `;

        const updateSubscription = `
    subscription OnUpdate${schema.model}($objectId: String, ${schema.types
          .map((type: any) => `$${type.name}: ${type.type}`)
          .join(", ")}) {
              onUpdate${schema.model}(objectId: $objectId, ${schema.types
          .map((type: any) => `${type.name}: $${type.name}`)
          .join(", ")}) {
                objectId
                ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
              }
            }
    `;

        const deleteSubscription = `
    subscription OnDelete${schema.model}($objectId: String, ${schema.types
          .map((type: any) => `$${type.name}: ${type.type}`)
          .join(", ")}) {
              onDelete${schema.model}(objectId: $objectId, ${schema.types
          .map((type: any) => `${type.name}: $${type.name}`)
          .join(", ")}) {
                objectId
                ${schema.types.map((type: any) => `${type.name}`).join("\n  ")}
              }
            }
    `;

        fileToExport = `
${fileToExport}

${getRequest}

${listRequest}

${createMutation}

${updateMutation}

${deleteMutation}

${createSubscription}

${updateSubscription}

${deleteSubscription}
    `;
      });

      fileToExport = {
        data: prettier.format(fileToExport, { parser: "graphql" }).trim(),
      };
    }

    res.locals.data = fileToExport;
    return next("router");
  } catch (err: any) {
    return next(err);
  }
};

export const createTable = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { fields, tableName, timestamps } = req.body;

    // Get config files path
    const resolversPath = path.resolve(__dirname, "../../config/resolvers.js");
    const schemaGraphQLPath = path.resolve(
      __dirname,
      "../../config/schema.graphql"
    );
    const schemaSQLPath = path.resolve(__dirname, "../../config/schema.sql");
    const sequelizePath = path.resolve(__dirname, "../../config/sequelize.js");

    let sequelize = "";
    if (fs.existsSync(sequelizePath)) {
      sequelize = fs.readFileSync(sequelizePath).toString();
    }

    sequelize = `
${sequelize}

module.exports.${tableName}Schema = function (sequelize, DataTypes) {
  return sequelize.define(
    "${tableName}",
    {
      objectId: {
        type: DataTypes.STRING(255),
        allowNull: false,
        primaryKey: true,
      },
      ${fields
        .filter(
          (field: any) =>
            field.name !== "objectId" &&
            getSequelizeFieldsFilterConditions(timestamps, field.name)
        )
        .filter((field: any) => !!field.name)
        .map((field: any) => {
          return `${field.name}: {
          type: ${convertGraphQLToSequelizeType(field.type)},
          allowNull: ${field.required ? "false" : "true"},
        }`;
        })}
    }, {
      timestamps: ${timestamps === false ? "false" : "true"},
      tableName: "${tableName}",
    });
};
`;

    if (fs.existsSync(schemaSQLPath)) {
      fs.unlinkSync(schemaSQLPath);
      if (fs.existsSync(resolversPath)) fs.unlinkSync(resolversPath);
      if (fs.existsSync(schemaGraphQLPath)) fs.unlinkSync(schemaGraphQLPath);
    }

    fs.writeFileSync(
      sequelizePath,
      prettier.format(sequelize, { parser: "babel" })
    );

    autogenerateModel(database, false, tableName);

    res.locals.data = {
      success: true,
    };
    return next("router");
  } catch (err: any) {
    return next(err);
  }
};

export const resetServer = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    await removeAllTables(database, "DROP");
    await flushall();

    // Delete buckets
    const buckets = await s3.listBuckets().promise();
    if (buckets.Buckets?.length) {
      await Promise.all(
        buckets.Buckets.map(
          async (bucket) => await deleteBucketAndFiles(bucket.Name!)
        )
      );
    }

    // Get config files path
    const resolversPath = path.resolve(__dirname, "../../config/resolvers.js");
    const schemaGraphQLPath = path.resolve(
      __dirname,
      "../../config/schema.graphql"
    );
    const schemaSQLPath = path.resolve(__dirname, "../../config/schema.sql");
    const sequelizePath = path.resolve(__dirname, "../../config/sequelize.js");
    const bucketsPath = path.resolve(__dirname, "../../config/buckets.txt");

    if (fs.existsSync(resolversPath)) fs.unlinkSync(resolversPath);
    if (fs.existsSync(schemaGraphQLPath)) fs.unlinkSync(schemaGraphQLPath);
    if (fs.existsSync(schemaSQLPath)) fs.unlinkSync(schemaSQLPath);
    if (fs.existsSync(sequelizePath)) fs.unlinkSync(sequelizePath);
    if (fs.existsSync(bucketsPath)) fs.unlinkSync(bucketsPath);

    const logsPath = path.resolve(__dirname, "../../config/logs.txt");
    fs.writeFileSync(
      logsPath,
      `GQLServer reseted at ${new Date().toISOString()}`
    );

    res.locals.data = {
      success: true,
    };
    return next("router");
  } catch (err: any) {
    return next(err);
  }
};

export const cleanupDatabase = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    await removeAllTables(database);

    res.locals.data = {
      success: true,
    };
    return next("router");
  } catch (err: any) {
    return next(err);
  }
};
