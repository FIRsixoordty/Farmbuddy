import type { Metadata } from "next";
import { Leaf } from "lucide-react";

import { PagePlaceholder } from "@/components/layout/page-placeholder";

export const metadata: Metadata = { title: "Detail Komoditas" };

export default async function KomoditasDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  await params;

  return (
    <PagePlaceholder
      icon={Leaf}
      title="Detail Komoditas"
      description="Overview, kalender tanam, kebutuhan, alat, tahapan budidaya, hama/penyakit, dan panen akan tampil di sini."
      phaseNote="Dibangun pada Phase 8 — Crop Modules"
    />
  );
}
