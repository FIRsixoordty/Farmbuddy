import type { Metadata } from "next";
import { Wrench } from "lucide-react";

import { PagePlaceholder } from "@/components/layout/page-placeholder";

export const metadata: Metadata = { title: "Alat & Mesin" };

export default function AlatMesinPage() {
  return (
    <PagePlaceholder
      icon={Wrench}
      title="Alat & Mesin Pertanian"
      description="Ensiklopedia alat dan mesin pertanian (alsintan) dari pra-panen hingga pasca-panen akan tampil di sini."
      phaseNote="Dibangun pada Phase 9 — Tools & Machinery"
    />
  );
}
