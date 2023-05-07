import { PlusSmIcon, TrashIcon } from "@heroicons/react/solid";
import Spinner from "components/Spinner";
import { FieldArray, Form, Formik } from "formik";
import toast from "react-hot-toast";
import { postData } from "utils/api-helpers";

function TypeInput({
  disabled,
  name,
  value,
  handleChange,
  type,
  typeName,
  setFieldValue,
}: {
  disabled?: boolean;
  name: string;
  value: string;
  handleChange: any;
  type: string;
  typeName: string;
  setFieldValue: any;
}) {
  return (
    <div>
      <div className="relative rounded-md shadow-sm">
        <input
          type="text"
          className="focus:ring-green-500 focus:border-green-500 block w-full pr-24 sm:text-sm border-gray-300 rounded-md disabled:opacity-60"
          placeholder="Field name"
          required
          name={name}
          value={value}
          onChange={handleChange}
          disabled={disabled}
        />
        <div className="absolute inset-y-0 right-0 flex items-center">
          <label className="sr-only">Type</label>
          <select
            disabled={disabled}
            value={type}
            onChange={(e) => setFieldValue(typeName, e.target.value)}
            className="focus:ring-green-500 focus:border-green-500 h-full py-0 pl-2 pr-7 border-transparent bg-transparent text-gray-500 sm:text-sm rounded-md"
          >
            <option value="String">String</option>
            <option value="Float">Float</option>
            <option value="Int">Int</option>
            <option value="Boolean">Boolean</option>
            <option value="Date">Date</option>
            <option value="[String]">[String]</option>
            <option value="[Float]">[Float]</option>
            <option value="[Int]">[Int]</option>
            <option value="[Boolean]">[Boolean]</option>
            <option value="[Date]">[Date]</option>
          </select>
        </div>
      </div>
    </div>
  );
}

export default function CreateTableForm() {
  const initialValues = {
    tableName: "",
    timestamps: true,
    fields: [
      { name: "objectId", type: "String", disabled: true },
      { name: "createdAt", type: "Date", disabled: true },
      { name: "updatedAt", type: "Date", disabled: true },
      { name: "", type: "String", disabled: false },
    ],
  };

  function addField(values, setValues) {
    const fields = [...values.fields];
    fields.push({ name: "", type: "String", disabled: false });
    setValues({ ...values, fields });
  }

  function removeField(values, setValues, index) {
    const fields = [...values.fields];
    fields.splice(index, 1);
    setValues({ ...values, fields });
  }

  return (
    <div className="max-w-md w-full py-8">
      <h1 className="mb-5 font-bold text-gray-800 text-center text-xl">
        Create Table
      </h1>
      <Formik
        initialValues={initialValues}
        onSubmit={async (values) => {
          try {
            await postData("/admin/config/tables", {
              tableName: values.tableName,
              fields: values.fields,
              timestamps: values.timestamps,
            });
            await new Promise((resolve) => setTimeout(resolve, 8000));
            window.location.reload();
          } catch (err) {
            toast.error(err.message);
          }
        }}
      >
        {({ values, setValues, handleChange, setFieldValue, isSubmitting }) => (
          <Form>
            <div className="space-y-5">
              <div className="pb-6">
                <label
                  htmlFor="email"
                  className="block text-sm font-medium text-gray-700"
                >
                  Table name
                </label>
                <div className="mt-1">
                  <input
                    type="text"
                    name="tableName"
                    onChange={handleChange}
                    required
                    className="shadow-sm focus:ring-green-500 focus:border-green-500 block w-full sm:text-sm border-gray-300 rounded-md"
                    placeholder="Table name"
                  />
                </div>
              </div>

              <div className="relative">
                <div
                  className="absolute inset-0 flex items-center"
                  aria-hidden="true"
                >
                  <div className="w-full border-t border-gray-300" />
                </div>
                <div className="relative flex justify-center">
                  <span className="px-2 bg-gray-50 text-sm text-gray-500">
                    Table Fields
                  </span>
                </div>
              </div>

              <FieldArray
                name="fields"
                render={() => (
                  <>
                    {values.fields.map((field, index) => (
                      <div key={index} className="relative">
                        <TypeInput
                          name={`fields.${index}.name`}
                          value={values.fields[index].name}
                          disabled={values.fields[index].disabled}
                          handleChange={handleChange}
                          type={values.fields[index].type}
                          typeName={`fields.${index}.type`}
                          setFieldValue={setFieldValue}
                        />
                        {!values.fields[index].disabled && (
                          <button
                            type="button"
                            onClick={() =>
                              removeField(values, setValues, index)
                            }
                            className="absolute inset-y-0 -right-7"
                          >
                            <TrashIcon className="h-4 w-4 text-gray-500" />
                          </button>
                        )}
                      </div>
                    ))}
                  </>
                )}
              />
              <div className="relative">
                <div
                  className="absolute inset-0 flex items-center"
                  aria-hidden="true"
                >
                  <div className="w-full border-t border-gray-300" />
                </div>
                <div className="relative flex justify-center">
                  <button
                    type="button"
                    onClick={() => addField(values, setValues)}
                    className="inline-flex items-center shadow-sm px-4 py-1 border border-gray-300 text-sm leading-5 font-medium rounded-full text-gray-700 bg-gray-50 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
                  >
                    <PlusSmIcon
                      className="-ml-1.5 mr-1 h-5 w-5 text-gray-400"
                      aria-hidden="true"
                    />
                    <span>Add field</span>
                  </button>
                </div>
              </div>
            </div>

            <div className="pt-5">
              <div className="relative flex items-start">
                <div className="flex items-center h-5">
                  <input
                    type="checkbox"
                    name="timestamps"
                    id="timestamps"
                    checked={values.timestamps}
                    onChange={(e) => {
                      const fields = [...values.fields];
                      if (!e.target.checked) {
                        fields.splice(1, 1);
                        fields.splice(1, 1);
                      } else {
                        fields.splice(1, 0, {
                          name: "updatedAt",
                          type: "Date",
                          disabled: true,
                        });
                        fields.splice(1, 0, {
                          name: "createdAt",
                          type: "Date",
                          disabled: true,
                        });
                      }
                      setValues({
                        ...values,
                        fields,
                        timestamps: e.target.checked,
                      });
                    }}
                    className="focus:ring-green-500 h-4 w-4 text-green-600 border-gray-300 rounded"
                  />
                </div>
                <div className="ml-3 text-sm">
                  <label
                    htmlFor="timestamps"
                    className="font-medium text-gray-700"
                  >
                    Auto-timestamps
                  </label>
                  <p className="text-gray-500">
                    Automatically add createdAt and updatedAt fields
                  </p>
                </div>
              </div>
            </div>

            <button
              type="submit"
              disabled={isSubmitting}
              className="mx-auto mt-10 w-full flex items-center justify-center px-4 py-2 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50"
            >
              {isSubmitting && <Spinner />}
              Create Table
            </button>
          </Form>
        )}
      </Formik>
    </div>
  );
}
