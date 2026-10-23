import { NextRequest, NextResponse } from "next/server";
import { cookies } from "next/headers";
import { db } from "@/lib/db";
import type { SessionUser } from "@/lib/auth";

export const dynamic = "force-dynamic";

export async function POST(req: NextRequest) {
  try {
    const { username, password } = await req.json();
    if (!username || !password) {
      return NextResponse.json({ error: "Username dan password wajib diisi" }, { status: 400 });
    }

    const user = await db.user.findUnique({
      where: { username: String(username).trim() },
    });

    if (!user || !user.active || user.password !== String(password)) {
      return NextResponse.json({ error: "Username atau password salah" }, { status: 401 });
    }

    await db.user.update({
      where: { id: user.id },
      data: { lastLogin: new Date() },
    });

    const sessionUser: SessionUser = {
      id: user.id,
      username: user.username,
      name: user.name,
      role: user.role as SessionUser["role"],
      email: user.email,
      phone: user.phone,
      avatar: user.avatar,
      active: user.active,
      lastLogin: new Date().toISOString(),
      createdAt: user.createdAt.toISOString(),
    };

    const cookieStore = await cookies();
    cookieStore.set("an-nahl-session", user.id, {
      httpOnly: true,
      sameSite: "lax",
      path: "/",
      maxAge: 60 * 60 * 24 * 7,
    });

    return NextResponse.json({ user: sessionUser });
  } catch (err) {
    console.error("[auth/login] error:", err);
    return NextResponse.json({ error: "Terjadi kesalahan server" }, { status: 500 });
  }
}
