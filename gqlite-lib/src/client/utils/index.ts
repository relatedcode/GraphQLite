import fetch from "node-fetch";

export let SERVER_URL = "http://localhost:4000";
export let ADMIN_AUTH_ENDPOINTS = false;

export function setUrl(url: string) {
  SERVER_URL = url;
}

export function useAdminAuthEndpoints(option = true) {
  ADMIN_AUTH_ENDPOINTS = option;
}

export const now = () => Math.floor(Date.now() / 1000);

export const postData = async (
  url: string,
  data?: {},
  addHeaders?: {}
): Promise<any> => {
  const headers: any = {
    "Content-Type": "application/json",
    ...addHeaders,
  };
  const res = await fetch(`${SERVER_URL}${url}`, {
    method: "post",
    headers,
    body: JSON.stringify(data || {}),
  });
  if (!res.ok) {
    const e: any = await res.json();
    const error = new Error(e.error.message);
    throw error;
  }
  const contentType = res.headers.get("content-type");
  if (contentType && contentType.indexOf("application/json") !== -1)
    return await res.json();
};
