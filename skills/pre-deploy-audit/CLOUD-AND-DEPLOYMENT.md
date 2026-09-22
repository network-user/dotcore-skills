# Cloud and deployment hunting

## When to use

Используй для IAM, IaC, containers, serverless, ingress, secrets injection,
runtime configuration и workload identity.

## Классы

- IAM wildcard, confused deputy, cross-account/resource selector и privilege path;
- IaC public bucket, broad security group, unsafe default и secret в state/plan;
- container root, privileged mode, host mount, build secret и mutable image;
- serverless event trust, function URL, over-broad role и tenant selector;
- ingress/proxy trust, metadata service, internal route и unsafe CORS;
- runtime config, debug, admin port, secret exposure и fail-open behavior.

## Validation rules

Отделяй source-visible permission от provider policy. Нужны actor, effective role,
resource и concrete result. Не объявляй public deployment по одному YAML без
доказательства примененного path; отсутствующий provider факт - `needs_validation`.
