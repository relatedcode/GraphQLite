import { XCircleIcon } from "@heroicons/react/solid";

export default function StatusError({ errors }) {
  return (
    <div className="rounded-md bg-red-50 p-4 mt-5">
      <div className="flex">
        <div className="flex-shrink-0">
          <XCircleIcon className="h-5 w-5 text-red-400" aria-hidden="true" />
        </div>
        <div className="ml-3">
          <h3 className="text-sm font-medium text-red-800">
            There were {errors.length} errors with your config files
          </h3>
          <div className="mt-2 text-sm text-red-700">
            <ul role="list" className="list-disc pl-5 space-y-1">
              {errors.map((error) => (
                <li key={error} className="font-mono">
                  {error}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
