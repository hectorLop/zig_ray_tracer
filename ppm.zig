const std = @import("std");
const main = @import("main.zig");

pub const PPMType = enum {
    p3,
    p6,

    fn get_white_color(self: PPMType) []const u8 {
        return switch (self) {
            .p3 => "  0   0   0\n",
            .p6 => "\x00\x00\x00",
        };
    }

    fn get_black_color(self: PPMType) []const u8 {
        return switch (self) {
            .p3 => "255 255 255\n",
            .p6 => "\xFF\xFF\xFF",
        };
    }
};

pub fn save(filename: []const u8, ppm_type: PPMType, image: main.Image) !void {
    const file = try std.fs.cwd().createFile(filename, .{ .read = true, .truncate = true });
    defer file.close();

    try writeHeader(file, ppm_type, image);

    const black = ppm_type.get_black_color();
    const white = ppm_type.get_white_color();

    for (0..image.height) |y| {
        for (0..image.width) |x| {
            switch (image.data[y][x]) {
                '.' => try file.writeAll(black),
                else => try file.writeAll(white),
            }
        }
    }
}

fn writeHeader(file: std.fs.File, ppm_type: PPMType, image: main.Image) !void {
    const header = switch (ppm_type) {
        .p3 => "P3\n",
        .p6 => "P6\n",
    };
    _ = try file.writeAll(header);

    var buf: [6]u8 = undefined;
    const size = try std.fmt.bufPrint(&buf, "{} {}\n", .{ image.width, image.height });
    _ = try file.writeAll(size);
    _ = try file.writeAll("255\n");
}
