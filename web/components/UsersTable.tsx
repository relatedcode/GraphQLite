import { Menu, Transition } from "@headlessui/react";
import {
  DotsVerticalIcon,
  PencilIcon,
  TrashIcon,
} from "@heroicons/react/outline";
import { UserCircleIcon } from "@heroicons/react/solid";
import useUsers from "hooks/useUsers";
import { Fragment, useState } from "react";
import toast from "react-hot-toast";
import { deleteData } from "utils/api-helpers";
import classNames from "utils/classNames";
import EditUserModal from "./EditUserModal";
import EmptyUsers from "components/EmptyUsers";

function User({ user }) {
  const [open, setOpen] = useState(false);

  const deleteUser = async () => {
    try {
      await deleteData(`/auth/users/${user.objectId}`);
    } catch (err) {
      toast.error(err.message);
    }
  };

  return (
    <tr>
      <td className="px-6 py-4 whitespace-nowrap">
        <div className="flex items-center">
          <div className="flex-shrink-0 h-10 w-10">
            <UserCircleIcon className="h-10 w-10 rounded-full text-gray-500" />
          </div>
          <div className="ml-4">
            <div className="text-sm font-medium text-gray-700">{user.name}</div>
          </div>
        </div>
      </td>
      <td className="px-6 py-4 whitespace-nowrap">
        <div className="text-sm font-medium text-gray-700">{user.email}</div>
      </td>
      <td className="px-6 py-4 whitespace-nowrap">
        {!user.isDeleted && (
          <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
            Active
          </span>
        )}
        {user.isDeleted && (
          <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">
            Deleted
          </span>
        )}
      </td>
      <td className="px-6 py-4 whitespace-nowrap">
        <div className="text-sm font-medium text-gray-700">
          {new Date(user.createdAt).toLocaleString()}
        </div>
      </td>
      <td className="pr-6">
        <Menu as="div" className="relative flex justify-end items-center">
          <Menu.Button
            disabled={user.isDeleted}
            className="w-8 h-8 inline-flex items-center justify-center text-gray-400 rounded-full hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-30"
          >
            <span className="sr-only">Open options</span>
            <DotsVerticalIcon className="w-5 h-5" aria-hidden="true" />
          </Menu.Button>
          <Transition
            as={Fragment}
            enter="transition ease-out duration-100"
            enterFrom="transform opacity-0 scale-95"
            enterTo="transform opacity-100 scale-100"
            leave="transition ease-in duration-75"
            leaveFrom="transform opacity-100 scale-100"
            leaveTo="transform opacity-0 scale-95"
          >
            <Menu.Items className="mx-3 origin-top-right absolute right-7 top-0 w-48 mt-1 rounded-md shadow-lg z-10 bg-white ring-1 ring-black ring-opacity-5 divide-y divide-gray-200 focus:outline-none">
              <div className="py-1">
                <Menu.Item>
                  {({ active }) => (
                    <button
                      onClick={() => setOpen(true)}
                      className={classNames(
                        active ? "bg-gray-100 text-gray-900" : "text-gray-700",
                        "group flex items-center px-4 py-2 text-sm w-full"
                      )}
                    >
                      <PencilIcon
                        className="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500"
                        aria-hidden="true"
                      />
                      Edit
                    </button>
                  )}
                </Menu.Item>
              </div>
              <div className="py-1">
                <Menu.Item>
                  {({ active }) => (
                    <button
                      onClick={() => deleteUser()}
                      className={classNames(
                        active ? "bg-gray-100 text-gray-900" : "text-gray-700",
                        "group flex items-center px-4 py-2 text-sm w-full"
                      )}
                    >
                      <TrashIcon
                        className="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500"
                        aria-hidden="true"
                      />
                      Delete
                    </button>
                  )}
                </Menu.Item>
              </div>
            </Menu.Items>
          </Transition>
        </Menu>
      </td>
      <EditUserModal open={open} setOpen={setOpen} userId={user.objectId} />
    </tr>
  );
}

export default function UsersTable() {
  const { users: data } = useUsers();

  if (!data.length) return <EmptyUsers />;

  return (
    <div className="hidden sm:block">
      <div className="align-middle inline-block min-w-full border-b border-gray-200">
        <table className="min-w-full">
          <thead>
            <tr className="border-y border-gray-200 bg-gray-100">
              <th
                scope="col"
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              ></th>
              <th
                scope="col"
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Email
              </th>
              <th
                scope="col"
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Status
              </th>
              <th
                scope="col"
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Created
              </th>
              <th scope="col" className="relative px-6 py-3">
                <span className="sr-only">Edit</span>
              </th>
            </tr>
          </thead>
          <tbody className="bg-transparent divide-y divide-gray-200">
            {data.map((user) => (
              <User key={user.email} user={user} />
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
