import { Formik } from "formik";
import { postData } from "utils/api-helpers";

export default function CreateGroup() {
  return (
    <div>
      <span>Create group</span>
      <Formik
        initialValues={{ name: "", userId: "" }}
        onSubmit={async ({ name, userId }, { resetForm }) => {
          await postData("/groups", {
            name,
            userId,
          });
        }}
      >
        {({ values, handleChange, handleSubmit, isSubmitting }) => (
          <form onSubmit={handleSubmit} className="space-x-2">
            <input
              type="text"
              name="name"
              placeholder="Group name"
              onChange={handleChange}
              value={values.name}
            />
            <input
              type="text"
              name="userId"
              placeholder="User to add (id)"
              onChange={handleChange}
              value={values.userId}
            />
            <button type="submit" disabled={isSubmitting}>
              Create
            </button>
          </form>
        )}
      </Formik>
    </div>
  );
}
