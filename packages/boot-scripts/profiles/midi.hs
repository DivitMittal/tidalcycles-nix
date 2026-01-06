-- MIDI-focused TidalCycles Boot Script
-- Optimized for MIDI device control

:set -XOverloadedStrings
:set prompt ""

import Sound.Tidal.Context
import Sound.Tidal.MIDI.Context

-- Start Tidal with configured settings
tidal <- startTidal (superdirtTarget {oLatency = 0.1, oAddress = "127.0.0.1", oPort = 57120}) (defaultConfig {cVerbose = True, cFrameTimespan = 1/20})

-- Initialize MIDI devices (customize based on your setup)
-- devices <- midiDevices
-- m1 <- midiStream devices "Device1" 1 synthController
-- m2 <- midiStream devices "Device2" 1 synthController

-- Stream controls
let p = streamReplace tidal
    hush = streamHush tidal
    list = streamList tidal
    mute = streamMute tidal
    unmute = streamUnmute tidal
    solo = streamSolo tidal
    unsolo = streamUnsolo tidal
    once = streamOnce tidal
    asap = streamOnce tidal
    setcps = asap . cps

-- Pattern streams (audio)
let d1 = p 1
    d2 = p 2
    d3 = p 3
    d4 = p 4
    d5 = p 5
    d6 = p 6

-- MIDI streams (uncomment and configure based on your devices)
-- let m1 = p 7
--     m2 = p 8

-- Common MIDI CC mappings
let cc n = _ccn n
    modwheel = cc 1
    breath = cc 2
    foot = cc 4
    expression = cc 11
    sustain = cc 64
    portamento = cc 65

:set prompt "tidal> "
:set prompt-cont ""
