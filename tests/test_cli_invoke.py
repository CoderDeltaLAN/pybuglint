from __future__ import annotations

from pathlib import Path
from typer.testing import CliRunner
from pybuglint.cli import build_app

runner: CliRunner = CliRunner()
app = build_app()


def test_cli_main_on_tmp_dir(tmp_path: Path) -> None:
    (tmp_path / "ok.py").write_text("x = None\nif x is None:\n    pass\n")
    result = runner.invoke(app, [str(tmp_path)])
    assert result.exit_code == 0
    assert "Sin hallazgos" in result.stdout


def test_cli_detects_issue(tmp_path: Path) -> None:
    (tmp_path / "bad.py").write_text("def f(a=[]):\n    print(a)\n")
    result = runner.invoke(app, [str(tmp_path)])
    assert result.exit_code == 0
    assert "mutable por defecto" in result.stdout or "print residual" in result.stdout
