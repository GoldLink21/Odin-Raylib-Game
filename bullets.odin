package main

import rl "vendor:raylib"

makeBullet :: proc(x, y, w, h: f32, color: rl.Color) -> ^Entity {
    entity := makeEntity(x, y, w, h, color, bulletUpdate)
    entity.data["speed"] = 15
    entity.data["lifetime"] = 10
    return entity
}

bulletUpdate :: proc(this:^Entity) {
    lifetime := this.data["lifetime"].(f32) or_else 0
    // Kill if alive too lone
    if this.ticks > u32(lifetime) {
        this.toRemove = true
        return
    }

    speed := this.data["speed"].(f32) or_else 0
    entMoveForward(this, speed)
}