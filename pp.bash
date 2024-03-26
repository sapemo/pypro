#!/bin/false
# remember not to set non-local env vars in a source script willy-nilly

create_python_project() {
  (
    echo "Running Python project setup"
    python -m venv .venv
    source .venv/bin/activate
    pip install uv
    unset CONDA_PREFIX
    uv pip install --upgrade pip pre-commit ruff uv
    [ ! -e .git ] && git init && pre-commit install && git add . && git commit -m 'initial commit'
  )
}

cat_main() {
cat <<_EOF
def main():
    pass


if __name__ == "__main__":
    main()
_EOF
}

cat_pre_commit_config_yaml() {
cat <<_EOF
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v2.3.0
    hooks:
    - id: check-yaml
    - id: end-of-file-fixer
    - id: trailing-whitespace
- repo: https://github.com/astral-sh/ruff-pre-commit
  # Ruff version.
  rev: v0.2.2
  hooks:
    # Run the linter.
    - id: ruff
      args: [ --fix ]
    # Run the formatter.
    - id: ruff-format
_EOF
}

generate_default_files() {
  [ ! -e requirements.txt ] && touch requirements.txt
  [ ! -e requirements-dev.txt ] && printf "pip\npre-commit\nruff\nuv\n" >requirements-dev.txt
  [ ! -e .gitignore ] && echo .venv/ >.gitignore
  [ ! -e main.py ] && cat_main >main.py
  [ ! -e .pre-commit-config.yaml ] && cat_pre_commit_config_yaml >.pre-commit-config.yaml
}

load_environment() {
  unset CONDA_PREFIX
  source .venv/bin/activate
  echo "Entered project $(dirname "$PWD") environment; run 'deactivate' to exit."
}

is_venv() {
  return $(python -c 'import sys; print("1" if sys.prefix == sys.base_prefix else "0")')
}

main() {
  is_venv && echo "Project is already active; run 'deactivate' to exit." && return 1
  local target_dir="$1"
  2>/dev/null mkdir "$target_dir" && local is_first_run="true"
  cd "$target_dir" || return 42
  generate_default_files
  [ -v is_first_run ] && create_python_project
  load_environment
}

main $@
