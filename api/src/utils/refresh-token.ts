import { del, expire, get, lrange, lrem, rpush, setex } from "db/redis";
import { REFRESH_TOKEN_EXPIRES } from "lib/config";
import randomId from "utils/random-id";

export async function getRefreshTokensByUserId(uid: string) {
  const tokens = await lrange(uid, 0, -1);
  return tokens;
}

export async function createRefreshToken(uid: string) {
  const refreshToken = randomId(100);
  const expires = parseInt(REFRESH_TOKEN_EXPIRES);

  // Save the refresh token with an expiration time
  await setex(refreshToken, expires, uid);

  // Add the refresh token to the user's list of refresh tokens and set the expiration time
  await rpush(uid, refreshToken);
  await expire(uid, expires);

  return refreshToken;
}

export async function deleteRefreshToken(uid: string, token?: string) {
  if (!token) {
    // Logout everywhere (delete all refresh tokens)
    const tokens = await getRefreshTokensByUserId(uid);
    await Promise.all(tokens.map(async (token: string) => await del(token)));
    await del(uid);
  } else {
    // Logout from one place (delete one refresh token)
    await del(token);
    await lrem(uid, 0, token);
  }
}

export async function verifyRefreshToken(token: string) {
  const id = await get(token);
  if (!id) throw new Error("Your refresh token is invalid.");

  // Reset the token expiration time
  const expires = parseInt(REFRESH_TOKEN_EXPIRES);
  await expire(token, expires);
  await expire(id, expires);

  return id;
}
