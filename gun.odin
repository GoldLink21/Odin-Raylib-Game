package main

import "core:fmt"
import rl "vendor:raylib"

Gun :: struct {
    using entity:Entity,
    gunType : GunTypes,
    // Offset that the bullets can be when shooting
    accuracy:f32,
    // Ticks for how long the bullets will last for
    range: f32,

    maxAmmo : i32,
    // Time before the gun gets fully reloaded
    reloadSpeed: f32,
    // Current full ammo amount
    ammo : i32,
    // Bullets in clip
    clipSize : i32,
    // Bullets in current clip
    clip: i32,
    // Function returns a single bullet from the gun
    bullet : proc(this:^Gun) -> ^Entity,
    state : enum {
        // Can shoot
        Ready,
        // Between two shots
        Delayed,
        // Can not shoot
        Reloading,
        // Cannot shoot for other reasons
        Locked
    }
}

// General shooting styles
GunTypes :: union {
    GunTypeAuto, 
    GunTypeSemiauto,
    GunTypeCharge,
    GunTypeHold,
}

GunTypeAuto :: struct {
    // The number of ticks before the next bullet gets shot
    tickDelay : i32,
    // Current counter for next bullet to be fired
    ticksTillNextShot:i32,
}
GunTypeSemiauto :: struct {
    // Ticks before the next bullet can be shot
    ticksTillNextShot : i32,
}
GunTypeCharge :: struct {
    charge : i32,
    maxCharge : i32,
}
GunTypeHold :: struct {
    
}


gunMove :: proc(ent : ^Entity) {
    using rl
    gun, ok := ent.variant.(^Gun)
    // Prepares bullet
    shoot := proc(gun: ^Gun) -> ^Entity {
        if gun.bullet == nil do return nil
        bullet := gun->bullet()
        bullet.angleD = gun.angleD
        return bullet
    }
    // Only Guns allowed
    if !ok do return
    switch t in &gun.gunType {
        case GunTypeAuto: {
            if t.ticksTillNextShot <= 0 && IsKeyDown(.SPACE) {
                // fmt.printf("SHOOT\n")
                shoot(gun)
                t.ticksTillNextShot = t.tickDelay
            }
            t.ticksTillNextShot = max(0, t.ticksTillNextShot - 1)
        }
        case GunTypeSemiauto: {
            fmt.printf("SemiAuto")
        }
        case GunTypeCharge: {
            fmt.printf("Charge\n")
        }
        case GunTypeHold: {
            fmt.printf("Hold\n")
        }
        case: {
            fmt.printf("???\n")
        }
    }

    // if IsKeyDown(.SPACE) {
    //     delay := gun.data["shootDelay"].(f32) or_else 0
    //     if delay == 0 {
    //         gun.data["shootDelay"] = 1
    //         center := entGetCenter(gun)
    //         if gun.bullet == nil {
    //             fmt.printf("Gun does not have bullet function\n")
    //         } else {
    //             bullet := gun.bullet() // makeBullet(center.x, center.y, 10, 10, BLUE)
    //             bullet.angleD = getAngleDBetween(center, GetMousePosition()) + 
    //                 f32(2 * rand.int31_max(i32(gun.accuracy)))
    //         }
    //     }
    // }
    // // Change shoot delay
    // newVal := gun.data["shootDelay"].(f32) or_else 0
    // gun.data["shootDelay"] = max(0, newVal - 1)
}


makeGun :: proc(parent:^Entity, gunType: GunTypes, width, height: f32, color:rl.Color, bullet: proc(this:^Gun)->^Entity) -> ^Gun {
    gun := makeEntity(Gun, 0, 0, width, height, color, gunMove)
    gun.gunType = gunType
    gun.bullet = bullet
    return gun
}