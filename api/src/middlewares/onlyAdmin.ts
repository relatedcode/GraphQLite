import express from "express";

const onlyAdmin = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { admin } = res.locals;
    if (!admin)
      throw new Error("Only admin users are authorized to use this endpoint.");
    return next();
  } catch (err) {
    return next(err);
  }
};

export default onlyAdmin;
