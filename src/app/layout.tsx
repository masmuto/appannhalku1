import type { Metadata } from "next";
import "./globals.css";
import { Toaster } from "@/components/ui/sonner";

export const metadata: Metadata = {
  title: "GO An Nahl — Rumah Tahfidz",
  description:
    "Sistem Manajemen Santri & SPP Rumah Tahfidz An Nahl. Platform terpadu untuk pengelolaan data santri, pembayaran SPP, jadwal pembelajaran, dan laporan keuangan.",
  keywords: [
    "An Nahl",
    "Rumah Tahfidz",
    "Santri",
    "SPP",
    "Pesantren",
    "Manajemen",
  ],
  icons: {
    icon: "https://z-cdn.chatglm.cn/z-ai/static/logo.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="id" suppressHydrationWarning>
      <body className="font-sans antialiased min-h-screen bg-background text-foreground">
        {children}
        <Toaster richColors position="top-right" />
      </body>
    </html>
  );
}
