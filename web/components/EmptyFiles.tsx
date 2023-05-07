import { PhotographIcon, UploadIcon } from "@heroicons/react/outline";

export default function EmptyBuckets({ fileRef }) {
  return (
    <div className="text-center">
      <PhotographIcon className="mx-auto h-12 w-12 text-gray-400" />
      <h3 className="mt-2 text-sm font-medium text-gray-900">No files</h3>
      <p className="mt-1 text-sm text-gray-500">
        Get started by uploading a new file.
      </p>
      <div className="mt-6">
        <button
          type="button"
          onClick={() => fileRef.current.click()}
          className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <UploadIcon className="-ml-1 mr-2 h-5 w-5" aria-hidden="true" />
          Upload file
        </button>
      </div>
    </div>
  );
}
