import type { Metadata } from "next";

import { SettingsForm } from "@/components/profile/settings-form";
import { requireProfile } from "@/lib/supabase/profile";

export const metadata: Metadata = { title: "Pengaturan" };

export default async function PengaturanPage() {
  const { profile } = await requireProfile("/pengaturan");

  return (
    <div className="mx-auto max-w-2xl px-4 py-12 sm:px-6">
      <h1 className="text-2xl font-semibold text-foreground sm:text-3xl">
        Pengaturan Akun
      </h1>
      <p className="mt-2 text-sm text-muted-foreground">
        Kelola bagaimana kamu tampil ke komunitas Farm Buddy.
      </p>

      <div className="mt-8 rounded-2xl border border-border bg-card p-6 sm:p-8">
        <SettingsForm profile={profile} />
      </div>
    </div>
  );
}
