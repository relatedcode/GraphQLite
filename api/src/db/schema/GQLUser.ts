import Postgres from "db/postgres";
import pubsub from "db/pubsub";
import { withFilter } from "utils/with-filter";

const MODEL_NAME = "gql_users";

export async function getGQLUserDB(filter: any) {
  const user = (await Postgres.models[MODEL_NAME].findOne(filter)) as any;
  return user.dataValues;
}

export async function createGQLUserDB(args: any) {
  const user = (await Postgres.models[MODEL_NAME].create(args)) as any;
  pubsub.publish(MODEL_NAME, {
    GQLUser: user.dataValues,
  });
}

export async function updateGQLUserDB(args: any) {
  const filter = {
    where: { objectId: args.objectId },
    returning: true,
  };
  const { objectId, ...updatedObject } = args;
  const user = (
    await Postgres.models[MODEL_NAME].update(updatedObject, filter)
  )[1][0] as any;
  pubsub.publish(MODEL_NAME, {
    GQLUser: user.dataValues,
  });
}

export function createGQLUserSchema() {
  return `
    type GQLUser {
      objectId: String!
      email: String!
      isDeleted: Boolean!
      createdAt: Date!
      updatedAt: Date!
    }
    type Subscription {
      GQLUser(objectId: String): GQLUser!
    }
    type Query {
      GQLUsers: [GQLUser]
    }
  `;
}

export function createGQLUserResolver() {
  return {
    Subscription: {
      GQLUser: {
        subscribe: withFilter(
          () => pubsub.asyncIterator(MODEL_NAME),
          (payload, args) => {
            if (args.objectId) {
              return payload.user.objectId === args.objectId;
            }
            return true;
          }
        ),
      },
    },
    Query: {
      GQLUsers: async (root: any, args: any) => {
        let filter = {};
        return await Postgres.models[MODEL_NAME].findAll({
          where: filter,
          order: [["createdAt", "ASC"]],
        });
      },
    },
  };
}
