from pybuglint.cli import scan_text


def test_scan_text_detects_none_eq() -> None:
    text = "x = None\nif x == None:\n    print('oops')\n"
    findings = scan_text(text)
    assert any("comparación con None" in f[0] for f in findings)


def test_scan_text_bare_except() -> None:
    text = "try:\n    pass\nexcept:\n    pass\n"
    f = scan_text(text)
    assert any("except vacío o bare" in t[0] for t in f)
