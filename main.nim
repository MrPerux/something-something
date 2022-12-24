## Local imports
import globals
import sdl_wrapper
import drawing
import event_handling
import code_actions

## Library imports
import math
import sdl2
import sdl2/ttf

### Initialize G
addTodoProcedureAndSwitch()

### Initialization and game loop
proc main =
    setScreenDimensions(G.is_screen_maximized)
    G.window_title = "Gebruik de pijltjes"

    ## Setup
    sdlFailIf(not sdl2.init(INIT_VIDEO or INIT_TIMER or INIT_EVENTS)):
        "SDL2 initialization failed"
    defer: sdl2.quit()

    if G.is_screen_maximized:
        G.window = createWindow(
            title = G.window_title,
            x = SDL_WINDOWPOS_CENTERED,
            y = 0,
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

    initTextureAtlasStandardSize()
    
    ## Gameloop variables
    var
        dt: float32

        counter: uint64
        previousCounter: uint64

        frame_counter: cint
        last_frame_times: seq[float32]

    ## Enable text input
    startTextInput() #TODO: It also works without, apostrophe's are a pain to type though.

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
