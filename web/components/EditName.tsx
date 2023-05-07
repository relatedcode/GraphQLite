import { Formik } from "formik";
import { postData } from "utils/api-helpers";

export default function EditName() {
  return (
    <div>
      <span>Edit name</span>
      <Formik
        initialValues={{ objectId: "", name: "" }}
        onSubmit={async ({ objectId, name }, { resetForm }) => {
          await postData(`/users/${objectId}`, {
            name,
          });
        }}
      >
        {({ values, handleChange, handleSubmit, isSubmitting }) => (
          <form onSubmit={handleSubmit} className="space-x-2">
            <input
              type="text"
              name="objectId"
              placeholder="User Id"
              onChange={handleChange}
              value={values.objectId}
            />
            <input
              type="text"
              name="name"
              placeholder="Name"
              onChange={handleChange}
              value={values.name}
            />
            <button type="submit" disabled={isSubmitting}>
              Submit
            </button>
          </form>
        )}
      </Formik>
    </div>
  );
}
