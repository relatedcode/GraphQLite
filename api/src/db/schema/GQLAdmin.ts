import Postgres from "db/postgres";
import pubsub from "db/pubsub";
import { withFilter } from "utils/with-filter";

const MODEL_NAME = "gql_admins";

export async function getGQLAdminDB(filter: any) {
  const user = (await Postgres.models[MODEL_NAME].findOne(filter)) as any;
  return user.dataValues;
}

export async function createGQLAdminDB(args: any) {
  const user = (await Postgres.models[MODEL_NAME].create(args)) as any;
  pubsub.publish(MODEL_NAME, {
    GQLAdmin: user.dataValues,
  });
}

export async function updateGQLAdminDB(args: any) {
  const filter = {
    where: { objectId: args.objectId },
    returning: true,
  };
  const { objectId, ...updatedObject } = args;
  const user = (
    await Postgres.models[MODEL_NAME].update(updatedObject, filter)
  )[1][0] as any;
  pubsub.publish(MODEL_NAME, {
    GQLAdmin: user.dataValues,
  });
}

export function createGQLAdminSchema() {
  return `
    type GQLAdmin {
      objectId: String!
      email: String!
      isDeleted: Boolean!
      createdAt: Date!
      updatedAt: Date!
    }
    type Subscription {
      GQLAdmin(objectId: String): GQLAdmin!
    }
    type Query {
      GQLAdmins: [GQLAdmin]
    }
  `;
}

export function createGQLAdminResolver() {
  return {
    Subscription: {
      GQLAdmin: {
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
      GQLAdmins: async (root: any, args: any) => {
        let filter = {};
        return await Postgres.models[MODEL_NAME].findAll({
          where: filter,
          order: [["createdAt", "ASC"]],
        });
      },
    },
  };
}
