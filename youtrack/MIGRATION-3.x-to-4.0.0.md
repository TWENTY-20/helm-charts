# Migration Guide: 3.x -> 4.0.0

Chart version `4.0.0` simplifies Ingress configuration.

## What Changed

The chart no longer adds Traefik, ACME or cert-manager annotations automatically.
`ingress.configMode` was removed.
`ingress.enabled` is now `false` by default.
`ingress.hosts` is now required when `ingress.enabled=true`.
Example values such as `youtrack.example.com` and `youtrack-letsencrypt-cert` are rejected when `ingress.enabled=true`.

Before `4.0.0`, these annotations were part of the default values:

```yaml
ingress:
  annotations:
    kubernetes.io/ingress.class: traefik
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
```

Starting with `4.0.0`, `ingress.annotations` is empty by default:

```yaml
ingress:
  annotations: {}
```

Remove `ingress.configMode` from your values.
Set `ingress.enabled=true` if you want the chart to render an Ingress.
Set `ingress.hosts` explicitly, or set `ingress.enabled=false` if you only use port-forward/local access.
Replace all example host and TLS secret values before enabling Ingress.

## What You Need To Do

If your setup needs these annotations, add them explicitly to your values:

```yaml
ingress:
  ingressClassName: traefik
  annotations:
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: youtrack.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: youtrack-letsencrypt-cert
      hosts:
        - youtrack.example.com
```

If your cluster still needs the old ingress class annotation, add it explicitly too:

```yaml
ingress:
  annotations:
    kubernetes.io/ingress.class: traefik
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: youtrack.example.com
      paths:
        - path: /
          pathType: Prefix
```

## Example: Existing TLS Secret

If TLS is provided by an existing Kubernetes Secret, configure Ingress like this:

```yaml
ingress:
  enabled: true
  name: youtrack
  annotations:
    traefik.ingress.kubernetes.io/router.middlewares: traefik-internal-https-redirect@kubernetescrd
  ingressClassName: traefik-internal
  hosts:
    - host: youtrack.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: tls-secret
      hosts:
        - youtrack.example.com
```

## Check Before Upgrading

Run a dry-run and verify the rendered Ingress:

```bash
helm template <release> ./youtrack -f <values.yaml>
helm upgrade <release> ./youtrack -n <namespace> -f <values.yaml> --dry-run
```
