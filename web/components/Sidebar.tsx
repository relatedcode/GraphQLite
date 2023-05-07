import { Dialog, Menu, Transition } from "@headlessui/react";
import {
  CogIcon,
  CollectionIcon,
  DatabaseIcon,
  MenuAlt2Icon,
  UserGroupIcon,
  XIcon,
} from "@heroicons/react/outline";
import { UserCircleIcon } from "@heroicons/react/solid";
import Link from "next/link";
import { useRouter } from "next/router";
import { Fragment, useState } from "react";
import classNames from "utils/classNames";

const userNavigation = [{ name: "Sign out", href: "/logout" }];

export default function Sidebar({ children }) {
  const router = useRouter();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const navigation = [
    {
      name: "Auth",
      href: "/auth",
      icon: UserGroupIcon,
      current: router.pathname.includes("/auth"),
    },
    {
      name: "Database",
      href: "/database",
      icon: DatabaseIcon,
      current: router.pathname.includes("/database"),
    },
    {
      name: "GraphQL",
      href: "/graphql",
      icon: () => (
        <svg
          version="1.1"
          id="GraphQL_Logo"
          x="0px"
          y="0px"
          viewBox="0 0 400 400"
          enableBackground="new 0 0 400 400"
          xmlSpace="preserve"
          className="h-6 w-6 fill-current"
        >
          <g>
            <g>
              <g>
                <rect
                  x="122"
                  y="-0.4"
                  transform="matrix(-0.866 -0.5 0.5 -0.866 163.3196 363.3136)"
                  width="16.6"
                  height="320.3"
                />
              </g>
            </g>
            <g>
              <g>
                <rect x="39.8" y="272.2" width="320.3" height="16.6" />
              </g>
            </g>
            <g>
              <g>
                <rect
                  x="37.9"
                  y="312.2"
                  transform="matrix(-0.866 -0.5 0.5 -0.866 83.0693 663.3409)"
                  width="185"
                  height="16.6"
                />
              </g>
            </g>
            <g>
              <g>
                <rect
                  x="177.1"
                  y="71.1"
                  transform="matrix(-0.866 -0.5 0.5 -0.866 463.3409 283.0693)"
                  width="185"
                  height="16.6"
                />
              </g>
            </g>
            <g>
              <g>
                <rect
                  x="122.1"
                  y="-13"
                  transform="matrix(-0.5 -0.866 0.866 -0.5 126.7903 232.1221)"
                  width="16.6"
                  height="185"
                />
              </g>
            </g>
            <g>
              <g>
                <rect
                  x="109.6"
                  y="151.6"
                  transform="matrix(-0.5 -0.866 0.866 -0.5 266.0828 473.3766)"
                  width="320.3"
                  height="16.6"
                />
              </g>
            </g>
            <g>
              <g>
                <rect x="52.5" y="107.5" width="16.6" height="185" />
              </g>
            </g>
            <g>
              <g>
                <rect x="330.9" y="107.5" width="16.6" height="185" />
              </g>
            </g>
            <g>
              <g>
                <rect
                  x="262.4"
                  y="240.1"
                  transform="matrix(-0.5 -0.866 0.866 -0.5 126.7953 714.2875)"
                  width="14.5"
                  height="160.9"
                />
              </g>
            </g>
            <path
              d="M369.5,297.9c-9.6,16.7-31,22.4-47.7,12.8c-16.7-9.6-22.4-31-12.8-47.7c9.6-16.7,31-22.4,47.7-12.8
		C373.5,259.9,379.2,281.2,369.5,297.9"
            />
            <path
              d="M90.9,137c-9.6,16.7-31,22.4-47.7,12.8c-16.7-9.6-22.4-31-12.8-47.7c9.6-16.7,31-22.4,47.7-12.8
		C94.8,99,100.5,120.3,90.9,137"
            />
            <path
              d="M30.5,297.9c-9.6-16.7-3.9-38,12.8-47.7c16.7-9.6,38-3.9,47.7,12.8c9.6,16.7,3.9,38-12.8,47.7
		C61.4,320.3,40.1,314.6,30.5,297.9"
            />
            <path
              d="M309.1,137c-9.6-16.7-3.9-38,12.8-47.7c16.7-9.6,38-3.9,47.7,12.8c9.6,16.7,3.9,38-12.8,47.7
		C340.1,159.4,318.7,153.7,309.1,137"
            />
            <path
              d="M200,395.8c-19.3,0-34.9-15.6-34.9-34.9c0-19.3,15.6-34.9,34.9-34.9c19.3,0,34.9,15.6,34.9,34.9
		C234.9,380.1,219.3,395.8,200,395.8"
            />
            <path
              d="M200,74c-19.3,0-34.9-15.6-34.9-34.9c0-19.3,15.6-34.9,34.9-34.9c19.3,0,34.9,15.6,34.9,34.9
		C234.9,58.4,219.3,74,200,74"
            />
          </g>
        </svg>
      ),
      current: router.pathname.includes("/graphql"),
    },
    {
      name: "Storage",
      href: "/storage",
      icon: CollectionIcon,
      current: router.pathname.includes("/storage"),
    },
    {
      name: "Settings",
      href: "/settings",
      icon: CogIcon,
      current: router.pathname.includes("/settings"),
    },
  ];

  return (
    <div className="h-full flex">
      {/* Narrow sidebar */}
      <div className="hidden w-28 bg-green-600 overflow-y-auto md:block">
        <div className="w-full h-full py-6 flex flex-col items-center">
          <div className="flex-shrink-0 flex items-center">
            <img className="h-12 w-auto" src="/logo.png" alt="" />
          </div>
          <div className="mt-6 w-full h-full flex flex-col px-2">
            {navigation.map((item, index) => (
              <Link key={item.name} href={item.href}>
                <a
                  className={classNames(
                    item.current
                      ? "bg-green-800 text-white"
                      : "text-green-100 hover:bg-green-800 hover:text-white",
                    index === navigation.length - 1 ? "mt-auto" : "mt-1",
                    "group w-full p-3 rounded-md flex flex-col items-center text-xs font-medium"
                  )}
                  aria-current={item.current ? "page" : undefined}
                >
                  <item.icon
                    className={classNames(
                      item.current
                        ? "text-white"
                        : "text-green-300 group-hover:text-white",
                      "h-6 w-6"
                    )}
                    aria-hidden="true"
                  />
                  <span className="mt-2">{item.name}</span>
                </a>
              </Link>
            ))}
          </div>
        </div>
      </div>

      {/* Mobile menu */}
      <Transition.Root show={mobileMenuOpen} as={Fragment}>
        <Dialog
          as="div"
          className="fixed inset-0 z-40 flex md:hidden"
          onClose={setMobileMenuOpen}
        >
          <Transition.Child
            as={Fragment}
            enter="transition-opacity ease-linear duration-300"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="transition-opacity ease-linear duration-300"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <Dialog.Overlay className="fixed inset-0 bg-gray-600 bg-opacity-75" />
          </Transition.Child>
          <Transition.Child
            as={Fragment}
            enter="transition ease-in-out duration-300 transform"
            enterFrom="-translate-x-full"
            enterTo="translate-x-0"
            leave="transition ease-in-out duration-300 transform"
            leaveFrom="translate-x-0"
            leaveTo="-translate-x-full"
          >
            <div className="relative max-w-xs w-full bg-green-700 pt-5 pb-4 flex-1 flex flex-col">
              <Transition.Child
                as={Fragment}
                enter="ease-in-out duration-300"
                enterFrom="opacity-0"
                enterTo="opacity-100"
                leave="ease-in-out duration-300"
                leaveFrom="opacity-100"
                leaveTo="opacity-0"
              >
                <div className="absolute top-1 right-0 -mr-14 p-1">
                  <button
                    type="button"
                    className="h-12 w-12 rounded-full flex items-center justify-center focus:outline-none focus:ring-2 focus:ring-white"
                    onClick={() => setMobileMenuOpen(false)}
                  >
                    <XIcon className="h-6 w-6 text-white" aria-hidden="true" />
                    <span className="sr-only">Close sidebar</span>
                  </button>
                </div>
              </Transition.Child>
              <div className="flex-shrink-0 px-4 flex items-center">
                <img className="h-8 w-auto" src="/logo.png" alt="" />
              </div>
              <div className="mt-5 flex-1 h-0 px-2 overflow-y-auto">
                <nav className="h-full flex flex-col">
                  <div className="space-y-1">
                    {navigation.map((item) => (
                      <a
                        key={item.name}
                        href={item.href}
                        className={classNames(
                          item.current
                            ? "bg-green-800 text-white"
                            : "text-green-100 hover:bg-green-800 hover:text-white",
                          "group py-2 px-3 rounded-md flex items-center text-sm font-medium"
                        )}
                        aria-current={item.current ? "page" : undefined}
                      >
                        <item.icon
                          className={classNames(
                            item.current
                              ? "text-white"
                              : "text-green-300 group-hover:text-white",
                            "mr-3 h-6 w-6"
                          )}
                          aria-hidden="true"
                        />
                        <span>{item.name}</span>
                      </a>
                    ))}
                  </div>
                </nav>
              </div>
            </div>
          </Transition.Child>
          <div className="flex-shrink-0 w-14" aria-hidden="true">
            {/* Dummy element to force sidebar to shrink to fit close icon */}
          </div>
        </Dialog>
      </Transition.Root>

      <div className="flex-1 flex flex-col overflow-hidden">
        <header className="w-full">
          <div className="relative z-10 flex-shrink-0 h-16 bg-white border-b border-gray-200 shadow-sm flex">
            <button
              type="button"
              className="border-r border-gray-200 px-4 text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-green-500 md:hidden"
              onClick={() => setMobileMenuOpen(true)}
            >
              <span className="sr-only">Open sidebar</span>
              <MenuAlt2Icon className="h-6 w-6" aria-hidden="true" />
            </button>
            <div className="flex-1 flex justify-between px-4 sm:px-6">
              <div className="flex-1 flex"></div>
              <div className="ml-2 flex items-center space-x-4 sm:ml-6 sm:space-x-6">
                {/* Profile dropdown */}
                <Menu as="div" className="relative flex-shrink-0">
                  <div>
                    <Menu.Button className="bg-white rounded-full flex text-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500">
                      <span className="sr-only">Open user menu</span>
                      <UserCircleIcon className="h-8 w-8 rounded-full text-gray-500" />
                    </Menu.Button>
                  </div>
                  <Transition
                    as={Fragment}
                    enter="transition ease-out duration-100"
                    enterFrom="transform opacity-0 scale-95"
                    enterTo="transform opacity-100 scale-100"
                    leave="transition ease-in duration-75"
                    leaveFrom="transform opacity-100 scale-100"
                    leaveTo="transform opacity-0 scale-95"
                  >
                    <Menu.Items className="origin-top-right absolute right-0 mt-2 w-48 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5 focus:outline-none">
                      {userNavigation.map((item) => (
                        <Menu.Item key={item.name}>
                          {({ active }) => (
                            <Link href={item.href}>
                              <a
                                className={classNames(
                                  active ? "bg-gray-100" : "",
                                  "block px-4 py-2 text-sm text-gray-700"
                                )}
                              >
                                {item.name}
                              </a>
                            </Link>
                          )}
                        </Menu.Item>
                      ))}
                    </Menu.Items>
                  </Transition>
                </Menu>
              </div>
            </div>
          </div>
        </header>
        {children}
      </div>
    </div>
  );
}
