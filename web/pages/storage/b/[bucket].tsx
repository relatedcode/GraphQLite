import { Menu, Transition } from "@headlessui/react";
import {
  DotsVerticalIcon,
  DownloadIcon,
  TrashIcon,
  UploadIcon,
} from "@heroicons/react/outline";
import { getFileURL, uploadFile } from "gqlite-lib/dist/client/storage";
import AuthGuard from "components/AuthGuard";
import EmptyFiles from "components/EmptyFiles";
import Loading from "components/Loading";
import Sidebar from "components/Sidebar";
import Link from "next/link";
import { useRouter } from "next/router";
import { Fragment, useEffect, useRef, useState } from "react";
import toast from "react-hot-toast";
import useSWR, { mutate } from "swr";
import { deleteData, fetcher } from "utils/api-helpers";
import bytesToSize from "utils/bytesToSize";
import classNames from "utils/classNames";
import { sortDesc } from "utils/sort";

function FilesList({ fileRef }) {
  const router = useRouter();
  const { bucket } = router.query;
  const { data: files, error } = useSWR(
    bucket ? `/admin/storage/b/${bucket}/o` : null,
    fetcher
  );

  const deleteFile = async (key) => {
    try {
      await deleteData(`/storage/b/${bucket}/o/${encodeURIComponent(key)}`);
      await mutate(`/admin/storage/b/${bucket}/o`);
      toast.success("File deleted");
    } catch (err) {
      toast.error(err.message);
    }
  };

  if (!files && !error) return <Loading />;

  if (files?.data?.length === 0) return <EmptyFiles fileRef={fileRef} />;

  return (
    <div className="hidden sm:block">
      <div className="align-middle inline-block min-w-full border-b border-gray-200">
        <table className="min-w-full">
          <thead>
            <tr className="border-y border-gray-200 bg-gray-100">
              <th
                scope="col"
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/2"
              >
                Name
              </th>
              <th
                scope="col"
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/5"
              >
                Size
              </th>
              <th
                scope="col"
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/5"
              >
                Last Modified
              </th>
              <th scope="col" className="relative px-6 py-3">
                <span className="sr-only">Download</span>
              </th>
              <th scope="col" className="relative px-6 py-3">
                <span className="sr-only">Edit</span>
              </th>
            </tr>
          </thead>
          <tbody className="bg-transparent divide-y divide-gray-200">
            {[...files.data]
              .sort((a, b) => sortDesc(a, b, "LastModified"))
              .map((file) => (
                <tr key={file.Key}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-700">
                      {file.Key}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-700">
                      {bytesToSize(file.Size)}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-700">
                      {new Date(file.LastModified).toLocaleString()}
                    </div>
                  </td>
                  <td className="pr-6">
                    <button
                      onClick={() =>
                        window.open(
                          getFileURL(
                            `/storage/b/${bucket}/o/${encodeURIComponent(
                              file.Key
                            )}?token=${file.Head.Metadata.token}`
                          )
                        )
                      }
                      className="w-8 h-8 inline-flex items-center justify-center text-gray-400 rounded-full hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-30"
                    >
                      <span className="sr-only">Download</span>
                      <DownloadIcon className="w-5 h-5" aria-hidden="true" />
                    </button>
                  </td>
                  <td className="pr-6">
                    <Menu
                      as="div"
                      className="relative flex justify-end items-center"
                    >
                      <Menu.Button className="w-8 h-8 inline-flex items-center justify-center text-gray-400 rounded-full hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-30">
                        <span className="sr-only">Open options</span>
                        <DotsVerticalIcon
                          className="w-5 h-5"
                          aria-hidden="true"
                        />
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
                                  onClick={() => deleteFile(file.Key)}
                                  className={classNames(
                                    active
                                      ? "bg-gray-100 text-gray-900"
                                      : "text-gray-700",
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
                </tr>
              ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function Storage() {
  const router = useRouter();
  const { bucket } = router.query;

  const fileRef = useRef<any>(null);
  const [file, setFile] = useState<File | null>(null);

  const deleteBucket = async () => {
    try {
      await deleteData(`/admin/storage/b/${bucket}`);
      await mutate("/admin/storage/b/");
      toast.success("Bucket deleted");
      router.push("/storage");
    } catch (err) {
      toast.error(err.message);
    }
  };

  useEffect(() => {
    if (file) {
      (async () => {
        const filePath = file.name;
        await uploadFile(bucket as string, filePath, file);
        await mutate(`/admin/storage/b/${bucket}/o`);
        fileRef.current.value = "";
        setFile(null);
      })();
    }
  }, [file]);

  return (
    <Sidebar>
      <div className="flex-1 flex items-stretch overflow-hidden">
        <main className="flex-1 overflow-y-auto">
          <div className="pt-8 mx-auto">
            <div className="px-4 sm:px-6 lg:px-8 max-w-7xl font-medium text-gray-500 mb-2">
              <Link href="/storage">
                <a> &larr; Back to buckets</a>
              </Link>
            </div>
            <div className="flex justify-between items-center px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
              <h1 className="flex-1 text-2xl font-bold text-gray-900">
                {bucket}
              </h1>
              <div className="flex space-x-2">
                <button
                  type="button"
                  onClick={() => fileRef.current?.click()}
                  className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
                >
                  <UploadIcon
                    className="-ml-1 mr-2 h-5 w-5"
                    aria-hidden="true"
                  />
                  Upload file
                </button>
                <button
                  type="button"
                  onClick={() => deleteBucket()}
                  className="inline-flex items-center px-4 py-2 border border-gray-200 shadow-sm text-sm font-medium rounded-md text-red-500 bg-white focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                >
                  <TrashIcon
                    className="-ml-1 mr-2 h-5 w-5 text-red-500"
                    aria-hidden="true"
                  />
                  Delete bucket
                </button>
              </div>
            </div>
            <div className="mt-10">
              <input
                ref={fileRef}
                hidden
                type="file"
                onChange={(e) => setFile(e.target.files?.item(0))}
              />
              <FilesList fileRef={fileRef} />
            </div>
          </div>
        </main>
      </div>
    </Sidebar>
  );
}

export default function Main() {
  return (
    <AuthGuard>
      <Storage />
    </AuthGuard>
  );
}
