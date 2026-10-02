"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";

import type { ActionState } from "@/lib/actions/types";
import { createClient } from "@/lib/supabase/server";
import { settingsSchema } from "@/lib/validations/auth";

export async function updateSettingsAction(
  _prevState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const parsed = settingsSchema.safeParse({
    displayName: formData.get("displayName"),
    bio: formData.get("bio") || undefined,
    location: formData.get("location") || undefined,
  });

  if (!parsed.success) {
    return {
      status: "error",
      message: "Periksa kembali data yang kamu isi.",
      fieldErrors: parsed.error.flatten().fieldErrors,
    };
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  const { data: updated, error } = await supabase
    .from("profiles")
    .update({
      display_name: parsed.data.displayName,
      bio: parsed.data.bio || null,
      location: parsed.data.location || null,
    })
    .eq("id", user.id)
    .select("username")
    .single();

  if (error) {
    return {
      status: "error",
      message: "Gagal menyimpan perubahan. Silakan coba lagi.",
    };
  }

  // Refresh the navbar (part of the root layout) and the public profile
  // page immediately, not just on the next unrelated navigation.
  revalidatePath("/", "layout");
  revalidatePath(`/profil/${updated.username}`);

  return { status: "success", message: "Perubahan berhasil disimpan." };
}
