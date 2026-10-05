# Student Skill Exchange Platform

## Goal
Build the approved platform in this blank project as a polished, responsive college product. Since no prior student features or records exist here, the implementation will establish the complete working baseline without mock-only workflows.

## What will be built
- Add email/password and Google sign-in, onboarding, sign-out, and protected student pages.
- Add a responsive shared app shell with desktop navigation, mobile navigation, notifications, and account controls.
- Build a dashboard with totals for skills, teaching, learning, pending requests, accepted exchanges, and completed exchanges.
- Build editable student profiles with avatar, name, college, department, year, bio, teaching skills, learning skills, and completion percentage.
- Build skill discovery with instant search, category and teaching/learning filters, student cards, profile details, and useful empty states.
- Build request workflows for send, pending, accept, reject, accepted, and completed states, with status badges and disabled duplicate actions.
- Build accepted-exchange progress controls with Start, In Progress, and Completed states, a percentage control, progress bar, and completion celebration.
- Build a lightweight notification center for new requests, accepted/rejected requests, and completed exchanges, including unread count and mark-as-read.

## Data and safety
- Enable persistent storage through Lovable Cloud and add new tables for profiles, skills, profile skills, exchange requests, and notifications.
- Add a profile-avatar storage area with file-size/type safeguards and owner-only upload/update permissions.
- Apply row-level permissions so students control their own profile and actions while public profile/teaching data remains discoverable to signed-in students.
- Add database validation for valid request transitions and progress values.
- Prevent duplicate pending or accepted requests for the same student pair and skill with a database-level rule, backed by disabled UI actions.
- Generate notifications from trusted database events so the client cannot impersonate another student.
- Seed no fake student records; real records will be created through registration and onboarding.

## Pages
- `/` — concise product entry and sign-in call to action.
- `/auth` — sign in and registration.
- `/dashboard` — overview and recent activity.
- `/discover` — search and filter students by skills.
- `/profile` — edit the signed-in student's full profile and skills.
- `/students/$studentId` — view another student's public skill profile and request an exchange.
- `/requests` — incoming and outgoing requests with accept/reject actions.
- `/exchanges` — accepted and completed exchanges with progress updates.
- `/notifications` — notification history and read state.

## Visual direction
- Friendly collegiate visual identity using an editorial sans-serif, green primary actions, warm neutral surfaces, and amber/blue status accents.
- Clear hierarchy, compact statistic cards, clean profile and discovery cards, restrained shadows, rounded corners, and subtle motion.
- Responsive layouts for mobile, tablet, laptop, and desktop with accessible controls and readable lists.

## Technical details
- Use TanStack Start routes, React Query for server-state synchronization, and the generated Lovable Cloud client.
- Use protected server functions for user-owned reads and writes, with Zod validation on every mutation.
- Keep public metadata on every content route and use the existing UI component library for controls.
- Keep route files focused; share domain types, query keys, app shell, cards, badges, and form elements across pages.
- Record the new architecture decisions in `AGENTS.md` and keep a concise `roadmap.md` until all requested work is verified.

## Verification
- Run focused automated tests for duplicate prevention, request transitions, progress completion, validation, and route rendering.
- Verify sign-up/sign-in, onboarding, profile updates, skill creation, discovery/search/filtering, request send/accept/reject, progress updates, notifications, and navigation end to end with authenticated sessions.
- Check desktop and mobile layouts, browser console/network errors, database permissions, and the current production build signal.
- Leave the project ready to publish, but do not publish unless explicitly requested.
