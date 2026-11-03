// =====================================================================
// admin-manage-shops
// The only place that holds the service-role key. It lets a verified
// admin (row in public.admins) create a shop login or reset its password.
// Everything else (list / activate / suspend / extend) is done by the
// admin panel directly through RLS.
// =====================================================================
import { createClient } from "jsr:@supabase/supabase-js@2";

const LOGIN_EMAIL_DOMAIN = "dukany.app";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// Must stay identical to normalizeYemeniPhone() in both Flutter apps.
function normalizeYemeniPhone(raw: unknown): string | null {
  if (typeof raw !== "string") return null;
  let digits = raw
    .replace(/[٠-٩]/g, (d) => String(d.charCodeAt(0) - 0x0660))
    .replace(/\D/g, "");
  if (digits.startsWith("00")) digits = digits.substring(2);
  if (digits.startsWith("0")) digits = digits.substring(1);
  if (digits.length === 9 && digits.startsWith("7")) digits = `967${digits}`;
  return /^[0-9]{9,15}$/.test(digits) ? digits : null;
}

function cleanText(raw: unknown, min: number, max: number): string | null {
  if (typeof raw !== "string") return null;
  const value = raw.trim();
  return value.length >= min && value.length <= max ? value : null;
}

function cleanPassword(raw: unknown): string | null {
  return typeof raw === "string" && raw.length >= 6 && raw.length <= 72 ? raw : null;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse(405, { error: "method_not_allowed" });

  const serviceClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );

  // 1) Who is calling? Verify the JWT with Supabase Auth itself.
  const token = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  if (!token) return jsonResponse(401, { error: "unauthorized" });
  const { data: userData, error: userError } = await serviceClient.auth.getUser(token);
  if (userError || !userData?.user) {
    console.error("getUser failed:", userError?.message);
    return jsonResponse(401, { error: "unauthorized" });
  }

  // 2) Is the caller an admin?
  const { data: adminRow, error: adminError } = await serviceClient
    .from("admins")
    .select("user_id")
    .eq("user_id", userData.user.id)
    .maybeSingle();
  if (adminError) {
    // Not "you are not an admin": the server itself could not read the table.
    console.error("admins lookup failed:", adminError.message);
    return jsonResponse(500, { error: "admin_check_failed" });
  }
  if (!adminRow) return jsonResponse(403, { error: "forbidden" });

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return jsonResponse(400, { error: "invalid_body" });
  }

  switch (body.action) {
    case "create_shop":
      return await createShop(serviceClient, body);
    case "reset_password":
      return await resetPassword(serviceClient, body);
    default:
      return jsonResponse(400, { error: "unknown_action" });
  }
});

// deno-lint-ignore no-explicit-any
async function createShop(serviceClient: any, body: Record<string, unknown>) {
  const shopName = cleanText(body.shop_name, 2, 80);
  const ownerName = cleanText(body.owner_name, 2, 80);
  const phone = normalizeYemeniPhone(body.phone);
  const password = cleanPassword(body.password);
  const months = Number(body.months);
  if (!shopName || !ownerName || !phone || !password || !Number.isInteger(months) || months < 1 || months > 24) {
    return jsonResponse(400, { error: "invalid_input" });
  }

  const { data: existing } = await serviceClient.from("shops").select("id").eq("phone", phone).maybeSingle();
  if (existing) return jsonResponse(409, { error: "phone_taken" });

  const { data: created, error: createError } = await serviceClient.auth.admin.createUser({
    email: `${phone}@${LOGIN_EMAIL_DOMAIN}`,
    password,
    email_confirm: true,
    user_metadata: { shop_name: shopName, role: "shop_owner" },
  });
  if (createError || !created?.user) {
    console.error("createUser failed:", createError?.message);
    const alreadyExists = /already|exists|registered/i.test(createError?.message ?? "");
    return jsonResponse(alreadyExists ? 409 : 500, {
      error: alreadyExists ? "phone_taken" : "create_failed",
      detail: createError?.message ?? "no user returned",
    });
  }

  const subscriptionEndsAt = new Date();
  subscriptionEndsAt.setMonth(subscriptionEndsAt.getMonth() + months);

  const { data: shop, error: shopError } = await serviceClient
    .from("shops")
    .insert({
      owner_id: created.user.id,
      name: shopName,
      owner_name: ownerName,
      phone,
      is_active: true,
      subscription_ends_at: subscriptionEndsAt.toISOString(),
      notes: cleanText(body.notes, 1, 500),
    })
    .select()
    .single();

  if (shopError) {
    // Roll back the login so no orphan account stays behind.
    console.error("shop insert failed:", shopError.message);
    await serviceClient.auth.admin.deleteUser(created.user.id);
    return jsonResponse(500, { error: "shop_insert_failed", detail: shopError.message });
  }
  return jsonResponse(200, { shop });
}

// deno-lint-ignore no-explicit-any
async function resetPassword(serviceClient: any, body: Record<string, unknown>) {
  const shopId = typeof body.shop_id === "string" ? body.shop_id : null;
  const password = cleanPassword(body.password);
  if (!shopId || !password) return jsonResponse(400, { error: "invalid_input" });

  const { data: shop } = await serviceClient.from("shops").select("owner_id").eq("id", shopId).maybeSingle();
  if (!shop) return jsonResponse(404, { error: "shop_not_found" });

  const { error } = await serviceClient.auth.admin.updateUserById(shop.owner_id, { password });
  if (error) return jsonResponse(500, { error: "reset_failed" });
  return jsonResponse(200, { ok: true });
}
