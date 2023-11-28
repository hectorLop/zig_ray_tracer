const std = @import("std");
const ppm = @import("ppm.zig");

const Point = struct { x: i16, y: i16 };
const Circle = struct {
    center: Point,
    radius: i16,
    fn contains(self: Circle, point: Point) bool {
        const x: i16 = point.x - self.center.x;
        const y: i16 = point.y - self.center.y;

        const result = std.math.pow(i16, x, 2) + std.math.pow(i16, y, 2);
        return result <= std.math.pow(i16, self.radius, 2);
    }
};

fn draw_image(width: usize, height: usize, circle: Circle, allocator: *std.mem.Allocator) ![][]u8 {
    var matrix = try allocator.alloc([]u8, height);
    for (matrix, 0..) |_, index| {
        matrix[index] = try allocator.alloc(u8, width);
    }

    var curr_point: Point = undefined;

    // Optimize cache access by iterating the rows (x) sequentially
    for (0..height) |y| {
        for (0..width) |x| {
            curr_point = Point{ .x = @intCast(x), .y = @intCast(y) };

            if (circle.contains(curr_point)) {
                matrix[y][x] = '.';
            } else {
                matrix[y][x] = 'x';
            }
        }
    }

    return matrix;
}

pub const Image = struct {
    width: usize,
    height: usize,
    circle: Circle,
    data: [][]u8,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    const width: usize = 64;
    const height: usize = 48;
    const circle = Circle{ .center = Point{ .x = 32, .y = 24 }, .radius = 5 };

    var data: [][]u8 = try draw_image(width, height, circle, &allocator);
    var image = Image{ .width = 64, .height = 48, .circle = circle, .data = data };
    defer allocator.free(data);

    try ppm.save("test_save.ppm", ppm.PPMType.p6, image);
}
