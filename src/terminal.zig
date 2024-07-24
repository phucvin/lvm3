const std = @import("std");

const linux = std.os.linux;

var og_termios: linux.termios = undefined;

/// Disable canonical and echo terminal input modes.
pub fn disableCanonAndEcho() void {
    // Save the original terminal input settings.
    _ = linux.tcgetattr(linux.STDIN_FILENO, &og_termios);
    // Create a copy of the original settings and update the flags.
    var new_termios = og_termios;
    new_termios.lflag.ICANON = false;
    new_termios.lflag.ECHO = false;
    // Apply the new settings.
    _ = linux.tcsetattr(linux.STDIN_FILENO, linux.TCSA.NOW, &new_termios);
}

/// Restore the original terminal input settings.
pub fn restoreSettings() void {
    _ = linux.tcsetattr(linux.STDIN_FILENO, linux.TCSA.NOW, &og_termios);
}

/// Check whether the standard input has incoming data without blocking.
pub fn inputIsAvailable() bool {
    var fds = [_]linux.pollfd{.{ .fd = linux.STDIN_FILENO, .events = linux.POLL.IN, .revents = 0 }};
    const reported_events = linux.poll(&fds, fds.len, 0);
    return reported_events > 0 and (fds[0].revents & linux.POLL.IN) != 0;
}
