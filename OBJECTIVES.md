# Objectives
If any objective is not met, it should be treated as a bug.

# Portability
- should fully work on Linux and MacOS

# Tracking
- Planned tasks should be stored as a queue in a plain text file
- Active tasks should be stored as a stack in a plain text file
- Track completed tasks

# Quick actions

You should be able to **quickly**:
- check the current task - ('wn' or 'wn now')
- add new items to queue - ('wn new')
- add new items directly to stack ('wn s new')
- move items from queue to stack ('wn next')
- pop items from stack ('wn pop')
- see the stack ('wn s')
- see the next item from stack ('wn s peek')
- see the next item in queue ('wn q peek')

# Actions

You should be able to:
- see the queue ('wn q')
- see the queue and stack ('wn status')
- check stack size ('wn s size')
- check queue size ('wn q size')
- search/browse tasks in queue ('wn q grep ...')
- add task to stack that's not first in the queue ('wn top <index> && wn next')
- move current task back to queue - ('wn later')