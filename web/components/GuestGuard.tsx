import Loading from "components/Loading";
import useAuth from "hooks/useAuth";
import { useRouter } from "next/router";

export default function GuestGuard({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, isInitialized } = useAuth();
  const router = useRouter();

  if (!isInitialized) return <Loading />;

  if (user) router.push("/");

  return <>{children}</>;
}
