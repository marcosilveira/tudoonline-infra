#!/bin/bash
set -e

NAMESPACE="production"
echo "🧨 Deletando namespace $NAMESPACE..."
kubectl delete namespace $NAMESPACE --ignore-not-found

echo "🧹 Limpando releases Helm..."
helm uninstall mysql -n $NAMESPACE --wait 2>/dev/null || true
helm uninstall redis -n $NAMESPACE --wait 2>/dev/null || true
helm uninstall rabbitmq -n $NAMESPACE --wait 2>/dev/null || true
helm uninstall tudoonline-app -n $NAMESPACE --wait 2>/dev/null || true
helm uninstall goolhub-api -n $NAMESPACE --wait 2>/dev/null || true

echo "✨ Ambiente limpo!"
