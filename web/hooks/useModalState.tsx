import { ModalContext } from "providers/ModalProvider";
import { useContext } from "react";

export function useModalState() {
  return useContext(ModalContext);
}
