import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";

export const categories = ["Programming", "Web Development", "AI & ML", "Data Science", "Design", "Communication", "Languages", "Academics", "Other"] as const;
const categorySchema = z.enum(categories);
const skillSchema = z.object({ name: z.string().trim().min(1).max(80), category: categorySchema });

export const getAppData = createServerFn({ method: "GET" }).middleware([requireSupabaseAuth]).handler(async ({ context }) => {
  const db = context.supabase;
  const [profiles, skills, profileSkills, requests, notifications] = await Promise.all([
    db.from("profiles").select("*"),
    db.from("skills").select("*"),
    db.from("profile_skills").select("*"),
    db.from("exchange_requests").select("*"),
    db.from("notifications").select("*").order("created_at", { ascending: false }),
  ]);
  const error = profiles.error ?? skills.error ?? profileSkills.error ?? requests.error ?? notifications.error;
  if (error) throw new Error(error.message);
  return { userId: context.userId, profiles: profiles.data, skills: skills.data, profileSkills: profileSkills.data, requests: requests.data, notifications: notifications.data };
});

export const saveProfile = createServerFn({ method: "POST" }).middleware([requireSupabaseAuth]).inputValidator((input) => z.object({
  fullName: z.string().trim().min(2).max(100), college: z.string().trim().min(2).max(140), department: z.string().trim().min(2).max(100), studyYear: z.number().int().min(1).max(8), bio: z.string().trim().max(500), avatarPath: z.string().max(500).nullable(), teaching: z.array(skillSchema).max(20), learning: z.array(skillSchema).max(20),
}).parse(input)).handler(async ({ data, context }) => {
  const db = context.supabase;
  const { error: profileError } = await db.from("profiles").upsert({ id: context.userId, full_name: data.fullName, college: data.college, department: data.department, study_year: data.studyYear, bio: data.bio, avatar_path: data.avatarPath });
  if (profileError) throw new Error(profileError.message);
  const allSkills = [...data.teaching.map((skill) => ({ ...skill, direction: "teaching" as const })), ...data.learning.map((skill) => ({ ...skill, direction: "learning" as const }))];
  const { error: deleteError } = await db.from("profile_skills").delete().eq("profile_id", context.userId);
  if (deleteError) throw new Error(deleteError.message);
  for (const item of allSkills) {
    let { data: existing } = await db.from("skills").select("id").eq("normalized_name", item.name.toLowerCase().trim()).eq("category", item.category).maybeSingle();
    if (!existing) {
      const created = await db.from("skills").insert({ name: item.name.trim(), category: item.category, created_by: context.userId }).select("id").single();
      if (created.error) {
        const retry = await db.from("skills").select("id").eq("normalized_name", item.name.toLowerCase().trim()).eq("category", item.category).single();
        if (retry.error) throw new Error(retry.error.message);
        existing = retry.data;
      } else existing = created.data;
    }
    const link = await db.from("profile_skills").insert({ profile_id: context.userId, skill_id: existing.id, direction: item.direction });
    if (link.error) throw new Error(link.error.message);
  }
  return { ok: true };
});

export const sendExchangeRequest = createServerFn({ method: "POST" }).middleware([requireSupabaseAuth]).inputValidator((input) => z.object({ recipientId: z.string().uuid(), requestedSkillId: z.string().uuid(), offeredSkillId: z.string().uuid().nullable(), message: z.string().trim().max(500) }).parse(input)).handler(async ({ data, context }) => {
  if (data.recipientId === context.userId) throw new Error("You cannot request an exchange with yourself.");
  const { error } = await context.supabase.from("exchange_requests").insert({ requester_id: context.userId, recipient_id: data.recipientId, requested_skill_id: data.requestedSkillId, offered_skill_id: data.offeredSkillId, message: data.message });
  if (error?.code === "23505") throw new Error("An active request already exists for this student and skill.");
  if (error) throw new Error(error.message);
  return { ok: true };
});

export const updateExchange = createServerFn({ method: "POST" }).middleware([requireSupabaseAuth]).inputValidator((input) => z.object({ id: z.string().uuid(), action: z.enum(["accept", "reject", "progress"]), progress: z.number().int().min(0).max(100).optional() }).parse(input)).handler(async ({ data, context }) => {
  const patch = data.action === "accept" ? { status: "accepted" as const } : data.action === "reject" ? { status: "rejected" as const } : { progress: data.progress ?? 0 };
  const { error } = await context.supabase.from("exchange_requests").update(patch).eq("id", data.id);
  if (error) throw new Error(error.message);
  return { ok: true };
});

export const markNotificationsRead = createServerFn({ method: "POST" }).middleware([requireSupabaseAuth]).handler(async ({ context }) => {
  const { error } = await context.supabase.from("notifications").update({ read_at: new Date().toISOString() }).eq("user_id", context.userId).is("read_at", null);
  if (error) throw new Error(error.message);
  return { ok: true };
});
