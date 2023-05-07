import {
  createGQLUserDB,
  getGQLUserDB,
  updateGQLUserDB,
} from "db/schema/GQLUser";
import express from "express";
import { JWT_EXPIRES } from "lib/config";
import { hashPassword, verifyPassword } from "utils/hash";
import { createToken } from "utils/jwt";
import {
  createRefreshToken,
  deleteRefreshToken,
  verifyRefreshToken,
} from "utils/refresh-token";
import { v4 as uuidv4 } from "uuid";

export const verify = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  const { user, admin } = res.locals;
  res.locals.data = {
    ...(admin && { admin }),
    ...user,
  };
  return next("router");
};

export const create = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { email, password } = req.body;

    const id = uuidv4();
    await createGQLUserDB({
      objectId: id,
      email,
      passwordHash: hashPassword(password),
    });

    const token = createToken({
      sub: id,
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

export const update = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { uid, admin } = res.locals;
    const { email, password } = req.body;
    const { id } = req.params;

    if (!admin && id !== uid)
      throw new Error("You are not authorized to update this user.");

    await getGQLUserDB({ where: { objectId: id, isDeleted: false } });

    await updateGQLUserDB({
      objectId: id,
      ...(email && { email }),
      ...(password && { passwordHash: hashPassword(password) }),
    });

    res.locals.data = {
      uid: id,
    };
    return next("router");
  } catch (err: any) {
    if (err.message === "Cannot read property 'dataValues' of null")
      err.message = "The user has been deleted.";
    return next(err);
  }
};

export const remove = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { uid, admin } = res.locals;
    const { id } = req.params;

    if (!admin && id !== uid)
      throw new Error("You are not authorized to delete this user.");

    await updateGQLUserDB({
      objectId: id,
      isDeleted: true,
    });

    res.locals.data = {
      success: true,
    };
    return next("router");
  } catch (err) {
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

    const user = await getGQLUserDB({ where: { email, isDeleted: false } });
    const id = user.objectId;

    if (!verifyPassword(password, user.passwordHash))
      throw new Error("Your password is invalid.");

    const token = createToken({
      sub: id,
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

    const user = await getGQLUserDB({ where: { objectId: id } });

    const token = createToken({
      sub: id,
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
