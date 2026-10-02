import type { Metadata } from "next";

import { Footer } from "@/components/layout/footer";
import { Navbar } from "@/components/layout/navbar";

import "@fontsource-variable/inter";
import "@fontsource-variable/plus-jakarta-sans";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "Farm Buddy — Teman Bertani, Dari Belajar Sampai Panen",
    template: "%s · Farm Buddy",
  },
  description:
    "Platform edukasi dan komunitas pertanian untuk belajar budidaya, kalender tanam, alat pertanian, dan berdiskusi bersama.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="id">
      <body className="flex min-h-screen flex-col">
        <Navbar />
        <main className="flex-1">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
