import type { Metadata } from "next";
import { MessagesSquare } from "lucide-react";

import { PagePlaceholder } from "@/components/layout/page-placeholder";

export const metadata: Metadata = { title: "Komunitas" };

export default function KomunitasPage() {
  return (
    <PagePlaceholder
      icon={MessagesSquare}
      title="Komunitas"
      description="Daftar diskusi Q&A dari sesama pegiat pertanian akan tampil di sini."
      phaseNote="Dibangun pada Phase 6 — Komunitas"
    />
  );
}
