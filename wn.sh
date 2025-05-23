#!/bin/sh

WN_DIR=".wn"
QUEUE_FILE="task-queue.txt"
STACK_FILE="task-stack.txt"
DONE_FILE="done-tasks.txt"
PREFIXED_QUEUE_FILE="$WN_DIR/$QUEUE_FILE"
PREFIXED_STACK_FILE="$WN_DIR/$STACK_FILE"
PREFIXED_DONE_FILE="$WN_DIR/$DONE_FILE"
TMP_QUEUE_FILE="/tmp/$QUEUE_FILE.tmp"
TMP_STACK_FILE="/tmp/$STACK_FILE.tmp"
TMP_DONE_FILE="/tmp/$DONE_FILE.tmp"
TMP_ANY_FILE="/tmp/anyfile.tmp"

#commands
init() {
  mkdir -p "$WN_DIR"
  touch "$PREFIXED_QUEUE_FILE"
  touch "$PREFIXED_STACK_FILE"
  touch "$PREFIXED_DONE_FILE"
}

util_remove_first_line() {
  TARGET_FILE="$1"
  tail -n +2 "$TARGET_FILE" > "$TMP_ANY_FILE"
  cat "$TMP_ANY_FILE" > "$TARGET_FILE"
}

util_remove_specific_line() {
  TARGET_FILE="$1"
  TARGET_LINE="$2"
  awk -v INDEX="$TARGET_LINE" 'NR!=INDEX {print $0}' "$TARGET_FILE" > "$TMP_ANY_FILE"
  cat "$TMP_ANY_FILE" > "$TARGET_FILE"
}

util_insert_first_line() {
  TARGET_FILE="$1"
  LINE="$2"
  echo "$LINE" | cat - "$TARGET_FILE" > "$TMP_ANY_FILE"
  cat "$TMP_ANY_FILE" > "$TARGET_FILE"
}

stack_new() {
  if [ "$1" = "" ]; then
    echo "No args"
  else
    util_insert_first_line "$PREFIXED_STACK_FILE" "$*"
    echo "Task '$*' added to stack"
    stack_size
  fi
}

stack_size() {
  grep -c '^' "$PREFIXED_STACK_FILE"
}

stack_pop() {
  if [ "$(stack_size)" = 0 ]; then
    echo "No current task"
  else
    echo "Completed: "
    line=$(head -n 1 "$PREFIXED_STACK_FILE")
    echo "$line"

    util_insert_first_line "$PREFIXED_DONE_FILE" "$(date) - $line"
    util_remove_first_line "$PREFIXED_STACK_FILE"
    now
  fi
}

queue_top() {
  line=$(sed -n "$1"'p' "$PREFIXED_QUEUE_FILE")
  if [ "$line" = "" ]; then
    return
  fi

  util_remove_specific_line "$PREFIXED_QUEUE_FILE" "$1"
  util_insert_first_line "$PREFIXED_QUEUE_FILE" "$line"
  echo "Task '$line' moved to the top of the queue"
}

queue_grep() {
  grep -n "$1" "$PREFIXED_QUEUE_FILE"
}

queue_size() {
  grep -c '^' "$PREFIXED_QUEUE_FILE"
}

queue_new() {
  if [ "$1" = "" ]; then
    echo "No args"
  else
    echo "$*" >> "$PREFIXED_QUEUE_FILE"
    echo "Task '$*' added to queue"
    queue_size
  fi
}

queue() {
  if [ "$1" = "" ]; then
    cat -n "$PREFIXED_QUEUE_FILE"
  else
    func="$1"
    shift
    "queue_$func" "$*"
  fi
}

stack() {
  if [ "$1" = "" ]; then
      cat -n "$PREFIXED_STACK_FILE"
    else
      func="$1"
      shift
      "stack_$func" "$*"
    fi
}

next() {
  if [ "$(queue_size)" = 0 ]; then
    echo "Empty queue"
  else
    LINE=$(head -n 1 "$PREFIXED_QUEUE_FILE") 
    util_insert_first_line "$PREFIXED_STACK_FILE" "$LINE"
    util_remove_first_line "$PREFIXED_QUEUE_FILE"
  fi
}

pop() {
  stack_pop
}

now() {
  if [ "$(stack_size)" = 0 ]; then
    echo "No active task"
  else
    echo "Current task:"
    head -n 1 "$PREFIXED_STACK_FILE"
  fi
}

status() {
  echo "Stack:"
  cat "$PREFIXED_STACK_FILE"
  echo "Queue:"
  cat "$PREFIXED_QUEUE_FILE"
}

#Aliases

new() {
  queue_new "$@"
}

q() {
  queue "$@"
}

s() {
  stack "$@"
}

main() {
  if [ "$1" = "init" ]
  then
  init
  elif [ -d $WN_DIR ] && [ -f $PREFIXED_QUEUE_FILE ] && [ -f $PREFIXED_STACK_FILE ]
  then
    if [ "$1" = "" ]; then
      now #default action
    else
      "$@"
    fi
  else
    echo "Init first"
  fi
}

main "$@"

