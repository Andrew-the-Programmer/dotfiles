from utils2 import config, get_cwd_path, get_home_path, get_system_config_path

register = config.register("xcompose")


@register.links()
def tmux_links():
    cwd = get_cwd_path(__file__)
    return [(cwd / "XCompose", get_home_path() / ".XCompose")]
