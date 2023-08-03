package main

// import "core:fmt"
import "vendor:raylib"

// Camera starts at (0,0)
camera : raylib.Vector2 = {0, 0}

main :: proc() {
    // fmt.printf("Hello\n")
    using raylib
    
    
    screenWidth :: 800
    screenHeight :: 450

    InitWindow(screenWidth, screenHeight, "Testing")

    SetTargetFPS(60)

    for !WindowShouldClose() {
        UpdateAll()
        DrawAll()
    }
    CloseWindow()
}

UpdateAll :: proc() {
    using raylib
    speed : f32 = 5.0
    if IsKeyDown(.W) do E.pos.y -= speed
    if IsKeyDown(.S) do E.pos.y += speed
    if IsKeyDown(.A) do E.pos.x -= speed
    if IsKeyDown(.D) do E.pos.x += speed
    if IsKeyDown(.Q) do E.angleD -= speed
    if IsKeyDown(.E) do E.angleD += speed
    
    if IsKeyDown(.UP) do E.offset.y -= speed
    if IsKeyDown(.DOWN) do E.offset.y += speed
    if IsKeyDown(.LEFT) do E.offset.x -= speed
    if IsKeyDown(.RIGHT) do E.offset.x += speed

    if entitiyCollides(&E, &E2) {
        E.color = GREEN
    } else {
        E.color = RED
    }
}




DrawAll :: proc() {
    using raylib
    BeginDrawing()
    ClearBackground({r=0x18, g=0x18, b=0x18, a=0xFF})
    drawEntity(&E)
    drawEntity(&E2)
    EndDrawing()
}