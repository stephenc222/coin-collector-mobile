# import basic2d
# import strutils
# import math
# import strfmt
# import streams
# import os

import times
import sdl2
import sdl2.image
import sdl2.ttf

import game_types
import scene_management
from scenes import titleScene

proc newGame(renderer: RendererPtr): Game =
  new result
  result.sceneManager = newGameSceneManager()
  result.renderer = renderer
  # result.font = openFontRW(readRW("DejaVuSans.ttf"), freesrc = 1, 24)
  result.font = openFont("../DejaVuSans.ttf", 24)
  sdlFailIf(result.font.isNil):
    "Failed to load font"
  result.sceneManager.register(titleScene)
  result.sceneManager.enter(titleScene)

proc wasPressed(game:Game, input:Input): bool =
  if game.inputs[input]:
    game.inputPressed[input] = true
    result = false
  else:
    if game.inputPressed[input]:
      game.inputPressed[input] = false
      result = true

proc update(game: Game, tick: int) =
  discard

proc toInput(key: Scancode): Input =
  case key
  of SDL_SCANCODE_A: Input.left
  of SDL_SCANCODE_D: Input.right
  of SDL_SCANCODE_LEFT: Input.left
  of SDL_SCANCODE_RIGHT: Input.right
  of SDL_SCANCODE_SPACE: Input.confirm
  of SDL_SCANCODE_UP: Input.up
  of SDL_SCANCODE_DOWN: Input.down
  of SDL_SCANCODE_Q: Input.quit
  of SDL_SCANCODE_ESCAPE: Input.quit
  of SDL_SCANCODE_BACKSPACE: Input.cancel
  of SDL_SCANCODE_RETURN: Input.confirm
  else: Input.none

proc handleInput(game: Game) =
  var event = defaultEvent
  while pollEvent(event):
    case event.kind
    of QuitEvent: game.inputs[Input.quit] = true
    of KeyDown: game.inputs[event.key.keysym.scancode.toInput] = true
    of KeyUp: game.inputs[event.key.keysym.scancode.toInput] = false
    else: discard

proc render(game: Game, tick: int) =
  game.renderer.clear()

  game.renderer.present()

proc main() =
  sdlFailIf(not sdl2.init(INIT_EVERYTHING)):
    "Failed to initialize SDL2"

  defer:
    sdl2.quit()

  sdlFailIf(not sdl2.setHint("SDL_RENDER_SCALE_QUALITY", "2")):
    "Failed to set linear texture filtering"

  sdlFailIf(image.init(image.IMG_INIT_PNG) != image.IMG_INIT_PNG):
    "Failed to initialize SDL2 Image extension"
  defer:
    image.quit()

  sdlFailIf(ttfInit() == SdlError):
    "Failed to initialize SDL2 TTF extension"
  defer:
    ttfQuit()

  let window = sdl2.createWindow(
    title = "Coin Collector - Desktop Alpha",
    x = SDL_WINDOWPOS_CENTERED,
    y = SDL_WINDOWPOS_CENTERED,
    w = 1280,
    h = 720,
    flags = SDL_WINDOW_SHOWN)
  sdlFailIf(window.isNil):
    "Failed to create window"
  defer:
    window.destroy()

  let renderer = window.createRenderer(
    index = -1,
    flags = sdl2.Renderer_Accelerated or sdl2.Renderer_PresentVsync)
  sdlFailIf(renderer.isNil):
    "Failed to create renderer"
  defer:
    renderer.destroy()

  renderer.setDrawColor(r = 0x30, g = 0x60, b = 0x90)

  # var lmb:bool = false

  var
    game = newGame(renderer)
    startTime = epochTime()
    lastTick = 0

  while not game.inputs[Input.quit]:
    game.handleInput()
    let newTick = int((epochTime() - startTime) * 50)
    for tick in lastTick+1..newTick:
      game.update(tick)
    lastTick = newTick
    game.render(lastTick)

when isMainModule:
  main()

  # var masterEvent: sdl2.Event = sdl2.defaultEvent
  # var isRunning: bool = true
  # while isRunning:
  #   while sdl2.pollEvent(masterEvent):
  #     case masterEvent.kind:
  #       of sdl2.QuitEvent: isRunning = false
  #       of sdl2.KeyDown:
  #         if masterEvent.key.keysym.sym == sdl2.K_ESCAPE:
  #           isRunning = false
  #       else: discard
  #   # grab mouse state
  #   # if LMB is down, print mouse position to console
  #   var mouseX: cint = 0
  #   var mouseY: cint = 0
  #   if sdl2.SDL_BUTTON(sdl2.getMouseState(mouseX, mouseY)) == sdl2.BUTTON_LEFT:
  #     if lmb == false:
  #       lmb = true
  #   else:
  #     if lmb:
  #       lmb = false
  #       stdout.write("mouse clicked at ", $mouseX, ",", $mouseY, char(0xa))

  #   renderer.clear()
  #   renderer.present()
