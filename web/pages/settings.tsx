import { DownloadIcon, TrashIcon } from "@heroicons/react/outline";
import AuthGuard from "components/AuthGuard";
import CleanupDBModal from "components/database/CleanupDBModal";
import ResetServerModal from "components/database/ResetServerModal";
import Loading from "components/Loading";
import Sidebar from "components/Sidebar";
import { useFormik } from "formik";
import { useModalState } from "hooks/useModalState";
import toast from "react-hot-toast";
import useSWR from "swr";
import { deleteData, fetcher } from "utils/api-helpers";
import { downloadFile } from "utils/download";

function Divider() {
  return (
    <div className="hidden sm:block" aria-hidden="true">
      <div className="py-5">
        <div className="border-t border-gray-200" />
      </div>
    </div>
  );
}

function Keys() {
  const { data, error } = useSWR("/admin/secret_key", fetcher);

  if (!data && !error) return <Loading />;
  return (
    <div>
      <div className="md:grid md:grid-cols-3 md:gap-6">
        <div className="md:col-span-1">
          <div className="px-4 sm:px-0">
            <h3 className="text-lg font-medium leading-6 text-gray-900">
              Secret key
            </h3>
            <p className="mt-1 text-sm text-gray-600">
              This key has administrator permissions on all the endpoints.
              Please keep it safe.
            </p>
          </div>
        </div>
        <div className="mt-5 md:mt-0 md:col-span-2">
          <form action="#" method="POST">
            <div className="shadow sm:rounded-md sm:overflow-hidden">
              <div className="px-4 py-5 bg-white space-y-6 sm:p-6">
                <div className="grid grid-cols-3 gap-6">
                  <div className="col-span-3 sm:col-span-2">
                    <label
                      htmlFor="secretKey"
                      className="block text-sm font-medium text-gray-700"
                    >
                      Secret key
                    </label>
                    <div className="mt-1 flex rounded-md shadow-sm">
                      <input
                        type="text"
                        name="secretKey"
                        disabled
                        id="secretKey"
                        value={data.key}
                        className="focus:ring-green-500 focus:border-green-500 flex-1 block w-full rounded-md sm:text-sm border-gray-300 disabled:opacity-80"
                        placeholder="www.example.com"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

function Exports() {
  const { data } = useSWR("/admin/config", fetcher);

  return (
    <div>
      <div className="md:grid md:grid-cols-3 md:gap-6">
        <div className="md:col-span-1">
          <div className="px-4 sm:px-0">
            <h3 className="text-lg font-medium leading-6 text-gray-900">
              Exports
            </h3>
            <p className="mt-1 text-sm text-gray-600">
              Export your schema details or the database.
            </p>
          </div>
        </div>
        <div className="mt-5 md:mt-0 md:col-span-2">
          <div className="shadow sm:rounded-md sm:overflow-hidden">
            <div className="px-4 py-5 bg-white space-y-6 sm:p-6">
              <div className="grid grid-cols-3 gap-6">
                <div className="col-span-3 divide-y divide-gray-200">
                  {data?.sequelize && (
                    <div className="sm:flex sm:items-center sm:justify-between py-3 first:pt-0 last:pb-0">
                      <h3 className="text-base leading-6 font-medium text-gray-700">
                        Studio GraphQL Schema
                      </h3>

                      <div className="mt-5 sm:mt-0 sm:ml-6 sm:flex-shrink-0 sm:flex sm:items-center">
                        <button
                          type="button"
                          onClick={async () => {
                            const res = await fetcher(
                              `/admin/config/export?origin=${window?.location.hostname}`
                            );
                            downloadFile(
                              JSON.stringify(res, null, 2),
                              "schema.json",
                              "text/json"
                            );
                          }}
                          className="w-full inline-flex items-center whitespace-nowrap px-4 py-2 text-sm font-medium rounded-md shadow-sm text-white bg-green-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-70"
                        >
                          <DownloadIcon
                            className="-ml-1 mr-2 h-5 w-5"
                            aria-hidden="true"
                          />
                          Download
                        </button>
                      </div>
                    </div>
                  )}

                  {data?.sequelize && (
                    <div className="sm:flex sm:items-center sm:justify-between py-3 first:pt-0 last:pb-0">
                      <h3 className="text-base leading-6 font-medium text-gray-700">
                        Client GraphQL Schema
                      </h3>

                      <div className="mt-5 sm:mt-0 sm:ml-6 sm:flex-shrink-0 sm:flex sm:items-center">
                        <button
                          type="button"
                          onClick={async () => {
                            const res = await fetcher(
                              `/admin/config/export?origin=${window?.location.hostname}&type=client`
                            );
                            downloadFile(
                              res.data,
                              "schema.graphql",
                              "text/plain"
                            );
                          }}
                          className="w-full inline-flex items-center whitespace-nowrap px-4 py-2 text-sm font-medium rounded-md shadow-sm text-white bg-green-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-70"
                        >
                          <DownloadIcon
                            className="-ml-1 mr-2 h-5 w-5"
                            aria-hidden="true"
                          />
                          Download
                        </button>
                      </div>
                    </div>
                  )}

                  {data?.sequelize && (
                    <div className="sm:flex sm:items-center sm:justify-between py-3 first:pt-0 last:pb-0">
                      <h3 className="text-base leading-6 font-medium text-gray-700">
                        Swift code export
                      </h3>

                      <div className="mt-5 sm:mt-0 sm:ml-6 sm:flex-shrink-0 sm:flex sm:items-center">
                        <button
                          type="button"
                          onClick={async () => {
                            const res = await fetcher(
                              `/admin/config/export?origin=${window?.location.hostname}&type=ios`
                            );
                            downloadFile(
                              res.data,
                              "schema.swift",
                              "text/plain"
                            );
                          }}
                          className="w-full inline-flex items-center whitespace-nowrap px-4 py-2 text-sm font-medium rounded-md shadow-sm text-white bg-green-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-70"
                        >
                          <DownloadIcon
                            className="-ml-1 mr-2 h-5 w-5"
                            aria-hidden="true"
                          />
                          Download
                        </button>
                      </div>
                    </div>
                  )}

                  <div className="sm:flex sm:items-center sm:justify-between py-3 first:pt-0 last:pb-0">
                    <h3 className="text-base leading-6 font-medium text-gray-700">
                      Database export
                    </h3>

                    <div className="mt-5 sm:mt-0 sm:ml-6 sm:flex-shrink-0 sm:flex sm:items-center">
                      <button
                        type="button"
                        className="w-full inline-flex items-center whitespace-nowrap px-4 py-2 text-sm font-medium rounded-md shadow-sm text-white bg-green-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-70"
                      >
                        <DownloadIcon
                          className="-ml-1 mr-2 h-5 w-5"
                          aria-hidden="true"
                        />
                        Download
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function CleanUp() {
  const { setResetServerOpen, setCleanupDBOpen } = useModalState();

  const formikResetServer = useFormik({
    initialValues: {},
    enableReinitialize: true,
    onSubmit: async () => {
      try {
        await deleteData("/admin/reset");
        await new Promise((resolve) => setTimeout(resolve, 8000));
        localStorage.clear();
        window.location.href = "/";
      } catch (err) {
        toast.error(err.message);
      }
    },
  });

  const formikCleanupDB = useFormik({
    initialValues: {},
    enableReinitialize: true,
    onSubmit: async () => {
      try {
        await deleteData("/admin/cleanup_database");
        setCleanupDBOpen(false);
        toast.success("Database cleaned up successfully");
        window.location.reload();
      } catch (err) {
        toast.error(err.message);
      }
    },
  });

  return (
    <div>
      <div className="md:grid md:grid-cols-3 md:gap-6">
        <div className="md:col-span-1">
          <div className="px-4 sm:px-0">
            <h3 className="text-lg font-medium leading-6 text-gray-900">
              Cleanup
            </h3>
            <p className="mt-1 text-sm text-gray-600">
              Cleanup your database or reset the server completely.
            </p>
          </div>
        </div>
        <div className="mt-5 md:mt-0 md:col-span-2">
          <div className="shadow sm:rounded-md sm:overflow-hidden">
            <div className="px-4 py-5 bg-white space-y-6 sm:p-6">
              <div className="grid grid-cols-3 gap-6">
                <div className="col-span-3 divide-y divide-gray-200">
                  <div className="sm:flex sm:items-center sm:justify-between pb-3">
                    <h3 className="text-base leading-6 font-medium text-gray-700">
                      Cleanup Database
                    </h3>
                    <div className="mt-5 sm:mt-0 sm:ml-6 sm:flex-shrink-0 sm:flex sm:items-center">
                      <button
                        type="button"
                        onClick={() => setCleanupDBOpen(true)}
                        className="w-full inline-flex items-center whitespace-nowrap px-4 py-2 text-sm font-medium rounded-md shadow-sm text-white bg-red-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-70"
                      >
                        <TrashIcon
                          className="-ml-1 mr-2 h-5 w-5"
                          aria-hidden="true"
                        />
                        Cleanup
                      </button>
                    </div>
                  </div>

                  <div className="sm:flex sm:items-center sm:justify-between pt-3">
                    <h3 className="text-base leading-6 font-medium text-gray-700">
                      Reset Server
                    </h3>

                    <div className="mt-5 sm:mt-0 sm:ml-6 sm:flex-shrink-0 sm:flex sm:items-center">
                      <button
                        type="button"
                        onClick={() => setResetServerOpen(true)}
                        className="w-full inline-flex items-center whitespace-nowrap px-4 py-2 text-sm font-medium rounded-md shadow-sm text-white bg-red-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-70"
                      >
                        <TrashIcon
                          className="-ml-1 mr-2 h-5 w-5"
                          aria-hidden="true"
                        />
                        Reset
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <ResetServerModal
        onSubmit={formikResetServer.handleSubmit}
        isSubmitting={formikResetServer.isSubmitting}
      />
      <CleanupDBModal
        onSubmit={formikCleanupDB.handleSubmit}
        isSubmitting={formikCleanupDB.isSubmitting}
      />
    </div>
  );
}

function Settings() {
  return (
    <Sidebar>
      <div className="flex-1 flex items-stretch overflow-hidden">
        <main className="flex-1 overflow-y-auto">
          <div className="pt-8 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center">
              <h1 className="flex-1 text-2xl font-bold text-gray-900">
                Settings
              </h1>
            </div>
            <div className="mt-10">
              <Keys />
              <Divider />
              <Exports />
              <Divider />
              <CleanUp />
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
      <Settings />
    </AuthGuard>
  );
}
