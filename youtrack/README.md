# ☸️ YouTrack Helm Chart
This Helm chart deploys [JetBrains YouTrack](https://www.jetbrains.com/youtrack)

[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=%23c3bc0e&color=grey)](https://github.com/TWENTY-20/helm-charts)
[![Helm Chart Version](https://img.shields.io/badge/helm%20chart%20version-1.0.0-green?style=for-the-badge&logoColor=%23c3bc0e&color=%23c3bc0e)](https://artifacthub.io/packages/helm/twenty20-helm-charts/youtrack)
[![Docker Image Size](https://img.shields.io/docker/image-size/jetbrains/youtrack?style=for-the-badge&logo=docker&logoColor=%23c3bc0e&color=%23c3bc0e)](https://hub.docker.com/r/jetbrains/youtrack)

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

- **volumeStorage:** backups on Kubernetes Persistent Volumes
```yaml
persistence:
    backups:
      backupType: volumeStorage
```
- **objectStorage:** backups on cloud object storage (at this moment tested only with [OpenTelekomCloud OBS](https://docs.otc.t-systems.com/object-storage-service))
```yaml
persistence:
    backups:
        backupType: objectStorage
```

<span style="color:yellow">**OPTIONAL:**</span>

#### <span style="color:yellow">Persistence Configuration</span>
set the volume storageSize via `values.yaml`

To customize storageClassName or storageType, check the available storage classes in your cluster using a tool like k9s or `kubectl get storageclass`
```yaml
persistence:
    data:
        name: data
        storageClassName: csi-disk-default
        storageType: SSD
        storageSize: 50Gi

    logs:
        name: logs
        storageClassName: csi-disk-default
        storageType: SSD
        storageSize: 5Gi

    conf:
        name: config
        storageClassName: csi-disk-default
        storageType: SSD
        storageSize: 1Gi
```
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

## 📦 Installation
```bash
helm repo add twenty20 https://twenty-20.github.io/helm-charts
```
```bash
helm repo update
```
```bash
helm install youtrack twenty20/youtrack -f values.yaml
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
