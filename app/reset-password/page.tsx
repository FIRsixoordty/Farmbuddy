import Link from "next/link";
import type { Metadata } from "next";

import { AuthShell } from "@/components/auth/auth-shell";
import { ResetPasswordForm } from "@/components/auth/reset-password-form";
import { Alert } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { getCurrentProfile } from "@/lib/supabase/profile";

export const metadata: Metadata = { title: "Atur Ulang Kata Sandi" };

export default async function ResetPasswordPage() {
  // Reaching this page with a valid session means the /auth/confirm route
  // already verified the recovery link. No session here means the link was
  // missing, already used, or expired.
  const current = await getCurrentProfile();

  return (
    <AuthShell
      title="Atur Ulang Kata Sandi"
      description="Buat kata sandi baru untuk akun Farm Buddy kamu."
    >
      {current ? (
        <ResetPasswordForm />
      ) : (
        <div className="flex flex-col gap-4">
          <Alert variant="destructive">
            Tautan reset kata sandi tidak valid atau sudah kedaluwarsa.
          </Alert>
          <Button asChild>
            <Link href="/forgot-password">Kirim Ulang Tautan</Link>
          </Button>
        </div>
      )}
    </AuthShell>
  );
}
