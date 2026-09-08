#!/bin/sh
set -e

C4_EXPORT_DIR="/app/report/assets/diagram-sources/c4-exported"

# Eliminando archivos de leyenda (-key.puml)
rm -f "${C4_EXPORT_DIR}"/*-key.puml

# Normalizando nombres de archivos PlantUML a kebab-case estándar
[ -f "${C4_EXPORT_DIR}/structurizr-SystemContext.puml" ] && mv -f "${C4_EXPORT_DIR}/structurizr-SystemContext.puml" "${C4_EXPORT_DIR}/context-level-diagram-atelier.puml" || true
[ -f "${C4_EXPORT_DIR}/structurizr-Containers.puml" ] && mv -f "${C4_EXPORT_DIR}/structurizr-Containers.puml" "${C4_EXPORT_DIR}/container-level-diagram-atelier.puml" || true
[ -f "${C4_EXPORT_DIR}/structurizr-Components-API.puml" ] && mv -f "${C4_EXPORT_DIR}/structurizr-Components-API.puml" "${C4_EXPORT_DIR}/component-level-diagram-api.puml" || true
[ -f "${C4_EXPORT_DIR}/structurizr-Components-WebApp.puml" ] && mv -f "${C4_EXPORT_DIR}/structurizr-Components-WebApp.puml" "${C4_EXPORT_DIR}/component-level-diagram-webapp.puml" || true
[ -f "${C4_EXPORT_DIR}/structurizr-Deployment-Production.puml" ] && mv -f "${C4_EXPORT_DIR}/structurizr-Deployment-Production.puml" "${C4_EXPORT_DIR}/deployment-diagram-atelier.puml" || true

for f in "${C4_EXPORT_DIR}"/structurizr-*.puml; do
    if [ -f "$f" ]; then
        target=$(basename "$f" | sed 's/^structurizr-//')
        mv -f "$f" "${C4_EXPORT_DIR}/$target"
    fi
done
