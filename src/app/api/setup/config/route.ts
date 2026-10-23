import { NextRequest, NextResponse } from "next/server";
import { db } from "@/lib/db";

export const dynamic = "force-dynamic";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { url, publishableKey, serviceRoleKey, initialize } = body;
    if (!url || !publishableKey) {
      return NextResponse.json({ error: "URL dan Publishable Key wajib diisi" }, { status: 400 });
    }

    const now = new Date();
    const config = await db.supabaseConfig.upsert({
      where: { id: "singleton" },
      update: {
        url,
        publishableKey,
        serviceRoleKey: serviceRoleKey || null,
        configured: true,
        configuredAt: now,
        initialized: initialize ? true : false,
        initializedAt: initialize ? now : null,
      },
      create: {
        id: "singleton",
        url,
        publishableKey,
        serviceRoleKey: serviceRoleKey || null,
        configured: true,
        configuredAt: now,
        initialized: !!initialize,
        initializedAt: initialize ? now : null,
      },
    });

    return NextResponse.json({
      data: {
        configured: config.configured,
        initialized: config.initialized,
        configuredAt: config.configuredAt?.toISOString(),
        initializedAt: config.initializedAt?.toISOString(),
      },
    });
  } catch (err) {
    console.error("[setup/config] error:", err);
    return NextResponse.json({ error: "Gagal menyimpan konfigurasi" }, { status: 500 });
  }
}

export async function GET() {
  try {
    const config = await db.supabaseConfig.findUnique({ where: { id: "singleton" } });
    return NextResponse.json({
      data: {
        url: config?.url || "",
        publishableKey: config?.publishableKey ? "***" : "",
        serviceRoleKey: config?.serviceRoleKey ? "***" : "",
        hasPublishableKey: !!config?.publishableKey,
        hasServiceRoleKey: !!config?.serviceRoleKey,
        configured: !!config?.configured,
        initialized: !!config?.initialized,
      },
    });
  } catch {
    return NextResponse.json({ data: null });
  }
}
