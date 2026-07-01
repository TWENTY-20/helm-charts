{{- define "youtrack.initContainerScript" -}}
{{- if eq .Values.config.mountStrategy "copy" }}
echo "Copying YouTrack JVM options"
cp /tmp/youtrack-config/youtrack.jvmoptions /opt/youtrack/conf/youtrack.jvmoptions
{{- end }}
{{- if .Values.metrics.enabled }}
{{ include "youtrack.initContainerMetricsScript" . }}
{{- end }}
echo "[YouTrack Configuration]"
/opt/youtrack/bin/youtrack.sh configure "--base-url={{ .Values.config.baseUrl }}" "--listen-port={{ .Values.service.port }}"
{{- end }}
