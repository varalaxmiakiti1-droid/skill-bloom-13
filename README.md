# Skill Connect

Upgrade my existing Student Skill Exchange Platform.

IMPORTANT: This is an EXISTING WORKING PROJECT. Do NOT rebuild it from scratch. Do NOT remove, rename, or break any existing features, pages, components, database tables, or working functionality.

First inspect the current project and understand how the existing student profiles, skill exchange, requests, accept/reject flow, and other features are implemented. Then make the improvements below while preserving everything that already works.

MAIN GOAL

Make the Student Skill Exchange Platform look and feel like a polished, real-world college application while keeping it simple and easy to use.

1. STUDENT PROFILE IMPROVEMENT

Improve the existing student profile with:

Profile photo/avatar

Student name

College

Department/branch

Year

Skills they can teach

Skills they want to learn

Short bio

Progress/completion percentage

Add a clean profile card.

Do NOT remove any existing profile fields.

2. SKILL DISCOVERY

Improve the existing skill browsing/search functionality.

Students should be able to:

Search for a skill

Filter by category

See students who can teach that skill

See what each student wants to learn

View the student's profile

Suggested skill categories:

Programming

Web Development

AI & ML

Data Science

Design

Communication

Languages

Academics

Other

Keep the existing functionality working.

3. SKILL EXCHANGE REQUESTS

Improve the existing request system.

A student should be able to:

Send Request → Pending → Accept / Reject → Accepted

Show clear status badges:

Pending

Accepted

Rejected

Completed

Do NOT create duplicate requests between the same students for the same skill.

If a request is already pending or accepted, disable the request button and show the current status.

4. PROGRESS FEATURE

Add a simple progress system for accepted skill exchanges.

After a request is accepted, create a progress section.

Show:

Skill Exchange Progress

Example:

Learning: Python
Teaching: HTML
Progress: 60%

Add:

Start

In Progress

Completed

Allow the student to update progress.

Use a visual progress bar.

When progress reaches 100%, show:

Exchange Completed 🎉

Do not interfere with the existing request/accept system.

5. DASHBOARD

Improve the existing dashboard.

Show small statistics:

Total Skills

Skills Teaching

Skills Learning

Pending Requests

Accepted Exchanges

Completed Exchanges

Use clean cards with icons.

Keep the dashboard simple and responsive.

6. NOTIFICATIONS

Add a simple notification area for important actions:

New skill exchange request

Request accepted

Request rejected

Exchange completed

Show unread notification count.

Do not create unnecessary notification complexity.

7. SEARCH AND FILTER UI

Make the skill search experience clean.

Add:

Search bar:

"Search skills..."

Category filter:

"All Categories"

Optional filter:

"Teaching / Learning"

Results should update without refreshing the entire page.

8. UI/UX IMPROVEMENT

Keep the existing branding and overall functionality, but improve the visual design.

Use:

Modern student-friendly design

Clean cards

Rounded corners

Soft shadows

Consistent spacing

Professional typography

Clear buttons

Responsive mobile layout

Desktop-friendly dashboard

Smooth but subtle animations

Avoid excessive gradients and unnecessary animations.

Make it look like a genuine college startup/product rather than a basic demo website.

9. EMPTY STATES

Add useful empty states.

Examples:

No skills found:

"No students found for this skill."

No requests:

"You don't have any exchange requests yet."

No completed exchanges:

"Complete your first skill exchange to see it here."

10. DATA SAFETY

IMPORTANT:

Do not delete existing database data.

Do not reset existing users.

Do not change existing database structures unless absolutely necessary.

If a database change is required, make a safe migration that preserves existing records.

Do not expose API keys or sensitive configuration in frontend code.

11. RESPONSIVENESS

Make sure the entire application works properly on:

Desktop

Laptop

Tablet

Mobile

Check that:

Navigation works

Cards resize correctly

Buttons remain accessible

Forms do not overflow

Tables/lists remain readable

12. IMPORTANT — DO NOT BREAK EXISTING FEATURES

Before finishing:

Test the existing functionality.

Especially verify:

Student creation

Student profiles

Skill creation

Skill browsing

Search

Sending requests

Accepting requests

Rejecting requests

Existing progress functionality

Existing navigation

Existing database operations

Do not replace working functionality with mock data.

Do not create duplicate pages for existing features.

Reuse existing components wherever possible.

FINAL CHECK

After implementing the upgrade:

Fix all TypeScript/JavaScript errors.

Fix console errors.

Check all buttons and navigation.

Check database operations.

Check mobile responsiveness.

Make sure existing data is preserved.

Make sure the project builds successfully.

Make sure the production version works.

Then prepare the project for production publishing.

IMPORTANT: Do NOT publish a broken version. Only publish after the application builds successfully and the existing features continue working.

Finally, provide a short summary of:

What was upgraded

What existing features were preserved

Any database changes made

Whether the production build passed

Whether the project is ready to publish

This project was built with [Lovable](https://lovable.dev).

**Live app**: https://skill-bloom-13.lovable.app

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/c047b027-7ec9-5e11-9f2c-db843c716d49).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
