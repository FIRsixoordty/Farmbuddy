import { z } from "zod";

// Mirrors the `profiles.username` check constraint in supabase/schema.sql
// (`^[a-z0-9_]{3,30}$`) and the Zod rule from Section 25 of the master
// prompt (lowercase, alphanumeric, underscore).
const usernameSchema = z
  .string()
  .min(1, "Username wajib diisi")
  .min(3, "Username minimal 3 karakter")
  .max(30, "Username maksimal 30 karakter")
  .regex(
    /^[a-z0-9_]+$/,
    "Username hanya boleh huruf kecil, angka, dan underscore",
  );

const displayNameSchema = z
  .string()
  .min(1, "Nama tampilan wajib diisi")
  .max(80, "Nama tampilan maksimal 80 karakter");

const emailSchema = z
  .string()
  .min(1, "Email wajib diisi")
  .email("Format email tidak valid");

// Supabase's own project-level minimum is 6 by default; 8 is a slightly
// stricter app-level default since the master prompt doesn't specify one.
const passwordSchema = z
  .string()
  .min(8, "Kata sandi minimal 8 karakter");

export const registerSchema = z.object({
  email: emailSchema,
  password: passwordSchema,
  username: usernameSchema,
  displayName: displayNameSchema,
});

export type RegisterInput = z.infer<typeof registerSchema>;

export const loginSchema = z.object({
  email: emailSchema,
  password: z.string().min(1, "Kata sandi wajib diisi"),
});

export type LoginInput = z.infer<typeof loginSchema>;

export const forgotPasswordSchema = z.object({
  email: emailSchema,
});

export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;

export const resetPasswordSchema = z
  .object({
    password: passwordSchema,
    confirmPassword: z.string().min(1, "Konfirmasi kata sandi wajib diisi"),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Konfirmasi kata sandi tidak cocok",
    path: ["confirmPassword"],
  });

export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;

export const settingsSchema = z.object({
  displayName: displayNameSchema,
  bio: z.string().max(280, "Bio maksimal 280 karakter").optional(),
  location: z.string().max(80, "Lokasi maksimal 80 karakter").optional(),
});

export type SettingsInput = z.infer<typeof settingsSchema>;
