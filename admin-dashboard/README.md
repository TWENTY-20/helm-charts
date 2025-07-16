# ☸️ Admin-Dashboard Helm Chart

[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=%23c3bc0e&color=grey)](https://github.com/TWENTY-20/helm-charts)

## 📝 Description
This flexible and lightweight Helm chart deploys the Admin-Dashboard on a Kubernetes cluster using the official nginx-unprivileged alpine-slim Docker image.
It offers customization via the `values.yaml`, allowing you to modify the HTML content of your Admin-Dashboard easily.
---
## ✨ Features
- Runs the official nginx-unprivileged [Docker image](https://hub.docker.com/r/nginxinc/nginx-unprivileged)
- No persistent storage needed
- Traefik compatible
- Easy whitelisting of Traefik deny-all setups
- Possibility to set securityContext and resource limits
- Highly customizable via `values.yaml`
- HTML Code in `values.yaml` to customise the Admin-Dashboard links and design 

---
## 📄 Requirements
[![Kubernetes Version](https://img.shields.io/badge/kubernetes-%3E%3D1.30-blue?style=for-the-badge&logo=kubernetes&logoColor=%23c3bc0e&color=%23c3bc0e)](https://kubernetes.io/releases/)
[![Helm Version](https://img.shields.io/badge/helm-%3E%3D3.0-green?style=for-the-badge&logo=helm&logoColor=%23c3bc0e&color=%23c3bc0e)](https://helm.sh/docs/intro/install/)
---
## ⚙️ Configuration
Please refer to the values.yaml file for a complete reference of all available configuration parameters.

#### <span style="color:red">Ingress Host</span>
When enabling Ingress in your cluster, make sure to set your hostname via `values.yaml`
```yaml
ingress:
  enabled: true
  host: "set-your-hostname"
```
#### <span style="color:yellow">NetworkPolicy deny-all</span>
When using deny-all NetworkPolicy in your cluster & using Traefik you can simply whitelist Traefik via `values.yaml`

```yaml
networkPolicyWhitelist:
  traefik:
    enabled: true
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
helm install admin-dashboard twenty20-helm-charts/admin-dashboard -f values.yaml
```
---

## 🪪 License
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-green?style=for-the-badge&color=%23c3bc0e)](https://github.com/TWENTY-20/helm-charts/blob/main/admin-dashboard/LICENSE)

---
## 🌐 Social
[![Facebook](https://img.shields.io/badge/facebook-%231877F2.svg?style=for-the-badge&logo=facebook)](https://www.facebook.com/twenty20.de/)
[![Instagram](https://img.shields.io/badge/instagram-%23E4405F.svg?style=for-the-badge&logo=instagram)](https://www.instagram.com/we_are_twenty20/)
[![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin)](https://de.linkedin.com/company/twenty-20-gmbh-&-co-kg)
[![Xing](https://img.shields.io/badge/xing-%2300714F.svg?style=for-the-badge&logo=xing)](https://www.xing.com/pages/twenty-20gmbh-co-kg)
