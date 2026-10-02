"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, Search, User as UserIcon } from "lucide-react";

import { LogoutButton } from "@/components/auth/logout-button";
import { Logo } from "@/components/layout/logo";
import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetClose,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { primaryNavLinks } from "@/lib/nav-links";
import { cn } from "@/lib/utils";
import type { Profile } from "@/types/profile";

function NavbarClient({ profile }: { profile: Profile | null }) {
  const pathname = usePathname();

  const isActive = (href: string) =>
    href === "/" ? pathname === "/" : pathname.startsWith(href);

  return (
    <header className="sticky top-0 z-40 border-b border-border/80 bg-background/90 backdrop-blur supports-[backdrop-filter]:bg-background/75">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between gap-4 px-4 sm:px-6">
        <Logo />

        <nav className="hidden items-center gap-1 md:flex">
          {primaryNavLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className={cn(
                "rounded-md px-3 py-2 text-sm font-medium text-foreground/70 transition-colors hover:bg-secondary hover:text-secondary-foreground",
                isActive(link.href) && "bg-secondary text-secondary-foreground",
              )}
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="icon"
            className="hidden sm:inline-flex"
            aria-label="Cari di Farm Buddy"
          >
            <Search />
          </Button>

          {profile ? (
            <div className="hidden items-center gap-2 sm:flex">
              <Link
                href={`/profil/${profile.username}`}
                className="flex items-center gap-2 rounded-md px-2 py-1.5 text-sm font-medium text-foreground/80 hover:bg-secondary hover:text-secondary-foreground"
              >
                <span className="flex size-7 items-center justify-center rounded-full bg-secondary text-primary">
                  <UserIcon className="size-4" strokeWidth={2} />
                </span>
                {profile.display_name}
              </Link>
              <LogoutButton className="w-auto" />
            </div>
          ) : (
            <div className="hidden items-center gap-2 sm:flex">
              <Button variant="outline" size="sm" asChild>
                <Link href="/login">Masuk</Link>
              </Button>
              <Button variant="default" size="sm" asChild>
                <Link href="/register">Daftar</Link>
              </Button>
            </div>
          )}

          <Sheet>
            <SheetTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="md:hidden"
                aria-label="Buka menu navigasi"
              >
                <Menu />
              </Button>
            </SheetTrigger>

            <SheetContent side="right" className="w-4/5 sm:max-w-xs">
              <SheetHeader>
                <SheetTitle>
                  <Logo />
                </SheetTitle>
              </SheetHeader>

              <nav className="flex flex-col gap-1 px-4">
                {primaryNavLinks.map((link) => (
                  <SheetClose asChild key={link.href}>
                    <Link
                      href={link.href}
                      className={cn(
                        "rounded-md px-3 py-2.5 text-sm font-medium text-foreground/80 transition-colors hover:bg-secondary hover:text-secondary-foreground",
                        isActive(link.href) &&
                          "bg-secondary text-secondary-foreground",
                      )}
                    >
                      {link.label}
                    </Link>
                  </SheetClose>
                ))}
              </nav>

              <div className="mt-auto flex flex-col gap-2 border-t border-border p-4">
                {profile ? (
                  <>
                    <SheetClose asChild>
                      <Link
                        href={`/profil/${profile.username}`}
                        className="flex items-center gap-2 rounded-md px-2 py-2 text-sm font-medium text-foreground/80 hover:bg-secondary"
                      >
                        <span className="flex size-7 items-center justify-center rounded-full bg-secondary text-primary">
                          <UserIcon className="size-4" strokeWidth={2} />
                        </span>
                        {profile.display_name}
                      </Link>
                    </SheetClose>
                    <LogoutButton />
                  </>
                ) : (
                  <>
                    <SheetClose asChild>
                      <Button variant="outline" asChild>
                        <Link href="/login">Masuk</Link>
                      </Button>
                    </SheetClose>
                    <SheetClose asChild>
                      <Button variant="default" asChild>
                        <Link href="/register">Daftar</Link>
                      </Button>
                    </SheetClose>
                  </>
                )}
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </header>
  );
}

export { NavbarClient };
