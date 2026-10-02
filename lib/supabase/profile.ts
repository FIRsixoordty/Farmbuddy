import { redirect } from "next/navigation";

import { createClient } from "@/lib/supabase/server";
import type { Profile } from "@/types/profile";

/**
 * Returns the current user + profile, or null if nobody is signed in.
 *
 * Uses `getUser()` rather than `getSession()`: `getSession()` only reads the
 * local cookie without checking it's still valid, while `getUser()`
 * revalidates against Supabase Auth. That distinction matters here because
 * this result gates access to protected pages.
 */
export async function getCurrentProfile(): Promise<{
  user: { id: string; email: string | null };
  profile: Profile;
} | null> {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) return null;

    const { data: profile } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.id)
      .single();

    if (!profile) return null;

    return { user: { id: user.id, email: user.email ?? null }, profile };
  } catch {
    // Fail closed: if Supabase can't be reached or the session can't be
    // verified, treat the visitor as signed out rather than risk showing
    // protected content.
    return null;
  }
}

/**
 * For Server Components that require a signed-in user. Redirects to
 * /login (preserving the originally requested path via ?next=) when there
 * is no valid session, so the page body never runs for a signed-out
 * visitor. This is the authoritative check — proxy.ts only does a faster
 * "optimistic" redirect for the common case and must not be relied on
 * alone (see Next.js's own guidance on Proxy + auth).
 */
export async function requireProfile(currentPath: string) {
  const result = await getCurrentProfile();

  if (!result) {
    const next = encodeURIComponent(currentPath);
    redirect(`/login?next=${next}`);
  }

  return result;
}
