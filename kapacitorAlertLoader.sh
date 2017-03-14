#!/bin/bash
defineTasks() {
  for file in "$@"; do
    task=${file%\.*}
    handleError $(kapacitor define "$task" -dbrp "$DATABASE.$RETENTION_POLICY" -type $(getType $file) -tick $file 2>&1 1> /dev/null)
  done;
}

defineTasksFromTemplates() {
  for file in "$@"; do
    task=${file%\.*}
    handleError $(kapacitor define "$task" -dbrp "$DATABASE.$RETENTION_POLICY" -type $(getType $file) -template $task -vars $VARS -tick $file 2>&1 1> /dev/null)
  done;
}

defineTemplates() {
  for file in "$@"; do
    template=${file%\.*}
    handleError $(kapacitor define-template "$template" -type $(getType $file) -tick $file 2>&1 1> /dev/null)
  done;
}

deleteTasks() {
  handleError $(kapacitor delete tasks "$1" 2>&1 1> /dev/null)
}

deleteTemplates() {
  handleError $(kapacitor delete templates "$1" 2>&1 1> /dev/null)
}

enableTasks() {
  task=${1%\.*}
  handleError $(kapacitor enable "$task" 2>&1 >/dev/null)
}

disableTasks() {
  task=${1%\.*}
  handleError $(kapacitor disable "$task" 2>&1 >/dev/null)
}

reloadTasks() {
  task=${1%\.*}
  handleError $(kapacitor reload "$task" 2>&1 >/dev/null)
}

getType() {
  if grep -q "stream" "$1"; then type="stream"; else type="batch"; fi; echo $type
}

handleError() {
  if [[ "$1" == *"err"* || "$1" == *"failed"* || "$1" == *"unknown"* || "$1" == *"invalid response"* ]]; then exit 1; fi
}

set -x #echo on
[ -z "$FUNCTION" ] && echo "Need to set FUNCTION for kapacitorAlertLoader to execute. Ex. defineTasks, defineTemplates, defineTasksFromTemplates, enableTasks, disableTasks, or reloadTasks" && exit 1;
[ -z "$ALERT" ] && echo "Need to set ALERT. Ex. scriptname.tick, prefix*, or *suffix.tick" && exit 1;
if [[ $FUNCTION = "defineTemplates" ]]; then
  defineTemplates $ALERT
elif [[ $FUNCTION = "enableTasks" ]]; then
  enableTasks $ALERT
elif [[ $FUNCTION = "deleteTasks" ]]; then
  deleteTasks "$ALERT"
elif [[ $FUNCTION = "deleteTemplates" ]]; then
  deleteTemplates "$ALERT"
elif [[ $FUNCTION = "disableTasks" ]]; then
  disableTasks $ALERT
else
  [ -z "$DATABASE" ] && echo "Need to set DATABASE alert will target" && exit 1;
  [ -z "$RETENTION_POLICY" ] && echo "Need to set RETENTION_POLICY alert will have" && exit 1;
  if [[ $FUNCTION = "defineTasks" ]]; then
    defineTasks $ALERT
  elif [[ $FUNCTION = "defineTasksFromTemplates" ]]; then
    [ -z "$VARS" ] && echo "When deploying alert that is based on a template, you need to set a VARS json file. Ex: vars.json" && exit 1;
    defineTasksFromTemplates $ALERT
  fi
fi
