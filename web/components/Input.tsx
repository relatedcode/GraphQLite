import { forwardRef } from "react";
import classNames from "utils/classNames";

function Input(
  {
    className,
    label,
    placeholder,
    name,
    required = false,
    type,
    handleChange,
    value,
    autoComplete,
    disabled = false,
    infos,
    leftIcon,
    rightIcon,
    hiddenLabel = false,
    customInfos,
  }: {
    label: string;
    name: string;
    required?: boolean;
    placeholder?: string;
    className?: string;
    type: "text" | "email" | "password" | "number";
    handleChange?: any;
    value?: string;
    autoComplete?: string;
    disabled?: boolean;
    infos?: string;
    leftIcon?: string;
    rightIcon?: string;
    hiddenLabel?: boolean;
    customInfos?: React.ReactNode;
  },
  ref
) {
  return (
    <div className={className}>
      <div className="flex justify-between">
        <label
          htmlFor={name}
          className={classNames(
            hiddenLabel ? "sr-only" : "block text-sm font-medium text-gray-700"
          )}
        >
          {label}
        </label>
        {!required && <span className="text-sm text-gray-500">Optional</span>}
      </div>
      <div className="mt-1 relative rounded-md shadow-sm">
        {leftIcon && (
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <span className="text-gray-500 sm:text-sm">{leftIcon}</span>
          </div>
        )}
        <input
          id={name}
          name={name}
          type={type}
          ref={ref}
          autoComplete={autoComplete}
          required={required}
          onChange={handleChange}
          placeholder={placeholder}
          value={value}
          disabled={disabled}
          className={classNames(
            leftIcon ? "pl-7" : "",
            rightIcon ? "pr-12" : "",
            "appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm"
          )}
        />
        {rightIcon && (
          <div className="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
            <span className="text-gray-500 sm:text-sm">{rightIcon}</span>
          </div>
        )}
      </div>
      {infos && (
        <p className="mt-2 text-sm text-gray-500" id={`${name}-description`}>
          {infos}
        </p>
      )}
      {customInfos}
    </div>
  );
}

export default forwardRef(Input);
