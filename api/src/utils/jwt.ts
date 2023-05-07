import jwt from "jsonwebtoken";
import { JWT_EXPIRES, SECRET_KEY } from "lib/config";
import now from "utils/now";

export function createToken(params: any) {
  const expiresIn = parseInt(JWT_EXPIRES);
  const token = jwt.sign({ ...params, iat: now() }, SECRET_KEY, {
    expiresIn,
  });
  return token;
}

export function verifyToken(token: string) {
  const decoded = jwt.verify(token, SECRET_KEY);
  return decoded;
}
