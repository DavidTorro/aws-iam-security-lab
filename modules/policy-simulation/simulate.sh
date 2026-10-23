#!/usr/bin/env bash
# Programa del data source external: recibe la consulta de Terraform por stdin,
# llama al simulador de IAM y devuelve un mapa plano acción → decisión
set -euo pipefail

query="$(cat)"

# El data source solo admite strings, así que las listas llegan codificadas en JSON
request="$(jq '{
  PolicyInputList: [.policy],
  ActionNames: (.actions | fromjson),
  ResourceArns: (.resources | fromjson),
  ContextEntries: (.context | fromjson)
}' <<<"$query")"

# Solo evalúa el JSON recibido, sin mezclarlo con los permisos del rol del laboratorio
aws iam simulate-custom-policy --cli-input-json "$request" --output json |
  jq '[.EvaluationResults[] | {key: .EvalActionName, value: .EvalDecision}] | from_entries'
