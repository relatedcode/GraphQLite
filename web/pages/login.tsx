import GuestGuard from "components/GuestGuard";
import Input from "components/Input";
import { useFormik } from "formik";
import useAuth from "hooks/useAuth";
import { toast } from "react-hot-toast";
import Link from "next/link";

function Login() {
  const { login } = useAuth();
  const formik = useFormik({
    initialValues: {
      email: "",
      password: "",
    },
    onSubmit: async ({ email, password }, { resetForm }) => {
      try {
        await login(email, password);
        resetForm();
      } catch (err) {
        toast.error(err.message);
      }
    },
  });

  return (
    <div className="min-h-full flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <img className="mx-auto h-20 w-auto" src="/logo.png" alt="" />
        <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
          Sign in to your Admin Console
        </h2>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          <form onSubmit={formik.handleSubmit} className="space-y-6">
            <Input
              label="Email"
              name="email"
              type="email"
              handleChange={formik.handleChange}
              value={formik.values.email}
              required
            />
            <Input
              label="Password"
              name="password"
              type="password"
              handleChange={formik.handleChange}
              value={formik.values.password}
              required
            />
            <div>
              <button
                type="submit"
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
              >
                Sign in
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

export default function Main() {
  return (
    <GuestGuard>
      <Login />
    </GuestGuard>
  );
}
