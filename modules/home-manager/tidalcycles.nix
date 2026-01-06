{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf mkMerge types;
  inherit (lib.lists) optional optionals;
  inherit (lib.strings) concatMapStringsSep;

  cfg = config.programs.tidalcycles;

  # Import custom types and utilities
  tidalTypes = import ../../lib/types.nix {inherit lib;};

  # Import boot and supercollider script builders
  bootScripts = import ../../packages/boot-scripts/default.nix {inherit pkgs lib;};
  scScripts = import ../../packages/supercollider-scripts/default.nix {inherit pkgs lib;};

  # Platform detection
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;

  # SuperCollider package selection based on platform and user preference
  superColliderPackage =
    if cfg.supercollider.package != null
    then cfg.supercollider.package
    else if isDarwin
    then pkgs.supercollider
    else pkgs.supercollider;

  # Generate boot script based on configuration
  bootScript = bootScripts.mkBootScript {
    inherit (cfg.boot) profile;
    inherit (cfg.boot) customScript;
    connection = {
      inherit (cfg.boot.connection) address;
      inherit (cfg.boot.connection) port;
      inherit (cfg.boot.connection) latency;
    };
    inherit (cfg.boot) frameTimespan;
    inherit (cfg.boot) verbose;
    inherit (cfg.boot) orbits;
    inherit (cfg.boot) extraImports;
    inherit (cfg.boot) extraFunctions;
  };

  # Generate SuperDirt start script
  startScript = scScripts.mkStartScript {
    inherit (cfg.superdirt) profile;
    inherit (cfg.superdirt) customScript;
    inherit (cfg.supercollider.serverOptions) numBuffers;
    inherit (cfg.supercollider.serverOptions) memSize;
    inherit (cfg.supercollider.serverOptions) numWireBufs;
    inherit (cfg.supercollider.serverOptions) maxNodes;
    inherit (cfg.supercollider.serverOptions) numOutputBusChannels;
    inherit (cfg.supercollider.serverOptions) numInputBusChannels;
    inherit (cfg.supercollider.serverOptions) sampleRate;
    inherit (cfg.supercollider.serverOptions) blockSize;
    inherit (cfg.boot.connection) port;
    inherit (cfg.boot) orbits;
    inherit (cfg.superdirt) extraSampleDirs;
    inherit (cfg.superdirt) extraConfig;
  };

  # Generate SuperDirt installation script
  installScript = scScripts.mkInstallScript {
    inherit (cfg.superdirt) quarks;
  };

  # Helper script to install SuperDirt
  installSuperdirtScript = pkgs.writeShellScriptBin "install-superdirt" ''
    set -euo pipefail

    echo "Installing SuperDirt and required quarks..."
    echo "This may take several minutes on first run."
    echo ""

    ${superColliderPackage}/bin/sclang ${installScript}

    echo ""
    echo "SuperDirt installation complete!"
    echo "You can now run 'start-superdirt' to launch SuperDirt."
  '';

  # Helper script to install SC3 plugins (macOS only)
  installSc3PluginsScript = mkIf isDarwin (pkgs.writeShellScriptBin "install-sc3-plugins" ''
    set -euo pipefail

    echo "Installing SC3 Plugins (macOS)..."
    echo "This requires sc3-plugins to be available in your nixpkgs."
    echo ""

    SC_EXTENSIONS="$HOME/Library/Application Support/SuperCollider/Extensions"
    mkdir -p "$SC_EXTENSIONS"

    if [ -d "${pkgs.sc3-plugins or ""}/lib/SuperCollider/plugins" ]; then
      ln -sf "${pkgs.sc3-plugins}/lib/SuperCollider/plugins" "$SC_EXTENSIONS/SC3plugins"
      echo "SC3 Plugins installed successfully!"
    else
      echo "Error: sc3-plugins package not found in nixpkgs"
      exit 1
    fi
  '');

  # Helper script to start SuperDirt
  startSuperdirtScript = pkgs.writeShellScriptBin "start-superdirt" ''
    set -euo pipefail

    echo "Starting SuperDirt..."
    echo "Press Ctrl+C to stop."
    echo ""

    ${superColliderPackage}/bin/sclang ${startScript}
  '';

  # Helper script to start Tidal REPL
  tidalReplScript = pkgs.writeShellScriptBin "tidal-repl" ''
    set -euo pipefail

    # Check if SuperDirt is running
    if ! pgrep -x "sclang" > /dev/null 2>&1; then
      echo "Warning: SuperDirt does not appear to be running."
      echo "Start it with 'start-superdirt' in another terminal."
      echo ""
    fi

    echo "Starting Tidal REPL..."
    echo "Loading boot script from: ${bootScript}"
    echo ""

    # Start GHCi with the boot script
    ${cfg.package}/bin/ghci -ghci-script ${bootScript}
  '';

  # Wrapper script for sclang with proper configuration
  sclangWrapperScript = pkgs.writeShellScriptBin "sclang" ''
    set -euo pipefail

    # Set up SuperCollider environment
    export SC_JACK_DEFAULT_INPUTS="${toString cfg.supercollider.serverOptions.numInputBusChannels}"
    export SC_JACK_DEFAULT_OUTPUTS="${toString cfg.supercollider.serverOptions.numOutputBusChannels}"

    # Execute sclang with all arguments
    exec ${superColliderPackage}/bin/sclang "$@"
  '';

  # Generate MIDI configuration code for boot script
  midiConfig = lib.optionalString (cfg.midi.devices != []) ''
    -- MIDI Configuration
    ${concatMapStringsSep "\n" (device: ''
        tidal <- startStream (defaultConfig {cFrameTimespan = 1/20}) [(superdirtTarget {oLatency = ${toString cfg.boot.connection.latency}, oAddress = "${cfg.boot.connection.address}", oPort = ${toString cfg.boot.connection.port}}), (midiTarget "${device.name}" {oLatency = ${toString device.latency}})]
      '')
      cfg.midi.devices}
  '';

  # Generate OSC configuration code for boot script
  oscConfig = lib.optionalString (cfg.osc.targets != []) ''
    -- OSC Configuration
    ${concatMapStringsSep "\n" (target: ''
        let ${target.name} = pS "ctrl" $ OSC "${target.address}" ${toString target.port}
      '')
      cfg.osc.targets}
  '';

  # Sample pack derivations
  samplePacks = builtins.listToAttrs (map (pack: {
      inherit (pack) name;
      value = pkgs.fetchurl {
        inherit (pack) url;
        inherit (pack) sha256;
      };
    })
    cfg.superdirt.samplePacks);

  # Sample pack installation script
  installSamplePacksScript = mkIf (cfg.superdirt.samplePacks != []) (pkgs.writeShellScriptBin "install-sample-packs" ''
    set -euo pipefail

    SAMPLES_DIR="${config.xdg.dataHome}/SuperCollider/samples-extra"
    mkdir -p "$SAMPLES_DIR"

    echo "Installing sample packs..."
    ${concatMapStringsSep "\n" (pack: ''
        echo "Installing ${pack.name}..."
        if [ -f "${samplePacks.${pack.name}}" ]; then
          tar -xzf "${samplePacks.${pack.name}}" -C "$SAMPLES_DIR"
        else
          echo "Warning: ${pack.name} not found, skipping..."
        fi
      '')
      cfg.superdirt.samplePacks}

    echo ""
    echo "Sample pack installation complete!"
  '');
in {
  options.programs.tidalcycles = {
    enable = mkEnableOption "TidalCycles live coding environment";

    package = mkOption {
      type = types.package;
      default = pkgs.haskellPackages.tidal;
      description = "The TidalCycles package to use.";
    };

    ## Boot Configuration
    boot = {
      profile = mkOption {
        type = types.enum ["minimal" "standard" "extended" "midi"];
        default = "standard";
        description = ''
          Boot script profile to use.

          - minimal: Basic TidalCycles setup
          - standard: Recommended setup with transitions
          - extended: Additional custom functions
          - midi: MIDI-focused configuration
        '';
      };

      customScript = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to a custom boot script.
          If set, this overrides the profile setting.
        '';
      };

      connection = mkOption {
        type = tidalTypes.connectionType;
        default = {};
        description = "OSC connection settings for SuperDirt.";
      };

      frameTimespan = mkOption {
        type = types.float;
        default = 1.0 / 20.0;
        description = ''
          Frame timespan for Tidal's clock (default: 1/20 seconds).
          Lower values = more precise timing but higher CPU usage.
        '';
      };

      verbose = mkOption {
        type = types.bool;
        default = true;
        description = "Enable verbose logging in TidalCycles.";
      };

      orbits = mkOption {
        type = types.ints.positive;
        default = 12;
        description = "Number of audio orbits (channels) to create.";
      };

      extraImports = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["qualified Data.Map as Map" "Control.Monad"];
        description = "Additional Haskell imports to include in boot script.";
      };

      extraFunctions = mkOption {
        type = types.lines;
        default = "";
        example = ''
          -- Custom function
          myPattern = fast 2 $ sound "bd sd"
        '';
        description = "Additional Haskell code to include in boot script.";
      };
    };

    ## SuperCollider Configuration
    supercollider = {
      enable = mkEnableOption "SuperCollider installation and configuration" // {default = true;};

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = ''
          SuperCollider package to use.
          If null, uses the default package for your platform.
        '';
      };

      serverOptions = {
        numBuffers = mkOption {
          type = types.ints.positive;
          default = 1024 * 256;
          description = "Number of audio buffers.";
        };

        memSize = mkOption {
          type = types.ints.positive;
          default = 8192 * 32;
          description = "Real-time memory size in kilobytes.";
        };

        numWireBufs = mkOption {
          type = types.ints.positive;
          default = 128;
          description = "Number of wire buffers for inter-server communication.";
        };

        maxNodes = mkOption {
          type = types.ints.positive;
          default = 1024 * 32;
          description = "Maximum number of synthesis nodes.";
        };

        numOutputBusChannels = mkOption {
          type = types.ints.positive;
          default = 2;
          description = "Number of output audio channels.";
        };

        numInputBusChannels = mkOption {
          type = types.ints.positive;
          default = 2;
          description = "Number of input audio channels.";
        };

        sampleRate = mkOption {
          type = types.ints.positive;
          default = 48000;
          description = "Audio sample rate in Hz.";
        };

        blockSize = mkOption {
          type = types.ints.positive;
          default = 64;
          description = "Audio buffer block size.";
        };
      };
    };

    ## SuperDirt Configuration
    superdirt = {
      enable = mkEnableOption "SuperDirt installation and configuration" // {default = true;};

      profile = mkOption {
        type = types.enum ["minimal" "standard" "advanced"];
        default = "standard";
        description = ''
          SuperDirt startup script profile.

          - minimal: Basic setup
          - standard: Recommended with extra samples
          - advanced: Performance-tuned with custom routing
        '';
      };

      customScript = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to a custom SuperDirt startup script.
          If set, this overrides the profile setting.
        '';
      };

      quarks = mkOption {
        type = types.listOf types.str;
        default = ["SuperDirt" "Vowel"];
        description = "SuperCollider Quarks to install for SuperDirt.";
      };

      samplePacks = mkOption {
        type = types.listOf tidalTypes.samplePackType;
        default = [];
        example = [
          {
            name = "808";
            url = "https://example.com/808-samples.tar.gz";
            sha256 = "0000000000000000000000000000000000000000000000000000";
          }
        ];
        description = "Additional sample packs to install.";
      };

      extraSampleDirs = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["/path/to/samples"];
        description = "Additional directories containing audio samples.";
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        example = ''
          // Custom SuperDirt configuration
          ~dirt.orbits[0].setGlobalEffects([\\distortion, \\reverb]);
        '';
        description = "Additional SuperCollider code to run after SuperDirt initialization.";
      };
    };

    ## MIDI Configuration
    midi = {
      enable = mkEnableOption "MIDI support in TidalCycles";

      devices = mkOption {
        type = types.listOf tidalTypes.midiDeviceType;
        default = [];
        example = [
          {
            name = "MIDI Fighter";
            channels = 16;
            latency = 0.1;
          }
        ];
        description = "MIDI devices to configure for TidalCycles.";
      };
    };

    ## OSC Configuration
    osc = {
      enable = mkEnableOption "OSC (Open Sound Control) support";

      targets = mkOption {
        type = types.listOf tidalTypes.oscTargetType;
        default = [];
        example = [
          {
            name = "processing";
            address = "127.0.0.1";
            port = 12000;
          }
        ];
        description = "OSC targets to send patterns to.";
      };
    };

    ## Helper Scripts
    helpers = {
      installScripts = mkEnableOption "Install helper scripts for managing TidalCycles" // {default = true;};

      wrapSclang = mkEnableOption "Wrap sclang with environment configuration" // {default = true;};
    };

    ## Editor Integration
    editor = {
      vim = {
        enable = mkEnableOption "Vim/Neovim integration";

        plugin = mkOption {
          type = types.package;
          default = pkgs.vimPlugins.vim-tidal;
          description = "Vim plugin for TidalCycles.";
        };
      };

      emacs = {
        enable = mkEnableOption "Emacs integration";

        package = mkOption {
          type = types.package;
          default = pkgs.emacsPackages.tidal;
          description = "Emacs package for TidalCycles.";
        };
      };

      vscode = {
        enable = mkEnableOption "VS Code integration";
      };
    };

    ## Development Options
    development = {
      enableGhc = mkEnableOption "Install GHC for Haskell development" // {default = true;};

      extraHaskellPackages = mkOption {
        type = types.listOf types.package;
        default = [];
        example = ["haskellPackages.lens" "haskellPackages.vector"];
        description = "Additional Haskell packages to install for development.";
      };

      enableCabal = mkEnableOption "Install Cabal build tool";

      enableStack = mkEnableOption "Install Stack build tool";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Core TidalCycles installation
    {
      home.packages =
        [cfg.package]
        ++ optional cfg.supercollider.enable superColliderPackage
        ++ optional cfg.development.enableGhc pkgs.ghc
        ++ optional cfg.development.enableCabal pkgs.cabal-install
        ++ optional cfg.development.enableStack pkgs.stack
        ++ cfg.development.extraHaskellPackages;
    }

    # Helper scripts
    (mkIf cfg.helpers.installScripts {
      home.packages =
        [
          installSuperdirtScript
          startSuperdirtScript
          tidalReplScript
        ]
        ++ optional (cfg.superdirt.samplePacks != []) installSamplePacksScript
        ++ optional (isDarwin && cfg.supercollider.enable) installSc3PluginsScript;
    })

    # sclang wrapper
    (mkIf (cfg.helpers.wrapSclang && cfg.supercollider.enable) {
      home.packages = [sclangWrapperScript];
    })

    # Boot script installation
    {
      xdg.configFile."tidal/BootTidal.hs" = {
        source = bootScript;
      };
    }

    # SuperDirt startup script installation
    (mkIf cfg.superdirt.enable {
      xdg.configFile."SuperCollider/start-superdirt.scd" = {
        source = startScript;
      };
    })

    # MIDI configuration
    (mkIf (cfg.midi.enable && cfg.midi.devices != []) {
      xdg.configFile."tidal/midi.hs" = {
        text = midiConfig;
      };
    })

    # OSC configuration
    (mkIf (cfg.osc.enable && cfg.osc.targets != []) {
      xdg.configFile."tidal/osc.hs" = {
        text = oscConfig;
      };
    })

    # Vim integration
    (mkIf cfg.editor.vim.enable {
      programs.vim.plugins = optionals (config.programs.vim.enable or false) [cfg.editor.vim.plugin];
      programs.neovim.plugins = optionals (config.programs.neovim.enable or false) [cfg.editor.vim.plugin];
    })

    # Emacs integration
    (mkIf cfg.editor.emacs.enable {
      programs.emacs.extraPackages = optionals (config.programs.emacs.enable or false) (_epkgs: [cfg.editor.emacs.package]);
    })

    # VS Code integration
    (mkIf cfg.editor.vscode.enable {
      programs.vscode.extensions = optionals (config.programs.vscode.enable or false) [
        pkgs.vscode-extensions.tidalcycles.vscode-tidalcycles or null
      ];
    })

    # Platform-specific audio setup (Linux)
    (mkIf (isLinux && cfg.supercollider.enable) {
      home.sessionVariables = {
        # Ensure JACK/ALSA environment is set up
        SC_JACK_DEFAULT_INPUTS = toString cfg.supercollider.serverOptions.numInputBusChannels;
        SC_JACK_DEFAULT_OUTPUTS = toString cfg.supercollider.serverOptions.numOutputBusChannels;
      };
    })

    # Platform-specific audio setup (macOS)
    (mkIf (isDarwin && cfg.supercollider.enable) {
      home.sessionVariables = {
        # macOS CoreAudio settings
        SC_AUDIO_DRIVER = "CoreAudio";
      };
    })

    # Sample directories setup
    (mkIf cfg.superdirt.enable {
      home.activation.createSampleDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${config.xdg.dataHome}/SuperCollider/samples-extra"
        ${lib.optionalString (cfg.superdirt.extraSampleDirs != []) ''
          $DRY_RUN_CMD echo "Additional sample directories configured:"
          ${concatMapStringsSep "\n" (dir: ''
              $DRY_RUN_CMD echo "  - ${dir}"
            '')
            cfg.superdirt.extraSampleDirs}
        ''}
      '';
    })

    # Post-installation message
    {
      home.activation.tidalcyclesInfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ "$VERBOSE" = "1" ]; then
          echo ""
          echo "TidalCycles has been installed!"
          echo ""
          echo "Next steps:"
          ${lib.optionalString cfg.superdirt.enable ''
          echo "  1. Install SuperDirt: run 'install-superdirt'"
        ''}
          ${lib.optionalString (isDarwin && cfg.supercollider.enable) ''
          echo "  2. Install SC3 Plugins (optional): run 'install-sc3-plugins'"
        ''}
          ${lib.optionalString (cfg.superdirt.samplePacks != []) ''
          echo "  3. Install sample packs: run 'install-sample-packs'"
        ''}
          ${lib.optionalString cfg.superdirt.enable ''
          echo "  4. Start SuperDirt: run 'start-superdirt' in one terminal"
        ''}
          echo "  5. Start Tidal REPL: run 'tidal-repl' in another terminal"
          echo ""
          echo "For more information, see: https://tidalcycles.org/"
        fi
      '';
    }
  ]);
}
