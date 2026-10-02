"use server";

import { redirect } from "next/navigation";

import type { ActionState } from "@/lib/actions/types";
import { getSiteUrl } from "@/lib/site-url";
import { createClient } from "@/lib/supabase/server";
import { isSafeRedirectPath } from "@/lib/utils";
import {
  forgotPasswordSchema,
  loginSchema,
  registerSchema,
  resetPasswordSchema,
} from "@/lib/validations/auth";

// Supabase Auth (GoTrue) error messages are plain English strings with no
// stable error code for most of them, so we match on message text. Falls
// back to a generic message for anything not mapped here.
function mapAuthErrorMessage(message: string): string {
  const known: Record<string, string> = {
    "Invalid login credentials": "Email atau kata sandi salah.",
    "Email not confirmed":
      "Email belum dikonfirmasi. Cek inbox kamu untuk tautan konfirmasi.",
    "User already registered":
      "Email ini sudah terdaftar. Coba masuk, atau gunakan email lain.",
  };

  return (
    known[message] ??
    (message.toLowerCase().includes("password")
      ? "Kata sandi tidak memenuhi syarat minimum Supabase untuk project ini."
      : "Terjadi kesalahan. Silakan coba lagi.")
  );
}

export async function registerAction(
  _prevState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const parsed = registerSchema.safeParse({
    email: formData.get("email"),
    password: formData.get("password"),
    username: formData.get("username"),
    displayName: formData.get("displayName"),
  });

  if (!parsed.success) {
    return {
      status: "error",
      message: "Periksa kembali data yang kamu isi.",
      fieldErrors: parsed.error.flatten().fieldErrors,
    };
  }

  const { email, password, username, displayName } = parsed.data;
  const supabase = await createClient();

  // Friendly pre-check so a taken username surfaces as a normal field
  // error. This does not fully close the race-condition window by itself —
  // the unique constraint + on_auth_user_created trigger (schema.sql,
  // section 11) is the real guarantee, and it fails the whole signup
  // atomically (verified in supabase/README.md) rather than leaving an
  // orphaned auth user.
  const { data: existingUsername } = await supabase
    .from("profiles")
    .select("id")
    .eq("username", username)
    .maybeSingle();

  if (existingUsername) {
    return {
      status: "error",
      fieldErrors: { username: ["Username sudah digunakan, coba yang lain."] },
    };
  }

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      // Read by the on_auth_user_created trigger (schema.sql) to create
      // the matching profiles row — see supabase/README.md.
      data: { username, display_name: displayName },
    },
  });

  if (error) {
    return { status: "error", message: mapAuthErrorMessage(error.message) };
  }

  // If email confirmation is off (or already auto-confirmed), signUp()
  // returns an active session immediately and we can go straight in.
  if (data.session) {
    redirect("/dashboard");
  }

  return {
    status: "success",
    message:
      "Pendaftaran berhasil! Cek email kamu untuk mengonfirmasi akun sebelum masuk.",
  };
}

export async function loginAction(
  _prevState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const parsed = loginSchema.safeParse({
    email: formData.get("email"),
    password: formData.get("password"),
  });

  if (!parsed.success) {
    return {
      status: "error",
      message: "Periksa kembali data yang kamu isi.",
      fieldErrors: parsed.error.flatten().fieldErrors,
    };
  }

  const rawNext = formData.get("next");
  const nextPath = isSafeRedirectPath(rawNext) ? rawNext : "/dashboard";

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithPassword(parsed.data);

  if (error) {
    return { status: "error", message: mapAuthErrorMessage(error.message) };
  }

  redirect(nextPath);
}

export async function logoutAction() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/");
}

export async function forgotPasswordAction(
  _prevState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const parsed = forgotPasswordSchema.safeParse({
    email: formData.get("email"),
  });

  if (!parsed.success) {
    return {
      status: "error",
      message: "Periksa kembali email yang kamu isi.",
      fieldErrors: parsed.error.flatten().fieldErrors,
    };
  }

  const supabase = await createClient();
  const siteUrl = await getSiteUrl();

  const { error } = await supabase.auth.resetPasswordForEmail(
    parsed.data.email,
    { redirectTo: `${siteUrl}/auth/confirm?next=/reset-password` },
  );

  if (error) {
    return { status: "error", message: mapAuthErrorMessage(error.message) };
  }

  // Same message whether or not the email is actually registered, so this
  // flow can't be used to check which emails have an account.
  return {
    status: "success",
    message:
      "Kalau email tersebut terdaftar, tautan reset kata sandi sudah kami kirim. Cek inbox atau folder spam kamu.",
  };
}

export async function updatePasswordAction(
  _prevState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const parsed = resetPasswordSchema.safeParse({
    password: formData.get("password"),
    confirmPassword: formData.get("confirmPassword"),
  });

  if (!parsed.success) {
    return {
      status: "error",
      message: "Periksa kembali kata sandi yang kamu isi.",
      fieldErrors: parsed.error.flatten().fieldErrors,
    };
  }

  const supabase = await createClient();
  const { error } = await supabase.auth.updateUser({
    password: parsed.data.password,
  });

  if (error) {
    return { status: "error", message: mapAuthErrorMessage(error.message) };
  }

  redirect("/dashboard");
}
