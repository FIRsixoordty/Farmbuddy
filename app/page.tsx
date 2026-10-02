import Link from "next/link";
import { BookOpen, MessagesSquare, Share2, Sprout } from "lucide-react";

import { Button } from "@/components/ui/button";

const journeySteps = [
  {
    label: "Belajar",
    description: "Pelajari waktu tanam dan cara budidaya tiap komoditas.",
    icon: BookOpen,
  },
  {
    label: "Berdiskusi",
    description: "Tanyakan kendala di lapangan ke komunitas.",
    icon: MessagesSquare,
  },
  {
    label: "Berbagi",
    description: "Bagikan pengalaman dan foto hasil budidaya.",
    icon: Share2,
  },
  {
    label: "Bertumbuh",
    description: "Kembangkan pengetahuan dan hasil panen bersama.",
    icon: Sprout,
  },
];

export default function HomePage() {
  return (
    <div className="mx-auto max-w-6xl px-4 py-16 sm:px-6 sm:py-24">
      <section className="grid items-center gap-12 md:grid-cols-2 md:gap-16">
        <div className="flex flex-col gap-6">
          <h1 className="text-4xl font-semibold leading-tight text-foreground sm:text-5xl">
            Belajar Bertani Jadi Lebih Mudah.
          </h1>
          <p className="max-w-md text-base text-muted-foreground sm:text-lg">
            Temukan waktu tanam, pelajari cara budidaya, gunakan alat yang
            tepat, dan berdiskusi bersama sesama pegiat pertanian.
          </p>
          <div className="flex flex-wrap gap-3">
            <Button size="lg" asChild>
              <Link href="/komoditas">Mulai Belajar</Link>
            </Button>
            <Button size="lg" variant="outline" asChild>
              <Link href="/komunitas">Jelajahi Komunitas</Link>
            </Button>
          </div>
        </div>

        <div className="relative rounded-2xl border border-border bg-card p-8 shadow-sm">
          <p className="text-sm font-medium text-muted-foreground">
            Farm Buddy menemani setiap tahap
          </p>
          <div className="mt-6 flex flex-col gap-4">
            <div className="flex items-center gap-3 rounded-xl bg-secondary px-4 py-3">
              <span className="size-2.5 rounded-full bg-accent" />
              <span className="text-sm font-medium text-secondary-foreground">
                Musim tanam terdekat
              </span>
            </div>
            <div className="flex items-center gap-3 rounded-xl bg-muted px-4 py-3">
              <span className="size-2.5 rounded-full bg-harvest" />
              <span className="text-sm font-medium text-foreground/80">
                Perkiraan panen
              </span>
            </div>
            <p className="text-xs text-muted-foreground">
              Kalender tanam lengkap hadir di halaman{" "}
              <Link href="/kalender" className="underline underline-offset-2">
                Kalender Tanam
              </Link>
              .
            </p>
          </div>
        </div>
      </section>

      <section className="mt-24">
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {journeySteps.map((step, index) => (
            <div
              key={step.label}
              className="relative flex flex-col gap-3 rounded-2xl border border-border bg-card p-6"
            >
              <span className="flex size-10 items-center justify-center rounded-lg bg-secondary text-primary">
                <step.icon className="size-5" strokeWidth={2} />
              </span>
              <h2 className="text-lg font-semibold text-foreground">
                {index + 1}. {step.label}
              </h2>
              <p className="text-sm text-muted-foreground">
                {step.description}
              </p>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
