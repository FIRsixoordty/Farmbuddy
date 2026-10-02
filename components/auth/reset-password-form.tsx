"use client";

import { useActionState } from "react";

import { updatePasswordAction } from "@/lib/actions/auth";
import { initialActionState } from "@/lib/actions/types";
import { Alert } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

function FieldError({ messages }: { messages?: string[] }) {
  if (!messages?.length) return null;
  return <p className="text-sm text-destructive">{messages[0]}</p>;
}

function ResetPasswordForm() {
  const [state, formAction, isPending] = useActionState(
    updatePasswordAction,
    initialActionState,
  );

  return (
    <form action={formAction} className="flex flex-col gap-5">
      {state.status === "error" && state.message && (
        <Alert variant="destructive">{state.message}</Alert>
      )}

      <div className="flex flex-col gap-1.5">
        <Label htmlFor="password">Kata Sandi Baru</Label>
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

      <div className="flex flex-col gap-1.5">
        <Label htmlFor="confirmPassword">Konfirmasi Kata Sandi Baru</Label>
        <Input
          id="confirmPassword"
          name="confirmPassword"
          type="password"
          autoComplete="new-password"
          aria-invalid={!!state.fieldErrors?.confirmPassword}
          required
        />
        <FieldError messages={state.fieldErrors?.confirmPassword} />
      </div>

      <Button type="submit" size="lg" disabled={isPending}>
        {isPending ? "Menyimpan..." : "Simpan Kata Sandi Baru"}
      </Button>
    </form>
  );
}

export { ResetPasswordForm };
