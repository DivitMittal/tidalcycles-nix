_: {
  flake = {
    # Overlay for custom packages
    overlays.default = final: _prev: {
      tidalcycles-scripts = final.callPackage ./packages {};
    };
  };
}
