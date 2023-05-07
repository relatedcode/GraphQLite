import * as storage from "controllers/storage";
import { Router } from "express";
import authMiddleware from "middlewares/auth";

const router = Router();

router.post("/b/:name/upload", authMiddleware, storage.uploadObject);
router.get("/b/:name/o/:key", storage.getObject);
router.delete("/b/:name/o/:key", authMiddleware, storage.deleteObject);

export default router;
