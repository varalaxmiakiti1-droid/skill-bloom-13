import { Link, useNavigate, useRouter } from "@tanstack/react-router";
import { useQueryClient, useSuspenseQuery } from "@tanstack/react-query";
import { Bell, BookOpen, Compass, Handshake, LayoutDashboard, LogOut, Menu, UserRound } from "lucide-react";
import { useState } from "react";
import { appDataQuery } from "@/lib/app-data";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { ProfileAvatar } from "./profile-avatar";
import { cn } from "@/lib/utils";

const nav = [
  { to: "/dashboard" as const, label: "Dashboard", icon: LayoutDashboard },
  { to: "/discover" as const, label: "Discover", icon: Compass },
  { to: "/requests" as const, label: "Requests", icon: Handshake },
  { to: "/exchanges" as const, label: "Exchanges", icon: BookOpen },
  { to: "/profile" as const, label: "Profile", icon: UserRound },
];
function NavLinks({ close }: { close?: () => void }) { return <nav className="space-y-1">{nav.map(({ to, label, icon: Icon }) => <Link key={to} to={to} onClick={close} activeProps={{ className: "bg-primary-soft text-primary" }} inactiveProps={{ className: "text-muted-foreground hover:bg-muted hover:text-foreground" }} className="flex h-11 items-center gap-3 rounded-md px-3 text-sm font-medium transition-colors"><Icon className="h-5 w-5" />{label}</Link>)}</nav>; }
export function AppShell({ children }: { children: React.ReactNode }) {
  const { data } = useSuspenseQuery(appDataQuery()); const me = data.profiles.find((p) => p.id === data.userId); const unread = data.notifications.filter((n) => !n.read_at).length;
  const [open, setOpen] = useState(false); const queryClient = useQueryClient(); const navigate = useNavigate(); const router = useRouter();
  const signOut = async () => { await queryClient.cancelQueries(); queryClient.clear(); await supabase.auth.signOut(); await navigate({ to: "/auth", replace: true }); void router.invalidate(); };
  return <div className="min-h-screen bg-background"><aside className="fixed inset-y-0 left-0 z-30 hidden w-64 border-r bg-sidebar p-5 lg:block"><Link to="/dashboard" className="mb-8 flex items-center gap-3"><span className="grid h-10 w-10 place-items-center rounded-md bg-primary text-lg font-bold text-primary-foreground">S</span><span><strong className="block text-base text-foreground">SkillSwap</strong><small className="text-muted-foreground">Campus community</small></span></Link><NavLinks /><div className="absolute bottom-5 left-5 right-5 flex items-center gap-3 border-t pt-5"><ProfileAvatar name={me?.full_name ?? "Student"} path={me?.avatar_path} /><div className="min-w-0 flex-1"><p className="truncate text-sm font-semibold">{me?.full_name || "Complete profile"}</p><p className="truncate text-xs text-muted-foreground">{me?.department || "Student"}</p></div><Button variant="ghost" size="icon" onClick={signOut} aria-label="Sign out" title="Sign out"><LogOut /></Button></div></aside><div className="lg:pl-64"><header className="sticky top-0 z-20 flex h-16 items-center justify-between border-b bg-background/95 px-4 backdrop-blur sm:px-6 lg:px-10"><Sheet open={open} onOpenChange={setOpen}><SheetTrigger asChild><Button variant="ghost" size="icon" className="lg:hidden" aria-label="Open navigation"><Menu /></Button></SheetTrigger><SheetContent side="left" className="w-72 p-5"><div className="mb-8 text-lg font-bold">SkillSwap</div><NavLinks close={() => setOpen(false)} /></SheetContent></Sheet><div className="hidden text-sm text-muted-foreground sm:block">Learn from peers. Share what you know.</div><div className="flex items-center gap-2"><Button variant="ghost" size="icon" asChild className="relative" title="Notifications"><Link to="/notifications"><Bell />{unread > 0 && <span className={cn("absolute right-1 top-1 grid min-w-4 place-items-center rounded-full bg-destructive px-1 text-[10px] font-bold text-destructive-foreground")}>{unread > 9 ? "9+" : unread}</span>}</Link></Button><ProfileAvatar name={me?.full_name ?? "Student"} path={me?.avatar_path} className="h-9 w-9" /></div></header><main className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-10 lg:py-10">{children}</main></div></div>;
}
