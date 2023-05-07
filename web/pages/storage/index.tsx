import { PlusIcon } from "@heroicons/react/outline";
import AuthGuard from "components/AuthGuard";
import EmptyBuckets from "components/EmptyBuckets";
import Loading from "components/Loading";
import NewBucketModal from "components/NewBucketModal";
import Sidebar from "components/Sidebar";
import { useModalState } from "hooks/useModalState";
import Link from "next/link";
import useSWR from "swr";
import { fetcher } from "utils/api-helpers";

function BucketsList() {
  const { data: buckets, error } = useSWR("/admin/storage/b", fetcher);

  if (!buckets && !error) return <Loading />;

  if (buckets?.data?.length === 0) return <EmptyBuckets />;

  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
      {buckets.data.map((bucket) => (
        <div
          key={bucket.Name}
          className="relative rounded-lg border border-gray-300 bg-white px-6 py-5 shadow-sm flex items-center space-x-3 hover:border-gray-400 focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-green-500"
        >
          <Link href={`/storage/b/${bucket.Name}`}>
            <a className="focus:outline-none">
              <span className="absolute inset-0" aria-hidden="true" />
              <p className="text-sm font-medium text-gray-900">{bucket.Name}</p>
              <p className="text-sm text-gray-500 truncate">
                Created at {new Date(bucket.CreationDate).toLocaleString()}
              </p>
            </a>
          </Link>
        </div>
      ))}
    </div>
  );
}

function Storage() {
  const { setNewBucketOpen: setOpen } = useModalState();
  return (
    <Sidebar>
      <div className="flex-1 flex items-stretch overflow-hidden">
        <main className="flex-1 overflow-y-auto">
          <div className="pt-8 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center">
              <h1 className="flex-1 text-2xl font-bold text-gray-900">
                Buckets
              </h1>
              <button
                type="button"
                onClick={() => setOpen(true)}
                className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
              >
                <PlusIcon className="-ml-1 mr-2 h-5 w-5" aria-hidden="true" />
                New bucket
              </button>
            </div>
            <div className="mt-10">
              <BucketsList />
              <NewBucketModal />
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
