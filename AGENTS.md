# Repository Guidelines

## Project Structure & Module Organization
- `lib/homepage` holds application logic: long-running clients in `clients/`, sortable list domain in `sortable_list/`, and supporting contexts under `store.ex`. Phoenix web layers live in `lib/homepage_web`, split into controllers, LiveView modules, and components. 
- `priv/repo` contains migrations and seeds; `priv/static` serves compiled assets. Shared translations are under `priv/gettext`. 
- Frontend assets reside in `assets` (Tailwind, esbuild entrypoints), while runtime releases are prepared via `rel/overlays`.

## Build, Test, and Development Commands
- `mix deps.get` installs Elixir dependencies; run after dependency updates.
- `mix ecto.setup` provisions the database from `priv/repo/migrations` and seeds default data.
- `mix phx.server` starts the development server at http://localhost:4000 with Tailwind and esbuild watchers.
- `mix test` executes the ExUnit suite; combine with `mix test --trace` when debugging.
- `mix assets.deploy` compiles and digests assets for release; fly.io deployments rely on its output.

## Coding Style & Naming Conventions
- Follow `mix format` (configured via `.formatter.exs`) before commits; default width 98 and 2-space indentation align with existing modules.
- Use descriptive, snake_case filenames for modules inside `lib/homepage`, with matching `CamelCase` module names (e.g., `lib/homepage/clients/nhl.ex` → `Homepage.Clients.NHL`).
- Prefer pipeline-friendly, pure functions; isolate side-effects in GenServers or clients under `Homepage.Clients`.
- SCSS/Tailwind utilities live in `assets/css`. Name LiveView assigns with `:snake_case` atoms for template clarity.

## Testing Guidelines
- Tests live under `test/homepage` for domain logic and `test/homepage_web` for controllers and LiveViews; shared helpers are in `test/support`.
- Name test files with `_test.exs` and describe cases with `"module context"` strings. Use `setup` callbacks from the existing fixtures in `test/support/fixtures`.
- Target critical paths (data polling, list sorting) and ensure new features include synchronous and async coverage.

## Commit & Pull Request Guidelines
- Match the existing imperative style (`Add healthcheck`, `Update dockerfile with new versions`): short subject (≤72 chars), present-tense verb, optional body for context.
- Reference related issues in the PR description, outline user impact, and include screenshots or terminal output when UI or ops workflows change.
- Confirm `mix test`, `mix format`, and `mix assets.deploy` succeed before requesting review; note any skipped steps with rationale.
