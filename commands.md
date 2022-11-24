# Commands / Tips

- find all the specific files then display it
```
bat $(fd tsconfig.json)

# https://unix.stackexchange.com/questions/292253/how-to-use-cat-command-on-find-commands-output
fd tsconfig.json -x bat {} \;
```
