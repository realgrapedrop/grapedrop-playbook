# Security Posture

A six-rule security baseline Claude Code reads at session start and applies to every commit, refactor, and new feature. This is the operational copy.

## The framework

Every app has two planes. Control plane is the brain (identity, policy, configuration, secrets). Data plane is the muscle (every request, every byte flowing through). Three rules per plane.

| Rule | Plane | In one line |
|---|---|---|
| 1. Secrets stay secret | Control | Credentials never live in code or repos |
| 2. Never trust input | Data | Validate everything before using it |
| 3. Auth from day one | Control | Every route declares who can use it |
| 4. HTTPS everywhere | Data | Plain text on the wire is a leak |
| 5. Dependencies are someone else's code | Control | Audit before installing, block known vulnerabilities |
| 6. Don't store what you don't need | Data | Less data means less liability |

## Rule 1. Secrets stay secret (Control)

**Apply.** Always read secrets from environment variables. If a new secret is needed, stop and ask the user, add the variable to `.env.example` with a placeholder, never invent a value. Confirm `.env` is gitignored. Run the project's secret scanner before commit; if it blocks, fix the source, never bypass.

**Forbidden.** Hardcoded credentials, even temporarily for testing. Logging environment variables that contain credentials. Credentials in commit messages, comments, or PR descriptions.

**Scanners.** `gitleaks` (free, popular, scans past commits). `detect-secrets` (best for adding scanning to an older project, supports a baseline file).

## Rule 2. Never trust input (Data)

**Apply.** Validate every external input (HTTP requests, form data, file uploads, URL parameters, webhooks, message queues) at the entry point using a schema library (`zod`, `pydantic`, `joi`, or whatever the project uses). Reject malformed input with a 400 before any processing. Only pass validated, typed values into business logic, queries, files, or shells. Add a test that sends invalid input and asserts rejection.

**Forbidden.** Raw input passed into database queries (use parameterized queries). Raw input passed into shell commands (use argument arrays). String concatenation to build queries or commands. Relying only on client-side validation.

**Why the test matters.** A validation check without a test is one the AI might quietly remove during a future edit. With a test in place, removing the check breaks the build.

## Rule 3. Auth from day one (Control)

**Apply.** When creating a new route, page, API endpoint, or background job, declare the access requirement at the top of the file (`public`, `authenticated`, or a specific role). Run the access check through middleware before any handler logic. Routes opt OUT of auth via an explicit public-routes allowlist, not by forgetting. Hash passwords with `bcrypt`, `argon2`, or `scrypt` at current recommended cost factors.

**Forbidden.** Routes without an explicit access declaration. Security by obscurity (unguessable URLs as the only protection). Plaintext, MD5, SHA-1, or unsalted password hashes. Hardcoded admin credentials or auth bypasses for testing.

If access requirements are unclear, default to `authenticated` and ask the user.

## Rule 4. HTTPS everywhere (Data)

**Apply.** Use `https://` for all URLs going to the public internet. Use `http://` only for `localhost` or `127.0.0.1` in local development. Validate TLS certificates with library defaults. For local HTTPS, use a proper CA tool (`mkcert`), not disabled verification.

**Forbidden.** `http://` for any non-localhost URL. `rejectUnauthorized: false`, `verify=False`, `--insecure`, `--no-check-certificate`. Catching and swallowing TLS errors.

If a TLS error appears, surface it to the user. Do not silence it.

## Rule 5. Dependencies are someone else's code (Control, supply chain)

**Apply.** Before installing, run the language's audit (`npm audit`, `pip-audit`, `cargo audit`, etc.). Confirm the package has recent maintenance, real maintainers, and no current advisories. Pin versions in lockfiles. Commit lockfiles. For updates, read release notes for security-relevant changes.

**Forbidden.** Installing a package without verification. Lowering audit thresholds to silence warnings. Adding a dependency for what the standard library handles. Deleting or regenerating a lockfile to resolve conflicts.

If a package's signals look weak, ask the user before installing and suggest alternatives.

## Rule 6. Don't store what you don't need (Data)

**Apply.** When designing a schema, form, API request, or log statement that captures user data, name the specific feature that needs each personal field and the retention period (in a code comment). If no current feature needs the field, propose dropping it. For logs, use structured logging with named fields and log only what is needed to debug. For analytics, prefer aggregated counts over individual records.

**Forbidden.** Future-proofing fields with personal data and no current use case. Logging full request bodies, response bodies, auth headers, cookies, or session tokens. Indefinite retention without a documented policy. Collecting third-party API data the app does not need.

If the use case or retention is unclear, ask the user. Default to less.

## Inheritance

Every persona under `.project/<ROLE>-PERSONA.md` inherits these six rules. No persona overrides them. A violation is a blocker, not a nice-to-have.
