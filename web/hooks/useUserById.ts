import useUsers from "hooks/useUsers";

export default function useUserById(id: any) {
  const { users, loading } = useUsers();
  return { user: users.find((g) => g.objectId === id), loading };
}
