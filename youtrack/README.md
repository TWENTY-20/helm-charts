# ☸️ YouTrack Helm Chart
This Helm chart deploys [JetBrains YouTrack](https://www.jetbrains.com/youtrack)

[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=%23c3bc0e&color=grey)](https://github.com/TWENTY-20/helm-charts)

## 📝 Description
This flexible and dynamic Helm chart deploys YouTrack on a Kubernetes cluster using the official Docker image.

It supports extensive customization through `values.yaml`, allowing you to tailor storage, networking, and security settings to your environment.

An `initContainer` configures the `baseUrl` before startup, ensuring proper service behavior behind reverse proxies.

---
## ✨ Features
- Runs the official YouTrack [Docker image](https://hub.docker.com/r/jetbrains/youtrack)
- Supports persistent storage for data, logs and configuration
- Supports backup via volumeStorage or objectStorage (at this moment tested only with [OpenTelekomCloud OBS](https://docs.otc.t-systems.com/object-storage-service))
- Traefik compatible
- Cert-Manager compatible
- Easy whitelisting of Traefik & Cert-Manager for NetworkPolicy deny-all setups
- IP-based access restriction support
- Possibility to set securityContext and resource limits
- Highly customizable via `values.yaml`

---
## 📄 Requirements
[![Kubernetes Version](https://img.shields.io/badge/kubernetes-%3E%3D1.30-blue?style=for-the-badge&logo=kubernetes&logoColor=%23c3bc0e&color=%23c3bc0e)](https://kubernetes.io/releases/)
[![Helm Version](https://img.shields.io/badge/helm-%3E%3D3.0-green?style=for-the-badge&logo=helm&logoColor=%23c3bc0e&color=%23c3bc0e)](https://helm.sh/docs/intro/install/)
---
## ⚙️ Configuration
Please refer to the values.yaml file for a complete reference of all available configuration parameters.

<span style="color:red">**REQUIRED:**</span>
#### <span style="color:red;">Base URL</span>
before Installation set baseUrl via `values.yaml`
```yaml
config:
  baseUrl: "https://youtrack.example.com"
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
- **objectStorage:** backups on cloud object storage (at this moment tested only with [OpenTelekomCloud OBS](https://docs.otc.t-systems.com/object-storage-service))
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

---
<span style="color:yellow;">**OPTIONAL:**</span>

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
