export const FAKE_EMAIL = true;

export const getGQLServerUrl = () => {
  return typeof window !== "undefined"
    ? process.env.NEXT_PUBLIC_GQL_SERVER_URL ||
        `http://${window?.location.hostname}:4000`
    : "";
};
