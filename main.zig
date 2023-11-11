const std = @import("std");

const Point = struct { x: i16, y: i16 };
const Circle = struct { center: Point, radius: i16 };

const Image = struct {
    width: usize,
    height: usize,
    circle: Circle,
    fn draw_image(self: *Image, allocator: *std.mem.Allocator) ![][]u8 {
        var matrix = try allocator.alloc([]u8, self.height);
        for (matrix, 0..) |_, index| {
            matrix[index] = try allocator.alloc(u8, self.width);
        }

        var curr_point: Point = undefined;

        // Optimize cache access by iterating the rows (x) sequentially
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                curr_point = Point{ .x = @intCast(x), .y = @intCast(y) };

                if (is_inside_circle(curr_point, self.circle)) {
                    matrix[y][x] = '.';
                } else {
                    matrix[y][x] = 'x';
                }
            }
        }

        return matrix;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    const circle = Circle{ .center = Point{ .x = 32, .y = 24 }, .radius = 5 };
    var image = Image{ .width = 64, .height = 48, .circle = circle };

    var data: [][]u8 = try image.draw_image(&allocator);
    defer allocator.free(data);

    print_image(&image, data);
}

fn print_image(image: *Image, data: [][]u8) void {
    for (0..image.height) |y| {
        for (0..image.width) |x| {
            std.debug.print("{u}", .{data[y][x]});
        }
        std.debug.print("\n", .{});
    }
}

fn is_inside_circle(point: Point, circle: Circle) bool {
    const x: i16 = point.x - circle.center.x;
    const y: i16 = point.y - circle.center.y;

    const result = std.math.pow(i16, x, 2) + std.math.pow(i16, y, 2);
    return result <= std.math.pow(i16, circle.radius, 2);
}
