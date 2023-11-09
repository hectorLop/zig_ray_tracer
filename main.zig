const std = @import("std");

const Point = struct { x: i16, y: i16 };

pub fn main() void {
    const image = circle_at_origin();

    for (0..48) |x| {
        for (0..64) |y| {
            std.debug.print("{u}", .{image[x][y]});
        }
        std.debug.print("\n", .{});
    }
}

fn circle_at_origin() [48][64]u8 {
    var array: [48][64]u8 = undefined;
    const radius = 5;
    var curr_point: Point = undefined;

    for (0..48) |y| {
        for (0..64) |x| {
            curr_point = Point{ .x = @intCast(x), .y = @intCast(y) };

            if (is_inside_circle(curr_point, radius)) {
                array[y][x] = '.';
            } else {
                array[y][x] = 'x';
            }
        }
    }

    return array;
}

fn is_inside_circle(point: Point, radius: i16) bool {
    const center = Point{ .x = 31, .y = 24 };
    const x: i16 = point.x - center.x;
    const y: i16 = point.y - center.y;

    const result = std.math.pow(i16, x, 2) + std.math.pow(i16, y, 2);
    return result <= std.math.pow(i16, radius, 2);
}
