# pybuglint

![Python 3.12](https://img.shields.io/badge/python-3.12-blue)
![Lint: Ruff](https://img.shields.io/badge/lint-ruff-46a2f1)
![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)
![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)
[![CI](https://github.com/CoderDeltaLAN/pybuglint/actions/workflows/ci.yml/badge.svg)](https://github.com/CoderDeltaLAN/pybuglint/actions/workflows/ci.yml)
[![Donate](https://img.shields.io/badge/Donate-PayPal-0070ba.svg?logo=paypal)](https://www.paypal.com/donate/?hosted_button_id=YVENCBNCZWVPW)

> **pybuglint** — A modern **Python CLI** tool to detect and report *“almost-bugs”* often found in **AI-generated code**.
> Designed for developers who want **clean, safe and production-ready code**, with zero noise and actionable feedback.

---

## ✨ Features

- 🔍 Scan **files** or **directories** (`.py`).
- 📋 Built-in rules:
  - Equality vs `None` (`== None` → use `is None`).
  - Bare `except:` blocks.
  - Mutable default arguments (`[]`, `{}`).
  - Shadowing Python builtins (`list`, `dict`, `id`, `type`…).
  - Residual `print(...)` statements (use `logging` instead).
- 🎨 Beautiful tabular reports powered by [Rich](https://github.com/Textualize/rich).
- ✅ Fully tested (100% coverage).
- 🐍 Requires **Python 3.12**.

---

## 🚀 Installation

```bash
# Clone the repo
git clone https://github.com/CoderDeltaLAN/pybuglint.git
cd pybuglint

# Install dependencies
poetry install --no-interaction
```

---

## 🛠 Usage

```bash
# Scan a directory
poetry run pybuglint src

# Scan a single file
poetry run pybuglint my_script.py
```

---

## 📋 Example Output

```text
┏━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ Rule                     ┃ Line  ┃ Snippet     ┃ Suggestion                 ┃
┡━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━╇━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
│ Mutable default argument │     1 │ def f(a=[]):│ Avoid mutables as defaults │
│ Residual print statement │     2 │ print(a)    │ Remove prints; use logging │
└──────────────────────────┴───────┴─────────────┴────────────────────────────┘
```

If nothing is found:

```text
No findings
```

---

## 🔧 Development

```bash
# Lint + autofix
poetry run ruff check . --fix
poetry run ruff format .
poetry run black .

# Run tests with coverage
poetry run pytest -q
```

---

## 🤝 Contributing

1. Fork this repo.
2. Create a new branch:
   ```bash
   git checkout -b feat/add-rule
   ```
3. Make sure everything passes (lint + tests):
   ```bash
   poetry run ruff check . --fix
   poetry run black .
   poetry run pytest -q
   ```
4. Commit and push:
   ```bash
   git commit -m "feat: add new detection rule"
   git push origin feat/add-rule
   ```
5. Open a Pull Request 🚀

---

## 📌 Roadmap

- [ ] Configurable rules via YAML.
- [ ] Pre-commit integration.
- [ ] Optional automatic fixes.
- [ ] Publish to PyPI (`pip install pybuglint`).

---

## 🔍 SEO Keywords

AI code analyzer, Python linter, bug detection CLI, refactor AI code, Python static analysis, clean code automation, catch bugs early, developer productivity tools.

---

## 💖 Donations & Sponsorship

Support open-source: your donations keep projects clean, secure, and continuously evolving for the global community.

[![Donate](https://img.shields.io/badge/Donate-PayPal-0070ba.svg?logo=paypal)](https://www.paypal.com/donate/?hosted_button_id=YVENCBNCZWVPW)

---

## 👤 Author

**CoderDeltaLAN (Yosvel)**  
📧 `coderdeltalan.cargo784@8alias.com`  
🐙 [github.com/CoderDeltaLAN](https://github.com/CoderDeltaLAN)

---

## 📄 License

This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for details.


---

# .github/FUNDING.yml

```yaml
custom: ["https://www.paypal.com/donate/?hosted_button_id=YVENCBNCZWVPW"]
```
