import runpy
import sys
from pathlib import Path
import pytest


def test_module_entrypoint_runs(tmp_path: Path) -> None:
    f = tmp_path / "ok.py"
    f.write_text("def ok(a:int,b:int)->int:\n    return a+b\n")
    orig = sys.argv[:]
    sys.argv = ["pybuglint", str(f)]
    try:
        with pytest.raises(SystemExit) as e:
            # Ejecuta como "python -m pybuglint"
            runpy.run_module("pybuglint", run_name="__main__")
        assert e.value.code == 0
    finally:
        sys.argv = orig
