import { redirect } from "next/navigation";
import type { NextRequest } from "next/server";
import type { EmailOtpType } from "@supabase/supabase-js";

import { createClient } from "@/lib/supabase/server";
import { isSafeRedirectPath } from "@/lib/utils";

/**
 * Handles the link Supabase Auth emails out for both "confirm your email"
 * (type=signup/email) and "reset your password" (type=recovery) flows.
 * Both are configured in the Supabase dashboard's email templates to point
 * here with a `token_hash` + `type`, per Supabase's documented Next.js SSR
 * pattern — see docs/phase-3-auth.md for the exact template to set.
 */
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const tokenHash = searchParams.get("token_hash");
  const type = searchParams.get("type") as EmailOtpType | null;
  const rawNext = searchParams.get("next");
  const next = isSafeRedirectPath(rawNext) ? rawNext : "/";

  if (tokenHash && type) {
    const supabase = await createClient();
    const { error } = await supabase.auth.verifyOtp({
      type,
      token_hash: tokenHash,
    });

    if (!error) {
      redirect(next);
    }
  }

  redirect("/login?error=link-invalid");
}
