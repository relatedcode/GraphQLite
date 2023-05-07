import express from "express";
import { verifyToken } from "utils/jwt";

export const checkJWT = async (token?: string, isAdmin = false) => {
  if (!token) return false;
  try {
    const decodedToken = (await verifyToken(token)) as any;
    if (isAdmin && !decodedToken.admin) return false;
    return true;
  } catch (err) {
    return false;
  }
};

const authMiddleware = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const token = req.headers?.authorization?.split("Bearer ")[1];
    if (!token)
      throw new Error("The function must be called by an authenticated user.");

    if (token === process.env.SECRET_KEY) {
      res.locals.admin = true;
      return next();
    }

    const decodedToken = (await verifyToken(token)) as any;

    res.locals.uid = decodedToken.sub;
    res.locals.user = decodedToken.user;
    res.locals.admin = decodedToken.admin;
    return next();
  } catch (err: any) {
    if (err.message === "jwt expired")
      err.message = "Your auth token has expired.";
    if (err.message === "invalid signature")
      err.message = "Your auth token is invalid.";
    if (err.message === "jwt malformed")
      err.message = "Your auth token is invalid.";
    return next(err);
  }
};

export default authMiddleware;
