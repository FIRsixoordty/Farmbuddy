"use client";

import Link from "next/link";
import { useActionState } from "react";

import { forgotPasswordAction } from "@/lib/actions/auth";
import { initialActionState } from "@/lib/actions/types";
import { Alert } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

function FieldError({ messages }: { messages?: string[] }) {
  if (!messages?.length) return null;
  return <p className="text-sm text-destructive">{messages[0]}</p>;
}

function ForgotPasswordForm() {
  const [state, formAction, isPending] = useActionState(
    forgotPasswordAction,
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

      <Button type="submit" size="lg" disabled={isPending}>
        {isPending ? "Mengirim..." : "Kirim Tautan Reset"}
      </Button>

      <p className="text-center text-sm text-muted-foreground">
        Ingat kata sandi?{" "}
        <Link href="/login" className="text-primary underline underline-offset-2">
          Masuk
        </Link>
      </p>
    </form>
  );
}

export { ForgotPasswordForm };
