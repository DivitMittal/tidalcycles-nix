{lib}: let
  inherit (lib) types;
in {
  # Connection configuration type
  connectionType = types.submodule {
    options = {
      address = lib.mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "IP address for OSC connection";
      };

      port = lib.mkOption {
        type = types.port;
        default = 57120;
        description = "Port number for OSC connection";
      };

      latency = lib.mkOption {
        type = types.float;
        default = 0.1;
        description = "Audio latency in seconds";
      };
    };
  };

  # MIDI device type
  midiDeviceType = types.submodule {
    options = {
      name = lib.mkOption {
        type = types.str;
        description = "MIDI device name";
      };

      channels = lib.mkOption {
        type = types.ints.positive;
        default = 16;
        description = "Number of MIDI channels";
      };

      latency = lib.mkOption {
        type = types.float;
        default = 0.1;
        description = "MIDI latency in seconds";
      };
    };
  };

  # OSC target type
  oscTargetType = types.submodule {
    options = {
      name = lib.mkOption {
        type = types.str;
        description = "OSC target name";
      };

      address = lib.mkOption {
        type = types.str;
        description = "OSC target IP address";
      };

      port = lib.mkOption {
        type = types.port;
        description = "OSC target port";
      };
    };
  };

  # Sample pack type
  samplePackType = types.submodule {
    options = {
      name = lib.mkOption {
        type = types.str;
        description = "Sample pack name";
      };

      url = lib.mkOption {
        type = types.str;
        description = "URL to download sample pack from";
      };

      sha256 = lib.mkOption {
        type = types.str;
        description = "SHA256 hash of the sample pack archive";
      };
    };
  };
}
