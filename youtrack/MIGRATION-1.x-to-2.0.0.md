# Migration Guide: 1.x -> 2.0.0

Chart version `2.0.0` introduces breaking changes for persistence-related values.

## Important Before Upgrading

Before running the upgrade, create a full YouTrack backup via the YouTrack web UI.
Do not start the migration without a verified backup.

## Summary of Breaking Changes

1. `storageType` keys were removed and replaced by `annotations` blocks.
2. Object storage keys were refactored:
   - removed: `storageProvisioner`, `obsVolumeType`, `region`, `reclaimPolicy`
   - replaced by: `persistence.backups.annotations` and `persistence.backups.objectStorage.volumeAttributes`
3. `persistence.backups.backupType` is now strictly validated and must be `objectStorage` or `volumeStorage`.
4. Custom `.Values.volumes` and `.Values.volumeMounts` are no longer injected by the StatefulSet template.

## 1) Replace `storageType` with `annotations`

```yaml
# Old
persistence:
  data:
    storageType: SSD
  logs:
    storageType: SSD
  conf:
    storageType: SSD
  temp:
    storageType: SSD
  backups:
    volumeStorage:
      storageType: SATA

# New (generic)
persistence:
  data:
    annotations: {}
  logs:
    annotations: {}
  conf:
    annotations: {}
  temp:
    annotations: {}
  backups:
    volumeStorage:
      annotations: {}
```

### Example: all block-style PVCs on T-Cloud Public (`data`, `logs`, `conf`, `temp`, `backups.volumeStorage`)

```yaml
persistence:
  data:
    name: youtrack-data
    storageClassName: csi-disk-default
    storageSize: 10Gi
    accessModes:
      - ReadWriteOnce
    annotations:
      everest.io/disk-volume-type: SSD
  logs:
    name: youtrack-logs
    storageClassName: csi-disk-default
    storageSize: 5Gi
    accessModes:
      - ReadWriteOnce
    annotations:
      everest.io/disk-volume-type: SSD
  conf:
    name: youtrack-config
    storageClassName: csi-disk-default
    storageSize: 1Gi
    accessModes:
      - ReadWriteOnce
    annotations:
      everest.io/disk-volume-type: SSD
  temp:
    enabled: false
    name: youtrack-temp
    storageClassName: csi-disk-default
    storageSize: 100Gi
    accessModes:
      - ReadWriteOnce
    annotations:
      everest.io/disk-volume-type: SSD
  backups:
    backupType: volumeStorage
    volumeStorage:
      storageClassName: csi-disk-default
      storageSize: 50Gi
      accessModes:
        - ReadWriteOnce
      annotations:
        everest.io/disk-volume-type: SATA
```

### Example: all block-style PVCs on Azure File CSI (`data`, `logs`, `conf`, `temp`, `backups.volumeStorage`)

```yaml
persistence:
  data:
    name: youtrack-data
    storageClassName: default
    storageSize: 20Gi
    accessModes:
      - ReadWriteOnce
    annotations: {}
  logs:
    name: youtrack-logs
    storageClassName: default
    storageSize: 5Gi
    accessModes:
      - ReadWriteOnce
    annotations: {}
  conf:
    name: youtrack-config
    storageClassName: default
    storageSize: 1Gi
    accessModes:
      - ReadWriteOnce
    annotations: {}
  temp:
    enabled: false
    name: youtrack-temp
    storageClassName: default
    storageSize: 100Gi
    accessModes:
      - ReadWriteOnce
    annotations: {}
  backups:
    backupType: volumeStorage
    volumeStorage:
      storageClassName: default
      storageSize: 50Gi
      accessModes:
        - ReadWriteOnce
      annotations: {}
```

For Azure File CSI, annotations such as `volume.beta.kubernetes.io/storage-provisioner: file.csi.azure.com` are usually injected automatically by Kubernetes/CSI and normally do not need to be set in chart values.

`persistence.temp` is optional and can be enabled or disabled at any time.
Enabling `temp` is recommended for large backup imports or initial setups from backup, because backup archives are unpacked into the temp path first and worker-node local space can become a bottleneck.

## 2) Migrate object storage fields

### Old -> New field mapping

- `reclaimPolicy` -> `persistence.backups.annotations.everest.io/reclaim-policy`
- `storageProvisioner` -> `persistence.backups.objectStorage.volumeAttributes.storage.kubernetes.io/csiProvisionerIdentity`
- `obsVolumeType` -> `persistence.backups.objectStorage.volumeAttributes.everest.io/obs-volume-type`
- `region` -> `persistence.backups.objectStorage.volumeAttributes.everest.io/region`

```yaml
# Old
persistence:
  backups:
    objectStorage:
      storageProvisioner: everest-csi-provisioner
      obsVolumeType: STANDARD
      region: eu-de
      reclaimPolicy: retain-volume-only

# New
persistence:
  backups:
    annotations:
      everest.io/reclaim-policy: retain-volume-only
    objectStorage:
      volumeAttributes:
        storage.kubernetes.io/csiProvisionerIdentity: everest-csi-provisioner
        everest.io/obs-volume-type: STANDARD
        everest.io/region: eu-de
```

### Example: Backups PVC on T-Cloud Public (`backupType: objectStorage`)

```yaml
persistence:
  backups:
    backupType: objectStorage
    name: youtrack-test-showcase-backups
    objectStorage:
      storageClassName: csi-obsfs-retain
      fsType: obsfs
      csiDriver: obs.csi.everest.io
      accessModes:
        - ReadWriteMany
      size: 100Gi
      bucketId: <bucket-id>
      accessKeySecretKeySecretName: <obs-secret-name>
      volumeAttributes: {}
      annotations: {}
```

### Example: Backups PVC on Azure (`backupType: objectStorage`)

```yaml
persistence:
  backups:
    backupType: objectStorage
    name: youtrack-backups
    objectStorage:
      storageClassName: azureblob-fuse-premium
      fsType: fuse
      csiDriver: blob.csi.azure.com
      accessModes:
        - ReadWriteMany
      size: 100Gi
      bucketId: <container-or-bucket-id>
      accessKeySecretKeySecretName: <azure-storage-account-secret>
      volumeAttributes: {}
      annotations: {}
```

## 3) Validate backup mode

```yaml
persistence:
  backups:
    backupType: volumeStorage # or objectStorage
```

Any other value now fails chart rendering.

## 4) If you used extra volumes/mounts

Additional custom `.Values.volumes` and `.Values.volumeMounts` are no longer supported by this chart.

The chart intentionally mounts only the predefined YouTrack paths. Additional mounts are not recommended because YouTrack does not expect arbitrary extra volumes in its runtime layout.

## Recommended Upgrade Procedure

1. Copy your current production values into a dedicated migration values file.
2. Apply the mappings in this guide.
3. Run a dry-run render:

```bash
helm template <release> ./youtrack -f <migrated-values.yaml>
```

4. Run a dry-run upgrade in the target namespace:

```bash
helm upgrade <release> ./youtrack -n <namespace> -f <migrated-values.yaml> --dry-run
```

5. If output is clean, perform the real upgrade.
