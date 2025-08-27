from __future__ import annotations

from pathlib import Path
import pytest
from typer.testing import CliRunner
from refactoria.cli import build_app, _main_cmd

runner: CliRunner = CliRunner()
app = build_app()


def test_scans_single_file_branch(tmp_path: Path) -> None:
    p = tmp_path / "one.py"
    p.write_text("def f(a=[]):\n    pass\n")
    result = runner.invoke(app, [str(p)])
    assert result.exit_code == 0
    assert "mutable por defecto" in result.stdout


def test_invalid_path_exits_with_code_2(tmp_path: Path) -> None:
    missing = tmp_path / "missing.py"
    result = runner.invoke(app, [str(missing)])
    assert result.exit_code == 2
    assert "Ruta inválida" in result.stdout


def test_main_cmd_covers_direct_entry(tmp_path: Path, capsys: pytest.CaptureFixture[str]) -> None:
    (tmp_path / "ok.py").write_text("x = None\nif x is None:\n    pass\n")
    _main_cmd(tmp_path)
    out = capsys.readouterr().out
    assert "Sin hallazgos" in out
