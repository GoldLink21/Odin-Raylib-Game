package main

import "core:fmt"
import "core:math/rand"
import pm "vendor:portmidi"
import rl "vendor:raylib"

Bullet :: struct {
    using entity:Entity,
    // Angle the bullet flies at. Seperate from angleD for drawing reasons
    fireAngleD:f32,
    lifetime:f32,
}

makeBullet :: proc(gun: ^Gun, w, h: f32, color: rl.Color) -> ^Bullet {
    entity := makeEntity(Bullet, gun.pos.x, gun.pos.y, w, h, color, bulletUpdate)
    entity.speed = 15
    entity.lifetime = 15
    entity.fireAngleD = gun.angleD
    entity.change.w = 1
    entity.change.h = 1
    entity.change.angleD = 5
    return entity
}

bulletUpdate :: proc(this:^Entity) {
    bullet, ok := this.variant.(^Bullet)
    if !ok do return 
    // Only bullets past this point
    // Kill if alive too lone
    if this.ticks > u32(bullet.lifetime) {
        this.toRemove = true
        return
    }
    this.pos = movePosAtAngle(this.pos, bullet.fireAngleD, this.speed)
    // entMoveForward(this, this.speed)
}

