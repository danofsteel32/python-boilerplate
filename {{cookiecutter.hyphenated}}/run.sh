#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

PROJECT="{{cookiecutter.underscored}}"
VENVPATH="${VENVPATH:-./venv}"

## Dependencies ##
venv() {
	if [[ -d "${VENVPATH}/bin" ]]; then
		echo "source ${VENVPATH}/bin/activate"
	else
		echo "source ${VENVPATH}/Scripts/activate"
	fi
}

make-venv() {
	python -m venv "${VENVPATH}"
}

reset-venv() {
	rm -rf "${VENVPATH}"
	make-venv
}

wrapped-python() {
	if [[ -d "${VENVPATH}/bin" ]]; then
		"${VENVPATH}"/bin/python "$@"
	else
		"${VENVPATH}"/Scripts/python "$@"
	fi
}

wrapped-pip() {
	wrapped-python -m pip "$@"
}

python-deps() {
	wrapped-pip install --upgrade pip setuptools wheel

	local pip_extras="${1:-}"
	if [[ -z "${pip_extras}" ]]; then
		wrapped-pip install .
	else
		wrapped-pip install ".[${pip_extras}]"
	fi
}

install() {
	if [[ -d "${VENVPATH}" ]]; then
		python-deps "$@"
	else
		make-venv && python-deps "$@"
	fi
}

## UTILS ##
lint() {
	wrapped-python -m ruff check --fix --exit-non-zero-on-fix $PROJECT &&
		wrapped-python -m ruff format $PROJECT
}

test() {
	wrapped-python -m pytest
}

default() {
	wrapped-python -m "${PROJECT}"
}

"${@:-default}"
