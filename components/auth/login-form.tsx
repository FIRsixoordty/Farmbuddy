"use client";

import Link from "next/link";
import { useActionState } from "react";

import { loginAction } from "@/lib/actions/auth";
import { initialActionState } from "@/lib/actions/types";
import { Alert } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

function FieldError({ messages }: { messages?: string[] }) {
  if (!messages?.length) return null;
  return <p className="text-sm text-destructive">{messages[0]}</p>;
}

function LoginForm({ next }: { next?: string }) {
  const [state, formAction, isPending] = useActionState(
    loginAction,
    initialActionState,
  );

  return (
    <form action={formAction} className="flex flex-col gap-5">
      {next && <input type="hidden" name="next" value={next} />}

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

      <div className="flex flex-col gap-1.5">
        <div className="flex items-center justify-between">
          <Label htmlFor="password">Kata Sandi</Label>
          <Link
            href="/forgot-password"
            className="text-xs text-muted-foreground underline underline-offset-2 hover:text-foreground"
          >
            Lupa kata sandi?
          </Link>
        </div>
        <Input
          id="password"
          name="password"
          type="password"
          autoComplete="current-password"
          aria-invalid={!!state.fieldErrors?.password}
          required
        />
        <FieldError messages={state.fieldErrors?.password} />
      </div>

      <Button type="submit" size="lg" disabled={isPending}>
        {isPending ? "Masuk..." : "Masuk"}
      </Button>

      <p className="text-center text-sm text-muted-foreground">
        Belum punya akun?{" "}
        <Link
          href="/register"
          className="text-primary underline underline-offset-2"
        >
          Daftar
        </Link>
      </p>
    </form>
  );
}

export { LoginForm };
