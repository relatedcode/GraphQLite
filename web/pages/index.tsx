import Loading from "components/Loading";
import useAuth from "hooks/useAuth";
import router from "next/router";

export default function Main() {
  const { user, isInitialized } = useAuth();

  if (!isInitialized) return <Loading />;

  if (user) router.push("/auth");

  if (!user) router.push("/login");

  return <></>;
}
