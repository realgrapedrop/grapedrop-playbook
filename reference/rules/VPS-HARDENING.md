# VPS Setup and Hardening

A reusable pattern for standing up fresh VPS servers and handing them to an AI assistant
that hardens each one and leaves it ready to build on. It covers the front of the job only:
buy the machines, do the small amount of human prep, then let the AI harden each box. It
stops at a hardened, locked-down server with the Cloudflare Tunnel client installed and ready
to authorize. It does not cover the application build, the database setup, or creating and
routing the tunnel itself. Those belong in your project's architecture doc.

This is a template. Fill in the placeholders for your project: the number and size of
servers, the team roster, and the per-tier egress. Nothing here is tied to a specific app.

## The pattern

A common, low-cost shape is **two tiers behind an edge**: a web tier and an app tier, each
on its own VPS, both sitting behind a CDN/edge layer (Cloudflare in this template) that
provides DNS, caching, WAF, and DDoS protection. The origin is reached through the edge, not
directly, so the firewall stays default-deny inbound except SSH.

Adapt the tier count to your project. One box, two, or more. The hardening pass is identical
for every box; only the tier label and the per-tier egress differ.

- **Web / frontend tier.** Smaller box. Static or built sites, served through the edge cache,
  so the origin is reached rarely.
- **App / backend tier.** Larger box. The application services and, at small footprints, the
  database. The database binds to localhost and is never exposed to the network.

## Choosing the machines

Buy one server per tier. Map each box to exactly one tier and keep them labeled; the size and
the role go together.

| Tier | Plan / resources | What it will run | How to size |
|------|------------------|------------------|-------------|
| **Web / frontend** | `<plan>` (e.g. 2 vCPU, 8 GB RAM, NVMe disk) | Static built sites, behind the edge cache | Static files behind the edge cache mean the origin is reached rarely; match vCPU to the measured web peak. |
| **App / backend** | `<plan>` (e.g. 4 vCPU, 16 GB RAM, NVMe disk) | Application services plus the database | The database caches its working set in RAM, so RAM is usually the constraint, not CPU. Size RAM to the combined service peak plus the database working set. |

Size to your own measured peaks, not to round numbers. If you have a capacity appendix in
your architecture doc, use it.

The edge layer sits in front of every box as the CDN, DNS, WAF, and DDoS layer (Cloudflare's
free plan is enough), so there is no extra machine to buy. Both origins are reached through
the edge, never directly. The firewall steps below keep it that way.

## Step 1. Buy and provision each machine

Most VPS hosts split this into two parts per server: you **purchase** the plan at checkout,
then **set it up** in the host's control panel, where you pick the OS and location. Buy one
plan per tier under one account.

### Part A. Purchase the plans

1. Create or sign in to your VPS host account.
2. Add the **web tier** plan to the cart.
3. Add the **app tier** plan to the cart.
4. Pick the billing term and pay. Committed multi-year rates are cheaper but renew higher
   after the term, so plan for the renewal.

### Part B. Set up each server in the control panel

The OS, location, SSH key, and root password are chosen in the per-server setup wizard, not
at checkout. Do this for each box.

5. Open the host's dashboard, select the new server, and start its **Setup** wizard.
6. **Location.** Use the **same** data center for every box, so the tiers sit in one region
   and the hop between them stays local. Choose the region closest to most of your users.
7. **Operating system.** Choose a current LTS Linux (this template is written for **Ubuntu
   24.04 LTS**). Pick a plain OS template, not a pre-built app template.
8. **SSH key.** If the wizard offers to add an SSH key, paste your public key now (see Step 2)
   so the first login needs no password. If it does not, the AI installs it on first login
   using the root password.
9. **Root password.** Set a strong one and save it somewhere safe. It is temporary; the AI
   disables password login at the end.
10. **Name it** something recognizable, e.g. `<project>-web` and `<project>-app`.
11. **Wait for provisioning.** When it finishes, the panel shows the server's public **IP**,
    the **root** username, and the password.

Repeat for each server. Keep them labeled; the size and the tier go together.

## Step 2. Human prep before the AI takes over

You do only a few things by hand. The AI handles the rest. Each team member does the key step
once on their own machine, and the same key works on every server.

### Create your SSH key pair (on YOUR computer, not the server)

Every member runs this on their own machine. Each person keeps their own private key and sends
you only their public key line, which you collect into the roster.

An SSH key is two files: a **private key** that stays secret on your computer and is never
shared, and a **public key** that is safe to paste anywhere and is what goes on the server.

Open a terminal on your own machine.

- **Mac / Linux.** The built-in terminal.
- **Windows.** PowerShell or Windows Terminal (OpenSSH ships with Windows 10/11).

Run.

```
ssh-keygen -t ed25519 -C "your-email@example.com"
```

- Press Enter to accept the default location (`~/.ssh/id_ed25519`).
- Set a passphrase (recommended) or press Enter twice for none.

This creates two files.

- `~/.ssh/id_ed25519`, the private key. Never share it. Never paste it into chat.
- `~/.ssh/id_ed25519.pub`, the public key. This is what you give the AI.

Already have a key? Reuse your existing `~/.ssh/id_ed25519.pub`. The same key works for every
server.

### Copy your PUBLIC key text

Print it and copy the whole line. It starts with `ssh-ed25519` and ends with your email.

- **Mac / Linux.** `cat ~/.ssh/id_ed25519.pub`
- **Windows (PowerShell).** `Get-Content $HOME\.ssh\id_ed25519.pub`

It looks like.

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...long-string... your-email@example.com
```

### Gather what the AI needs, per server

Have these ready to paste. Most are the same for every box; only `VPS_IP` and `TIER` change.

| Placeholder  | What it is | Web box | App box |
|--------------|------------|---------|---------|
| `TIER`       | Which tier this box is | `web` | `app` |
| `VPS_IP`     | The server's public IP | the web IP | the app IP |
| `ROSTER`     | The team accounts: one username + public key + sudo level per person | same roster | same roster |
| `BOOTSTRAP_USER` | Your own username from the roster, verified first | same | same |

The `ROSTER` and `BOOTSTRAP_USER` come from the Team access section below. You also need each
server's temporary **root password** from Step 1 for its first login, unless you added the key
during checkout.

### Confirm you can reach each server

Once a box shows running, test it from your terminal.

```
ssh root@VPS_IP
```

Type "yes" to accept the fingerprint, then the root password. A shell prompt means you are in;
type `exit` and hand that box off to the AI. If it logs in with no password (because you added
the key at checkout), better still. Do this for every server.

## Team access, a separate key per person

Give each person their own login and their own SSH key, never a shared one. One account per
person, one public key per account. If someone leaves, you delete their account on every
server and they are locked out, with nobody else touched and no shared key to re-cut. It also
means the auth logs show who did what, which a single shared `deploy` login can never tell you.

A private key never leaves its owner's machine. You never see anyone else's private key and
you never should. Each member generates their own key pair using the steps in Step 2 and sends
you only the public key line. You collect those public keys into the roster and hand it to the
AI, which creates one account per person.

### The roster (template)

One row per person, one public key each. Scope sudo by role; not everyone needs full root.

| Role | Username | Sudo level | Why this level |
|------|----------|------------|----------------|
| Owner / lead | `<user>` | Break&nbsp;glass | Rarely needs a shell. Keep the account minimal and reach for it only when there is a real reason. |
| Bootstrap admin | `<user>` | Full | Owns the build, needs full control. Created and verified first as the bootstrap admin, the account tested before locking anything down. |
| Operator / admin | `<user>` | Full | Operates the servers day to day, needs full control. |
| Developer | `<user>` | Limited | Deploys and debugs the app. Does not need blanket root. Grant only the app and service scope, not the sudo group. |

**Trade-off.** A separate account and key per person beats one shared `deploy` login, because
individual accounts give clean per-person removal and a real audit trail, at the cost of more
accounts to create and keep in `AllowUsers`.

### What each person does

Each member, on their own machine, follows Step 2 to create a key pair and copy their public
key line. They send you that line and nothing else, never the private key, and never over a
channel you would not also trust with a password. You assemble the roster, then hand it to the
AI at handoff.

### Rotating someone out

When a member leaves, lock them out the same way on every server. You do not rotate their
private key, they hold it. You revoke access by deleting their account and key, and you rotate
any shared secret they could have copied.

1. Delete the account and its home directory: `sudo deluser --remove-home <username>`. That
   removes their `authorized_keys` with it, so their key no longer opens the box.
2. Remove their name from `AllowUsers` in `/etc/ssh/sshd_config`, then
   `sudo systemctl restart ssh`.
3. Rotate any shared secrets they had access to. Their own SSH key dies with the account, but
   anything shared they may have seen, database passwords, API tokens, tunnel credentials,
   should be rotated, since you cannot un-see those.
4. Confirm `ssh <username>@VPS_IP` is now rejected on every box.

## Step 3. Hand off to the AI, once per machine

Run the hardening prompt **once per server**, in a separate AI session each time. Harden every
box the same way. The only differences are the `TIER` label, the `VPS_IP`, and the per-tier
egress ports in Phase 6.

1. Start a fresh AI session for one server.
2. Paste the prompt below and fill in `TIER`, `ROSTER`, `BOOTSTRAP_USER`, and `VPS_IP` for
   that box.
3. Approve each phase as the AI works through it.
4. **Do not let the assistant disable root or password login until you have confirmed, in a
   separate terminal, that you (BOOTSTRAP_USER) can log in with the key and no password.**
   Every other roster member should also confirm their own login once `AllowUsers` is set. The
   prompt enforces this, but you are the final check. A lockout is the one mistake that is not
   easily undone.
5. When the first box is done, repeat for the next.

## The hardening prompt

```
You are helping me harden a brand-new Ubuntu 24.04 LTS VPS and prepare it for a new
application. This is one of several servers in a multi-tier setup. You have SSH access as root
for this first session only. Work carefully, one phase at a time, and explain what each
command does before running it.

PLACEHOLDERS (I will provide these):
- TIER: which tier this box is, "web" (frontend, smaller box) or "app" (backend, larger box)
- ROSTER: the team from the Team access section, each row a username, that person's SSH public
  key, and a sudo level ("full" or "limited"). One account per person, one key per account.
- BOOTSTRAP_USER: my own username from the roster, created and verified first so the box is
  never locked before a working login exists.
- VPS_IP: the server's IP address

CONTEXT:
This box sits behind a CDN/edge (Cloudflare), which is the CDN, DNS, WAF, and DDoS layer. The
origin is reached through the edge, not directly, so keep inbound locked down to SSH and let
the follow-on work decide how the web or API traffic arrives (Cloudflare Tunnel is preferred,
and its client, cloudflared, is installed in Phase 9). Do not open inbound web ports in this
hardening pass.

CRITICAL SAFETY RULE:
Never disable password auth or root login until I have confirmed, in a SEPARATE terminal,
that I can SSH in as BOOTSTRAP_USER using my key with no password. If that test fails, we fix
it BEFORE touching the SSH config. Locking myself out is the one unacceptable outcome. Every
other roster member must also be in AllowUsers with their key in place before password auth is
disabled, or they are locked out too.

Phase 1. System updates, bring the OS fully current
This box ships with whatever package versions were in the base image, which may be weeks or
months old. Bring everything to the latest patched versions before anything else, so known
fixes in the kernel and in the system libraries are in place from the start.
- apt update                  # refresh the list of available package versions
- apt upgrade -y              # upgrade installed packages to current patched versions
- apt full-upgrade -y         # allow upgrades that add or remove dependencies, including the kernel
- apt autoremove --purge -y   # remove packages that are no longer needed
- apt autoclean               # clear obsolete downloads from the local package cache
- Check whether the updates need a reboot by testing for /var/run/reboot-required. If it is
  present, tell me, then reboot and wait for the box to come back before continuing. A kernel
  or core library update only takes full effect after a reboot.
- Install and enable unattended-upgrades so security patches keep applying automatically
  after this session. Confirm it is active with: unattended-upgrades --dry-run

Phase 2. Create the admin accounts, one per team member
Create a SEPARATE Linux account for each person in ROSTER, never one shared account. This is
what lets me remove one person later without touching the others.
- Create BOOTSTRAP_USER first, so Phase 3 can verify a working login before anything is locked.
- For EACH person in ROSTER:
  - Create the user. Add "full" members to the sudo group. For a "limited" member, do NOT add
    them to the sudo group, grant only the specific access I name, or leave sudo off until I
    specify it.
  - Create /home/<user>/.ssh and write THAT person's public key into their authorized_keys.
  - Set ownership to the user and permissions 700 on .ssh, 600 on authorized_keys.
- Never put more than one person's key in one account. One account, one key, one owner. That
  is what keeps the lockout in the Team access section clean.

Phase 3. TEST LOGIN (do not skip)
- Stop and tell me to open a new terminal and run: ssh BOOTSTRAP_USER@VPS_IP
- Confirm it logs in with the key and that "sudo -v" works.
- Only continue once I confirm success. Each other roster member should test their own login
  once Phase 4 sets AllowUsers, but BOOTSTRAP_USER is the one that gates the lockdown.

Phase 4. SSH hardening
Edit /etc/ssh/sshd_config and set:
  PermitRootLogin no
  PasswordAuthentication no
  PubkeyAuthentication yes
  MaxAuthTries 3
  ClientAliveInterval 300
  ClientAliveCountMax 2
  AllowUsers <every username in ROSTER, space separated>
Then restart SSH. On Ubuntu 24.04 the service is "ssh" (not "sshd"):
  systemctl restart ssh
Notes:
- List every roster member in AllowUsers. Any member left out is locked out even with a valid
  key. When a member is later rotated out, this line is one of the two places to remove them.
- Many budget VPS hosts block non-standard SSH ports at the network edge, and Ubuntu 24.04
  uses a systemd socket unit that can ignore the Port directive in sshd_config. Keep SSH on
  port 22 unless I tell you I've confirmed the host and socket allow a custom port.
- After restart, have me confirm BOOTSTRAP_USER still logs in, and have each roster member
  confirm their own login, before continuing.

Phase 5. fail2ban (brute-force protection)
- Install fail2ban.
- Create /etc/fail2ban/jail.local with an [sshd] jail: enabled, port 22, maxretry 3,
  bantime 3600, findtime 600, logpath /var/log/auth.log.
- Enable and start fail2ban.

Phase 6. Firewall (UFW)
- Default deny incoming, default deny outgoing.
- Allow inbound + outbound 22/tcp (SSH management).
- Allow outbound 53/tcp + 53/udp (DNS), 80/tcp + 443/tcp (apt, package installs, HTTPS),
  123/udp (NTP time sync).
- TIER-SPECIFIC OUTBOUND. Ask me before opening anything beyond the base set above:
  - If TIER is "web": the base set is enough. Static sites reach the edge over 443.
  - If TIER is "app": this box will later run the application services and the database. The
    database stays bound to localhost and is NEVER exposed to the network. The backends will
    need outbound HTTPS (443) to reach the edge and any third-party APIs they call. 443
    outbound already covers HTTPS destinations; confirm with me before adding any non-443
    egress.
- Do NOT open inbound web ports (80/443) in this pass. Inbound web/API traffic arrives via
  Cloudflare Tunnel in the follow-on phases, which needs no inbound ports.
- Enable UFW and show me the final ruleset with "ufw status verbose".
Note: UFW filters by port, not domain. If the app uses Docker, warn me that Docker bypasses
UFW for published ports, prefer host networking or explicit iptables rules.

Phase 7. Disable unnecessary services
- List running services.
- Disable anything not needed on a server (e.g. snapd, cups, avahi-daemon), but ask me first
  if any look application-relevant.

Phase 8. Kernel hardening (sysctl)
Write /etc/sysctl.d/99-hardening.conf with:
  net.ipv4.ip_forward = 0
  net.ipv4.conf.all.accept_redirects = 0
  net.ipv4.conf.default.accept_redirects = 0
  net.ipv4.conf.all.send_redirects = 0
  net.ipv4.tcp_syncookies = 1
  net.ipv4.conf.all.log_martians = 1
  net.ipv4.conf.all.accept_source_route = 0
  net.ipv4.icmp_echo_ignore_broadcasts = 1
Apply with: sysctl -p /etc/sysctl.d/99-hardening.conf
(If the app needs IP forwarding, e.g. Docker or a VPN, tell me and adjust ip_forward.)

Phase 9. Cloudflare Tunnel tooling
Both origins sit behind the edge and reach it through an outbound-only tunnel, so no inbound
web ports are ever opened. Install the tunnel client now so the tunnel can be created right
after hardening.
- The tunnel client is cloudflared, the single edge tool this setup needs. It runs the tunnel
  on this box with no other dependencies, no Node and no extra CLI.
- Install cloudflared from Cloudflare's own apt repository, so apt and unattended-upgrades keep
  it patched, rather than a one-off .deb download:
  - Add Cloudflare's GPG key and the pkg.cloudflare.com apt source for the noble (24.04) release.
  - apt update
  - apt install -y cloudflared
  Confirm with: cloudflared --version
- Do NOT run the browser login or create the tunnel yourself. That step authorizes against my
  account and opens a browser, which I do from my own machine. Stop here and tell me to run,
  from my own logged-in session:
    cloudflared tunnel login
  and then create and route the named tunnel. Installing the client is where this pass ends.
- Installing or running cloudflared opens no inbound ports. The tunnel dials out to the edge,
  so the firewall stays default-deny inbound except SSH. Leave the Phase 6 rules as they are.

Phase 10. Verification checklist
Confirm and report on each:
- [ ] OS fully patched (apt update, then apt list --upgradable shows nothing held back)
- [ ] cloudflared installed on a current version (cloudflared --version)
- [ ] Root SSH login disabled (ssh root@VPS_IP is rejected)
- [ ] Password auth disabled (key-only)
- [ ] Each roster member's key login works, and BOOTSTRAP_USER has working sudo
- [ ] fail2ban active (fail2ban-client status sshd)
- [ ] UFW enabled, default deny incoming, rules as expected
- [ ] Unattended-upgrades enabled (unattended-upgrades --dry-run)
- [ ] sysctl hardening applied
- [ ] No unexpected services listening (ss -tlnp)

After verification, summarize what was changed and give me the exact command to log in
going forward. State which TIER this box is in the summary so I can label it.
```

## Per-tier specifics

The hardening pass is the same for both boxes. What differs is what each will run next and the
egress the firewall opens for it. This is context for the AI, not build instructions.

| | Web tier | App tier |
|--|----------|----------|
| Runs next | Static built sites, served through the edge | Application services plus the database |
| Inbound | None beyond SSH. Served through the edge. | None beyond SSH. Reached through the edge. |
| Outbound | Base set only (DNS, HTTP/HTTPS, NTP) | Base set plus HTTPS to the edge and any third-party APIs the backend calls |
| Database | None | Bound to localhost, never exposed to the network |

Keep the database point firm. On the app box the database shares the machine with the
backends, which is acceptable at a small footprint, but it must listen on localhost only. The
path to lift the database onto its own VPS later stays open, but that is not part of this
setup.

## Optional follow-on phases (ask the AI to continue)

Include only what a given box needs. These start moving past hardening into build, so they are
listed, not run by default here.

- **Runtime install (app box)**: the application runtime (e.g. Node.js via NodeSource),
  `build-essential` + `python3` for native module compilation, a process manager (e.g. PM2)
  with `startup` + `save` for boot persistence.
- **Create and route the Cloudflare tunnel (both boxes)**: `cloudflared` is already installed
  in Phase 9. The remaining step is to authorize it against the account
  (`cloudflared tunnel login`), create a named tunnel per box, point it at the local web or API
  service, and add the DNS route. The tunnel is outbound-only, so the firewall keeps
  default-deny inbound except SSH and no web ports open to the internet. The web tier can
  instead be served from a static host (e.g. Cloudflare Pages) connected straight to the repo,
  which needs no origin box at all.
- **Backups (app box especially)**: a nightly cron to copy app and database data, plus the
  host's own snapshot feature. Mandate offsite backups and a tested restore for the app box.
- **Log rotation**: cap log growth (e.g. `pm2-logrotate` or system `logrotate`).

## Gotchas worth keeping in the prompt

These are the things that actually bite, not theory.

1. **Test the new-user key login in a second terminal before disabling root/password.** This
   is the single most important step. Everything else is recoverable; a lockout is not.
2. **Ubuntu 24.04 service name is `ssh`, not `sshd`.** `systemctl restart sshd` fails
   silently-ish.
3. **Custom SSH ports often do not work.** Budget hosts block them at the network layer, and
   24.04's `ssh.socket` systemd unit can override the `Port` directive. Keep 22 unless
   verified.
4. **Docker punches through UFW.** Published container ports bypass the firewall. Use host
   networking or write explicit DOCKER-USER iptables rules.
5. **UFW is port-level, not domain-level.** Allowing outbound 443 allows all HTTPS and WSS
   destinations. For true egress allow-listing you need iptables and ipset or a forward proxy.
6. **One box, one session, do not cross them.** Harden each box in a separate run and label
   each. The size and the tier go together: the small box is the frontend, the larger box is
   the backend and database.
7. **cloudflared is the only edge tool needed on the box.** It runs the tunnel by itself, with
   no Node and no extra CLI. Install it from Cloudflare's apt repo so it stays patched with the
   rest of the system.
