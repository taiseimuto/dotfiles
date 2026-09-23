## Dependency

```bash
brew install gauche
```

## Collect configuration files

```bash
gosh manage.scm collect
```

## Install configuration files to new environment

```bash
gosh manage.scm install
```

## Managed files

Edit `*dotfiles*` in `manage.scm`. Each entry is `(dotfiles-name source-path tag ...)`.

- Files that don't exist on the source side are skipped (the destination is left untouched).
- Entries tagged `optional` ask `[y/N]` on `install`.
