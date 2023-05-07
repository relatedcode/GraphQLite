import useAuth from "hooks/useAuth";
import { useRouter } from "next/router";
import Loading from "./Loading";

export default function AuthGuard({ children }: { children: React.ReactNode }) {
  const { user, isInitialized } = useAuth();
  const router = useRouter();

  if (!isInitialized) return <Loading />;

  if (!user) router.push("/login");

  return <>{children}</>;
}
