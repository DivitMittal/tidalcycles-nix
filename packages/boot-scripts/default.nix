{
  pkgs,
  lib,
  ...
}: {
  # Boot script profiles are in ./profiles/
  # They are referenced by the main module

  # Helper function to generate a boot script
  mkBootScript = {
    profile ? "standard",
    customScript ? null,
    connection ? {},
    frameTimespan ? (1.0 / 20.0),
    verbose ? true,
    orbits ? 12,
    extraImports ? [],
    extraFunctions ? "",
  }: let
    conn =
      {
        address = "127.0.0.1";
        port = 57120;
        latency = 0.1;
      }
      // connection;

    # Read the profile or custom script
    baseScript =
      if customScript != null
      then builtins.readFile customScript
      else builtins.readFile (./profiles + "/${profile}.hs");

    # Replace placeholders in the script
    processedScript =
      builtins.replaceStrings
      [
        "oLatency = 0.1"
        "oAddress = \"127.0.0.1\""
        "oPort = 57120"
        "cVerbose = True"
        "cFrameTimespan = 1/20"
        "0 ! 12"
      ]
      [
        "oLatency = ${toString conn.latency}"
        "oAddress = \"${conn.address}\""
        "oPort = ${toString conn.port}"
        "cVerbose = ${lib.boolToString verbose}"
        "cFrameTimespan = ${toString frameTimespan}"
        "0 ! ${toString orbits}"
      ]
      baseScript;

    # Add extra imports and functions
    extraContent = lib.optionalString (extraImports != [] || extraFunctions != "") ''
      -- Extra imports
      ${lib.concatMapStringsSep "\n" (i: "import ${i}") extraImports}

      -- Extra functions
      ${extraFunctions}
    '';

    finalScript =
      if extraContent != ""
      then processedScript + "\n" + extraContent
      else processedScript;
  in
    pkgs.writeText "BootTidal.hs" finalScript;
}
