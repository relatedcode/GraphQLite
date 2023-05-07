import useAuth from "hooks/useAuth";
import { useEffect } from "react";

export default function Logout() {
  const { logout } = useAuth();

  useEffect(() => {
    (async () => {
      await logout();
      window.location.replace("/login");
    })();
  }, []);

  return <></>;
}
