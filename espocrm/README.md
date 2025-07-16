# Helm chart for EspoCRM

EspoCRM is a web application that allows users to view, enter, and evaluate all company relationships, regardless of type. People, companies, projects, or opportunities — all in an easy and intuitive interface.

Source: [EspoCRM's official website](https://www.espocrm.com)

## Requirements

- Kubernetes 1.30+
- Helm 3.0+
- An external database (MySQL, MariaDB, PostgreSQL)

## Description

This Helm chart deploys EspoCRM on a Kubernetes cluster using the Helm package manager. It runs EspoCRM in a PHP-FPM container behind an Nginx reverse proxy, with Ingress support for external access.

## Configuration

Please refer to the `values.yaml` file for a complete reference of all available configuration parameters.

### Database

- This chart does **not** deploy a database.
- You **must** create a database and a user with full privileges on this database beforehand.
- The database **must** be reachable from the Kubernetes cluster.
- Database connection details can be configured via the `values.yaml` file or via a Kubernetes Secret.

⚠️ **If these values are left empty, EspoCRM will not start successfully**.


### Ingress

- This Helm chart deploys EspoCRM together with an Nginx container that acts as a reverse proxy.
- You need to manually adjust the Ingress settings in `values.nginx.ingress` and `values.nginx.config` to match your cluster's setup:

e.g.:
 ```yaml
    hosts:
      - host: crm.example.com 
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: existing-secret
        hosts:
           - crm.example.com
 ```

 ```nginx
    server {
      listen 80 default_server;
      listen [::]:80 default_server;
      
      server_name crm.example.com;
    }
 ```


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

## Installation Example
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

## License

This Helm chart is released under the Apache License 2.0.

EspoCRM itself is licensed under the GNU Affero General Public License v3 (AGPLv3).
For more information about EspoCRM, please visit [EspoCRM's official website](https://www.espocrm.com)