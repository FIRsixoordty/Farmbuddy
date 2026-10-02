import Link from "next/link";
import type { Metadata } from "next";
import { CalendarDays, MessagesSquare, Sprout } from "lucide-react";

import { requireProfile } from "@/lib/supabase/profile";

export const metadata: Metadata = { title: "Dashboard" };

const quickActions = [
  {
    label: "Tanya Komunitas",
    href: "/komunitas/tanya",
    icon: MessagesSquare,
  },
  { label: "Lihat Kalender", href: "/kalender", icon: CalendarDays },
  { label: "Pelajari Komoditas", href: "/komoditas", icon: Sprout },
];

export default async function DashboardPage() {
  // Authoritative auth check — redirects to /login?next=/dashboard if
  // there's no valid session. proxy.ts also redirects optimistically, but
  // this is what actually guards the page.
  const { profile } = await requireProfile("/dashboard");

  return (
    <div className="mx-auto max-w-6xl px-4 py-12 sm:px-6">
      <h1 className="text-2xl font-semibold text-foreground sm:text-3xl">
        Selamat datang kembali, {profile.display_name}
      </h1>
      <p className="mt-2 text-sm text-muted-foreground">
        @{profile.username}
      </p>

      <div className="mt-8 grid gap-4 sm:grid-cols-3">
        {quickActions.map((action) => (
          <Link
            key={action.href}
            href={action.href}
            className="flex flex-col gap-3 rounded-2xl border border-border bg-card p-6 transition-colors hover:bg-secondary/60"
          >
            <span className="flex size-10 items-center justify-center rounded-lg bg-secondary text-primary">
              <action.icon className="size-5" strokeWidth={2} />
            </span>
            <span className="font-medium text-foreground">
              {action.label}
            </span>
          </Link>
        ))}
      </div>

      <p className="mt-10 rounded-xl border border-dashed border-border bg-muted/40 px-4 py-3 text-sm text-muted-foreground">
        Diskusi terbaru, ringkasan kalender, dan aktivitas teman akan tampil
        di sini begitu Phase 6 (Komunitas), Phase 7 (Kalender), dan Phase 10
        (Friendship) selesai dibangun.
      </p>
    </div>
  );
}
