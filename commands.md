# Commands / Tips

- find all the specific files then display it
```
bat $(fd tsconfig.json)
```

```
# https://unix.stackexchange.com/questions/292253/how-to-use-cat-command-on-find-commands-output
fd tsconfig.json -x bat {} \;
```

- global find & replace
```
rg --files-with-matches <find> | xargs sd <find> <replace-with>
```

```
rg --files-with-matches "https://auth.xnfts.dev" | xargs sd "https://auth.xnfts.dev" "http://127.0.0.1:8776"
```
