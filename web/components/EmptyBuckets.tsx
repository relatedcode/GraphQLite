/* This example requires Tailwind CSS v2.0+ */
import { CollectionIcon, PlusIcon } from "@heroicons/react/outline";
import { useModalState } from "hooks/useModalState";

export default function EmptyBuckets() {
  const { setNewBucketOpen } = useModalState();
  return (
    <div className="text-center">
      <CollectionIcon className="mx-auto h-12 w-12 text-gray-400" />
      <h3 className="mt-2 text-sm font-medium text-gray-900">No buckets</h3>
      <p className="mt-1 text-sm text-gray-500">
        Get started by creating a new bucket.
      </p>
      <div className="mt-6">
        <button
          type="button"
          onClick={() => setNewBucketOpen(true)}
          className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <PlusIcon className="-ml-1 mr-2 h-5 w-5" aria-hidden="true" />
          New bucket
        </button>
      </div>
    </div>
  );
}
