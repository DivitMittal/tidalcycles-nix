-- Minimal TidalCycles Boot Script
-- Provides only the essentials for live coding

:set -XOverloadedStrings
:set prompt ""

import Sound.Tidal.Context

-- Start Tidal with default configuration
tidal <- startTidal (superdirtTarget {oLatency = 0.1, oAddress = "127.0.0.1", oPort = 57120}) (defaultConfig {cVerbose = True, cFrameTimespan = 1/20})

-- Essential stream controls
let p = streamReplace tidal
    hush = streamHush tidal
    d1 = p 1
    d2 = p 2
    d3 = p 3
    d4 = p 4

:set prompt "tidal> "
:set prompt-cont ""
