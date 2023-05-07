import { serverErrors } from "app";
import { filterRequestAttributes } from "controllers/admin";
import fs from "fs";
import path from "path";
import prettier from "prettier";
import { DataTypes, Sequelize } from "sequelize";

function capitalizeFirstLetter(string: string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

export function convertGraphQLToSequelizeType(type: string): string {
  if (type === "String") return "DataTypes.TEXT";
  if (type === "Int") return "DataTypes.INTEGER";
  if (type === "Float") return "DataTypes.DOUBLE";
  if (type === "Boolean") return "DataTypes.BOOLEAN";
  if (type === "Date") return "DataTypes.DATE";
  if (type === "[String]") return "DataTypes.ARRAY(DataTypes.TEXT)";
  if (type === "[Int]") return "DataTypes.ARRAY(DataTypes.INTEGER)";
  if (type === "[Float]") return "DataTypes.ARRAY(DataTypes.DOUBLE)";
  if (type === "[Boolean]") return "DataTypes.ARRAY(DataTypes.BOOLEAN)";
  if (type === "[Date]") return "DataTypes.ARRAY(DataTypes.DATE)";
  return "DataTypes.TEXT";
}

function checkIfArray(sequelizeType: string, graphQLType: string): string {
  if (sequelizeType.includes("[]")) return `[${graphQLType}]`;
  return graphQLType;
}

export function convertSequelizeType(type: string): string {
  if (type.includes("VARCHAR") || type.includes("TEXT"))
    return checkIfArray(type, "String");
  if (type.includes("INT")) return checkIfArray(type, "Int");
  if (
    type.includes("REAL") ||
    type.includes("DOUBLE") ||
    type.includes("DECIMAL") ||
    type.includes("FLOAT")
  )
    return checkIfArray(type, "Float");
  if (type.includes("BOOLEAN")) return checkIfArray(type, "Boolean");
  if (type.includes("DATE") || type.includes("TIMESTAMP"))
    return checkIfArray(type, "Date");
  if (type.includes("UUID")) return checkIfArray(type, "String");
  return checkIfArray(type, "String");
}

function checkIfArraySwift(
  sequelizeType: string,
  swiftType: [string, any]
): [string, any] {
  if (sequelizeType.includes("[]")) return [`[${swiftType[0]}]`, "[]"];
  return swiftType;
}

export function convertSequelizeToSwift(type: string): [string, any] {
  if (type.includes("VARCHAR") || type.includes("TEXT"))
    return checkIfArraySwift(type, ["String", '""']);
  if (type.includes("INT")) return checkIfArraySwift(type, ["Int", 0]);
  if (
    type.includes("REAL") ||
    type.includes("DECIMAL") ||
    type.includes("FLOAT")
  )
    return checkIfArraySwift(type, ["Float", 0]);
  if (type.includes("DOUBLE")) return checkIfArraySwift(type, ["Double", 0]);
  if (type.includes("BOOLEAN")) return checkIfArraySwift(type, ["Bool", false]);
  if (type.includes("DATE") || type.includes("TIMESTAMP"))
    return checkIfArraySwift(type, ["Date", "Date()"]);
  if (type.includes("UUID")) checkIfArraySwift(type, ["String", '""']);
  return checkIfArraySwift(type, ["String", '""']);
}

export function getModelName(name: string): string {
  if (name.slice(-1) === "s") {
    name = name.slice(0, -1);
  }
  return capitalizeFirstLetter(name);
}

export function autogenerateModel(
  sequelize: Sequelize,
  force = false,
  onlySchema = ""
) {
  try {
    const sequelizePath = path.resolve(__dirname, "../../config/sequelize.js");
    const sqlPath = path.resolve(__dirname, "../../config/schema.sql");

    if (fs.existsSync(sqlPath) && fs.existsSync(sequelizePath))
      throw new Error(
        "Collision error. Please provide either schema.sql or sequelize.js."
      );

    if (!fs.existsSync(sqlPath) && !fs.existsSync(sequelizePath))
      throw new Error("Please provide either schema.sql or sequelize.js.");

    if (!fs.existsSync(sequelizePath)) return;

    const graphqlPath = path.resolve(__dirname, "../../config/schema.graphql");
    let graphql = fs.existsSync(graphqlPath)
      ? fs.readFileSync(graphqlPath).toString()
      : "";

    const resolversPath = path.resolve(__dirname, "../../config/resolvers.js");
    let resolvers = fs.existsSync(resolversPath)
      ? fs.readFileSync(resolversPath).toString()
      : "";

    const cacheKey = Object.keys(require.cache).filter((x) =>
      x.includes("/app/config/sequelize.js")
    )[0];
    if (cacheKey) delete require.cache[cacheKey];

    const exportedModels = require(sequelizePath);

    const schemas: any[] = [];

    Object.keys(exportedModels).forEach((exportedModel) => {
      const model = exportedModels[exportedModel](sequelize, DataTypes);

      if (onlySchema && onlySchema !== model.name) return;

      model.sync({ alter: true });

      schemas.push({
        model: getModelName(model.name),
        sequelizeModelName: model.name,
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
              isArray: model.rawAttributes[key].type
                .toString({})
                .includes("[]"),
              required: !model.rawAttributes[key].allowNull,
            };
          })
          .filter((type: any) => type.name !== "objectId"),
      });
    });

    if ((graphql || resolvers) && !force && !onlySchema) return;

    if (force) {
      graphql = "";
      resolvers = "";
    }

    if (!onlySchema || !graphql) {
      graphql = `
      input TableDateFilterInput {
        eq: String
        ne: String
        gt: String
        gte: String
        lt: String
        lte: String
      }
  
      input TableStringFilterInput {
        eq: String
        ne: String
        startsWith: String
        endsWith: String
        substring: String
      }
      
      input TableFloatFilterInput {
        eq: Float
        ne: Float
        gt: Float
        gte: Float
        lt: Float
        lte: Float
        between: [Float]
        notBetween: [Float]
      }
      
      input TableIntFilterInput {
        eq: Int
        ne: Int
        gt: Int
        gte: Int
        lt: Int
        lte: Int
        between: [Int]
        notBetween: [Int]
      }
      
      input TableBooleanFilterInput {
        eq: Boolean
        ne: Boolean
      }
      
      input TableStringArrayFilterInput {
        contains: String
        eq: [String]
        ne: [String]
      }
      
      input TableFloatArrayFilterInput {
        contains: Float
        eq: [Float]
        ne: [Float]
      }
      
      input TableIntArrayFilterInput {
        contains: Int
        eq: [Int]
        ne: [Int]
      }
      
      input TableBooleanArrayFilterInput {
        contains: Boolean
        eq: [Boolean]
        ne: [Boolean]
      }
      
      input TableDateArrayFilterInput {
        contains: Date
        eq: [Date]
        ne: [Date]
      }`;
    }

    schemas.forEach((schema) => {
      graphql = `
  ${graphql}
  
  type ${schema.model} {
    objectId: String!
    ${schema.types
      .map(
        (type: any) => `${type.name}: ${type.type}${type.required ? "!" : ""}`
      )
      .join("\n  ")}
  }
  
  ${graphql.includes("type Subscription") ? "extend " : ""}type Subscription {
    onCreate${schema.model}(objectId: String, ${schema.types
        .map((type: any) => `${type.name}: ${type.type}`)
        .join(", ")}): ${schema.model}
    onUpdate${schema.model}(objectId: String, ${schema.types
        .map((type: any) => `${type.name}: ${type.type}`)
        .join(", ")}): ${schema.model}
    onDelete${schema.model}(objectId: String, ${schema.types
        .map((type: any) => `${type.name}: ${type.type}`)
        .join(", ")}): ${schema.model}
  }
  
  ${graphql.includes("type Query") ? "extend " : ""}type Query {
    get${schema.model}(objectId: String!): ${schema.model}
    list${schema.model}s(filter: Table${schema.model}FilterInput): [${
        schema.model
      }]
  }
  
  ${graphql.includes("type Mutation") ? "extend " : ""}type Mutation {
    create${schema.model}(objectId: String!, ${schema.types
        .map((type: any) =>
          filterRequestAttributes(type, schema)
            ? `${type.name}: ${type.type}${type.required ? "!" : ""}`
            : ""
        )
        .join(", ")}): ${schema.model}
    update${schema.model}(objectId: String!, ${schema.types
        .map((type: any) =>
          filterRequestAttributes(type, schema)
            ? `${type.name}: ${type.type}`
            : ""
        )
        .join(", ")}): ${schema.model}
    delete${schema.model}(objectId: String!): ${schema.model}
  }
  
  input Table${schema.model}FilterInput {
    objectId: TableStringFilterInput
    ${schema.types
      .map(
        (type: any) =>
          `${type.name}: Table${type.type.replace("[", "").replace("]", "")}${
            type.isArray ? "Array" : ""
          }FilterInput`
      )
      .join("\n  ")}
  }
  `;

      resolvers = `
  ${resolvers}
      
  const MODEL_NAME_${schema.model.toUpperCase()} = "${
        schema.sequelizeModelName
      }";
  module.exports.create${schema.model}Resolver = function (
    database,
    Operation,
    withFilter,
    pubsub
  ) {
    return {
      Subscription: {
        onCreate${schema.model}: {
          subscribe: withFilter(
            () => pubsub.asyncIterator("${schema.model.toUpperCase()}_CREATE"),
            (payload, args) => {
              if (args.objectId) {
                return payload.onCreate${
                  schema.model
                }.objectId === args.objectId;
              }
              ${schema.types
                .map(
                  (type: any) => `if (args.${type.name}) {
                return payload.onCreate${schema.model}.${type.name} === args.${type.name};
              }`
                )
                .join("\n")}
              return true;
            }
          ),
        },
        onUpdate${schema.model}: {
          subscribe: withFilter(
            () => pubsub.asyncIterator("${schema.model.toUpperCase()}_UPDATE"),
            (payload, args) => {
              if (args.objectId) {
                return payload.onUpdate${
                  schema.model
                }.objectId === args.objectId;
              }
              ${schema.types
                .map(
                  (type: any) => `if (args.${type.name}) {
                return payload.onUpdate${schema.model}.${type.name} === args.${type.name};
              }`
                )
                .join("\n")}
              return true;
            }
          ),
        },
        onDelete${schema.model}: {
          subscribe: withFilter(
            () => pubsub.asyncIterator("${schema.model.toUpperCase()}_DELETE"),
            (payload, args) => {
              if (args.objectId) {
                return payload.onDelete${
                  schema.model
                }.objectId === args.objectId;
              }
              ${schema.types
                .map(
                  (type: any) => `if (args.${type.name}) {
                return payload.onDelete${schema.model}.${type.name} === args.${type.name};
              }`
                )
                .join("\n")}
              return true;
            }
          ),
        }
      },
      Query: {
        get${schema.model}: async (root, args) => {
          return (
            await database.models[MODEL_NAME_${schema.model.toUpperCase()}].findOne({
              where: {
                objectId: {
                  [Operation.eq]: args.objectId,
                },
              },
            })
          ).dataValues;
        },
        list${schema.model}s: async (root, args) => {
          const { filter } = args;
          return await database.models[MODEL_NAME_${schema.model.toUpperCase()}].findAll({
            where: filter ? {
              ${schema.types
                .map((type: any) => {
                  return `...(filter.${type.name}) && {
                            ${type.name}: {
                              ${
                                type.type === "String"
                                  ? `...(filter.${type.name}.eq !== undefined) && { [Operation.eq]: filter.${type.name}.eq },
                                    ...(filter.${type.name}.ne !== undefined) && { [Operation.ne]: filter.${type.name}.ne },
                                    ...(filter.${type.name}.substring !== undefined) && { [Operation.substring]: filter.${type.name}.substring },
                                    ...(filter.${type.name}.startsWith !== undefined) && { [Operation.startsWith]: filter.${type.name}.startsWith },
                                    ...(filter.${type.name}.endsWith !== undefined) && { [Operation.endsWith]: filter.${type.name}.endsWith },`
                                  : ""
                              }
                              ${
                                type.type === "Date"
                                  ? `...(filter.${type.name}.eq !== undefined) && { [Operation.eq]: filter.${type.name}.eq },
                                    ...(filter.${type.name}.ne !== undefined) && { [Operation.ne]: filter.${type.name}.ne },
                                    ...(filter.${type.name}.gt !== undefined) && { [Operation.gt]: filter.${type.name}.gt },
                                    ...(filter.${type.name}.gte !== undefined) && { [Operation.gte]: filter.${type.name}.gte },
                                    ...(filter.${type.name}.lt !== undefined) && { [Operation.lt]: filter.${type.name}.lt },
                                    ...(filter.${type.name}.lte !== undefined) && { [Operation.lte]: filter.${type.name}.lte },`
                                  : ""
                              }
                              ${
                                type.type === "Int" || type.type === "Float"
                                  ? `...(filter.${type.name}.eq !== undefined) && { [Operation.eq]: filter.${type.name}.eq },
                                    ...(filter.${type.name}.ne !== undefined) && { [Operation.ne]: filter.${type.name}.ne },
                                    ...(filter.${type.name}.gt !== undefined) && { [Operation.gt]: filter.${type.name}.gt },
                                    ...(filter.${type.name}.gte !== undefined) && { [Operation.gte]: filter.${type.name}.gte },
                                    ...(filter.${type.name}.lt !== undefined) && { [Operation.lt]: filter.${type.name}.lt },
                                    ...(filter.${type.name}.lte !== undefined) && { [Operation.lte]: filter.${type.name}.lte },
                                    ...(filter.${type.name}.between !== undefined) && { [Operation.between]: filter.${type.name}.between },
                                    ...(filter.${type.name}.notBetween !== undefined) && { [Operation.notBetween]: filter.${type.name}.notBetween },`
                                  : ""
                              }
                              ${
                                type.type === "Boolean"
                                  ? `...(filter.${type.name}.eq !== undefined) && { [Operation.eq]: filter.${type.name}.eq },
                                    ...(filter.${type.name}.ne !== undefined) && { [Operation.ne]: filter.${type.name}.ne },`
                                  : ""
                              }
                              ${
                                type.isArray
                                  ? `...(filter.${type.name}.contains !== undefined) && { [Operation.contains]: [filter.${type.name}.contains] },
                                    ...(filter.${type.name}.eq !== undefined) && { [Operation.eq]: filter.${type.name}.eq },
                                    ...(filter.${type.name}.ne !== undefined) && { [Operation.ne]: filter.${type.name}.ne },`
                                  : ""
                              }
                            }
                          },`;
                })
                .join("\n")}
            } : {},
          });
        }
      },
      Mutation: {
        create${schema.model}: async (root, args, context, info) => {
          const object = await database.models[MODEL_NAME_${schema.model.toUpperCase()}].create(args);
          pubsub.publish("${schema.model.toUpperCase()}_CREATE", {
            onCreate${schema.model}: object.dataValues,
          });
          return object.dataValues;
        },
        update${schema.model}: async (root, args, context, info) => {
          const filter = {
            where: { objectId: args.objectId },
            returning: true,
          };
          const object = (
            await database.models[MODEL_NAME_${schema.model.toUpperCase()}].update(args, filter)
          )[1][0];
          pubsub.publish("${schema.model.toUpperCase()}_UPDATE", {
            onUpdate${schema.model}: object.dataValues,
          });
          return object.dataValues;
        },
        delete${schema.model}: async (root, args, context, info) => {
          const filter = {
            where: { objectId: args.objectId },
          };
          const object = await database.models[MODEL_NAME_${schema.model.toUpperCase()}].findOne(filter);
          await database.models[MODEL_NAME_${schema.model.toUpperCase()}].destroy(filter);
          pubsub.publish("${schema.model.toUpperCase()}_DELETE", {
            onDelete${schema.model}: object.dataValues,
          });
          return object.dataValues;
        },
      },
    };
  };
  `;
    });

    fs.writeFileSync(
      graphqlPath,
      prettier.format(graphql, { parser: "graphql" })
    );
    fs.writeFileSync(
      resolversPath,
      prettier.format(resolvers, { parser: "babel" })
    );
  } catch (err: any) {
    console.error(err.message);
    serverErrors.push(err.message);
  }
}
