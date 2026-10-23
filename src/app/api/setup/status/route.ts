import { NextRequest, NextResponse } from "next/server";
import { db } from "@/lib/db";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    const config = await db.supabaseConfig.findUnique({ where: { id: "singleton" } });
    const userCount = await db.user.count();
    return NextResponse.json({
      data: {
        supabase: {
          url: config?.url || "",
          publishableKey: config?.publishableKey || "",
          serviceRoleKey: config?.serviceRoleKey || "",
          hasPublishableKey: !!config?.publishableKey,
          hasServiceRoleKey: !!config?.serviceRoleKey,
          configured: !!config?.configured,
          configuredAt: config?.configuredAt?.toISOString() || null,
          initialized: !!config?.initialized,
          initializedAt: config?.initializedAt?.toISOString() || null,
        },
        database: {
          hasUsers: userCount > 0,
          userCount,
          error: null,
        },
        needsSetup: userCount === 0,
        needsSupabaseSetup: false,
      },
    });
  } catch (err) {
    console.error("[setup/status] error:", err);
    return NextResponse.json({ error: "Gagal memuat status" }, { status: 500 });
  }
}
