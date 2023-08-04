package main

import "core:math"

/*
 Most of this is adapted from
 https://stackoverflow.com/questions/62028169/how-to-detect-when-rotated-rectangles-are-colliding-each-other

*/

vectorMagnitude :: proc(v:Vector2) -> f32 {
    return math.sqrt(v.x * v.x + v.y * v.y)
}

entitiyCollides :: proc(e1, e2 : ^Entity) -> bool{
    return isProjectionHit(e1, e2) && isProjectionHit(e2, e1)
}

@(private="file")
isProjectionHit :: proc(rect, onRect:^Entity) -> bool {
    lines := getEntAxis(onRect)
    corners := getEntCorners(rect)

    // isCollide := true
    for line, idx in lines {
        furthers_t :: struct {
            isSet : bool,
            signedDist : f32,
            corner : Vector2,
            projected : Vector2
        }

        furtherMin : furthers_t = {}
        furtherMax : furthers_t = {}
        
        halfRectSize := (idx == 0 ? onRect.size.x : onRect.size.y) / 2
        for corner in corners {
            projected := projectPointOnLine(corner, line)
            CP := projected - entityGetCenter(onRect)
            sign := (CP.x * line.direction.x) + (CP.y * line.direction.y) > 0
            signedDistance := vectorMagnitude(CP) * (sign ? 1 : -1)

            if !furtherMin.isSet || furtherMin.signedDist > signedDistance {
                furtherMin = {true, signedDistance, corner, projected}
            }
            if !furtherMax.isSet || furtherMax.signedDist < signedDistance {
                furtherMax = {true, signedDistance, corner, projected}
            }
        }
        if (!(furtherMin.signedDist < 0 && furtherMax.signedDist > 0
                || math.abs(furtherMin.signedDist) < halfRectSize
                || math.abs(furtherMax.signedDist) < halfRectSize)) {
            return false
        }
    }
    return true
}
@(private="file")
getEntAxis :: proc(ent : ^Entity) -> [2]Line {
    newCenter := rotatePoint(ent.pos, ent.rotateOffset + ent.pos, ent.angleD)
    return {
        {newCenter, rotatePoint({1, 0}, {0,0}, ent.angleD)},
        {newCenter, rotatePoint({0, 1}, {0,0}, ent.angleD)}
    }
}

@(private="file")
projectPointOnLine :: proc(point:Vector2, line:Line) -> Vector2 {
    dotVal := line.direction.x * (point.x - line.origin.x) + line.direction.y * (point.y - line.origin.y)
    return {
        line.origin.x + line.direction.x * dotVal,
        line.origin.y + line.direction.y * dotVal
    }
}
