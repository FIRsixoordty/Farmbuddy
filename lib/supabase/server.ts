import { cookies } from "next/headers";
import { createServerClient } from "@supabase/ssr";

/**
 * Supabase client for use on the server: Server Components, Route Handlers,
 * and Server Actions. Must be created fresh per request (it reads cookies).
 *
 * TODO(Phase 2): pass a generated `Database` type once the schema exists.
 * TODO(Phase 3): pair with middleware that refreshes the auth session cookie
 * on every request once login/logout exist.
 */
export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            );
          } catch {
            // The `setAll` method was called from a Server Component.
            // This can be ignored if there is middleware refreshing
            // sessions on every request (added in Phase 3).
          }
        },
      },
    },
  );
}
