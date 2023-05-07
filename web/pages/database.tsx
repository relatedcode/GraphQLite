import AuthGuard from "components/AuthGuard";
import DatabaseSchema from "components/database/DatabaseSchema";
import ResetConfirmModal from "components/database/ResetConfirmModal";
import Sidebar from "components/Sidebar";
import StatusError from "components/StatusError";
import { useModalState } from "hooks/useModalState";
import { useState } from "react";
import useSWR from "swr";
import { fetcher } from "utils/api-helpers";

function Tabs({ setFormik }) {
  return (
    <div className="flex flex-col flex-1">
      <div className="flex-1 flex">
        <DatabaseSchema setFormik={setFormik} />
      </div>
    </div>
  );
}

function Database() {
  const { data: status } = useSWR("/admin/status", fetcher);
  const { data: configFiles } = useSWR("/admin/config", fetcher);

  const { setResetConfirmOpen } = useModalState();

  const [formik, setFormik] = useState<any>(null);

  const hasConfigFiles = !!(
    configFiles?.resolvers ||
    configFiles?.schemaSQL ||
    configFiles?.sequelize ||
    configFiles?.schemaGraphQL
  );

  return (
    <Sidebar>
      <div className="flex-1 flex items-stretch overflow-hidden">
        <main className="flex-1 overflow-y-auto flex">
          <div className="pt-8 mx-auto px-4 sm:px-6 lg:px-8 flex flex-col flex-1">
            <div className="flex justify-between items-center">
              <h1 className="flex-1 text-2xl font-bold text-gray-900 py-1">
                Database
              </h1>
              <div className="flex space-x-2 min-w-min">
                {formik?.dirty && (
                  <div className="flex pl-6 space-x-2">
                    <button
                      type="button"
                      disabled={formik.isSubmitting}
                      onClick={() => setResetConfirmOpen(true)}
                      className="w-full items-center whitespace-nowrap px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-70"
                    >
                      {formik.isSubmitting
                        ? "Restarting..."
                        : "Save and Restart"}
                    </button>
                    <button
                      type="button"
                      disabled={formik.isSubmitting}
                      onClick={() => formik.resetForm()}
                      className="w-full items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-70"
                    >
                      Cancel
                    </button>
                  </div>
                )}
              </div>
            </div>
            <div className="flex-1 flex flex-col">
              {status?.errors && hasConfigFiles && (
                <StatusError errors={status?.errors || "Error"} />
              )}
              <Tabs setFormik={setFormik} />
            </div>
          </div>
        </main>
      </div>
      <ResetConfirmModal
        onSubmit={() => formik?.handleSubmit()}
        isSubmitting={formik?.isSubmitting}
      />
    </Sidebar>
  );
}

export default function Main() {
  return (
    <AuthGuard>
      <Database />
    </AuthGuard>
  );
}
