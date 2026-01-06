// Advanced SuperDirt startup script
// High-performance configuration with extensive customization

(
  s.reboot {
    // High-performance server options
    s.options.numBuffers = 1024 * 512;
    s.options.memSize = 8192 * 64;
    s.options.numWireBufs = 256;
    s.options.maxNodes = 1024 * 64;
    s.options.numOutputBusChannels = 8;  // For multi-channel setups
    s.options.numInputBusChannels = 8;

    // Audio settings (adjust based on hardware)
    // s.options.device = "Your Audio Interface";
    s.options.sampleRate = 48000;
    s.options.blockSize = 64;
    // s.options.hardwareBufferSize = 128;

    s.waitForBoot {
      // Initialize SuperDirt with more channels
      ~dirt = SuperDirt(2, s);

      // Load default samples
      ~dirt.loadSoundFiles;

      // Load multiple sample directories
      ~dirt.loadSoundFiles(PathName(Platform.userAppSupportDir +/+ "samples-extra/*").absolutePath);
      ~dirt.loadSoundFiles(PathName(Platform.userAppSupportDir +/+ "samples-custom/*").absolutePath);
      "Loaded samples from extra and custom directories".postln;

      // Custom effects can be added here
      // Example: Add a custom reverb
      /*
      ~dirt.addModule('customReverb', { |dirtEvent|
        dirtEvent.sendSynth('customReverb' ++ dirtEvent.numChannels,
          [
            customReverb: ~customReverb,
            out: ~out
          ]
        )
      }, { ~customReverb.notNil });
      */

      // Start SuperDirt on port 57120 with 16 orbits
      ~dirt.start(57120, 0 ! 16);
      "SuperDirt started with 16 orbits on port 57120".postln;

      // MIDI Configuration
      MIDIClient.init;
      ~midiOut = MIDIOut.newByName("Your MIDI Device", "Port 1").latency_(Server.default.latency);
      ~dirt.soundLibrary.addMIDI(\midi, ~midiOut);
      "MIDI initialized".postln;
    };
  };
)
