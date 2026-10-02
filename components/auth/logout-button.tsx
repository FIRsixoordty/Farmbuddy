import { LogOut } from "lucide-react";

import { logoutAction } from "@/lib/actions/auth";
import { Button } from "@/components/ui/button";

function LogoutButton({ className }: { className?: string }) {
  return (
    <form action={logoutAction} className={className}>
      <Button type="submit" variant="outline" size="sm" className="w-full">
        <LogOut />
        Keluar
      </Button>
    </form>
  );
}

export { LogoutButton };
