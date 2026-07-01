# ☸️ YouTrack Helm Chart
This Helm chart deploys [JetBrains YouTrack](https://www.jetbrains.com/youtrack)

[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=%23c3bc0e&color=grey)](https://github.com/TWENTY-20/helm-charts)

## 📝 Description
This flexible and dynamic Helm chart deploys YouTrack on a Kubernetes cluster using the official Docker image.

It supports extensive customization through `values.yaml`, allowing you to tailor storage, networking, and security settings to your environment.

An `initContainer` configures both `baseUrl` and `listen-port` before startup, ensuring proper service behavior behind reverse proxies.

## ⚠️ Breaking Changes (2.0.0)
If you are upgrading from `1.x`, migration steps are required.

Please follow the migration guide: [MIGRATION-1.x-to-2.0.0.md](https://github.com/TWENTY-20/helm-charts/blob/main/youtrack/MIGRATION-1.x-to-2.0.0.md)

## ⚠️ Breaking Changes (3.0.0)
If you are upgrading from `2.x`, migration steps are required.

Please follow the migration guide: [MIGRATION-2.x-to-3.0.0.md](https://github.com/TWENTY-20/helm-charts/blob/main/youtrack/MIGRATION-2.x-to-3.0.0.md)

---
## ✨ Features
- Runs the official YouTrack [Docker image](https://hub.docker.com/r/jetbrains/youtrack)
- Supports persistent storage for data, logs, configuration and temp (optional)
- Supports backup via volumeStorage or objectStorage (tested with T-Cloud Public and Azure)
- Traefik compatible
- Cert-Manager compatible
- Easy whitelisting of Traefik & Cert-Manager for NetworkPolicy deny-all setups
- IP-based access restriction support
- Possibility to set securityContext and resource limits
- Optional Prometheus metrics via JMX Exporter
- Optional pod host aliases via `values.yaml`
- Optional sidecar containers and additional pod volumes via `values.yaml`
- Highly customizable via `values.yaml`

---
## 📄 Requirements
[![Kubernetes Version](https://img.shields.io/badge/kubernetes-%3E%3D1.30-blue?style=for-the-badge&logo=kubernetes&logoColor=%23c3bc0e&color=%23c3bc0e)](https://kubernetes.io/releases/)
[![Helm Version](https://img.shields.io/badge/helm-%3E%3D3.0-green?style=for-the-badge&logo=helm&logoColor=%23c3bc0e&color=%23c3bc0e)](https://helm.sh/docs/intro/install/)
---
## ⚙️ Configuration
Please refer to the values.yaml file for a complete reference of all available configuration parameters.

<span style="color:red;">**REQUIRED:**</span>

#### <span style="color:red;">Base URL</span>
Default for local/port-forward usage:
```yaml
config:
  baseUrl: "http://127.0.0.1:8080"
```
For production/external access, set your real public URL instead (for example `https://youtrack.example.com`).
If you keep the local default, set `ingress.enabled: false` and use port-forward access.
```yaml
config:
  baseUrl: "http://127.0.0.1:8080"
ingress:
  enabled: false
```
```bash
kubectl port-forward svc/http 8080:8080 -n <namespace>
```

#### <span style="color:red;">Backups</span>
choose either volumeStorage or objectStorage (only one active at a time).
> ℹ️ **Note:**
> The `name` field in each `persistence` section defines the suffix for the generated PersistentVolumeClaim.
> It is **freely configurable**.
> You can use meaningful names like `youtrack-backup` to make PVs/PVCs easier to identify.
- **volumeStorage:** backups on Kubernetes Persistent Volumes
```yaml
persistence:
  backups:
    backupType: volumeStorage
    name: youtrack-backup
```
- **objectStorage:** backups on cloud object storage (tested with T-Cloud Public and Azure)
```yaml
persistence:
  backups:
    backupType: objectStorage
    name: youtrack-backup
```
---
#### <span style="color:red;">Obtain Wizard Token</span>

Every time YouTrack is freshly deployed or upgraded to a new version, a setup token is required to complete the configuration via the web UI.

You can retrieve the token using:

```bash
kubectl exec -n namespace -it pod-name -- cat /opt/youtrack/conf/internal/services/configurationWizard/wizard_token.txt
```
ℹ️ Or simply check the pod logs during startup

<span style="color:yellow;">**OPTIONAL:**</span>



#### <span style="color:yellow;">Startup Options (3.x, Optional)</span>
Set startup configuration dynamically in `values.yaml` via one single `config.options` block:
```yaml
config:
  baseUrl: "http://127.0.0.1:8080"
  options:
    - -Ddisable.configuration.wizard.on.upgrade=true
    - -Djetbrains.youtrack.disableCheckForUpdate=true
    - -Xmx2048m
    - -XX:MaxMetaspaceSize=512m
```
`-Dbase-url` and `-Dlisten-port` are reserved; the chart sets base-url from `config.baseUrl` (init `configure --base-url` and ConfigMap) and listen-port from `service.port` (init `configure --listen-port`), so do not set either in `config.options`.

`config.mountStrategy` controls how `youtrack.jvmoptions` is injected:
- `subPath` (default): mount `youtrack.jvmoptions` directly from ConfigMap.
- `copy`: init container mounts ConfigMap at `/tmp/youtrack-config` and copies the file into `/opt/youtrack/conf`.

The chart adds a ConfigMap checksum annotation to the StatefulSet pod template, so changes in `config.options` trigger an automatic rolling restart.

#### <span style="color:yellow;">Prometheus Metrics via JMX Exporter (Optional)</span>
Enable `metrics.enabled` to expose Prometheus metrics from YouTrack via the JMX Exporter Java agent.

```yaml
metrics:
  enabled: true
  port: 9404
```

When enabled, the chart:
- creates a metrics ConfigMap with `jmx_exporter.yaml`
- downloads the JMX Exporter Java agent in the init container from `metrics.jarUrl`
- mounts the agent and config into the main YouTrack container
- exposes a `metrics` container port and `metrics` Kubernetes Service

The default JMX Exporter rules are defined in `values.yaml` under `metrics.jmxExporter.config`.
Override this block to customize exported metrics:

```yaml
metrics:
  enabled: true
  jmxExporter:
    config: |-
      startDelaySeconds: 10
      rules:
        - pattern: 'java.lang<type=Runtime><>Uptime:'
          name: process_uptime
```

`metrics.serviceMonitor.enabled` optionally creates a Prometheus Operator `ServiceMonitor`:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

Only enable `serviceMonitor.enabled` when the `monitoring.coreos.com/v1` `ServiceMonitor` CRD is installed in the cluster. Metrics still work without a `ServiceMonitor`; Prometheus can also scrape the generated `metrics` Service by other means.

If Prometheus selects `ServiceMonitor` objects by label, set matching labels with `metrics.serviceMonitor.labels`:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    labels:
      release: kube-prometheus-stack
```

#### <span style="color:yellow;">Database Cleanup (One-Time Recovery)</span>
If backup size grows quickly and logs contain `GC is disabled on database`, use Xodus recovery flags only as a temporary maintenance action.

Example (one-time run only):
```yaml
config:
  options:
    - -Dexodus.env.compactOnOpen=true
    - -Dexodus.entityStore.refactoring.missedLinks=true
    - -Dexodus.gc.utilization.fromScratch=true
    - -Dexodus.entityStore.refactoring.heavyLinks=true
    - -Dexodus.gc.filesDeletionDelay=21000
```

Important:
- Take a fresh backup before running recovery flags.
- Plan downtime: `compactOnOpen` can keep YouTrack offline for a long time during startup.
- Ensure enough free space on `/opt/youtrack/data` (roughly at least current DB size) for compaction temp data.
- `-Dexodus.entityStore.refactoring.heavyLinks=true` ran a one-time link refactoring and has no further effect.
- `-Dexodus.gc.utilization.fromScratch=true` forced the GC to recalculate its estimates from scratch after the heavy import period caused the estimates to drift. Now that the GC is working with accurate figures, it is no longer needed.
- `-Dexodus.gc.filesDeletionDelay=21000` is a safety measure during cleanup.
- Remove the recovery flags after one successful restart, then restart normally again.
- If `.del` files remain afterwards, delete them only while YouTrack is stopped and only after a fresh backup.

#### <span style="color:yellow;">GC Transaction Timeout (Large Installations)</span>
If logs contain errors like `GC for database /opt/youtrack/data/youtrack was interrupted because of timeout (500 ms) while cleaning file ...`, increase the GC transaction timeout.

```yaml
config:
  options:
    - -Dexodus.gc.transactionTimeout=5000
```

Value is in milliseconds. Increase only when needed.

---

#### <span style="color:yellow;">Sidecars (Optional)</span>
You can attach one or more sidecar containers and additional pod volumes via `values.yaml`.

```yaml
sidecars:
  containers:
    - name: vpn
      image: ghcr.io/example/vpn:1.0
      volumeMounts:
        - name: vpn-config
          mountPath: /vpn
  volumes:
    - name: vpn-config
      secret:
        secretName: vpn-secret
```

Important:
- `sidecars.containers` accepts complete Kubernetes container specs.
- `sidecars.volumes` appends pod-level volumes. (Use existing chart volumes or reference pre-created PVCs)
---

#### <span style="color:yellow;">Host Aliases (Optional)</span>
You can add static hostname entries to the YouTrack pod's `/etc/hosts` via `values.yaml`.

```yaml
hostAliases:
  - ip: "192.0.2.10"
    hostnames:
      - "jira.avat.local"
```
---


#### <span style="color:yellow;">Persistence Configuration</span>

By default, this chart uses `storageClassName: csi-disk-default`.
This works in most production-grade clusters with CSI drivers.

Check available storage classes in your cluster:

```bash
kubectl get storageclass
```

---
#### <span style="color:yellow">NetworkPolicy deny-all</span>
When using deny-all NetworkPolicy in your cluster & using Traefik you can simply whitelist Traefik via `values.yaml`

```yaml
networkPolicyWhitelist:
  traefik:
    enabled: true
```
When using deny-all NetworkPolicy in your cluster & using Cert-Manager you can simply whitelist Cert-Manager via `values.yaml`
```yaml
networkPolicyWhitelist:
  cert-manager:
    enabled: true
    port: 8089
```

---
#### <span style="color:yellow">IP Whitelist</span>
Enable IP whitelisting to restrict access to specified IP ranges via `values.yaml`
```yaml
ipWhitelist:
  enabled: true
  name: ip-whitelist
  sourceRange:
    - XXX.XXX.XXX.XXX/XX
```
**Important:**
If ipWhitelist.enabled is true, update your ingress annotations to include the whitelist middleware:
```traefik.ingress.kubernetes.io/router.middlewares: ip-whitelist@kubernetescrd```
---
#### <span style="color:yellow;">Ingress Config Mode</span>
Ingress supports two modes:

- `auto` (default): keeps the current behavior and derives host/TLS host from `config.baseUrl`.
- `manual`: uses explicit `ingress.hosts`, `ingress.tls`, and optional `ingress.ingressClassName`.
- In `manual` mode, annotations are fully user-managed. Make sure your annotations match the selected controller/class.

Default (`auto`):
```yaml
ingress:
  enabled: true
  configMode: auto
```

Manual:
```yaml
ingress:
  enabled: true
  configMode: manual
  ingressClassName: traefik
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
---
#### <span style="color:yellow;">Port Forwarding with Traefik Ingress</span>

Guide explains how to forward traffic to YouTrack via Traefik locally.

This setup assumes no restrictive NetworkPolicies block traffic between Traefik and YouTrack pods, like deny-all. Adjust as necessary if your environment differs.

Run the port-forward command, replacing placeholders as needed:

```bash
kubectl port-forward svc/<traefik-service-name> <local-port>:<service-port> -n <traefik-namespace>
```

Example:

```bash
kubectl port-forward svc/traefik 8080:80 -n traefik
```

Since Traefik routes traffic based on hostname, you must map your Ingress host to localhost by editing your /etc/hosts file with an entry like:

```bash
127.0.0.1 <ingress-host>
```

Replace \<ingress-host\> with your actual Ingress hostname, for example youtrack.example.com

After that, access YouTrack in your browser by navigating to:

```bash
http://<ingress-host>:<local-port>
```

Example:

```bash
http://youtrack.example.com:8080
```

---
## 📦 Installation
```bash
helm repo add twenty20-helm-charts https://twenty-20.github.io/helm-charts
```
```bash
helm repo update
```
```bash
helm install youtrack twenty20-helm-charts/youtrack -f values.yaml
```
---
## 🪪 License
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-green?style=for-the-badge&color=%23c3bc0e)](https://github.com/TWENTY-20/helm-charts/blob/main/youtrack/LICENSE)

YouTrack is a proprietary product developed by JetBrains and is subject to its own licensing terms.  For detailed information, please refer to the [YouTrack Server License Agreement](https://www.jetbrains.com/legal/docs/youtrack/license/)

---
## 🌐 Social
[![Facebook](https://img.shields.io/badge/facebook-%231877F2.svg?style=for-the-badge&logo=facebook)](https://www.facebook.com/twenty20.de/)
[![Instagram](https://img.shields.io/badge/instagram-%23E4405F.svg?style=for-the-badge&logo=instagram)](https://www.instagram.com/we_are_twenty20/)
[![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin)](https://de.linkedin.com/company/twenty-20-gmbh-&-co-kg)
[![Xing](https://img.shields.io/badge/xing-%2300714F.svg?style=for-the-badge&logo=xing)](https://www.xing.com/pages/twenty-20gmbh-co-kg)
