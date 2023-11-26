const std = @import("std");
const main = @import("main.zig");

pub const PPMType = enum {
    p3,
    p6,
};

pub fn save(filename: []const u8, ppm_type: PPMType, image: *main.Image, data: [][]u8) !void {
    const file = try std.fs.cwd().createFile(filename, .{ .read = true, .truncate = true });
    defer file.close();

    const header = switch (ppm_type) {
        .p3 => "P3\n",
        .p6 => "P6\n",
    };
    _ = try file.writeAll(header);

    var buf: [6]u8 = undefined;
    const size = try std.fmt.bufPrint(&buf, "{} {}\n", .{ image.width, image.height });
    _ = try file.writeAll(size);
    _ = try file.writeAll("255\n");

    const black = switch (ppm_type) {
        .p3 => "255 255 255\n",
        .p6 => "\xFF\xFF\xFF",
    };
    const white = switch (ppm_type) {
        .p3 => "  0   0   0\n",
        .p6 => "\x00\x00\x00",
    };

    for (0..image.height) |y| {
        for (0..image.width) |x| {
            if (data[y][x] == '.') {
                _ = try file.writeAll(black);
            } else {
                _ = try file.writeAll(white);
            }
        }
    }

    std.debug.print("File written", .{});
}
