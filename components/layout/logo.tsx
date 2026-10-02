import Link from "next/link";
import { Sprout } from "lucide-react";

import { cn } from "@/lib/utils";

function Logo({ className }: { className?: string }) {
  return (
    <Link
      href="/"
      className={cn(
        "flex items-center gap-2 font-display text-lg font-semibold tracking-tight text-primary",
        className,
      )}
    >
      <span className="flex size-8 items-center justify-center rounded-lg bg-primary text-primary-foreground">
        <Sprout className="size-4.5" strokeWidth={2.25} />
      </span>
      Farm Buddy
    </Link>
  );
}

export { Logo };
