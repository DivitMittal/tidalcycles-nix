// Minimal SuperDirt startup script
// Basic configuration for getting started quickly

(
  s.reboot {
    s.options.numBuffers = 1024 * 16;
    s.options.memSize = 8192 * 16;
    s.waitForBoot {
      ~dirt = SuperDirt(2, s);
      ~dirt.loadSoundFiles;
      ~dirt.start(57120, 0 ! 4);
      "SuperDirt started with 4 orbits on port 57120".postln;
    };
  };
)
