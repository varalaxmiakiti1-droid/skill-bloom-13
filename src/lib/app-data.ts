import { queryOptions } from "@tanstack/react-query";
import { getAppData } from "./app-data.functions";
export const appDataQuery = () => queryOptions({ queryKey: ["student-exchange"], queryFn: () => getAppData(), staleTime: 10_000 });
export type AppData = Awaited<ReturnType<typeof getAppData>>;
export type Profile = AppData["profiles"][number];
export type Skill = AppData["skills"][number];
export type Exchange = AppData["requests"][number];
