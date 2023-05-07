import * as jwt from "jsonwebtoken";
import { ADMIN_AUTH_ENDPOINTS, now, postData } from "../utils";

interface IUser {
  uid: string;
  email: string;
}

interface IDecodedToken {
  iat: number; // issued-at time
  exp: number; // expiration time
  sub: string; // subject (uid of the user)
  user: IUser;
}

let user: IUser | null = null;

export async function getIdToken() {
  let currentIdToken = localStorage.getItem("idToken");
  const expires = localStorage.getItem("expires");

  if (!currentIdToken) return null;

  if (expires && parseInt(expires) < now()) {
    try {
      const {
        idToken,
        refreshToken,
        expires,
        uid: id,
      } = await postData(
        (ADMIN_AUTH_ENDPOINTS ? "/admin" : "") + "/auth/refresh",
        {
          refreshToken: localStorage.getItem("refreshToken"),
        }
      );

      currentIdToken = idToken;
      localStorage.setItem("idToken", idToken);
      localStorage.setItem("refreshToken", refreshToken);
      localStorage.setItem("expires", now() + expires);
      localStorage.setItem("uid", id);
    } catch (err: any) {
      localStorage.clear();
      return null;
    }
  }

  return currentIdToken;
}

export async function getUser() {
  const idToken = await getIdToken();
  if (!idToken) return null;
  const decoded = jwt.decode(idToken) as IDecodedToken;
  return decoded.user;
}

export async function updateUser(uid: string, payload: any) {
  const idToken = await getIdToken();
  if (!idToken) throw new Error("No user");
  await postData(
    (ADMIN_AUTH_ENDPOINTS ? "/admin" : "") + `/auth/users/${uid}`,
    payload,
    {
      Authorization: `Bearer ${await getIdToken()}`,
    }
  );
  return true;
}

export async function logout() {
  const refreshToken = localStorage.getItem("refreshToken");
  if (!refreshToken) {
    localStorage.clear();
    return true;
  }
  await postData(
    (ADMIN_AUTH_ENDPOINTS ? "/admin" : "") + "/auth/logout",
    {
      refreshToken: localStorage.getItem("refreshToken"),
    },
    {
      Authorization: `Bearer ${await getIdToken()}`,
    }
  );
  localStorage.clear();
  user = null;
  return true;
}

export async function login(
  email: string,
  password: string
): Promise<IUser | null> {
  const { idToken, refreshToken, expires, uid } = await postData(
    (ADMIN_AUTH_ENDPOINTS ? "/admin" : "") + "/auth/login",
    { email, password }
  );
  localStorage.setItem("idToken", idToken);
  localStorage.setItem("refreshToken", refreshToken);
  localStorage.setItem("expires", now() + expires);
  localStorage.setItem("uid", uid);
  user = await getUser();
  return user;
}

export async function createUser(
  email: string,
  password: string
): Promise<IUser | null> {
  const { idToken, refreshToken, expires, uid } = await postData(
    (ADMIN_AUTH_ENDPOINTS ? "/admin" : "") + "/auth/users",
    { email, password }
  );
  localStorage.setItem("idToken", idToken);
  localStorage.setItem("refreshToken", refreshToken);
  localStorage.setItem("expires", now() + expires);
  localStorage.setItem("uid", uid);
  user = await getUser();
  return user;
}
