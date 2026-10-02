import type { Metadata } from "next";

import { AuthShell } from "@/components/auth/auth-shell";
import { LoginForm } from "@/components/auth/login-form";
import { Alert } from "@/components/ui/alert";
import { isSafeRedirectPath } from "@/lib/utils";

export const metadata: Metadata = { title: "Masuk" };

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ next?: string; error?: string }>;
}) {
  const params = await searchParams;
  const next = isSafeRedirectPath(params.next) ? params.next : undefined;

  return (
    <AuthShell
      title="Masuk ke Farm Buddy"
      description="Lanjutkan belajar dan berdiskusi bersama komunitas."
    >
      <div className="flex flex-col gap-5">
        {params.error === "link-invalid" && (
          <Alert variant="destructive">
            Tautan sudah tidak berlaku atau kedaluwarsa. Coba kirim ulang.
          </Alert>
        )}
        <LoginForm next={next} />
      </div>
    </AuthShell>
  );
}
