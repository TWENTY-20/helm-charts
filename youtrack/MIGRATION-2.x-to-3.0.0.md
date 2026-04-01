# Migration Guide: 2.x -> 3.0.0

Chart version `3.0.0` introduces breaking changes in JVM configuration handling.

## Important Before Upgrading

Before running the upgrade, create a full YouTrack backup via the YouTrack web UI.
Do not start the migration without a verified backup.

## Reference Docs

- Configure JVM Options: https://www.jetbrains.com/help/youtrack/server/configure-jvm-options.html
- Configuration Parameters: https://www.jetbrains.com/help/youtrack/server/youtrack-java-start-parameters.html

## Summary of Breaking Changes

1. `youtrack/templates/configmap.yaml` is now fully dynamic and renders exactly one list.
2. The old fixed `config.*` JVM-related keys were removed from `values.yaml` (they now remain as commented examples only).
3. Startup config is now defined only via `config.options` and rendered as-is line by line.
4. `service.port` is now the single source of truth for the runtime listen port.
   - the chart always configures listen-port via init container: `configure --listen-port=<service.port>`
   - do not set `-Dlisten-port=...` in `config.options` (chart rendering fails if you do)

## New Structure (3.0.0)

```yaml
config:
  name: configmap
  baseUrl: "https://youtrack.example.com"

  options:
    - -Ddisable.configuration.wizard.on.upgrade=true
    - -Djetbrains.youtrack.disableCheckForUpdate=true
    - -Dsecure-mode=disable
    - -Dstatistics-upload=false
    - -Xmx2048m
    - -XX:MaxMetaspaceSize=512m

service:
  port: 8080
```

## Old -> New Mapping

| old (2.x)                                 | new (3.0.0)                                                                     |
|-------------------------------------------|---------------------------------------------------------------------------------|
| `config.youtrackAdminRestore`             | `config.options: ["-Djetbrains.youtrack.admin.restore=<value>"]`                |
| `config.youtrackSupportEmail`             | `config.options: ["-Djetbrains.youtrack.support.email=<value>"]`                |
| `config.youtrackDisableCheckForUpdate`    | `config.options: ["-Djetbrains.youtrack.disableCheckForUpdate=<value>"]`        |
| `config.dnqTextIndexMinPrefixQueryLength` | `config.options: ["-Djetbrains.dnq.textIndex.minPrefixQueryLength=<value>"]`    |
| `config.youtrackMailLimit`                | `config.options: ["-Djetbrains.youtrack.mailLimit=<value>"]`                    |
| `config.youtrackEventMergeTimeout`        | `config.options: ["-Djetbrains.youtrack.event.merge.timeout=<value>"]`          |
| `config.youtrackDefaultPage`              | `config.options: ["-Djetbrains.youtrack.default.page=<value>"]`                 |
| `config.youtrackWebHookBaseUrl`           | `config.options: ["-Djetbrains.youtrack.webHooksBaseUrl=<value>"]`              |
| `config.httpRequestHeaderBufferSize`      | `config.options: ["-Djetbrains.http.request.header.buffer.size=<value>"]`       |
| `config.httpResponseHeaderBufferSize`     | `config.options: ["-Djetbrains.http.response.header.buffer.size=<value>"]`      |
| `config.youtrackLicenseName`              | `config.options: ["-Djetbrains.youtrack.licenseName=<value>"]`                  |
| `config.youtrackLincenseKey`              | `config.options: ["-Djetbrains.youtrack.licenseKey=<value>"]`                   |
| `config.youtrackDumbMode`                 | `config.options: ["-Djetbrains.youtrack.dumbMode=<value>"]`                     |
| `config.youtrackAiPlatformConfigUrl`      | `config.options: ["-Djetbrains.youtrack.ai.platform.config.url=<value>"]`       |
| `config.secureMode`                       | `config.options: ["-Dsecure-mode=<value>"]`                                     |
| `config.statisticsUpload`                 | `config.options: ["-Dstatistics-upload=<value>"]`                               |
| `config.hubAuthLoginThrottlingEnabled`    | `config.options: ["-Djetbrains.hub.auth.login.throttling.enabled=<value>"]`     |
| `config.fileEncoding`                     | `config.options: ["-Dfile.encoding=<value>"]`                                   |
| `config.javaAwtHeadless`                  | `config.options: ["-Djava.awt.headless=<value>"]`                               |
| `config.youtrackSingleTierApp`            | `config.options: ["-Djetbrains.youtrack.singleTierApp=<value>"]`                |
| `config.hubAdminSkip`                     | `config.options: ["-Djetbrains.hub.admin.skip=<value>"]`                        |
| `config.forceCheckDataConsistency`        | `config.options: ["-Dexodus.log.forceCheckDataConsistency=<value>"]`            |
| `config.clearBrokenBlobs`                 | `config.options: ["-Dexodus.entityStore.refactoring.clearBrokenBlobs=<value>"]` |
| `config.heapDumpOnOutOfMemoryError`       | `config.options: ["-XX:-HeapDumpOnOutOfMemoryError"]`                           |
| `config.heapDumpPath`                     | `config.options: ["-XX:HeapDumpPath=<path>"]`                                   |
| `config.errorFile`                        | `config.options: ["-XX:ErrorFile=<path>"]`                                      |
| `config.enableAssertions`                 | `config.options: ["-ea"]`                                                       |
| `config.disableAssertions`                | `config.options: ["-da"]`                                                       |
| `config.metaspaceSize`                    | `config.options: ["-XX:MetaspaceSize=<value>"]`                                 |
| `config.maxMetaspaceSize`                 | `config.options: ["-XX:MaxMetaspaceSize=<value>"]`                              |
| `config.xmx`                              | `config.options: ["-Xmx<value>"]`                                               |
| `config.debug`                            | `config.options: ["-debug"]`                                                    |
| `config.sdebug`                           | `config.options: ["-sdebug"]`                                                   |

## Recommended Upgrade Procedure

1. Copy your current production values into a dedicated migration values file.
2. Move all old `config.*` JVM-related keys into `config.options` as raw JVM option lines.
3. Add any new custom property you need (for example `-Ddisable.configuration.wizard.on.upgrade=true`).
4. Run a dry-run render:

```bash
helm template <release> ./youtrack -f <migrated-values.yaml>
```

5. Run a dry-run upgrade in the target namespace:

```bash
helm upgrade <release> ./youtrack -n <namespace> -f <migrated-values.yaml> --dry-run
```

6. If output is clean, perform the real upgrade.
