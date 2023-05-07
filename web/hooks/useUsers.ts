import { useContext } from "react";
import UsersContext from "contexts/UsersContext";

const useGroups = () => useContext(UsersContext);

export default useGroups;
