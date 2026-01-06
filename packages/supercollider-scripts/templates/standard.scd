// Standard SuperDirt startup script
// Recommended configuration with proper buffer sizes and extra samples

(
  s.reboot {
    // Server options
    s.options.numBuffers = 1024 * 256;
    s.options.memSize = 8192 * 32;
    s.options.numWireBufs = 128;
    s.options.maxNodes = 1024 * 32;
    s.options.numOutputBusChannels = 2;
    s.options.numInputBusChannels = 2;

    s.waitForBoot {
      // Initialize SuperDirt
      ~dirt = SuperDirt(2, s);

      // Load default samples
      ~dirt.loadSoundFiles;

      // Load additional sample packs from ~/.local/share/SuperCollider/samples-extra
      ~dirt.loadSoundFiles(PathName(Platform.userAppSupportDir +/+ "samples-extra/*").absolutePath);
      "Loaded samples from ~/.local/share/SuperCollider/samples-extra".postln;

      // Start SuperDirt on port 57120 with 12 orbits
      ~dirt.start(57120, 0 ! 12);
      "SuperDirt started with 12 orbits on port 57120".postln;
    };
  };
)
