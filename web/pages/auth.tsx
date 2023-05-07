import { PlusIcon } from "@heroicons/react/outline";
import AuthGuard from "components/AuthGuard";
import NewUserModal from "components/NewUserModal";
import Sidebar from "components/Sidebar";
import UsersTable from "components/UsersTable";
import { useModalState } from "hooks/useModalState";

function Auth() {
  const { setNewUserOpen } = useModalState();
  return (
    <Sidebar>
      <div className="flex-1 flex items-stretch overflow-hidden">
        <main className="flex-1 overflow-y-auto">
          <div className="pt-8 mx-auto">
            <div className="flex justify-between items-center px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
              <h1 className="flex-1 text-2xl font-bold text-gray-900">Users</h1>
              <button
                type="button"
                onClick={() => setNewUserOpen(true)}
                className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
              >
                <PlusIcon className="-ml-1 mr-2 h-5 w-5" aria-hidden="true" />
                New user
              </button>
            </div>
            <div className="mt-10">
              <UsersTable />
            </div>
          </div>
        </main>
      </div>
      <NewUserModal />
    </Sidebar>
  );
}

export default function Main() {
  return (
    <AuthGuard>
      <Auth />
    </AuthGuard>
  );
}
