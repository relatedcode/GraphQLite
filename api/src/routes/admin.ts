import { makeExecutableSchema } from "@graphql-tools/schema";
import * as admin from "controllers/admin";
import * as storage from "controllers/storage";
import { createDateResolver, createDateSchema } from "db/schema/Date";
import {
  createGQLAdminResolver,
  createGQLAdminSchema,
} from "db/schema/GQLAdmin";
import { createGQLUserResolver, createGQLUserSchema } from "db/schema/GQLUser";
import { Router } from "express";
import { graphqlHTTP } from "express-graphql";
import { merge } from "lodash";
import authMiddleware from "middlewares/auth";
import onlyAdmin from "middlewares/onlyAdmin";

const gqlUserSchema = createGQLUserSchema();
const gqlUserResolver = createGQLUserResolver();

const gqlAdminSchema = createGQLAdminSchema();
const gqlAdminResolver = createGQLAdminResolver();

const dateSchema = createDateSchema();
const dateResolver = createDateResolver();

/* Resolvers */
const adminResolvers = merge(gqlUserResolver, gqlAdminResolver, dateResolver);

/* Schemas */
const adminTypeDefs = [gqlUserSchema, gqlAdminSchema, dateSchema];

export const adminSchema = makeExecutableSchema({
  typeDefs: adminTypeDefs,
  resolvers: adminResolvers,
});

const router = Router();

router.get("/secret_key", authMiddleware, onlyAdmin, admin.getSecretKey);
router.get("/status", authMiddleware, onlyAdmin, admin.getSchemaStatus);
router.delete("/reset", authMiddleware, onlyAdmin, admin.resetServer);
router.delete(
  "/cleanup_database",
  authMiddleware,
  onlyAdmin,
  admin.cleanupDatabase
);

/* Admin Config endpoints */
router.get("/config", authMiddleware, onlyAdmin, admin.getConfigFiles);
router.post("/config", authMiddleware, onlyAdmin, admin.editConfigFiles);
router.get("/config/export", authMiddleware, onlyAdmin, admin.exportSchema);
router.post("/config/tables", authMiddleware, onlyAdmin, admin.createTable);

/* Admin Auth endpoints */
router.post("/auth/users", admin.create);
router.post("/auth/login", admin.login);
router.post("/auth/logout", authMiddleware, onlyAdmin, admin.logout);
router.post("/auth/refresh", admin.refresh);

/* Admin Storage endpoints */
router.post("/storage/b", authMiddleware, onlyAdmin, storage.createBucket);
router.delete(
  "/storage/b/:name",
  authMiddleware,
  onlyAdmin,
  storage.deleteBucket
);
router.get("/storage/b", authMiddleware, onlyAdmin, storage.listBuckets);
router.get(
  "/storage/b/:name/o",
  authMiddleware,
  onlyAdmin,
  storage.listObjects
);

router.use(
  "/graphql",
  authMiddleware,
  onlyAdmin,
  graphqlHTTP({
    schema: adminSchema,
    graphiql: false,
  })
);

export default router;
