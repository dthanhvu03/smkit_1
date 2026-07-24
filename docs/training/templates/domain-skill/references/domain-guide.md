# DOMAIN guide — deep rules (progressive disclosure)

Loaded by the domain skill. Keep `SKILL.md` short; put depth here.

## Ubiquitous language
| Term (founder words) | Meaning | Not the same as |
|----------------------|---------|-----------------|
| TERM_A | … | … |

## Critical single-entry services
| Service | Owns | Bypass looks like |
|---------|------|-------------------|
| SERVICE_NAME | … | Direct table update / UI-only check |

## Append-only / never hard-delete
- TABLE_OR_STREAM_1
- TABLE_OR_STREAM_2

Corrections use: cancel / reversal / adjustment / exception — not UPDATE/DELETE of history.

## Illegal states (design out)
- …

## Common failure modes (what juniors miss)
1. …
2. …

## Test expectations
- Happy path
- Authorization deny (403)
- Validation fail (422) when inputs matter
- Invariant regression for this domain

## Human Owner
Stop for: schema, production data, permission matrix, multi-module rule changes.

> Replace placeholders. Prefer linking to real docs over duplicating ERD tables here.
