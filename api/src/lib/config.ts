export const JWT_EXPIRES = process.env.JWT_EXPIRES || "3600";
export const REFRESH_TOKEN_EXPIRES =
  process.env.REFRESH_TOKEN_EXPIRES || "604800";
export const SECRET_KEY = process.env.SECRET_KEY as string;
