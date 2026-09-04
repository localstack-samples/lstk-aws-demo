# lstk AWS Demo — S3 Static Website

A live-demo project for `lstk`, the LocalStack CLI: install → choose emulator → login → deploy → inspect → snapshot, all against a real static website deployed to S3 via Terraform, running entirely on the LocalStack AWS emulator.

This deploys a real static website on S3 — modeled on the [S3 static website Terraform tutorial](https://docs.localstack.cloud/aws/tutorials/s3-static-website-terraform/) — rather than a throwaway bucket, so the demo has something concrete to show off at the end.

## Folder structure

```
lstk-aws-demo/
├── reset-demo.sh
├── main.tf
└── www/
    ├── index.html
    └── error.html
```

`main.tf` is the Terraform project deployed below. `reset-demo.sh` resets both `lstk` and the local Terraform artifacts in one shot (see the practice-run section below).

---

## 1. Environment reset (do this before the session, not on stage)

The goal is for your machine to look like it's never run `lstk` before, so the demo can show the full first-run experience live. This means undoing your current install and config ahead of time.

### Stop and log out
```bash
lstk stop
lstk logout
```
`lstk logout` clears the stored keyring token — without this, the browser login step won't trigger live.

### Note your persistent-state location, then clear it
```bash
lstk volume path     # prints the path, in case you want to inspect/back it up first
lstk volume clear
```

### Find and remove your config directory
```bash
lstk config path      # prints the active config.toml location
```
This also deletes `lstk.log`, since it lives alongside `config.toml`. Typical locations:

- **macOS/Linux:** `$HOME/.config/lstk/`
- **macOS (only if `~/.config` didn't exist on first run):** `$HOME/Library/Application Support/lstk/`
- **Windows:** `%AppData%\lstk\`
- Also check for a project-local `./.lstk/` folder in whatever directory you'll demo from, and remove it if present — it takes priority over the global config.

### Remove the `localstack` AWS CLI profile (if you ran `lstk setup aws` before)
`lstk` has no "unsetup" command, so this is manual: open `~/.aws/config` and `~/.aws/credentials` and delete the `[profile localstack]` / `[localstack]` sections.

### Remove Terraform artifacts (do this before every practice run)

Since you'll be rehearsing this multiple times, this folder will accumulate local Terraform artifacts that make `init`/`apply` behave like a *second* run instead of a fresh one — even after you've wiped the emulator itself above. Clear them out:

```bash
cd lstk-aws-demo
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate terraform.tfstate.backup
rm -f localstack_providers_override.tf   # lstk tf's auto-generated provider override — should self-clean, but double-check
```

`reset-demo.sh` (in this folder) runs the `lstk stop` / `logout` / `volume clear` steps plus this Terraform cleanup in one shot — run it between practice passes instead of retyping all of this each time.

### Uninstall the `lstk` binary itself
Pick whichever matches how you installed it:
```bash
# Homebrew
brew uninstall localstack/tap/lstk
brew untap localstack/tap        # optional, fully removes the tap

# npm
npm uninstall -g @localstack/lstk

# Manual binary
rm $(which lstk)                 # or wherever you placed it on PATH
```

This is optional as removing the `lstk` config directory is enough to force first-use behaviour, but make sure `lstk` is updated before the demo so that the update notice isn't shown.

---

## 2. Pre-stage for a smooth live demo

Do these in advance — not live, since they involve network calls or file creation that can stall:

- **Pre-pull the Docker image** so `lstk start` doesn't hang on a slow pull:
  ```bash
  docker pull localstack/localstack:latest
  ```
- Confirm **Terraform** and the **AWS CLI** are both on `PATH`.
- Have your browser ready and logged into the right LocalStack account for a fast login step, plus a second tab ready to open the website endpoint later.
- Re-install `lstk` (Homebrew/npm/binary — whichever you uninstalled above) so it's present but unconfigured when you walk on stage.

---

## 3. Live Demo Run-of-Show (~5 min)

| Time | Step | Commands / Notes |
|---|---|---|
| 0:00–0:45 | **Install & first run** | Narrate the one-liner (`brew install localstack/tap/lstk` or `npm install -g @localstack/lstk`). Run `lstk` cold — this triggers the interactive config wizard. **Choose AWS** when prompted for an emulator. |
| 0:45–1:05 | **Browser login** | No keyring token exists, so the browser opens automatically. Authenticate. |
| 1:05–1:20 | **Status / TUI** | The TUI shows live emulator state. `lstk status` also works for a quick text summary. |
| 1:20–3:00 | **Deploy with Terraform** | From this folder: `lstk tf init` then `lstk tf apply`. Call out there's no `provider.tf` in the project — `lstk tf` generates and injects it automatically. This provisions the bucket, website config, public-access policy, and uploads both HTML files. |
| 3:00–3:45 | **Inspect with `lstk aws`** | `lstk aws s3 ls` to show the bucket, then `lstk aws s3api get-bucket-website --bucket lstk-demo-website` to show the live website config. Copy the `website_endpoint` from the Terraform output and open it in the browser (or `curl` it) to show the real page being served. |
| 3:45–4:25 | **Snapshot** | `lstk snapshot save pod:demo-baseline` then `lstk snapshot list`. Narrate: *"This used to be split across two separate commands in the old CLI — `state` and `cloudpod`. Now it's one `snapshot` command, whether you're saving to a local file, a cloud snapshot, or your own S3 bucket."* |
| 4:25–5:00 | **Close: project-level config** | `lstk config path` to show where the config lives. If time allows, open `config.toml` and skim it — point out the commented-out `image`, `volumes`, `env`, and `snapshot` fields as a quick tour of the advanced capabilities (custom registries, init-hook mounts, named env profiles, auto-loaded snapshots). Mention that **project-level config** is what lets you point a folder at a different emulator (e.g. Azure) without touching the global config. |

---

## Quick command reference

```bash
# Terraform deploy
lstk tf init
lstk tf apply

# Inspect deployed resources
lstk aws s3 ls
lstk aws s3api get-bucket-website --bucket lstk-demo-website
curl http://lstk-demo-website.s3-website.localhost.localstack.cloud:4566/

# Snapshot commands used in the demo
lstk snapshot save pod:demo-baseline
lstk snapshot list

# Show config (teaser only — don't edit live)
lstk config path
```
