import { useEffect, useState } from "react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { supabase } from "@/integrations/supabase/client";
import { cn } from "@/lib/utils";
export function ProfileAvatar({ path, name, className }: { path?: string | null; name: string; className?: string }) {
  const [src, setSrc] = useState<string>();
  useEffect(() => { if (!path) { setSrc(undefined); return; } let active = true; void supabase.storage.from("profile-avatars").createSignedUrl(path, 3600).then(({ data }) => { if (active) setSrc(data?.signedUrl); }); return () => { active = false; }; }, [path]);
  const initials = name.split(" ").filter(Boolean).slice(0, 2).map((part) => part[0]).join("").toUpperCase() || "ST";
  return <Avatar className={cn("h-12 w-12 border-2 border-background shadow-sm", className)}><AvatarImage src={src} alt={name} /><AvatarFallback className="bg-primary-soft font-semibold text-primary">{initials}</AvatarFallback></Avatar>;
}
