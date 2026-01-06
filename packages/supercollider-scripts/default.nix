{
  pkgs,
  lib,
  ...
}: {
  # SuperCollider script templates are in ./templates/

  # Helper function to generate SuperDirt start script
  mkStartScript = {
    profile ? "standard",
    customScript ? null,
  }: let
    # Read the profile or custom script
    baseScript =
      if customScript != null
      then builtins.readFile customScript
      else builtins.readFile (./templates + "/${profile}.scd");
    # For custom configurations, we may need more sophisticated replacement
    # For now, use the base script as-is
  in
    pkgs.writeText "start-superdirt.scd" baseScript;

  # Installation script for SuperDirt quarks
  mkInstallScript = {quarks ? ["SuperDirt" "Vowel"]}: let
    quarksList = lib.concatMapStringsSep "\n" (q: "Quarks.install(\"${q}\");") quarks;
  in
    pkgs.writeText "install-superdirt.scd" ''
      ${quarksList}
      0.exit;
    '';
}
