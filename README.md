# "What's next"

A minimal, command-line based task tracker that treats distractions as something expected.  
You should be able to switch the context and then come back to whatever you were doing.  
That's why there's not only queue of planned things, but also stack to store the current task and interrupted tasks.  
This solution makes sure that at one point there's clearly one thing that you're working on.

# Usage

### Init project
```
   wn init
```
### Plan new task
```
wn new 'Some task'
```
### Start working on a task (Move task to stack)
```
wn next
```
### Check the current task
```
wn
```
or
```
wn now
```
### Mark task as finished
```
wn pop
```
### Print the whole queue
```
wn queue
```
or
```
wn q
```
### Print the whole stack
```
wn stack
```
or
```
wn s
```