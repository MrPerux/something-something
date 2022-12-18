## Local imports
import globals
import sdl_wrapper
import drawing
import event_handling

## Library imports
import os
import math
import sdl2
import sdl2/ttf

### Initialization and game loop
proc main =
    const MONITOR_WIDTH = if existsEnv("WSL_INTEROP"): 2560 else: 1920
    const MONITOR_HEIGHT = if existsEnv("WSL_INTEROP"): 1440 else: 1053

    let maximized_mode = fileExists("runtime/maximized_mode.option")
    if maximized_mode:
        G.width = MONITOR_WIDTH
        G.height = MONITOR_HEIGHT
    else:
        G.width = 600
        G.height = 400
    G.window_title = "Gebruik de pijltjes"

    ## Setup
    sdlFailIf(not sdl2.init(INIT_VIDEO or INIT_TIMER or INIT_EVENTS)):
        "SDL2 initialization failed"
    defer: sdl2.quit()

    if maximized_mode:
        G.window = createWindow(
            title = G.window_title,
            x = SDL_WINDOWPOS_CENTERED,
            y = SDL_WINDOWPOS_CENTERED,
            w = G.width,
            h = G.height,
            flags = SDL_WINDOW_SHOWN or SDL_WINDOW_MAXIMIZED or SDL_WINDOW_BORDERLESS or SDL_WINDOW_RESIZABLE
        )
    else:
        G.window = createWindow(
            title = G.window_title,
            x = SDL_WINDOWPOS_CENTERED,
            y = 0,
            w = G.width,
            h = G.height,
            flags = SDL_WINDOW_SHOWN or SDL_WINDOW_BORDERLESS or SDL_WINDOW_RESIZABLE
        )

    sdlFailIf G.window.isNil: "window could not be created"
    defer: G.window.destroy()

    G.renderer = createRenderer(
        window = G.window,
        index = -1,
        flags = Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture
    )
    sdlFailIf G.renderer.isNil: "renderer could not be created"
    defer: G.renderer.destroy()

    sdlFailIf(not ttfInit()): "SDL_TTF initialization failed"
    defer: ttfQuit()

    
    # Gameloop variables
    var
        dt: float32

        counter: uint64
        previousCounter: uint64

        frame_counter: cint
        last_frame_times: seq[float32]

    ## Game loop
    while G.running:
        ## Time delta calculation
        previousCounter = counter
        counter = getPerformanceCounter()
        dt = (counter - previousCounter).float / getPerformanceFrequency().float

        ## Framerate calculation
        last_frame_times.add(dt)
        if last_frame_times.len > 30:
            last_frame_times.delete(0)
        G.current_fps = last_frame_times.len.toFloat / last_frame_times.sum
        frame_counter += 1

        ## Handle events
        var event = defaultEvent
        while pollEvent(event):
            handleEvent(event)

        ## Draw
        drawScreen()
        
main()
