import type { NavLink } from "@/types/nav";

/**
 * Primary site navigation, shared between the desktop navbar and the
 * mobile drawer so the two never drift out of sync.
 */
export const primaryNavLinks: NavLink[] = [
  { label: "Beranda", href: "/" },
  { label: "Komunitas", href: "/komunitas" },
  { label: "Kalender Tanam", href: "/kalender" },
  { label: "Komoditas", href: "/komoditas" },
  { label: "Alat & Mesin", href: "/alat-mesin" },
];
