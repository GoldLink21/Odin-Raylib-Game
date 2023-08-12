package main

// import "core:fmt"
import rl "vendor:raylib"
import "entity"
import "util"

Entity :: entity.Entity

// Camera starts at (0,0)
camera : rl.Vector2 = {0, 0}

main :: proc() {
    // fmt.printf("Hello\n")
    using rl
    
    screenWidth : i32 = 800
    screenHeight : i32 = 450

    SetConfigFlags({.WINDOW_RESIZABLE})
    InitWindow(screenWidth, screenHeight, "Testing")
    SetTargetFPS(60)

    player.drawLayer = 2
    player.speed = 5
    E2.drawLayer = 1
    playerGun.parent = player
    playerGun.parentOffset = {25, 5}
    playerGun.drawLayer = 3

    for !WindowShouldClose() {
        if IsWindowResized() /* && !IsWindowFullscreen() */ {
            screenWidth = GetScreenWidth()
            screenHeight = GetScreenHeight()
        }
        UpdateAll()
        DrawAll()
    }
    CloseWindow()
}

player := entity.makeEntity(entity.Entity, 150,150,40,40,rl.RED, proc(this:^Entity){
    using rl
    if IsKeyDown(.W) do this.pos.y -= this.speed
    if IsKeyDown(.S) do this.pos.y += this.speed
    if IsKeyDown(.A) do this.pos.x -= this.speed
    if IsKeyDown(.D) do this.pos.x += this.speed
    if IsKeyDown(.Q) do this.angleD -= this.speed
    if IsKeyDown(.E) do this.angleD += this.speed
    if IsKeyDown(.F) do entity.entMoveForward(this, this.speed)
    
    if IsKeyDown(.UP) do this.rotateOffset.y -= this.speed
    if IsKeyDown(.DOWN) do this.rotateOffset.y += this.speed
    if IsKeyDown(.LEFT) do this.rotateOffset.x -= this.speed
    if IsKeyDown(.RIGHT) do this.rotateOffset.x += this.speed

    // Point to mouse
    center := entity.entGetCenter(this)
    this.angleD = util.getAngleDBetween(center.x, center.y, f32(GetMouseX()), f32(GetMouseY()))
})

playerGun := entity.makeGun(player, entity.GunTypeAuto{10, 0}, 30,5, rl.GOLD, proc(this:^entity.Gun) -> ^Entity{
    bullet := entity.makeBullet(this, 5,5,rl.RED)
    return bullet
})

E2 := entity.makeEntity(Entity, 250,250,40,40,rl.PINK)

UpdateAll :: proc() {
    entity.updateAllEntities()
    // Short term changes

}


DrawAll :: proc() {
    using rl
    BeginDrawing()
    ClearBackground({r=0x18, g=0x18, b=0x18, a=0xFF})
    entity.drawAllEntities()
    EndDrawing()
}