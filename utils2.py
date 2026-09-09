import importlib
import subprocess
from collections.abc import Iterable
from pathlib import Path
from typing import Callable

Pathlike = str | Path


def get_cwd_path(file: str):
    return Path(file).parent.resolve()


def get_home_path():
    return Path.home()


def get_system_config_path():
    return Path.home() / ".config"


def Link(target: Pathlike, link: Pathlike) -> None:
    """refs=[(target, link)]
    ln -sdfn { target } { link }"""

    Path(link).parent.mkdir(parents=True, exist_ok=True)
    _ = subprocess.run(["ln", "-sinT", target, link])


class ConfigRegister:
    name: str
    links_fn: Callable[[], Iterable[tuple[Pathlike, Pathlike]]] | None = None
    install_fn: Callable[[], None] | None = None

    def __init__(self, name: str) -> None:
        self.name = name

    def install(self):
        def decorator(func: Callable[[], None]):
            self.install_fn = func
            return func

        return decorator

    def links(self):
        def decorator(func: Callable[[], Iterable[tuple[Pathlike, Pathlike]]]):
            self.links_fn = func
            return func

        return decorator

    def export(self):
        if self.links_fn is not None:
            for target, link in self.links_fn():
                # print(f"{target} -> {link}")
                Link(target, link)
        if self.install_fn is not None:
            self.install_fn()


class ConfigRegistry:
    def __init__(self):
        self.config_registers: dict[str, ConfigRegister] = {}

    def register(self, name: str):
        register = ConfigRegister(name)
        if name in self.config_registers:
            raise RuntimeError(f"Config for '{name}' is already registered.")
        self.config_registers[name] = register
        return register

    def load_all(self):
        for pkg in [
            item.name
            for item in Path(".").iterdir()
            if item.is_dir() and (item / "export.py").exists()
        ]:
            try:
                _ = importlib.import_module(f"{pkg}.export")
            except ModuleNotFoundError:
                print(f"No export module found for '{pkg}'")

    def export(self, pkg: str) -> None:
        register = self.config_registers.get(pkg)
        if register is None:
            raise RuntimeError(f"Package '{pkg}' did not register itself.")
        register.export()


config = ConfigRegistry()
