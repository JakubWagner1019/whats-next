#!/bin/sh

WN_DIR=".wn"
QUEUE_FILE="task-queue.txt"
STACK_FILE="task-stack.txt"
PREFIXED_QUEUE_FILE="$WN_DIR/$QUEUE_FILE"
PREFIXED_STACK_FILE="$WN_DIR/$STACK_FILE"
TMP_QUEUE_FILE="/tmp/$PREFIXED_QUEUE_FILE.tmp"
TMP_STACK_FILE="/tmp/$PREFIXED_STACK_FILE.tmp"

#commands
init() {
  mkdir -p "$WN_DIR"
  touch "$PREFIXED_QUEUE_FILE"
  touch "$PREFIXED_STACK_FILE"
}

stack_new() {
  if [ "$1" = "" ]; then
    echo "No args"
  else
    echo "$*" | cat - "$PREFIXED_STACK_FILE" > "$TMP_STACK_FILE"
    cat "$TMP_STACK_FILE" > "$PREFIXED_STACK_FILE"
    echo "Task '$*' added to stack"
    stack_size
  fi
}

stack_size() {
  grep -c '^' "$PREFIXED_STACK_FILE"
}

stack_pop() {
  if [ $(stack_size) = 0 ]; then
    echo "No current task"
  else
    echo "Popped:"
    head -n 1 "$PREFIXED_STACK_FILE"
    now
  fi
}

queue_top() {
  line=$(sed -n "$1"'p' "$PREFIXED_QUEUE_FILE")
  if [ "$line" = "" ]; then
    return
  fi

  sed -i "$1"'d' "$PREFIXED_QUEUE_FILE"
  echo "$line" | cat - "$PREFIXED_QUEUE_FILE" > "$TMP_QUEUE_FILE"
  cat "$TMP_QUEUE_FILE" > "$PREFIXED_QUEUE_FILE"
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
      "queue_$func" "$*"
    fi
}

next() {
  if [ $(queue_size) = 0 ]; then
    echo "Empty queue"
  else
    head -n 1 "$PREFIXED_QUEUE_FILE" | cat - "$PREFIXED_STACK_FILE" > "$TMP_STACK_FILE"
    cat "$TMP_STACK_FILE" > "$PREFIXED_STACK_FILE"
    sed -i '1d' "$PREFIXED_QUEUE_FILE"
  fi
}

pop() {
  stack_pop
}

now() {
  echo "Current task:"
  head -n 1 "$PREFIXED_STACK_FILE"
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

