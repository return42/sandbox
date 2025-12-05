import typing as t
import subprocess
import os
import pdb

class Shell:

    _sh = None

    @property
    def sh(self):
        if not self._sh:
            self._sh = subprocess.Popen(
                ["/bin/sh"],
                stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                text=True, universal_newlines=True, bufsize=1
            )
        return self._sh

    def exec(self, script: str, exit_on_err: bool=True, verbose: bool=False) -> int:
        """Executes command (script) in the shell and return the exit
        code."""

        if not self.sh:
            return 42

        end_tag = "### exit_code:"

        self.sh.stdin.write("set +e\n")
        self.sh.stdin.write("set +x\n")

        if exit_on_err:
            self.sh.stdin.write("set -e\n")
        if verbose:
            self.sh.stdin.write("set -x\n")

        self.sh.stdin.write(f"{script}\n")
        self.sh.stdin.write(f'printf "{end_tag} $?\\0"\n')
        self.sh.stdin.write(f'printf "{end_tag} $?\\0" >&2\n')
        self.sh.stdin.write(f'echo "{end_tag}')
        self.sh.stdin.flush()

        for out in self.sh.stdout:
            print(f"STD-OUT: {out.strip()}")
        for err in self.sh.stderr:
            print(f"STD-ERR: {err.strip()}")

        XXXXXXXX
        print(f"EXIT-CODE: {exit_code}")
        return exit_code

shell = Shell()
for script in [
    "ls -la . >&2",
    "pwd",
    "ls -la /xxxxx",
    "ls -la .",
]:
    print(f"script: {script}")
    shell.exec(script)
