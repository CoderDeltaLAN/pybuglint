#!/usr/bin/env bash
set -euo pipefail

echo "== Lint & format =="
poetry run ruff check . --fix
poetry run ruff format .
poetry run black .

echo "== Type check =="
poetry run mypy .

echo "== Tests =="
poetry run pytest -q

echo "== Reglas: matriz de verificación =="
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

# none == / !=
cat > "$workdir/none_eq.py" <<'P'
x = None
if x == None:
    pass
P

# bare except
cat > "$workdir/bare_except.py" <<'P'
try:
    1/0
except:
    pass
P

# mutable default
echo 'def f(a=[]): pass' > "$workdir/mutable_default.py"

# shadow builtins
echo 'list = 3' > "$workdir/shadow_builtins.py"

# print residual
echo 'print("debug")' > "$workdir/print_residual.py"

out_rules="$(poetry run pybuglint "$workdir" || true)"
printf "%s\n" "$out_rules"

grep -q "comparación con None" <<<"$out_rules"
grep -q "except vacío o bare" <<<"$out_rules"
grep -q "mutable por defecto" <<<"$out_rules"
grep -q "shadowing de builtins" <<<"$out_rules"
grep -q "print residual" <<<"$out_rules"

echo "== Escaneo limpio =="
okdir="$(mktemp -d)"
echo -e "x=None\nif x is None:\n    pass\n" > "$okdir/ok.py"
out_ok="$(poetry run pybuglint "$okdir")"
printf "%s\n" "$out_ok"
grep -q "Sin hallazgos" <<<"$out_ok"

echo "== Build & wheel smoke =="
poetry build

tmpvenv="$(mktemp -d)"
python -m venv "$tmpvenv/venv"
source "$tmpvenv/venv/bin/activate"
python -m pip install --upgrade pip >/dev/null

wheel="$(ls -1 dist/pybuglint-*.whl | head -n1)"
echo "Instalando wheel: $wheel"
python -m pip install "$wheel" >/dev/null

command -v pybuglint >/dev/null
pybuglint --help

deactivate
rm -rf "$tmpvenv"

echo "✅ SMOKE PASÓ EN VERDE"
