from utils2 import config, get_cwd_path, get_home_path, get_system_config_path

register = config.register("zsh")


@register.links()
def zsh_links():
    cwd = get_cwd_path(__file__)
    config = get_system_config_path() / "zsh"

    return [
        (cwd / "zshenv", get_home_path() / ".zshenv"),
        (cwd / "zshrc", get_home_path() / ".zshrc"),
        (cwd / "zshrc", config / ".zshrc"),
        *[
            (cwd / s, config / s)
            for s in [
                "scripts",
                "source",
                "plugins-config",
                "file-plugins",
                "p10k-configs",
                "plugin-functions.sh",
                "zshrc.sh",
            ]
        ],
    ]
