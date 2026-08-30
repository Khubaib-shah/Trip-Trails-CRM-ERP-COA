import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";

interface BranchState {
  activeBranchId: string | "all";
  activeCurrency: string;
  setActiveBranchId: (id: string | "all") => void;
  setActiveBranch: (id: string | "all", currency?: string) => void;
}

export const useBranchStore = create<BranchState>()(
  persist(
    (set) => ({
      activeBranchId: "all",
      activeCurrency: "PKR",
      setActiveBranchId: (id) => set({ activeBranchId: id }),
      setActiveBranch: (id, currency) => set({ activeBranchId: id, activeCurrency: currency || "PKR" }),
    }),
    {
      name: "tf-active-branch",
      storage: createJSONStorage(() => localStorage),
    }
  )
);
