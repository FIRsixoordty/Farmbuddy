import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

/**
 * Merge Tailwind class names safely, resolving conflicting utility classes
 * (e.g. "p-2" vs "p-4") in favor of the last one provided.
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Only allow redirecting to a same-origin, relative path (e.g. after
 * login). Rejects absolute URLs and protocol-relative paths ("//evil.com")
 * so a crafted `?next=` query param can never send someone off-site.
 */
export function isSafeRedirectPath(path: unknown): path is string {
  return (
    typeof path === "string" &&
    path.startsWith("/") &&
    !path.startsWith("//") &&
    !path.includes("://")
  );
}
