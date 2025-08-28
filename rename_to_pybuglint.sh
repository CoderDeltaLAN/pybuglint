#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Failed at line $LINENO"; exit 1' ERR
export LC_ALL=C.UTF-8

old="pybuglint"
new="pybuglint"

echo "== 1) Renombrar paquete =="
git mv "src/$old" "src/$new"

echo "== 2) Actualizar imports/tests/README/CI/scripts =="
grep -RIl "$old" . | grep -Ev '\.git/|dist/|build/|\.egg-info/|\.venv/|\.png$|\.jpg$' | while read -r f; do
  sed -i "s/\b$old\b/$new/g" "$f"
done

echo "== 3) Ajustes de __init__ =="
cat > "src/$new/__init__.py" <<PY
from __future__ import annotations

__all__: list[str] = ["__version__"]
__version__: str = "0.1.0"
PY

echo "== 4) pyproject.toml =="
python - <<'PY'
from pathlib import Path
import re

p = Path("pyproject.toml")
text = p.read_text(encoding="utf-8")

# nombre proyecto
text = re.sub(r'name\s*=\s*"[Rr]efactoria"', 'name = "pybuglint"', text)

# packages include
text = re.sub(r'packages\s*=\s*\[[^\]]+\]',
              'packages = [{ include = "pybuglint", from = "src" }]', text)

# console-scripts
text = re.sub(r'\[project\.scripts\][\s\S]*?\n(\[|$)',
              '[project.scripts]\npybuglint = "pybuglint.cli:main"\nrefactoria = "pybuglint.cli:main"\n\\1',
              text)

# keywords SEO
if "keywords" not in text:
    text = text.replace('[project]\n', '[project]\nkeywords = ["python","lint","bug","scan","static-analysis","ai"]\n', 1)

p.write_text(text, encoding="utf-8")
print("pyproject.toml actualizado.")
PY

echo "== 5) README y tests =="
[ -f README.md ] && sed -i "s/[Rr]efactoria/pybuglint/g" README.md
sed -i 's/from pybuglint\.cli/from pybuglint.cli/g' tests/*.py
sed -i 's/\brefactoria\b/pybuglint/g' scripts/*.sh || true

echo "== 6) Verificación total =="
bash scripts/verify_release_git_safe.sh

echo "== 7) Git commit/tag =="
git add -A
git commit -m "chore: rename project to pybuglint (keeps pybuglint CLI alias)" || true
git tag -a v0.1.0-rc.2 -m "pybuglint 0.1.0-rc.2 (renamed from pybuglint)" || true

echo "✅ Renombrado completo"
