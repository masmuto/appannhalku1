import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { db } from "@/lib/db";

let cachedClient: { url: string; key: string; client: SupabaseClient } | null = null;

export async function getSupabaseClient(): Promise<SupabaseClient | null> {
  const config = await db.supabaseConfig.findUnique({ where: { id: "singleton" } });
  if (!config || !config.url || !config.publishableKey) return null;

  // Reuse cached client if url+key unchanged
  if (cachedClient && cachedClient.url === config.url && cachedClient.key === config.publishableKey) {
    return cachedClient.client;
  }

  const client = createClient(config.url, config.publishableKey, {
    auth: { persistSession: false },
  });
  cachedClient = { url: config.url, key: config.publishableKey, client };
  return client;
}

export interface SupabaseConfigSnapshot {
  url: string;
  publishableKey: string;
  hasServiceRoleKey: boolean;
  configured: boolean;
  initialized: boolean;
}

export async function getSupabaseConfigSnapshot(): Promise<SupabaseConfigSnapshot | null> {
  const config = await db.supabaseConfig.findUnique({ where: { id: "singleton" } });
  if (!config) return null;
  return {
    url: config.url,
    publishableKey: config.publishableKey,
    hasServiceRoleKey: !!config.serviceRoleKey,
    configured: config.configured,
    initialized: config.initialized,
  };
}
