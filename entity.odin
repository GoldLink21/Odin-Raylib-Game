package main

import "core:math"
import "core:fmt"
import "core:strings"
import "core:sort"
import "core:slice"
import rl "vendor:raylib"

Vector2 :: rl.Vector2
Vector3 :: rl.Vector3
Vector4 :: rl.Vector4

Line :: struct {
    origin, 
    direction: Vector2,
}

entities : [dynamic]^Entity

EntityDataValue :: union {
    string, f32
}

Entity :: struct {
    // Center of rect
    pos : Vector2,
    // Rect dimensions
    size : Vector2,
    // Offset from center for rotations
    rotateOffset : Vector2,
    // Angle to rotate for
    angleD : f32,
    color : rl.Color,
    toRemove : bool,
    // The higher the value, the more it's above others
    drawLayer : i8,
    update : proc(this:^Entity),
    // Pos is updated to be the new center before drawing
    drawProc : proc(this:^Entity),
    // The number of updates the entity has gone through
    ticks : u32,
    props : EntityProperties,
    // Stores any extra data for the entity
    data : map[string]EntityDataValue
}

EntityProperties :: struct {
    hidden : bool,
    // Skip updating the entity
    supressUpdate : bool,
}



makeEntityProps :: proc() -> EntityProperties {
    return {
        false,
        false,
    }
}

// Handles setting up all small things with generic entities
makeEntity :: proc(x, y, width, height:f32, color:rl.Color, update:proc(^Entity)=nil, draw:proc(^Entity)=nil) -> ^Entity {
    ent := new(Entity)
    ent.pos = {x, y}
    ent.size = {width, height}
    ent.rotateOffset = {0,0}
    ent.angleD = 0
    ent.color = color
    ent.update = update
    ent.drawProc = draw
    ent.drawLayer = 0

    ent.props = makeEntityProps()

    ent.data = make(map[string]EntityDataValue)

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
        pts := rotateRect(ent.pos, ent.size, ent.rotateOffset, ent.angleD)
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
    pts := rotateRect(ent.pos, ent.size, ent.rotateOffset, ent.angleD)
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
        if entities[i].toRemove {
            // Removes any allocated data from an entity
            cleanEntity(entities[i])
            ordered_remove(&entities, i)
            i -= 1
        } else {
            if entities[i].update != nil && !entities[i].props.supressUpdate do entities[i]->update()
            entities[i].ticks += 1
        }
    }
}

// Takes a line and converts to a raylib Ray and draws it
drawLine :: proc(line : Line, color: rl.Color) {
    ray : rl.Ray = {{line.origin.x, line.origin.y, 0}, {line.direction.x, line.direction.y, 0}}
    rl.DrawRay(ray, color)
}