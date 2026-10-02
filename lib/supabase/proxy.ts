import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

// Paths that require a signed-in user. This is only an *optimistic* check
// for a fast redirect on the common case (no session cookie at all) — the
// authoritative check lives in each protected Server Component via
// requireProfile(), per Next.js's own guidance that Proxy must not be the
// sole gate for auth (a matcher change or refactor could silently remove
// Proxy coverage from a route).
const PROTECTED_PATH_PREFIXES = ["/dashboard", "/pengaturan"];

/**
 * Refreshes the Supabase auth session cookie on every request, and
 * optimistically redirects signed-out visitors away from protected paths.
 * Called from the root `proxy.ts`.
 */
export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value),
          );
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options),
          );
        },
      },
    },
  );

  // IMPORTANT: do not add logic between createServerClient and this call.
  // getUser() is what actually refreshes the token if it's expired.
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const isProtectedPath = PROTECTED_PATH_PREFIXES.some((prefix) =>
    request.nextUrl.pathname.startsWith(prefix),
  );

  if (!user && isProtectedPath) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("next", request.nextUrl.pathname);
    return NextResponse.redirect(loginUrl);
  }

  return response;
}
