<!-- LOVABLE:BEGIN -->
> [!IMPORTANT]
> This project is connected to [Lovable](https://lovable.dev). Avoid rewriting
> published git history — force pushing, or rebasing/amending/squashing commits
> that are already pushed — as it rewrites history on Lovable's side and the
> user will likely lose their project history.
>
> Commits you push to the connected branch sync back to Lovable and show up in
> the editor, so keep the branch in a working state.
<!-- LOVABLE:END -->

- Keep all signed-in student experiences under the integration-managed `_authenticated` route; this centralizes session gating.
- Access student-owned records through authenticated server functions and RLS; this prevents client-side authorization bypass.
- Treat exchange requests as the single source of truth for status and progress; this keeps request and completion flows consistent.
