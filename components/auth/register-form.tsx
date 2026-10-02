"use client";

import Link from "next/link";
import { useActionState } from "react";

import { registerAction } from "@/lib/actions/auth";
import { initialActionState } from "@/lib/actions/types";
import { Alert } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

function FieldError({ messages }: { messages?: string[] }) {
  if (!messages?.length) return null;
  return <p className="text-sm text-destructive">{messages[0]}</p>;
}

function RegisterForm() {
  const [state, formAction, isPending] = useActionState(
    registerAction,
    initialActionState,
  );

  if (state.status === "success") {
    return (
      <div className="flex flex-col gap-4">
        <Alert variant="success">{state.message}</Alert>
        <Button variant="outline" asChild>
          <Link href="/login">Kembali ke halaman masuk</Link>
        </Button>
      </div>
    );
  }

  return (
    <form action={formAction} className="flex flex-col gap-5">
      {state.status === "error" && state.message && (
        <Alert variant="destructive">{state.message}</Alert>
      )}

      <div className="flex flex-col gap-1.5">
        <Label htmlFor="displayName">Nama Tampilan</Label>
        <Input
          id="displayName"
          name="displayName"
          autoComplete="name"
          placeholder="Budi Santoso"
          aria-invalid={!!state.fieldErrors?.displayName}
          required
        />
        <FieldError messages={state.fieldErrors?.displayName} />
      </div>

      <div className="flex flex-col gap-1.5">
        <Label htmlFor="username">Username</Label>
        <Input
          id="username"
          name="username"
          autoComplete="username"
          placeholder="budi_tani"
          pattern="[a-z0-9_]+"
          aria-invalid={!!state.fieldErrors?.username}
          required
        />
        <p className="text-xs text-muted-foreground">
          Huruf kecil, angka, dan underscore saja.
        </p>
        <FieldError messages={state.fieldErrors?.username} />
      </div>

      <div className="flex flex-col gap-1.5">
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          name="email"
          type="email"
          autoComplete="email"
          placeholder="kamu@contoh.com"
          aria-invalid={!!state.fieldErrors?.email}
          required
        />
        <FieldError messages={state.fieldErrors?.email} />
      </div>

      <div className="flex flex-col gap-1.5">
        <Label htmlFor="password">Kata Sandi</Label>
        <Input
          id="password"
          name="password"
          type="password"
          autoComplete="new-password"
          placeholder="Minimal 8 karakter"
          aria-invalid={!!state.fieldErrors?.password}
          required
        />
        <FieldError messages={state.fieldErrors?.password} />
      </div>

      <Button type="submit" size="lg" disabled={isPending}>
        {isPending ? "Mendaftarkan..." : "Daftar"}
      </Button>

      <p className="text-center text-sm text-muted-foreground">
        Sudah punya akun?{" "}
        <Link href="/login" className="text-primary underline underline-offset-2">
          Masuk
        </Link>
      </p>
    </form>
  );
}

export { RegisterForm };
