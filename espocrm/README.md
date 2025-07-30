# Helm chart for EspoCRM

This Helm chart deploys EspoCRM on a Kubernetes cluster using the Helm package manager. It runs EspoCRM in a PHP-FPM container behind an Nginx reverse proxy, with Ingress support for external access.


## 📝 Description
EspoCRM is a web application that allows users to view, enter, and evaluate all company relationships, regardless of type. People, companies, projects, or opportunities — all in an easy and intuitive interface.

Source: [EspoCRM's official website](https://www.espocrm.com)


## 📄 Requirements

- Kubernetes 1.30+
- Helm 3.0+
- An external database (MySQL, MariaDB, PostgreSQL)


## ⚙️ Configuration

Please refer to the `values.yaml` file for a complete reference of all available configuration parameters.

### Database

- This chart does **not** deploy a database.
- You **must** create a database and a user with full privileges on this database beforehand.
- The database **must** be reachable from the Kubernetes cluster.
- Database connection details can be configured via the `values.yaml` file or via a Kubernetes Secret.

⚠️ **If these values are left empty, EspoCRM will not start successfully**.


### Ingress

This Helm chart deploys EspoCRM together with an Nginx container that acts as a reverse proxy. The chart supports both traditional Kubernetes Ingress (via Nginx Ingress Controller) and Traefik IngressRoute.

#### Option 1: Kubernetes Ingress (Default)

- You need to adjust the Ingress settings in `values.nginx.ingress` and `values.nginx.config` to match your cluster's setup.
- To configure ingress-controller-specific behavior, you can provide custom annotations under `nginx.ingress.annotations`, such as TLS settings, middleware references, or ingress class definitions

e.g.:
 ```yaml
nginx:
  ingress:
    enabled: true
    name: espocrm-ingress
    annotations: {}
      # Example:
      # kubernetes.io/ingress.class: traefik
      # cert-manager.io/cluster-issuer: letsencrypt-prod
      # traefik.ingress.kubernetes.io/router.middlewares: traefik-https-redirect@kubernetescrd
      ...

    hosts:
      - host: crm.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: ""
        hosts:
           - crm.example.com
 ```

 ```yaml
nginx:
  config:
    content: |-
      # ...existing configuration...
      server {
        listen 80 default_server;
        listen [::]:80 default_server;
        
        server_name crm.example.com;
        # ...rest of nginx config...
      }
 ```


#### Option 2: Traefik IngressRoute
**Note:** The Nginx container still runs as a reverse proxy for the PHP-FPM container. Only the ingress mechanism changes when using Traefik.

⚠️ **Do NOT enable this together with `.Values.nginx.ingress`**.

1. Disable Ingress and enable Traefik
```yaml
nginx:
  ingress:
    enabled: false

nginx:
  traefik:
    enabled: true

```
2. Adjust the Ingress settings in `values.nginx.traefik` and `values.nginx.config` to match your cluster's setup.

```yaml
  traefik:
    enabled: false
    ingressRoute:
      name: espocrm-ingressroute
      host: crm.example.com
      # TLS configuration
      tls:
        enabled: true
        certResolver: letsencrypt-prod

      # Additional middlewares to apply
      middlewares: []
        # - name: traefik-https-redirect
        #   namespace: traefik
        # - name: traefik-security-headers
        #   namespace: traefik
```
**Traefik Features Included:**
- Automatic HTTPS redirect
- Security headers (HSTS, X-Frame-Options, CSP, etc.)
- Gzip compression
- WebSocket support (`/wss` endpoint)
- TLS with cert-manager or existing secrets
- Custom middleware support



### Secrets
You can set environment variables directly in your values.yaml file or, preferably, via a Kubernetes Secret.
Using a Secret is the recommended approach for production deployments to avoid sensitive data exposure.

The Secret usage must be enabled explicitly in `values.yaml`. 
```yaml
secret:
  enabled: true
  name: espocrm-config
```

When using a Secret:
- The Secret can provide the same environment variables that would otherwise be generated from `values.externalDatabase`, `values.espocrm.settings` and `values.espocrm.config`.
- The Secret **must** contain the exact environment variable names that EspoCRM expects.

⚠️ **Values in `values.yaml` will override Secret entries unless explicitly left empty (i.e.,"")**

For more details on required environment variables, refer to the official EspoCRM documentation:  
[EspoCRM Installation Environment Variables](https://docs.espocrm.com/administration/docker/installation/#installation-environments)

## 📦 Installation
1. Create the database and user with full privileges:
```sql
CREATE DATABASE espocrm;
CREATE USER 'espocrm_user'@'%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON espocrm.* TO 'espocrm_user'@'%';
FLUSH PRIVILEGES;
```
2. Create the Kubernetes Secret (optional) e.g. :
```bash
kubectl create secret generic espocrm-config \
  --from-literal=ESPOCRM_DATABASE_PASSWORD=your_password \
  --from-literal=ESPOCRM_ADMIN_PASSWORD=your_admin_password \
  --from-literal=ESPOCRM_CONFIG_OIDC_CLIENT_SECRET=your_oidc_client_secret
```

3. Deploy the chart:
```bash
helm install espocrm twenty20-helm-charts/espocrm-chart -f values.yaml
```

## 🪪 License

This Helm chart is released under the Apache License 2.0.

EspoCRM itself is licensed under the GNU Affero General Public License v3 (AGPLv3).
For more information about EspoCRM, please visit [EspoCRM's official website](https://www.espocrm.com)

---
## 🌐 Social
[![Facebook](https://img.shields.io/badge/facebook-%231877F2.svg?style=for-the-badge&logo=facebook)](https://www.facebook.com/twenty20.de/)
[![Instagram](https://img.shields.io/badge/instagram-%23E4405F.svg?style=for-the-badge&logo=instagram)](https://www.instagram.com/we_are_twenty20/)
[![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin)](https://de.linkedin.com/company/twenty-20-gmbh-&-co-kg)
[![Xing](https://img.shields.io/badge/xing-%2300714F.svg?style=for-the-badge&logo=xing)](https://www.xing.com/pages/twenty-20gmbh-co-kg)



## 🙏 Credits

Thanks to [@Erickk0](https://github.com/Erickk0) for the initial idea and contribution to the Traefik integration in [PR#10](https://github.com/TWENTY-20/helm-charts/pull/10).
