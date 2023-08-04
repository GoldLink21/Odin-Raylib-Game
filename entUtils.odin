package main

import rl "vendor:raylib"

// Gets entity corner positions
getEntCorners :: proc(ent : ^Entity) -> [4]Vector2 {
    return rotateRect(ent.pos, ent.size, ent.rotateOffset, ent.angleD)
}

// Used as drawProc
entDrawAsOval :: proc(this : ^Entity) {
    rl.DrawEllipse(i32(this.pos.x), i32(this.pos.y), this.size.x/2, this.size.y/2, this.color)
}

// Gets an entities center point after rotation
entGetCenter :: proc(ent : ^Entity) -> Vector2 {
    return rotatePoint(ent.pos, ent.rotateOffset + ent.pos, ent.angleD)
}


entMoveForward :: proc(ent:^Entity, speed:f32) {
    ent.pos = movePosAtAngle(ent.pos, ent.angleD, speed)
}