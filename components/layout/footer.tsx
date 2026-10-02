import Link from "next/link";

import { Logo } from "@/components/layout/logo";
import { primaryNavLinks } from "@/lib/nav-links";

const learnLinks = [
  { label: "Kalender Tanam", href: "/kalender" },
  { label: "Komoditas", href: "/komoditas" },
  { label: "Alat & Mesin", href: "/alat-mesin" },
];

const accountLinks = [
  { label: "Masuk", href: "/login" },
  { label: "Daftar", href: "/register" },
  { label: "Lupa Kata Sandi", href: "/forgot-password" },
];

function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="border-t border-border bg-secondary/40">
      <div className="mx-auto grid max-w-6xl gap-10 px-4 py-12 sm:px-6 md:grid-cols-[1.3fr_1fr_1fr]">
        <div className="flex flex-col gap-3">
          <Logo />
          <p className="max-w-xs text-sm text-muted-foreground">
            Teman bertani, dari belajar sampai panen. Platform edukasi dan
            komunitas untuk siapa saja yang ingin belajar budidaya pertanian.
          </p>
        </div>

        <FooterColumn title="Jelajahi" links={primaryNavLinks} />
        <FooterColumn title="Belajar" links={learnLinks} />
      </div>

      <div className="mx-auto max-w-6xl px-4 pb-4 sm:px-6">
        <FooterColumn title="Akun" links={accountLinks} inline />
      </div>

      <div className="border-t border-border">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-2 px-4 py-6 text-xs text-muted-foreground sm:flex-row sm:px-6">
          <p>© {year} Farm Buddy. Materi edukasi bertujuan sebagai panduan umum.</p>
          <p>Dibangun untuk petani, calon petani, dan pegiat pertanian Indonesia.</p>
        </div>
      </div>
    </footer>
  );
}

function FooterColumn({
  title,
  links,
  inline = false,
}: {
  title: string;
  links: { label: string; href: string }[];
  inline?: boolean;
}) {
  return (
    <div className="flex flex-col gap-3">
      <h2 className="text-sm font-semibold text-foreground">{title}</h2>
      <ul
        className={
          inline
            ? "flex flex-wrap gap-x-6 gap-y-2"
            : "flex flex-col gap-2"
        }
      >
        {links.map((link) => (
          <li key={link.href}>
            <Link
              href={link.href}
              className="text-sm text-muted-foreground transition-colors hover:text-foreground"
            >
              {link.label}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}

export { Footer };
