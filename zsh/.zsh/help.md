# Navigation
* __cd__      - Navigate to home directory
* __cd -[*n*]__ - Navigate to previous or __*n*th__-from-last directory
* __dirs -v__ - Print directory stack


# Command History

## Search
* __hist [*abc*]__ - Print full history or, optionally, filter for __*abc*__
* __shist__      - Interactively search history


## Recall
* __^L__     - Output from previous command
* __!!__     - Previous command
* __!*n*__     - __*n*th__ command
* __![*n*:]*__ - All arguments from previous or __*n*th__ command
* __![*n*:]^__ - First argument from previous or __*n*th__ command
* __![*n*:]$__ - Last argument from previous or __*n*th__ command

Prefix __*n*__ with __-__ to recall the __*n*th__-from-last command
Chain recall commands to create longer commands; e.g. __!51; !! && !-4 !-5:*__


## Modification
* __⎇ S__           - Prepend command with sudo
* __⎇ E__           - Edit current command in default editor
* __fc__            - Edit previous command in default editor
* __:s[g]/*abc*/*def*__ - Suffix any recall command to replace first or, optionally, all occurrences of __*abc*__ with __*def*__
* __^*abc*^*def*[\^:G]__ - Replace first or, optionally, all occurrences of __*abc*__ with __*def*__ in previous command
* __r "*abc*"="*def*"__ - Replace __"*abc*"__ with __"*def*"__ in previous command (caution: performs global substitution)
