import * as auth from "controllers/auth";
import { Router } from "express";
import authMiddleware from "middlewares/auth";

const router = Router();

router.get("/verify", authMiddleware, auth.verify);
router.post("/users", auth.create);
router.post("/users/:id", authMiddleware, auth.update);
router.delete("/users/:id", authMiddleware, auth.remove);
router.post("/login", auth.login);
router.post("/logout", authMiddleware, auth.logout);
router.post("/refresh", auth.refresh);

export default router;
