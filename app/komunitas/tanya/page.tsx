import type { Metadata } from "next";
import { HelpCircle } from "lucide-react";

import { PagePlaceholder } from "@/components/layout/page-placeholder";

export const metadata: Metadata = { title: "Tanya Komunitas" };

export default function TanyaKomunitasPage() {
  return (
    <PagePlaceholder
      icon={HelpCircle}
      title="Buat Pertanyaan Baru"
      description="Formulir membuat posting baru (judul, deskripsi, foto, kategori) akan hadir di sini."
      phaseNote="Dibangun pada Phase 6 — Komunitas"
    />
  );
}
