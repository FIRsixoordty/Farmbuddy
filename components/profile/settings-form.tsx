"use client";

import { useActionState } from "react";

import { updateSettingsAction } from "@/lib/actions/profile";
import { initialActionState } from "@/lib/actions/types";
import { Alert } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import type { Profile } from "@/types/profile";

function FieldError({ messages }: { messages?: string[] }) {
  if (!messages?.length) return null;
  return <p className="text-sm text-destructive">{messages[0]}</p>;
}

function SettingsForm({ profile }: { profile: Profile }) {
  const [state, formAction, isPending] = useActionState(
    updateSettingsAction,
    initialActionState,
  );

  return (
    <form action={formAction} className="flex flex-col gap-5">
      {state.status === "error" && state.message && (
        <Alert variant="destructive">{state.message}</Alert>
      )}
      {state.status === "success" && (
        <Alert variant="success">{state.message}</Alert>
      )}

      <div className="flex flex-col gap-1.5">
        <Label htmlFor="displayName">Nama Tampilan</Label>
        <Input
          id="displayName"
          name="displayName"
          defaultValue={profile.display_name}
          aria-invalid={!!state.fieldErrors?.displayName}
          required
        />
        <FieldError messages={state.fieldErrors?.displayName} />
      </div>

      <div className="flex flex-col gap-1.5">
        <Label htmlFor="bio">Bio</Label>
        <textarea
          id="bio"
          name="bio"
          rows={3}
          maxLength={280}
          defaultValue={profile.bio ?? ""}
          placeholder="Ceritakan sedikit tentang kegiatan bertani kamu"
          aria-invalid={!!state.fieldErrors?.bio}
          className="flex w-full rounded-md border border-input bg-card px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background"
        />
        <FieldError messages={state.fieldErrors?.bio} />
      </div>

      <div className="flex flex-col gap-1.5">
        <Label htmlFor="location">Lokasi</Label>
        <Input
          id="location"
          name="location"
          defaultValue={profile.location ?? ""}
          placeholder="Kota atau kabupaten"
          aria-invalid={!!state.fieldErrors?.location}
        />
        <FieldError messages={state.fieldErrors?.location} />
      </div>

      <div className="flex flex-col gap-1.5">
        <Label>Foto Profil</Label>
        <p className="rounded-md border border-dashed border-border bg-muted/40 px-3 py-2.5 text-xs text-muted-foreground">
          Unggah foto profil belum tersedia di fase ini — bucket storage{" "}
          <code>avatars</code> sudah disiapkan (Phase 2), tinggal
          dihubungkan ke antarmuka unggah gambar.
        </p>
      </div>

      <Button type="submit" size="lg" className="self-start" disabled={isPending}>
        {isPending ? "Menyimpan..." : "Simpan Perubahan"}
      </Button>
    </form>
  );
}

export { SettingsForm };
