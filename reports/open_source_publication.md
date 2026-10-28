# Open-source publication - 2026-10-28

**Generated:** 2026-10-28 15:54:27 +03:00
**Target:** <https://github.com/TDVVG-3/AtomicHeart-AR>

## 1. Download check

Release 1 is the GitHub release named **AtomicHeart-AR1**, tag **`0`**, published
2026-10-28 12:46:59 UTC. It has **no uploaded assets**.

The tag archive was downloaded and expanded:

| item | value |
| --- | --- |
| archive | `build/downloads/AtomicHeart-AR_release1_tag0.zip` |
| size | 408 bytes |
| expanded content | one file, `README.md`, 16 bytes |
| assets | none |

The public repository was also cloned to `build/github_upstream`; at that point it
contained only the 16-byte placeholder `README.md` and the initial commit
`a5085599b49c482bfe8d0966373b394c81300b9d`. No project source was present on GitHub.

## 2. Local open-source preparation

The local project was prepared for publication:

- `README.md` rewritten with release, install, build, verification, privacy, legal, and
  contributing sections.
- `STATUS.md` updated to the p12 release state.
- `CONTRIBUTING.md` expanded for public contributions.
- `CHANGELOG.md` gained a `1.0.0` release section.
- `DECISIONS.md`: DEC-012 is marked superseded; DEC-047 records the user-approved
  open-source publication policy.
- `.gitignore` now ignores the entire local `build/` directory.
- MIT `LICENSE` retained; third-party and game-content restrictions remain documented.
- Public Git commit: `6af5c2d` - `Open-source release: p12 Arabic localization, gates, and docs`.
- Local annotated tag: `v1.0.0`.
- Source archive: `build/release/AtomicHeart-AR-1.0.0-source.zip`, 30,446,185 bytes,
  SHA256 `782b2d47bc09385475a64207cb82265de16f4bce601107d943fa21425a5599d3`.

The commit contains 175 changed/added files and 85,019 insertions. It does not contain
`build/`, game PAKs, EXEs, DLLs, or unlicensed tool binaries.

## 3. Remote status

Remote added:

```text
origin  https://github.com/TDVVG-3/AtomicHeart-AR.git (fetch)
origin  https://github.com/TDVVG-3/AtomicHeart-AR.git (push)
```

Push was attempted with interactivity disabled:

```text
fatal: Cannot prompt because user interactivity has been disabled.
fatal: could not read Username for 'https://github.com': terminal prompts disabled
```

No source or release asset was uploaded. The public repository still shows only the
initial placeholder README until a GitHub login/token is available.

## 4. Required next step

Authenticate Git Credential Manager once:

```powershell
git credential-manager github login --device
```

Then push the prepared commit and tag:

```powershell
cd C:\AtomicHeart-AR
git push --force-with-lease -u origin master:main
git push origin v1.0.0
```

`--force-with-lease` is required because the remote `main` is an unrelated initial
commit. The remote repository is otherwise empty, so no real project history is being
overwritten.

After the push, create the GitHub release for tag `v1.0.0` and attach the source archive
if desired. Do **not** attach game PAKs, EXEs, DLLs, decrypted assets, or unlicensed
third-party tools.
