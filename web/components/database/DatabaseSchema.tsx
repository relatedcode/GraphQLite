import { Tab } from "@headlessui/react";
import {
  CogIcon,
  DatabaseIcon,
  LightningBoltIcon,
  PlusIcon,
  TableIcon,
} from "@heroicons/react/outline";
import { ChevronRightIcon } from "@heroicons/react/solid";
import CreateTableForm from "components/database/CreateTableForm";
import Loading from "components/Loading";
import { useFormik } from "formik";
import dynamic from "next/dynamic";
import { Fragment, useEffect, useState } from "react";
import toast from "react-hot-toast";
import useSWR from "swr";
import { fetcher, postData } from "utils/api-helpers";
import classNames from "utils/classNames";

const items = [
  {
    name: "Auto",
    type: "auto",
    description:
      "Automatically generate the GraphQL schema and resolvers from your SQL Sequelize schema.",
    iconColor: "bg-pink-500",
    icon: LightningBoltIcon,
  },
  {
    name: "Manual",
    type: "manual",
    description:
      "Provide the GraphQL schema, the GraphQL resolvers and the SQL schema manually. Recommended for expert users.",
    iconColor: "bg-green-500",
    icon: CogIcon,
  },
];

const CodeMirror = dynamic(
  () => {
    import("codemirror-graphql/lint");
    import("codemirror-graphql/mode");
    import("codemirror/addon/edit/closebrackets");
    import("codemirror/addon/edit/matchbrackets");
    import("codemirror/mode/javascript/javascript");
    import("codemirror/mode/sql/sql");
    return import("react-codemirror2").then((mod) => mod.Controlled as any);
  },
  { ssr: false }
);

function Tables({ value, setFieldValue }) {
  return (
    <CodeMirror
      // @ts-ignore
      value={value}
      options={{
        lineNumbers: true,
        lineWrapping: true,
        tabSize: 2,
        mode: "sql",
        autoCloseBrackets: true,
        matchBrackets: true,
        showCursorWhenSelecting: true,
        readOnly: false,
        foldGutter: {
          minFoldSize: 2,
        },
      }}
      onBeforeChange={(editor, data, value) => {
        setFieldValue("schemaSQL", value);
      }}
    />
  );
}

function Sequelize({ value, setFieldValue }) {
  return (
    <CodeMirror
      // @ts-ignore
      value={value}
      options={{
        lineNumbers: true,
        lineWrapping: true,
        tabSize: 2,
        mode: "javascript",
        autoCloseBrackets: true,
        matchBrackets: true,
        showCursorWhenSelecting: true,
        readOnly: false,
        foldGutter: {
          minFoldSize: 2,
        },
      }}
      onBeforeChange={(editor, data, value) => {
        setFieldValue("sequelize", value);
      }}
    />
  );
}

export default function DatabaseSchema({ setFormik }) {
  const { data, error } = useSWR("/admin/config", fetcher);

  const [type, setType] = useState<any>(null);

  useEffect(() => {
    if (data?.sequelize) setType("auto");
    else if (data?.schemaSQL) setType("manual");
  }, [data]);

  const formik = useFormik({
    initialValues: {
      schemaSQL: data?.schemaSQL || "",
      schemaGraphQL: data?.schemaGraphQL || "",
      resolvers: data?.resolvers || "",
      sequelize: data?.sequelize || "",
    },
    enableReinitialize: true,
    onSubmit: async () => {
      try {
        const sequelizeEdited =
          data?.sequelize || "" !== formik.values.sequelize;

        await postData("/admin/config", {
          schemaSQL: formik.values.schemaSQL,
          schemaGraphQL: formik.values.schemaGraphQL,
          resolvers: formik.values.resolvers,
          ...(sequelizeEdited && { sequelize: formik.values.sequelize }),
        });

        await new Promise((resolve) => setTimeout(resolve, 8000));

        setType(null);
        window.location.reload();
      } catch (err) {
        toast.error(err.message);
      }
    },
  });
  const { values, setFieldValue, isSubmitting, dirty } = formik;
  const { schemaSQL, sequelize } = values;

  useEffect(() => {
    setFormik(formik);
  }, [values, dirty, isSubmitting]);

  const subNavigation = [
    ...(type === "manual" ? [{ name: "SQL Schema", icon: DatabaseIcon }] : []),
    ...(type === "auto" ? [{ name: "Sequelize Schema", icon: TableIcon }] : []),
    ...(type === "auto" ? [{ name: "Create Table", icon: PlusIcon }] : []),
  ];

  const hasConfigFiles = !!(
    data?.resolvers ||
    data?.schemaSQL ||
    data?.sequelize ||
    data?.schemaGraphQL
  );

  if (!data && !error) return <Loading />;

  return hasConfigFiles || type ? (
    <div className="my-5 flex-1 flex flex-col">
      <Tab.Group>
        <Tab.List as="div" className="border-b border-gray-200 mb-5">
          <nav className="-mb-px flex space-x-8" aria-label="Tabs">
            {subNavigation.map((item) => (
              <Tab key={item.name} as={Fragment}>
                {({ selected }) => (
                  <div
                    className={classNames(
                      selected
                        ? "border-green-500 text-green-600"
                        : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300",
                      "group inline-flex items-center py-4 px-1 border-b-2 font-medium text-sm cursor-pointer focus:outline-none"
                    )}
                  >
                    <item.icon
                      className={classNames(
                        selected
                          ? "text-green-500"
                          : "text-gray-400 group-hover:text-gray-500",
                        "-ml-0.5 mr-2 h-5 w-5"
                      )}
                      aria-hidden="true"
                    />
                    <span>{item.name}</span>
                  </div>
                )}
              </Tab>
            ))}
          </nav>
        </Tab.List>

        <Tab.Panels
          as="div"
          className="space-y-6 sm:px-6 lg:px-0 lg:col-span-9 flex-1 flex overflow-y-auto"
        >
          {type === "manual" && (
            <Tab.Panel className="flex-1 flex">
              <Tables value={schemaSQL} setFieldValue={setFieldValue} />
            </Tab.Panel>
          )}
          {type === "auto" && (
            <Tab.Panel className="flex-1 flex">
              <Sequelize value={sequelize} setFieldValue={setFieldValue} />
            </Tab.Panel>
          )}
          {type === "auto" && (
            <Tab.Panel className="flex-1 flex justify-center">
              <CreateTableForm />
            </Tab.Panel>
          )}
        </Tab.Panels>
      </Tab.Group>
    </div>
  ) : (
    <div className="my-5 flex-1 flex flex-col">
      <div className="max-w-lg mx-auto mt-10">
        <h2 className="text-lg font-medium text-gray-900">
          Create your database schema
        </h2>
        <p className="mt-1 text-sm text-gray-500">
          Get started by choosing the database type you want to use.
        </p>
        <ul
          role="list"
          className="mt-6 border-t border-b border-gray-200 divide-y divide-gray-200"
        >
          {items.map((item, itemIdx) => (
            <li key={itemIdx}>
              <div className="relative group py-4 flex items-start space-x-3">
                <div className="flex-shrink-0">
                  <span
                    className={classNames(
                      item.iconColor,
                      "inline-flex items-center justify-center h-10 w-10 rounded-lg"
                    )}
                  >
                    <item.icon
                      className="h-6 w-6 text-white"
                      aria-hidden="true"
                    />
                  </span>
                </div>
                <div className="min-w-0 flex-1">
                  <div className="text-sm font-medium text-gray-900">
                    <button onClick={() => setType(item.type)}>
                      <span className="absolute inset-0" aria-hidden="true" />
                      {item.name}
                    </button>
                  </div>
                  <p className="text-sm text-gray-500">{item.description}</p>
                </div>
                <div className="flex-shrink-0 self-center">
                  <ChevronRightIcon
                    className="h-5 w-5 text-gray-400 group-hover:text-gray-500"
                    aria-hidden="true"
                  />
                </div>
              </div>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
