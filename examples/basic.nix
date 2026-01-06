# Basic TidalCycles configuration example
# This is a minimal working configuration
{
  programs.tidalcycles = {
    enable = true;

    # Uses standard profile by default
    # boot.profile = "standard";

    # Default SuperCollider configuration
    # supercollider.enable = true;

    # Default SuperDirt configuration
    # superdirt.enable = true;

    # Helper scripts enabled by default
    # helpers.installScripts = true;
  };
}
