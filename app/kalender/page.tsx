import type { Metadata } from "next";
import { CalendarDays } from "lucide-react";

import { PagePlaceholder } from "@/components/layout/page-placeholder";

export const metadata: Metadata = { title: "Kalender Tanam" };

export default function KalenderPage() {
  return (
    <PagePlaceholder
      icon={CalendarDays}
      title="Kalender Tanam"
      description="Matriks kalender tanam dan panen untuk tiap komoditas, lengkap dengan tooltip, akan hadir di sini."
      phaseNote="Dibangun pada Phase 7 — Crop Calendar"
    />
  );
}
