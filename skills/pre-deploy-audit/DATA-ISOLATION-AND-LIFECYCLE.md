# Data isolation and lifecycle hunting

## When to use

Используй для multi-tenant data, search, cache, export, backup, migration,
deletion и restore.

## Классы

- tenant/owner predicate потерян в alternate query, batch или export;
- shared cache/search index key без resource scope;
- backup/restore, migration и replica path с другой authorization model;
- soft-delete, retention, tombstone и undelete/recovery confusion;
- object reference, pagination или count side-channel, который раскрывает чужие
  данные.

## Validation rules

Докажи lower-trust principal, чужой dummy resource и observed unauthorized read,
write, export или restore. Поле `tenant_id` без enforcement не считается control.
Реальный production dataset не используй.
