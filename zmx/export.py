import subprocess
from pathlib import Path

from utils2 import config, get_cwd_path

register = config.register("zmx")


@register.install()
def zmx_install():
    _ = subprocess.run(
        "go install github.com/mdsakalu/zmx-session-manager@latest", shell=True
    )


@register.links()
def zsh_links():
    cwd = get_cwd_path(__file__)

    return [
        (cwd / "plugins" / "zmx-picker" / "zp", Path.home() / ".local" / "bin" / "zp"),
        (
            cwd / "plugins" / "zmx-picker" / "zp-select",
            Path.home() / ".local" / "bin" / "zp-select",
        ),
    ]
