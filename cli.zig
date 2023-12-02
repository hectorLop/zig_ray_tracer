const ppm = @import("ppm.zig");
const std = @import("std");

const CLIError = error{ InvalidPPMType, UnknownArgument, ErrorParsingFilename, PPMTypeMissing, FilenameMissing };
const Args = struct { ppm_type: ppm.PPMType, filename: []const u8 };

pub fn parse_arguments(allocator: std.mem.Allocator) CLIError!Args {
    var args = std.process.args();
    _ = args.skip();

    var ppm_type: ?ppm.PPMType = null;
    var filename: ?[]const u8 = null;
    var argument_number: u8 = 0;
    while (args.next()) |argument| {
        switch (argument_number) {
            0 => ppm_type = std.meta.stringToEnum(ppm.PPMType, argument) orelse {
                std.debug.print("The PPM type introduced is invalid\n", .{});
                return CLIError.InvalidPPMType;
            },
            1 => filename = parse_filename(allocator, argument) catch {
                std.debug.print("Error parsing the filename\n", .{});
                return CLIError.ErrorParsingFilename;
            },
            else => {
                std.debug.print("Introduced more arguments that needed\n", .{});
                return CLIError.UnknownArgument;
            },
        }
        argument_number += 1;
    }

    if (ppm_type == null) {
        std.debug.print("PPM type is missing\n", .{});
        return CLIError.PPMTypeMissing;
    }
    if (filename == null) {
        std.debug.print("Filename is missing\n", .{});
        return CLIError.FilenameMissing;
    }

    return Args{ .ppm_type = ppm_type.?, .filename = filename.? };
}

fn parse_filename(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    const extension = ".ppm";
    if (std.mem.endsWith(u8, filename, extension)) return try allocator.dupe(u8, filename);

    var new_filename = try allocator.alloc(u8, filename.len + extension.len);
    _ = std.mem.copy(u8, new_filename[0..], filename);
    _ = std.mem.copy(u8, new_filename[filename.len..], extension);
    return new_filename;
}
