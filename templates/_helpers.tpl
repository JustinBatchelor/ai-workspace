{{/*
Workspace namespace derived from the username.
*/}}
{{- define "ai-workspace.namespace" -}}
{{ .Values.username }}-ai-ws
{{- end }}

{{/*
Notebook resource name (workbench editor).
*/}}
{{- define "ai-workspace.notebookName" -}}
codeserver-nb-{{ .Values.username }}
{{- end }}

{{/*
DevWorkspace resource name (devspace editor).
*/}}
{{- define "ai-workspace.devworkspaceName" -}}
devspace-{{ .Values.username }}
{{- end }}

{{/*
PVC name tied to the notebook (workbench only; Dev Spaces manages its own storage).
*/}}
{{- define "ai-workspace.pvcName" -}}
codeserver-nb-{{ .Values.username }}-pvc
{{- end }}

{{/*
Continue.dev ConfigMap name — works for both editor types.
*/}}
{{- define "ai-workspace.continueConfigName" -}}
{{- if eq .Values.editor.type "devspace" -}}
devspace-{{ .Values.username }}-continue
{{- else -}}
codeserver-nb-{{ .Values.username }}-continue
{{- end -}}
{{- end }}

{{/*
Resolve the model spec from the catalog (or explicit overrides).
Returns the catalog entry dict for the chosen model.
*/}}
{{- define "ai-workspace.modelSpec" -}}
{{- $catalog := .Values.modelCatalog -}}
{{- $name    := .Values.aiModel.name -}}
{{- if hasKey $catalog $name -}}
{{-   index $catalog $name | toYaml -}}
{{- else -}}
storageUri: {{ .Values.aiModel.storageUri | default "MISSING" | quote }}
cpu: {{ .Values.aiModel.cpu | default "4" | quote }}
memory: {{ .Values.aiModel.memory | default "16Gi" | quote }}
gpu: {{ .Values.aiModel.gpu | default "1" | quote }}
contextLength: 32768
displayName: {{ $name }}
{{- end -}}
{{- end }}

{{/*
Shortcut helpers that pull individual fields from the resolved model spec.
*/}}
{{- define "ai-workspace.modelStorageUri" -}}
{{- $spec := include "ai-workspace.modelSpec" . | fromYaml -}}
{{ $spec.storageUri }}
{{- end }}

{{- define "ai-workspace.modelCpu" -}}
{{- $spec := include "ai-workspace.modelSpec" . | fromYaml -}}
{{ $spec.cpu }}
{{- end }}

{{- define "ai-workspace.modelMemory" -}}
{{- $spec := include "ai-workspace.modelSpec" . | fromYaml -}}
{{ $spec.memory }}
{{- end }}

{{- define "ai-workspace.modelGpu" -}}
{{- $spec := include "ai-workspace.modelSpec" . | fromYaml -}}
{{ $spec.gpu }}
{{- end }}

{{- define "ai-workspace.modelContextLength" -}}
{{- $spec := include "ai-workspace.modelSpec" . | fromYaml -}}
{{ $spec.contextLength | default 32768 }}
{{- end }}

{{- define "ai-workspace.modelDisplayName" -}}
{{- $spec := include "ai-workspace.modelSpec" . | fromYaml -}}
{{ $spec.displayName | default .Values.aiModel.name }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "ai-workspace.labels" -}}
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/part-of: ai-workspace
ai-workspace/username: {{ .Values.username | quote }}
{{- end }}
