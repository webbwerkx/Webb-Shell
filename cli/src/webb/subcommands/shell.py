import subprocess
from argparse import Namespace

from webb.utils.paths import w_cache_dir


class Command:
    args: Namespace

    def __init__(self, args: Namespace) -> None:
        self.args = args

    def run(self) -> None:
        if self.args.show:
            self.print_ipc()
        elif self.args.log:
            self.print_log()
        elif self.args.kill:
            self.shell("kill")
        elif self.args.message:
            self.message(*self.args.message)
        else:
            args = ["qs", "-c", "webb", "-n"]
            if self.args.log_rules:
                args.extend(["--log-rules", self.args.log_rules])
            if self.args.daemon:
                args.append("-d")
                subprocess.run(args)
            else:
                shell = subprocess.Popen(args, stdout=subprocess.PIPE, universal_newlines=True)
                for line in shell.stdout:
                    if self.filter_log(line):
                        print(line, end="")

    def shell(self, *args: list[str]) -> str:
        return subprocess.check_output(["qs", "-c", "webb", *args], text=True)

    def filter_log(self, line: str) -> bool:
        return f"Cannot open: file://{w_cache_dir}/imagecache/" not in line

    def print_ipc(self) -> None:
        print(self.shell("ipc", "show"), end="")

    def print_log(self) -> None:
        if self.args.log_rules:
            log = self.shell("log", "-r", self.args.log_rules)
        else:
            log = self.shell("log")
        for line in log.splitlines():
            if self.filter_log(line):
                print(line)

    def message(self, *args: list[str]) -> None:
        print(self.shell("ipc", "call", *args), end="")
