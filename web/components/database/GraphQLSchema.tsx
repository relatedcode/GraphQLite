import { Tab } from "@headlessui/react";
import { CogIcon, TemplateIcon } from "@heroicons/react/outline";
import Loading from "components/Loading";
import { useFormik } from "formik";
import dynamic from "next/dynamic";
import { useRouter } from "next/router";
import { Fragment, useEffect } from "react";
import toast from "react-hot-toast";
import useSWR from "swr";
import { fetcher, postData } from "utils/api-helpers";
import classNames from "utils/classNames";

const CodeMirror = dynamic(
  () => {
    import("codemirror-graphql/lint");
    import("codemirror-graphql/mode");
    import("codemirror/addon/edit/closebrackets");
    import("codemirror/addon/edit/matchbrackets");
    import("codemirror/mode/javascript/javascript");
    return import("react-codemirror2").then((mod) => mod.Controlled as any);
  },
  { ssr: false }
);

const subNavigation = [
  { name: "Schema", icon: TemplateIcon, href: "/graphql?section=schema" },
  { name: "Resolvers", icon: CogIcon, href: "/graphql?section=resolvers" },
];

function Resolvers({ value, setFieldValue }) {
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
        setFieldValue("resolvers", value);
      }}
    />
  );
}

function Types({ value, setFieldValue }) {
  return (
    <CodeMirror
      // @ts-ignore
      value={value}
      options={{
        lineNumbers: true,
        lineWrapping: true,
        tabSize: 2,
        mode: "graphql",
        autoCloseBrackets: true,
        matchBrackets: true,
        showCursorWhenSelecting: true,
        readOnly: false,
        foldGutter: {
          minFoldSize: 2,
        },
      }}
      onBeforeChange={(editor, data, value) => {
        setFieldValue("schemaGraphQL", value);
      }}
    />
  );
}

export default function GraphQLSchema({ setFormik }) {
  const { data, error } = useSWR("/admin/config", fetcher);
  const router = useRouter();
  const { section } = router.query;

  const formik = useFormik({
    initialValues: {
      schemaSQL: data?.schemaSQL || "",
      schemaGraphQL: data?.schemaGraphQL || "",
      resolvers: data?.resolvers || "",
    },
    enableReinitialize: true,
    onSubmit: async () => {
      setSubmitting(true);
      try {
        await postData("/admin/config", {
          schemaSQL: formik.values.schemaSQL,
          schemaGraphQL: formik.values.schemaGraphQL,
          resolvers: formik.values.resolvers,
        });
        await new Promise((resolve) => setTimeout(resolve, 8000));
        window.location.reload();
        setSubmitting(false);
      } catch (err) {
        toast.error(err.message);
        setSubmitting(false);
      }
    },
  });
  const {
    values,
    setFieldValue,
    isSubmitting,
    setSubmitting,
    resetForm,
    handleSubmit,
    dirty,
  } = formik;
  const { schemaSQL, schemaGraphQL, resolvers } = values;

  useEffect(() => {
    setFormik(formik);
  }, [values, dirty, isSubmitting]);

  if (!data && !error) return <Loading />;

  return (
    <div className="my-5 flex-1 flex flex-col">
      <Tab.Group defaultIndex={section === "resolvers" ? 1 : 0}>
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
                    onClick={() => router.push(item.href)}
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
          <Tab.Panel className="flex-1 flex">
            <Types value={schemaGraphQL} setFieldValue={setFieldValue} />
          </Tab.Panel>
          <Tab.Panel className="flex-1 flex">
            <Resolvers value={resolvers} setFieldValue={setFieldValue} />
          </Tab.Panel>
        </Tab.Panels>
      </Tab.Group>
    </div>
  );
}
