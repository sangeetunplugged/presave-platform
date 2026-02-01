"use client";

import { SessionProvider } from "next-auth/react";
import { createContext, useContext, useState } from "react";

const AppContext = createContext<any>(null);

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <SessionProvider>
      <AppContext.Provider value={{}}>
        {children}
      </AppContext.Provider>
    </SessionProvider>
  );
}

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error("useApp must be used within Providers");
  }
  return context;
};
