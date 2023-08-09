package main

import "core:math"

// Rotates a point around an origin by an angle in degrees
rotatePoint :: proc(p:Vector2, origin:Vector2, angleD:f32) -> Vector2 {
    newAngle := angleD * math.PI / 180
    return Vector2{
        math.cos(newAngle) * (p.x - origin.x) - math.sin(newAngle) * (p.y - origin.y) + origin.x,
        math.sin(newAngle) * (p.x - origin.x) + math.cos(newAngle) * (p.y - origin.y) + origin.y,
    }
}

movePosAtAngle :: proc(pos:Vector2, angleD : f32, speed:f32) -> Vector2 {
    return {
        pos.x + math.cos(math.to_radians(angleD)) * speed,
        pos.y + math.sin(math.to_radians(angleD)) * speed
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
rotateRect :: proc(pos, size, rotateOffset: Vector2, angleD : f32) -> [4]Vector2 {
    corners := rectPointsNoRotate(pos, size)
    origin := pos + rotateOffset// + size/2
    return {
        rotatePoint(corners[0], origin, angleD),
        rotatePoint(corners[1], origin, angleD),
        rotatePoint(corners[2], origin, angleD),
        rotatePoint(corners[3], origin, angleD),
    }
}

getAngleDBetweenXY :: proc(x1, y1, x2, y2:f32) -> f32 {
    return math.to_degrees(math.atan2(y2 - y1, x2 - x1)) 
}

getAngleDBetweenV :: proc(p1, p2: Vector2) -> f32 {
    return getAngleDBetweenXY(p1.x, p1.y, p2.x, p2.y)
}

getAngleDBetween :: proc{getAngleDBetweenV, getAngleDBetweenXY}