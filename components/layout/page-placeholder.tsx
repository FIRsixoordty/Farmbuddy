import type { LucideIcon } from "lucide-react";
import { Construction } from "lucide-react";

function PagePlaceholder({
  icon: Icon = Construction,
  title,
  description,
  phaseNote,
}: {
  icon?: LucideIcon;
  title: string;
  description: string;
  phaseNote: string;
}) {
  return (
    <div className="mx-auto flex max-w-6xl flex-col items-center gap-4 px-4 py-24 text-center sm:px-6">
      <span className="flex size-14 items-center justify-center rounded-2xl bg-secondary text-primary">
        <Icon className="size-6" strokeWidth={2} />
      </span>
      <h1 className="text-2xl font-semibold text-foreground sm:text-3xl">
        {title}
      </h1>
      <p className="max-w-md text-sm text-muted-foreground sm:text-base">
        {description}
      </p>
      <span className="rounded-full border border-border bg-card px-3 py-1 text-xs font-medium text-muted-foreground">
        {phaseNote}
      </span>
    </div>
  );
}

export { PagePlaceholder };
