"use client";

import * as React from "react";

import { cn } from "@/lib/utils";

/**
 * NOTE: Radix does not ship a standalone Separator primitive dependency in
 * this project's install set, so this is a lightweight, accessible
 * implementation of the same shadcn/ui API surface (orientation + decorative)
 * without pulling in an extra package.
 */
function Separator({
  className,
  orientation = "horizontal",
  decorative = true,
  ...props
}: React.ComponentProps<"div"> & {
  orientation?: "horizontal" | "vertical";
  decorative?: boolean;
}) {
  return (
    <div
      data-slot="separator"
      role={decorative ? "none" : "separator"}
      aria-orientation={decorative ? undefined : orientation}
      className={cn(
        "shrink-0 bg-border",
        orientation === "horizontal" ? "h-px w-full" : "h-full w-px",
        className,
      )}
      {...props}
    />
  );
}

export { Separator };
