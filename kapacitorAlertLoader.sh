#!/bin/bash
defineTasks() {
  for file in $@; do
    handleError $(kapacitor define "$(${file%\.*})" -dbrp "$DATABASE.$RETENTION_POLICY" -type $(getType $file) -tick $file 2>&1 1> /dev/null)
  done;
}

defineTasksFromTemplates() {
  for file in $@; do
    handleError $(kapacitor define "${file%\.*}" -dbrp "$DATABASE.$RETENTION_POLICY" -type $(getType $file) -template ${file%\.*} -vars $VARS -tick $file 2>&1 1> /dev/null)
  done;
}

defineTemplates() {
  for file in $@; do \
    handleError $(kapacitor define-template "${file%\.*}" -type $(getType $file) -tick $file 2>&1 1> /dev/null)
  done;
}

enableTasks() {
  handleError $(kapacitor enable "$1" 2>&1 >/dev/null)
}

disableTasks() {
  handleError $(kapacitor disable "$1" 2>&1 >/dev/null)
}

reloadTasks() {
  handleError $(kapacitor reload "$1" 2>&1 >/dev/null)
}

getType() {
  if grep -q "stream" "$1"; then type="stream"; else type="batch"; fi; echo $type
}

handleError() {
  if [[ "$1" == *"err"* ||  "$1" == *"unknown"* ]]; then exit 1; fi
}

set -x #echo on
[ -z "$FUNCTION" ] && echo "Need to set FUNCTION for kapacitorAlertLoader to execute. Ex. defineTasks, defineTemplates, defineTasksFromTemplates, enableTasks, disableTasks, or reloadTasks" && exit 1;
[ -z "$ALERT" ] && echo "Need to set ALERT. Ex. scriptname.tick, prefix*, or *suffix.tick" && exit 1;
# defineTempaltes
if [[ $FUNCTION = "defineTemplates" ]]; then
  defineTemplates $ALERT
# enableTasks
elif [[ $FUNCTION = "enableTasks" ]]; then
  enableTasks $ALERT
# disableTasks
elif [[ $FUNCTION = "disableTasks" ]]; then
  disableTasks $ALERT
else
  [ -z "$DATABASE" ] && echo "Need to set DATABASE alert will target" && exit 1;
  [ -z "$RETENTION_POLICY" ] && echo "Need to set RETENTION_POLICY alert will have" && exit 1;
  # defineTasks
  if [[ $FUNCTION = "defineTasks" ]]; then
    defineTasks $ALERT
  # defineTasksFromTemplates
  elif [[ $FUNCTION = "defineTasksFromTemplates" ]]; then
    [ -z "$VARS" ] && echo "When deploying alert that is based on a template, you need to set a VARS json file. Ex: vars.json" && exit 1;
    defineTasksFromTemplates $ALERT
  fi
fi
