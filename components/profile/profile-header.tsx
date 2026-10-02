import { MapPin, User as UserIcon } from "lucide-react";

import type { Profile } from "@/types/profile";

function formatJoinDate(iso: string) {
  return new Intl.DateTimeFormat("id-ID", {
    month: "long",
    year: "numeric",
  }).format(new Date(iso));
}

function ProfileHeader({ profile }: { profile: Profile }) {
  return (
    <div className="flex flex-col items-center gap-4 rounded-2xl border border-border bg-card p-8 text-center sm:flex-row sm:text-left">
      <span className="flex size-20 shrink-0 items-center justify-center overflow-hidden rounded-full bg-secondary text-primary">
        {profile.avatar_url ? (
          // eslint-disable-next-line @next/next/no-img-element -- remote avatar URLs aren't known ahead of time (Storage), so next/image domain config isn't set up for them yet.
          <img
            src={profile.avatar_url}
            alt={profile.display_name}
            className="size-full object-cover"
          />
        ) : (
          <UserIcon className="size-8" strokeWidth={1.75} />
        )}
      </span>

      <div className="flex flex-col gap-1.5">
        <h1 className="text-2xl font-semibold text-foreground">
          {profile.display_name}
        </h1>
        <p className="text-sm text-muted-foreground">@{profile.username}</p>

        {profile.bio && (
          <p className="mt-1 max-w-md text-sm text-foreground/80">
            {profile.bio}
          </p>
        )}

        <div className="mt-2 flex flex-wrap items-center justify-center gap-x-4 gap-y-1 text-xs text-muted-foreground sm:justify-start">
          {profile.location && (
            <span className="inline-flex items-center gap-1">
              <MapPin className="size-3.5" />
              {profile.location}
            </span>
          )}
          <span>Bergabung sejak {formatJoinDate(profile.created_at)}</span>
        </div>
      </div>
    </div>
  );
}

export { ProfileHeader };
