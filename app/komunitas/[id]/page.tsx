import type { Metadata } from "next";
import { MessageCircle } from "lucide-react";

import { PagePlaceholder } from "@/components/layout/page-placeholder";

export const metadata: Metadata = { title: "Diskusi" };

export default async function KomunitasDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  await params;

  return (
    <PagePlaceholder
      icon={MessageCircle}
      title="Detail Diskusi"
      description="Isi posting lengkap dengan jawaban dari komunitas akan tampil di sini."
      phaseNote="Dibangun pada Phase 6 — Komunitas"
    />
  );
}
