{{- define "youtrack.metricsLoggingConfig" -}}
# Keep JUL logging available, but suppress JMX exporter INFO startup noise.
handlers=java.util.logging.ConsoleHandler
.level=INFO
java.util.logging.ConsoleHandler.level=INFO
io.prometheus.jmx.level=WARNING
e1723a08afd7bca35570fd31a7656f59.io.prometheus.jmx.level=WARNING
{{- end }}
