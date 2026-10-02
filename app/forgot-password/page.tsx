import type { Metadata } from "next";

import { AuthShell } from "@/components/auth/auth-shell";
import { ForgotPasswordForm } from "@/components/auth/forgot-password-form";

export const metadata: Metadata = { title: "Lupa Kata Sandi" };

export default function ForgotPasswordPage() {
  return (
    <AuthShell
      title="Pulihkan Kata Sandi"
      description="Masukkan email akun kamu, kami kirimkan tautan untuk atur ulang kata sandi."
    >
      <ForgotPasswordForm />
    </AuthShell>
  );
}
