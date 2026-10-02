import Link from "next/link";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { Settings } from "lucide-react";

import { ProfileHeader } from "@/components/profile/profile-header";
import { Button } from "@/components/ui/button";
import { getCurrentProfile } from "@/lib/supabase/profile";
import { createClient } from "@/lib/supabase/server";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ username: string }>;
}): Promise<Metadata> {
  const { username } = await params;
  return { title: `@${username}` };
}

export default async function ProfilPage({
  params,
}: {
  params: Promise<{ username: string }>;
}) {
  const { username } = await params;

  const supabase = await createClient();
  const { data: profile } = await supabase
    .from("profiles")
    .select("*")
    .eq("username", username)
    .maybeSingle();

  if (!profile) {
    notFound();
  }

  const current = await getCurrentProfile();
  const isOwnProfile = current?.profile.id === profile.id;

  return (
    <div className="mx-auto max-w-3xl px-4 py-12 sm:px-6">
      <ProfileHeader profile={profile} />

      {isOwnProfile && (
        <div className="mt-4 flex justify-center sm:justify-end">
          <Button variant="outline" size="sm" asChild>
            <Link href="/pengaturan">
              <Settings />
              Edit Profil
            </Link>
          </Button>
        </div>
      )}

      <div className="mt-6 rounded-2xl border border-dashed border-border bg-muted/40 p-6 text-center text-sm text-muted-foreground">
        Tab Postingan, Jawaban, dan Teman akan tampil di sini begitu Phase 6
        (Komunitas) dan Phase 10 (Friendship) selesai dibangun.
      </div>
    </div>
  );
}
