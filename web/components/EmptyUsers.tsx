/* This example requires Tailwind CSS v2.0+ */
import { UserAddIcon } from "@heroicons/react/outline";
import { PlusIcon } from "@heroicons/react/solid";
import { useModalState } from "hooks/useModalState";

export default function EmptyUsers() {
  const { setNewUserOpen } = useModalState();
  return (
    <div className="text-center">
      <UserAddIcon className="mx-auto h-12 w-12 text-gray-400" />
      <h3 className="mt-2 text-sm font-medium text-gray-900">No users</h3>
      <p className="mt-1 text-sm text-gray-500">
        Get started by creating a new user.
      </p>
      <div className="mt-6">
        <button
          type="button"
          onClick={() => setNewUserOpen(true)}
          className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <PlusIcon className="-ml-1 mr-2 h-5 w-5" aria-hidden="true" />
          New user
        </button>
      </div>
    </div>
  );
}
