import { headers } from "next/headers";

/**
 * Resolve the site's own public URL, used to build links inside emails
 * (password reset, etc). Prefers NEXT_PUBLIC_SITE_URL (reliable behind
 * proxies/CDNs in production); falls back to the incoming request's host
 * header so local dev and preview deployments work without extra config.
 */
export async function getSiteUrl() {
  const envUrl = process.env.NEXT_PUBLIC_SITE_URL;
  if (envUrl) {
    return envUrl.replace(/\/$/, "");
  }

  const headerList = await headers();
  const host = headerList.get("x-forwarded-host") ?? headerList.get("host");
  const protocol = headerList.get("x-forwarded-proto") ?? "http";

  return `${protocol}://${host}`;
}
