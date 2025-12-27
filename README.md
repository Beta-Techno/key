# Key — Bootstrap Secrets Bundles

This repository hosts encrypted bootstrap bundles (SOPS + age). The idea is simple: a fresh machine downloads one encrypted file, you enter a single unlock code, and Anvil immediately knows your Git identity, tokens, lockbox age key, and persona defaults before the rest of provisioning runs.

## Repository layout

```
key/
  README.md               # this file
  .sops.yaml              # SOPS creation rules (edit with your age recipient)
  bundles/                # encrypted bundles (.sops.yaml)
    .gitkeep              # placeholder so the directory exists
  examples/
    bootstrap.secrets.example.yaml  # template of the secrets we expect
  scripts/
    encrypt.sh            # helper to encrypt/decrypt bundles via sops
```

We intentionally keep *only* encrypted payloads inside `bundles/`. Keep plaintext templates in `examples/` (or anywhere outside this repo) and delete them once encrypted.

## Expected fields

Every bootstrap bundle is just a YAML map. At minimum we expect:

```yaml
git_username: nick
git_email: nick@example.com
# Personal access token with permissions to read private repos or upload SSH keys.
github_token: ghp_1234567890
# Optional: direct SSH private key or deploy key (if you prefer not to generate on host)
ssh_private_key: "-----BEGIN OPENSSH PRIVATE KEY-----..."
ssh_private_key_passphrase: ""
# Age key used to decrypt Lockbox / other SOPS stores.
lockbox_age_key: "AGE-SECRET-KEY-1QWERT..."
# Optional overrides
default_persona: dev
mani_repo_url: git@github.com:your-org/mani.git
```

Feel free to add Harbor tokens, observability endpoints, etc. Anvil loads the decrypted map into vars and wires everything automatically.

## Usage

1. Generate (or reuse) an age keypair for encryption.
2. Copy `examples/bootstrap.secrets.example.yaml` somewhere safe and fill in your real values.
3. Encrypt it into `bundles/<name>.sops.yaml` using `scripts/encrypt.sh` (or `sops -e`).
4. Publish this repo (or your fork) where bootstrap can download it.
5. During provisioning, enter the unlock code (age key). We decrypt the bundle, configure Git/SOPS/persona, then delete the plaintext.

### Encrypt helper

```
./scripts/encrypt.sh \
  --input examples/bootstrap.secrets.example.yaml \
  --output bundles/dev.sops.yaml
```

The script is a tiny wrapper around `sops` so you don’t forget flags. You can still run `sops -e` manually if you prefer.

## Default bundle

`bundles/` currently ships empty so you can decide whether to publish a public "press enter" bundle or maintain private forks. To provide a default, drop an encrypted file at `bundles/default.sops.yaml` and publish the corresponding age *public* key so users know which code unlocks it.

## Related repos

- [`nickbendasg/mani`](../mani) (placeholder) will eventually host the Mani manifest + commands used to sync all infrastructure repos. Point the `mani_repo_url` field at the manifest you want Anvil to pull.
- [`nickbendasg/anvil`](../anvil) consumes these bundles during bootstrap.

