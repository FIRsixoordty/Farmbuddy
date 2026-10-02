import type { Metadata } from "next";
import { Sprout } from "lucide-react";

import { PagePlaceholder } from "@/components/layout/page-placeholder";

export const metadata: Metadata = { title: "Komoditas" };

export default function KomoditasPage() {
  return (
    <PagePlaceholder
      icon={Sprout}
      title="Komoditas"
      description="Daftar kartu komoditas pangan, hortikultura, dan perkebunan beserta pencarian akan tampil di sini."
      phaseNote="Dibangun pada Phase 8 — Crop Modules"
    />
  );
}
