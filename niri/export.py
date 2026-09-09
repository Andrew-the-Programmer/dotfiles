from utils2 import config, get_cwd_path, get_home_path, get_system_config_path

register = config.register("niri")


@register.links()
def niri_links():
    cwd = get_cwd_path(__file__)
    config = get_system_config_path() / "niri"
    return [
        (cwd / "config.kdl", config / "config.kdl"),
        (cwd / "scripts", config / "scripts"),
        (
            cwd / "omarchy-menu-custom-niri",
            get_home_path() / ".local/share/omarchy/bin/omarchy-menu-custom-niri",
        ),
    ]
