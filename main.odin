package main

// import "core:fmt"
import rl "vendor:raylib"

// Camera starts at (0,0)
camera : rl.Vector2 = {0, 0}

main :: proc() {
    // fmt.printf("Hello\n")
    using rl
    
    screenWidth :: 800
    screenHeight :: 450

    InitWindow(screenWidth, screenHeight, "Testing")
    SetConfigFlags({.WINDOW_RESIZABLE})
    SetTargetFPS(60)

    E.drawLayer = 2
    E2.drawLayer = 1

    for !WindowShouldClose() {
        UpdateAll()
        DrawAll()
    }
    CloseWindow()
}

E := makeEntity(150,150,40,40,rl.RED, proc(this:^Entity){
    using rl
    speed : f32 = 5.0
    if IsKeyDown(.W) do this.pos.y -= speed
    if IsKeyDown(.S) do this.pos.y += speed
    if IsKeyDown(.A) do this.pos.x -= speed
    if IsKeyDown(.D) do this.pos.x += speed
    if IsKeyDown(.Q) do this.angleD -= speed
    if IsKeyDown(.E) do this.angleD += speed
    if IsKeyDown(.F) do moveEntForward(this, speed)
    
    if IsKeyDown(.UP) do this.rotateOffset.y -= speed
    if IsKeyDown(.DOWN) do this.rotateOffset.y += speed
    if IsKeyDown(.LEFT) do this.rotateOffset.x -= speed
    if IsKeyDown(.RIGHT) do this.rotateOffset.x += speed
})

E2 := makeEntity(250,250,40,40,rl.PINK)

UpdateAll :: proc() {
    using rl
    updateControls()

    updateAllEntities()

    // Short term changes
    if entitiyCollides(E, E2) {
        E.color = GREEN
    } else {
        E.color = RED
    }
}

updateControls :: proc() {
    using rl
    // speed : f32 = 5.0
    // if IsKeyDown(.W) do E.pos.y -= speed
    // if IsKeyDown(.S) do E.pos.y += speed
    // if IsKeyDown(.A) do E.pos.x -= speed
    // if IsKeyDown(.D) do E.pos.x += speed
    // if IsKeyDown(.Q) do E.angleD -= speed
    // if IsKeyDown(.E) do E.angleD += speed
    
    // if IsKeyDown(.UP) do E.offset.y -= speed
    // if IsKeyDown(.DOWN) do E.offset.y += speed
    // if IsKeyDown(.LEFT) do E.offset.x -= speed
    // if IsKeyDown(.RIGHT) do E.offset.x += speed
}



DrawAll :: proc() {
    using rl
    BeginDrawing()
    ClearBackground({r=0x18, g=0x18, b=0x18, a=0xFF})
    drawAllEntities()
    EndDrawing()
}