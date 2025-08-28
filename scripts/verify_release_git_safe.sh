#!/usr/bin/env bash
poetry install --with dev --no-interaction >/dev/null
set -eEuo pipefail
trap 'echo "❌ Failed at line $LINENO"; exit 1' ERR
export LC_ALL=C.UTF-8

echo "== Lint & Format =="
poetry run ruff check . --fix
poetry run ruff format .
poetry run python -m black .

echo "== Types & Tests =="
poetry run mypy .
poetry run pytest -q

echo "== Smokes =="
bash scripts/smoke_all.sh
bash scripts/smoke_extra.sh

echo "== Build =="
poetry build
python -m venv .venv_chk && source .venv_chk/bin/activate
python -m pip install --upgrade pip >/dev/null
python -m pip install twine >/dev/null
python -m twine check dist/*    # valida metadata/README
deactivate && rm -rf .venv_chk

echo "== Wheel install smoke =="
tmpvenv="$(mktemp -d)"
python -m venv "$tmpvenv/venv"
source "$tmpvenv/venv/bin/activate"
python -m pip install --upgrade pip >/dev/null
wheel="$(ls -1 dist/pybuglint-*.whl | head -n1)"
python -m pip install "$wheel" >/dev/null
pybuglint --help >/dev/null
deactivate && rm -rf "$tmpvenv"

echo "== Repo sanity =="
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git status --porcelain
  test -z "$(git status --porcelain)" || { echo "❌ Hay cambios sin commitear"; exit 2; }
else
  echo "No es un repo Git; omitiendo verificación."
fi

echo "✅ VERIFY OK"
