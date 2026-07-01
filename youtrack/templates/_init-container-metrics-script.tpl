{{- define "youtrack.initContainerMetricsScript" -}}
jmx_config_source="/jmx-exporter-config/jmx_exporter.yaml"
jmx_config_init_target="/jmx-exporter/jmx_exporter.yaml"
jmx_config_source_log="jmx-exporter-config/jmx_exporter.yaml"
jmx_config_target_log="opt/youtrack/jmx-exporter/jmx_exporter.yaml"
jmx_logging_source="/jmx-exporter-config/jmx_logging.properties"
jmx_logging_init_target="/jmx-exporter/jmx_logging.properties"
jmx_logging_source_log="jmx-exporter-config/jmx_logging.properties"
jmx_logging_target_log="opt/youtrack/jmx-exporter/jmx_logging.properties"
jmx_agent_url={{ .Values.metrics.jarUrl | quote }}
jmx_agent_init_target="/jmx-exporter/jmx_prometheus_javaagent.jar"
jmx_agent_target_log="opt/youtrack/jmx-exporter/jmx_prometheus_javaagent.jar"

echo "[JMX Exporter] Copy config: ${jmx_config_source_log} -> ${jmx_config_target_log}"
cp "${jmx_config_source}" "${jmx_config_init_target}"

echo "[JMX Exporter] Copy logging config: ${jmx_logging_source_log} -> ${jmx_logging_target_log}"
cp "${jmx_logging_source}" "${jmx_logging_init_target}"

echo "[JMX Exporter] Download java agent: ${jmx_agent_url} -> ${jmx_agent_target_log}"
curl -fsSL --retry 3 --connect-timeout 10 \
  -o "${jmx_agent_init_target}" \
  "${jmx_agent_url}"
echo "[JMX Exporter] Java agent ready: ${jmx_agent_target_log}"
{{- end }}
