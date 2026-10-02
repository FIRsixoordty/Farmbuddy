import type { Metadata } from "next";
import { Cog } from "lucide-react";

import { PagePlaceholder } from "@/components/layout/page-placeholder";

export const metadata: Metadata = { title: "Detail Alat" };

export default async function AlatMesinDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  await params;

  return (
    <PagePlaceholder
      icon={Cog}
      title="Detail Alat & Mesin"
      description="Fungsi, mekanisme kerja, dan modul terkait dari alat ini akan tampil di sini."
      phaseNote="Dibangun pada Phase 9 — Tools & Machinery"
    />
  );
}
