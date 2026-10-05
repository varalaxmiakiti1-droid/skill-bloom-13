import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
export function StatusBadge({ status }: { status: string }) {
  return <Badge variant="outline" className={cn("capitalize", status === "accepted" && "border-success/30 bg-success-soft text-success", status === "pending" && "border-warning/30 bg-warning-soft text-warning", status === "rejected" && "border-destructive/30 bg-destructive/10 text-destructive", status === "completed" && "border-info/30 bg-info-soft text-info")}>{status}</Badge>;
}
