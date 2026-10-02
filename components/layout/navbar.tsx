import { NavbarClient } from "@/components/layout/navbar-client";
import { getCurrentProfile } from "@/lib/supabase/profile";

async function Navbar() {
  const current = await getCurrentProfile();

  return <NavbarClient profile={current?.profile ?? null} />;
}

export { Navbar };
