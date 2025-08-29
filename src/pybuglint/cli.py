from __future__ import annotations

import re
from pathlib import Path

import typer
from rich.console import Console
from rich.table import Table

console = Console()

# Reglas de "casi-bugs" típicos en código generado por IA
RULES: list[tuple[str, str, str]] = [
    (
        "comparación con None usando ==/!=",
        r"==\s*None|!=\s*None",
        "Usa 'is None' o 'is not None'",
    ),
    ("except vacío o bare", r"^\s*except\s*:\s*$", "Captura explícita de excepciones"),
    (
        "mutable por defecto en función",
        r"def\s+\w+\(.*=\s*(\[\]|\{\})",
        "Evita mutables como default",
    ),
    (
        "shadowing de builtins",
        r"\b(list|dict|str|id|type|sum)\s*=",
        "Renombra para no sombrear builtins",
    ),
    ("print residual", r"^\s*print\(", "Quita prints; usa logging"),
]


def scan_text(text: str) -> list[tuple[str, int, str, str]]:
    findings: list[tuple[str, int, str, str]] = []
    lines = text.splitlines()
    compiled = [(name, re.compile(pattern), fix) for name, pattern, fix in RULES]
    for idx, line in enumerate(lines, start=1):
        for name, rx, fix in compiled:
            if rx.search(line):
                findings.append((name, idx, line.rstrip(), fix))
    return findings


def _run_scan(path: Path) -> int:
    if path.is_file() and path.suffix == ".py":
        targets = [path]
    elif path.is_dir():
        targets = [p for p in path.rglob("*.py")]
    else:
        typer.echo("Ruta inválida. Usa archivo .py o directorio.")
        raise typer.Exit(2)

    total = 0
    for file in targets:
        text = file.read_text(encoding="utf-8", errors="ignore")
        findings = scan_text(text)
        if findings:
            table = Table(title=str(file))
            table.add_column("Regla", style="bold")
            table.add_column("Línea", justify="right")
            table.add_column("Fragmento")
            table.add_column("Sugerencia")
            for name, ln, frag, fix in findings:
                table.add_row(name, str(ln), frag[:120], fix)
            console.print(table)
            total += len(findings)

    console.print(
        "[green]Sin hallazgos[/green]"
        if total == 0
        else f"[yellow]{total} hallazgos[/yellow]"
    )
    return 0


# Entry-point binario: `pybuglint <path>`
def _main_cmd(
    path: Path = typer.Argument(..., help="Archivo .py o carpeta a analizar"),
) -> None:
    _run_scan(path)


def main() -> None:  # pragma: no cover
    typer.run(_main_cmd)


# App para tests: `CliRunner().invoke(build_app(), [path])`
def build_app() -> typer.Typer:
    app = typer.Typer(no_args_is_help=True)

    @app.command()
    def scan(path: Path) -> None:
        """Escanea un archivo o carpeta y reporta 'casi-bugs' típicos de código IA."""
        _run_scan(path)

    return app
