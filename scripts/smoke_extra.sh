#!/usr/bin/env bash
set -eEuo pipefail
trap 'echo "❌ Failed at line $LINENO"; exit 1' ERR
export LC_ALL=C.UTF-8

echo "== Extra smoke: edge cases =="

work="$(mktemp -d)"
export work
mkdir -p "$work"/{a/b/c,crlf,huge,latin1}

# a) None equality (LF)
cat > "$work/a/none_eq.py" <<'P'
x=None
if x == None:
    pass
P

# b) Mixed
cat > "$work/a/b/c/mixed.py" <<'P'
try:
    1/0
except:
    pass
list = 3
print("debug")
def g(d={}): pass
x=None
if x == None:
    pass
P

# c) CRLF
printf "x=None\r\nif x == None:\r\n    pass\r\n" > "$work/crlf/none_eq_crlf.py"

# d) Symlink
ln -s "$work/a" "$work/link_to_a"

# e) Huge file
python - <<'PY'
import os
from pathlib import Path
p = Path(os.environ["work"]) / "huge/ok_big.py"
p.write_text("x=None\nif x is None:\n    pass\n" + "a=1\n"*100000, encoding="utf-8")
PY

# f) latin-1
python - <<'PY'
import os
from pathlib import Path
p = Path(os.environ["work"]) / "latin1/latin1_bad.py"
p.write_bytes("print('áéí')\n".encode("latin-1"))
PY

echo "== Run on root =="
out="$(poetry run pybuglint "$work" || true)"
printf "%s\n" "$out"

echo "== Assertions =="
grep -q "except vacío o bare" <<<"$out"
grep -q "shadowing de builtins" <<<"$out"
grep -q "print residual" <<<"$out"
grep -q "mutable por defecto" <<<"$out"
grep -q "comparación con None" <<<"$out"
echo "✔ Rules assertions OK"

echo "== Clean dir should pass =="
clean="$(mktemp -d)"
printf "x=None\nif x is None:\n    pass\n" > "$clean/ok.py"
out2="$(poetry run pybuglint "$clean")"
printf "%s\n" "$out2"
grep -q "Sin hallazgos" <<<"$out2"
echo "✔ Clean scan OK"

echo "== Exit codes =="
# La CLI imprime el mensaje en STDOUT (no STDERR). Capturamos ambos.
if poetry run pybuglint "$work/not-exists" >out_invalid 2>err_invalid; then
  echo "ERROR: esperaba fallo con exit!=0"; exit 1
fi
# Acepta que el mensaje aparezca en stdout (actual) o stderr (si se cambia en el futuro)
grep -q "Ruta inválida" out_invalid || grep -q "Ruta inválida" err_invalid
echo "✔ Invalid path behavior OK"

echo "✅ All extra smokes OK"
