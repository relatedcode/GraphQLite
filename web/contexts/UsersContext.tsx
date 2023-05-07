import { useQuery, useSubscription } from "@apollo/client";
import { USERS } from "graphql/queries";
import { USER } from "graphql/subscriptions";
import useAuth from "hooks/useAuth";
import { createContext, useEffect, useState } from "react";
import { sortDesc } from "utils/sort";

const UsersContext = createContext({
  users: [],
  loading: true,
});

export function UsersProvider({ children }) {
  const { user } = useAuth();
  const [users, setUsers] = useState([]);

  const { loading, data } = useQuery(USERS, {
    skip: !user,
    fetchPolicy: "network-only",
  });
  const { data: dataPush } = useSubscription(USER, { skip: !user });

  useEffect(() => {
    if (data) {
      setUsers(data.GQLUsers);
    }
  }, [data]);

  useEffect(() => {
    if (dataPush) {
      setUsers([
        ...users.filter((item) => item.objectId !== dataPush.GQLUser.objectId),
        dataPush.GQLUser,
      ]);
    }
  }, [dataPush]);

  return (
    <UsersContext.Provider
      value={{
        users: [...users].sort(sortDesc),
        loading,
      }}
    >
      {children}
    </UsersContext.Provider>
  );
}

export default UsersContext;
