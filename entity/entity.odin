package entity

import "core:math"
import "core:fmt"
import "core:strings"
import "core:sort"
import "core:slice"
import rl "vendor:raylib"

import "../util"


EntityVariants :: union {
    ^Entity, 
    ^Gun, 
    ^Bullet,
}

EntityDeltas :: struct {
    x, y, w, h: f32,
    angleD: f32
}

updateEntityDeltas :: proc(ent:^Entity) {
    ent.pos += {ent.change.x, ent.change.y}
    ent.size += {ent.change.w, ent.change.h}    
    ent.angleD += ent.change.angleD
}

entities : [dynamic]^Entity

// Data stored within the entity data hash table
EntityDataValue :: union {
    string, f32
}

Entity :: struct {
    // Center of rect
    using pos : Vector2,
    // Rect dimensions
    size : Vector2,
    // General speed used for moving
    speed : f32,
    // Offset from center for rotations
    rotateOffset : Vector2,
    // Angle to rotate for
    angleD : f32,
    // The color of the entity
    color : rl.Color,
    // Tells if the entity should be removed in the next game tick
    toRemove : bool,
    // The higher the value, the more it's above others
    drawLayer : i8,
    update : proc(this:^Entity),
    // Pos is updated to be the new center before drawing
    drawProc : proc(this:^Entity),
    // The number of updates the entity has gone through
    ticks : u32,
    // Holds general information that doesn't need to be always immediately accessible
    props : EntityProperties,
    // Stores any extra data for the entity
    data : map[string]EntityDataValue,
    // Entity to follow on movement
    parent : ^Entity,
    // offset from the parent, .x is forward, .y is sideways
    parentOffset : Vector2,
    // Update when needing more entity types
    variant : EntityVariants,
    // Values that change each tick
    change : EntityDeltas,
}

EntityProperties :: struct {
    hidden : bool,
    // Skip updating the entity
    supressUpdate : bool,
    // Updates angle to be the same as the parent every tick
    matchParentAngle : bool,
}



makeEntityProps :: proc() -> EntityProperties {
    return {
        hidden = false,
        supressUpdate = false,
        matchParentAngle = true,
    }
}

// Handles setting up all small things with generic entities
makeEntity :: proc($T: typeid, x, y, width, height:f32, color:rl.Color, update:proc(^Entity)=nil, draw:proc(^Entity)=nil) -> ^T {
    ent := new(T)
    ent.pos = {x, y}
    ent.size = {width, height}
    ent.rotateOffset = {0,0}
    ent.angleD = 0
    ent.color = color
    ent.update = update
    ent.drawProc = draw
    ent.drawLayer = 0

    ent.speed = 0

    ent.props = makeEntityProps()

    ent.data = make(map[string]EntityDataValue)

    ent.parentOffset = {0,0}

    ent.variant = ent

    append(&entities, ent)

    return ent;
}

// Handles removing any allocated data from an entity
cleanEntity :: proc(ent:^Entity) {
    delete(ent.data)
}


drawEntity :: proc(ent:^Entity) {
    using rl
    // If hidden, then don't draw
    if ent.props.hidden do return
    if ent.drawProc != nil {
        oldPos := ent.pos
        ent.pos = entGetCenter(ent)
        ent->drawProc()
        ent.pos = oldPos
    } else {
        pts := util.rotateRect(ent.pos, ent.size, ent.rotateOffset, ent.angleD)
        // Draw actual shape
        DrawTriangle(pts[2], pts[1], pts[0], ent.color)
        DrawTriangle(pts[0], pts[3], pts[2], ent.color)
        
        // Draw lines around actual location
        for i in 0..<3 {
            rl.DrawLineEx(pts[i], pts[i+1], 2, rl.RAYWHITE)
        }
        rl.DrawLineEx(pts[0], pts[3], 2, rl.RAYWHITE)
    }
}

// Debug drawing with guidelines and rotate point
drawEntityWithGuides :: proc(ent : ^Entity) {
    using rl
    // Draw what they should be

    DrawRectangleV(ent.pos - ent.size/2, ent.size, RAYWHITE)
    // Attempt to draw the new shape after rotation
    pts := util.rotateRect(ent.pos, ent.size, ent.rotateOffset, ent.angleD)
    // Draw actual shape
    DrawTriangle(pts[2], pts[1], pts[0], ent.color)
    DrawTriangle(pts[0], pts[3], pts[2], ent.color)

    // Draw lines around actual location
    for i in 0..<3 {
        DrawLineEx(pts[i], pts[i+1], 2, rl.RAYWHITE)
    }
    DrawLineEx(pts[0], pts[3], 2, rl.RAYWHITE)

    // Draw offset point
    DrawCircleV(ent.pos + ent.rotateOffset, 4, PURPLE)
}

drawAllEntities :: proc() {
    for ent in entities do drawEntity(ent)
}

updateAllEntities :: proc() {
    slice.sort_by(entities[:], proc(e1, e2:^Entity) -> bool {
        return e1.drawLayer < e2.drawLayer
    })
    for i := 0; i < len(entities); i += 1 {
        ent := entities[i]
        if ent.toRemove {
            // Removes any allocated data from an entity
            cleanEntity(ent)
            ordered_remove(&entities, i)
            i -= 1
        } else {
            if ent.parent != nil {
                // Go to parent position
                ent.pos = util.movePosAtAngle(util.movePosAtAngle(ent.parent.pos, ent.parent.angleD, ent.parentOffset.x), ent.parent.angleD + 90, ent.parentOffset.y)
                // Spin around same as parent
                ent.rotateOffset = ent.parent.rotateOffset
                // Face the way of the parent
                if ent.props.matchParentAngle do ent.angleD = ent.parent.angleD
            }
            // Use update function if its there
            if ent.update != nil && !ent.props.supressUpdate do ent->update()
            // Change entity by set values
            updateEntityDeltas(ent)
            entities[i].ticks += 1
        }
    }
}