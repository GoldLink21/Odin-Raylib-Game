package main

import "core:math"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Vector2 :: rl.Vector2
Vector3 :: rl.Vector3
Vector4 :: rl.Vector4

Line :: struct {
    origin, 
    direction: Vector2,
}

Entity :: struct {
    // Center of rect
    pos : Vector2,
    // Rect dimensions
    size : Vector2,
    // Offset from center for rotations
    offset : Vector2,
    // Angle to rotate for
    angleD : f32,
    color : rl.Color,
}

E : Entity = {
    {150,150},
    {40,40},
    {0,0},
    0,
    rl.RED
}

E2 : Entity = {
    {250,250},
    {40,40},
    {0,0},
    0,
    rl.PINK
}

// Rotates a point around an origin by an angle in degrees
rotatePoint :: proc(p:Vector2, origin:Vector2, angleD:f32) -> Vector2 {
    newAngle := angleD * rl.PI / 180
    return Vector2{
        math.cos(newAngle) * (p.x - origin.x) - math.sin(newAngle) * (p.y - origin.y) + origin.x,
        math.sin(newAngle) * (p.x - origin.x) + math.cos(newAngle) * (p.y - origin.y) + origin.y,
    }
}

// Gets the corners of a rect without rotating
rectPointsNoRotate :: proc(pos, size: Vector2) -> [4]Vector2 {
    hs := size/2
    hw := hs.x
    hh := hs.y
    return {
        // Top left
        pos - hs,
        // Top Right
        {pos.x + hs.x, pos.y - hs.y},
        // Bottom Right
        pos + hs,
        // Bottom Left
        {pos.x - hs.x, pos.y + hs.y}
    }
}

// Rotates a rectangle about an offset point
rotateRect :: proc(pos, size, offset: Vector2, angleD : f32) -> [4]Vector2 {
    corners := rectPointsNoRotate(pos, size)
    origin := pos + offset// + size/2
    return {
        rotatePoint(corners[0], origin, angleD),
        rotatePoint(corners[1], origin, angleD),
        rotatePoint(corners[2], origin, angleD),
        rotatePoint(corners[3], origin, angleD),
    }
}

// Gets entity corner positions
getEntCorners :: proc(ent : ^Entity) -> [4]Vector2 {
    return rotateRect(ent.pos, ent.size, ent.offset, ent.angleD)
}


drawEntity :: proc(ent : ^Entity) {
    using rl
    // Draw what they should be

    rl.DrawRectangleV(ent.pos - ent.size/2, ent.size, RAYWHITE)
    // Attempt to draw the new shape after rotation
    pts := rotateRect(ent.pos, ent.size, ent.offset, ent.angleD)
    // Draw actual shape
    DrawTriangle(pts[2], pts[1], pts[0], ent.color)
    DrawTriangle(pts[0], pts[3], pts[2], ent.color)

    // Draw lines around actual location
    for i in 0..<3 {
        rl.DrawLineEx(pts[i], pts[i+1], 2, rl.RAYWHITE)
    }
    rl.DrawLineEx(pts[0], pts[3], 2, rl.RAYWHITE)

    // Draw offset point
    DrawCircleV(ent.pos + ent.offset, 4, PURPLE)
}

// Gets an entities center point after rotation
entityGetCenter :: proc(ent : ^Entity) -> Vector2 {
    return rotatePoint(ent.pos, ent.offset + ent.pos, ent.angleD)
}

// Takes a line and converts to a raylib Ray and draws it
drawLine :: proc(line : Line, color: rl.Color) {
    ray : rl.Ray = {{line.origin.x, line.origin.y, 0}, {line.direction.x, line.direction.y, 0}}
    rl.DrawRay(ray, color)
}