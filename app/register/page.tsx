import type { Metadata } from "next";

import { AuthShell } from "@/components/auth/auth-shell";
import { RegisterForm } from "@/components/auth/register-form";

export const metadata: Metadata = { title: "Daftar" };

export default function RegisterPage() {
  return (
    <AuthShell
      title="Buat Akun Farm Buddy"
      description="Mulai belajar bertani, berdiskusi, dan berbagi bersama komunitas."
    >
      <RegisterForm />
    </AuthShell>
  );
}
