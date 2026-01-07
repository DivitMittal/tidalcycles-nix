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
    port ? 57120,
    orbits ? 12,
    numBuffers ? 1024 * 256,
    memSize ? 8192 * 32,
    numWireBufs ? 128,
    maxNodes ? 1024 * 32,
    numOutputBusChannels ? 2,
    numInputBusChannels ? 2,
    sampleRate ? 48000,
    blockSize ? 64,
    extraSampleDirs ? [],
    extraConfig ? "",
  }: let
    # Read the profile or custom script
    baseScript =
      if customScript != null
      then builtins.readFile customScript
      else builtins.readFile (./templates + "/${profile}.scd");

    # Generate extra sample directory loading code
    extraSampleDirCode =
      if extraSampleDirs != []
      then
        lib.concatMapStringsSep "\n" (dir: ''
          ~dirt.loadSoundFiles("${dir}");
          "Loaded samples from ${dir}".postln;
        '')
        extraSampleDirs
      else "";

    # Perform string replacements to inject configuration values
    configuredScript = builtins.replaceStrings
      [
        "s.options.numBuffers = 1024 * 256;"
        "s.options.numBuffers = 1024 * 512;"
        "s.options.memSize = 8192 * 32;"
        "s.options.memSize = 8192 * 64;"
        "s.options.numWireBufs = 128;"
        "s.options.numWireBufs = 256;"
        "s.options.maxNodes = 1024 * 32;"
        "s.options.maxNodes = 1024 * 64;"
        "s.options.numOutputBusChannels = 2;"
        "s.options.numOutputBusChannels = 8;"
        "s.options.numInputBusChannels = 2;"
        "s.options.numInputBusChannels = 8;"
        "s.options.sampleRate = 48000;"
        "s.options.blockSize = 64;"
        "~dirt.start(57120, 0 ! 12);"
        "~dirt.start(57120, 0 ! 16);"
        "      \"SuperDirt started with 12 orbits on port 57120\".postln;"
        "      \"SuperDirt started with 16 orbits on port 57120\".postln;"
        "      \"Loaded samples from extra and custom directories\".postln;"
      ]
      [
        "s.options.numBuffers = ${toString numBuffers};"
        "s.options.numBuffers = ${toString numBuffers};"
        "s.options.memSize = ${toString memSize};"
        "s.options.memSize = ${toString memSize};"
        "s.options.numWireBufs = ${toString numWireBufs};"
        "s.options.numWireBufs = ${toString numWireBufs};"
        "s.options.maxNodes = ${toString maxNodes};"
        "s.options.maxNodes = ${toString maxNodes};"
        "s.options.numOutputBusChannels = ${toString numOutputBusChannels};"
        "s.options.numOutputBusChannels = ${toString numOutputBusChannels};"
        "s.options.numInputBusChannels = ${toString numInputBusChannels};"
        "s.options.numInputBusChannels = ${toString numInputBusChannels};"
        "s.options.sampleRate = ${toString sampleRate};"
        "s.options.blockSize = ${toString blockSize};"
        "~dirt.start(${toString port}, 0 ! ${toString orbits});"
        "~dirt.start(${toString port}, 0 ! ${toString orbits});"
        "      \"SuperDirt started with ${toString orbits} orbits on port ${toString port}\".postln;"
        "      \"SuperDirt started with ${toString orbits} orbits on port ${toString port}\".postln;"
        "      \"Loaded samples from extra and custom directories\".postln;\n${extraSampleDirCode}"
      ]
      baseScript;

    # Add extra config before the final closing parenthesis
    finalScript =
      if extraConfig != ""
      then
        # Insert extraConfig before the final closing braces/parens
        lib.strings.replaceStrings
          ["    };\n  };\n)"]
          ["    };\n\n    // Extra configuration\n${extraConfig}\n  };\n)"]
          configuredScript
      else configuredScript;
  in
    pkgs.writeText "start-superdirt.scd" finalScript;

  # Installation script for SuperDirt quarks
  mkInstallScript = {quarks ? ["SuperDirt" "Vowel"]}: let
    quarksList = lib.concatMapStringsSep "\n" (q: "Quarks.install(\"${q}\");") quarks;
  in
    pkgs.writeText "install-superdirt.scd" ''
      ${quarksList}
      0.exit;
    '';
}
