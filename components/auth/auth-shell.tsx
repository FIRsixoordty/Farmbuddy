import type { ReactNode } from "react";

import { Logo } from "@/components/layout/logo";

function AuthShell({
  title,
  description,
  children,
}: {
  title: string;
  description: string;
  children: ReactNode;
}) {
  return (
    <div className="mx-auto flex max-w-md flex-col gap-8 px-4 py-16 sm:px-6">
      <div className="flex flex-col items-center gap-4 text-center">
        <Logo />
        <div className="flex flex-col gap-1.5">
          <h1 className="text-2xl font-semibold text-foreground">{title}</h1>
          <p className="text-sm text-muted-foreground">{description}</p>
        </div>
      </div>

      <div className="rounded-2xl border border-border bg-card p-6 sm:p-8">
        {children}
      </div>
    </div>
  );
}

export { AuthShell };
