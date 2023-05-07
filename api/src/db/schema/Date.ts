import { GraphQLScalarType, Kind } from "graphql";

const dateScalar = new GraphQLScalarType({
  name: "Date",
  description: "Date custom scalar type",
  serialize(value) {
    return new Date(value).toISOString(); // Convert outgoing Date to integer for JSON
  },
  parseValue(value) {
    return new Date(value).toISOString(); // Convert incoming integer to Date
  },
  parseLiteral(ast) {
    if (ast.kind === Kind.INT) {
      return new Date(parseInt(ast.value, 10)).toISOString(); // Convert hard-coded AST string to integer and then to Date
    }
    return null; // Invalid hard-coded value (not an integer)
  },
});

export function createDateSchema() {
  return `
    scalar Date
  `;
}

export function createDateResolver() {
  return {
    Date: dateScalar,
  };
}
