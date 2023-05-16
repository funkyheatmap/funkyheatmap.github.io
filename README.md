# funkyheatmap.github.io

## Set up

1. Install quarto, Python and R

2. Set up renv (Python & R environment).

  ```bash
  Rscript -e 'renv::restore()'
  ```

## Preview

Activate virtual environment

```bash
source renv/python/virtualenvs/renv-python-3.11/bin/activate
```

Render preview

```bash
quarto preview
```