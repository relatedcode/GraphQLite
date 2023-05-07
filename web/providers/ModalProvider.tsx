import { createContext, ReactNode, useState } from "react";

export const ModalContext = createContext({
  newUserOpen: false,
  setNewUserOpen: null as any,
  newBucketOpen: false,
  setNewBucketOpen: null as any,
  resetConfirmOpen: false,
  setResetConfirmOpen: null as any,
  resetServerOpen: false,
  setResetServerOpen: null as any,
  cleanupDBOpen: false,
  setCleanupDBOpen: null as any,
});

export default function ModalProvider({ children }: { children: ReactNode }) {
  const [newUserOpen, setNewUserOpen] = useState(false);
  const [newBucketOpen, setNewBucketOpen] = useState(false);
  const [resetConfirmOpen, setResetConfirmOpen] = useState(false);
  const [resetServerOpen, setResetServerOpen] = useState(false);
  const [cleanupDBOpen, setCleanupDBOpen] = useState(false);
  return (
    <ModalContext.Provider
      value={{
        newUserOpen,
        setNewUserOpen,
        newBucketOpen,
        setNewBucketOpen,
        resetConfirmOpen,
        setResetConfirmOpen,
        resetServerOpen,
        setResetServerOpen,
        cleanupDBOpen,
        setCleanupDBOpen,
      }}
    >
      {children}
    </ModalContext.Provider>
  );
}
