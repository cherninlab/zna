const std = @import("std");
const os = std.os;
const io = std.io;

pub const Key = enum {
    up,
    down,
    enter,
    escape,
    char,
    unknown,
};

pub const KeyEvent = struct {
    key: Key,
    char: ?u8,
};

var original_termios: os.termios = undefined;

pub fn enableRawMode() !void {
    const stdin = io.getStdIn();
    original_termios = try os.tcgetattr(stdin.handle);
    var raw = original_termios;

    raw.lflag &= ~@as(
        os.tcflag_t,
        os.ECHO | os.ICANON | os.ISIG | os.IEXTEN
    );
    raw.iflag &= ~@as(
        os.tcflag_t,
        os.IXON | os.ICRNL | os.BRKINT | os.INPCK | os.ISTRIP
    );
    raw.oflag &= ~@as(os.tcflag_t, os.OPOST);
    raw.cc[os.V.MIN] = 0;
    raw.cc[os.V.TIME] = 1;

    try os.tcsetattr(stdin.handle, .FLUSH, raw);
}

pub fn disableRawMode() void {
    const stdin = io.getStdIn();
    _ = os.tcsetattr(stdin.handle, .FLUSH, original_termios) catch {};
}

pub fn readKey() !KeyEvent {
    const stdin = std.io.getStdIn();
    var buf: [8]u8 = undefined;
    
    const bytes_read = try stdin.read(&buf);
    if (bytes_read == 0) return KeyEvent{ .key = .unknown, .char = null };

    if (bytes_read >= 3 and buf[0] == 27 and buf[1] == '[') {
        return switch (buf[2]) {
            'A' => KeyEvent{ .key = .up, .char = null },
            'B' => KeyEvent{ .key = .down, .char = null },
            else => KeyEvent{ .key = .unknown, .char = null },
        };
    }

    if (buf[0] == '\r' or buf[0] == '\n') {
        return KeyEvent{ .key = .enter, .char = null };
    }

    if (buf[0] == 27) {
        return KeyEvent{ .key = .escape, .char = null };
    }

    return KeyEvent{ .key = .char, .char = buf[0] };
}
