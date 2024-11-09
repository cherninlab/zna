const std = @import("std");
const term = @import("terminal.zig");
const nav = @import("navigator.zig");

pub fn run(navigator: *nav.Navigator) !void {
    while (true) {
        try clearScreen();
        try drawInterface(navigator);

        const key_event = try term.readKey();
        switch (key_event.key) {
            .up => try navigator.moveSelection(-1),
            .down => try navigator.moveSelection(1),
            .enter => try navigator.enterSelected(),
            .escape => break,
            .char => if (key_event.char) |c| {
                if (c == 'q') break;
            },
            .unknown => {},
        }
    }
}

fn clearScreen() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("\x1B[2J\x1B[H");
}

fn drawInterface(navigator: *nav.Navigator) !void {
    const stdout = std.io.getStdOut().writer();
    const entries = navigator.getCurrentEntries();
    const current_path = try navigator.getCurrentPath();

    try stdout.print("\x1B[36m{s}\x1B[0m\n\n", .{current_path});

    for (entries, 0..) |entry, i| {
        const is_selected = i == navigator.selected_index;
        const color = if (entry.kind == .Directory) "\x1B[34m" else "\x1B[0m";
        
        if (is_selected) {
            try stdout.writeAll("\x1B[7m");
        }
        try stdout.print("{s}{s}\x1B[0m\n", .{ color, entry.name });
    }
}
