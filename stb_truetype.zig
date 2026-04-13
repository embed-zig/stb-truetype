//! stb_truetype — stb font parsing bindings.
//!
//! Usage:
//!   const stb = @import("stb_truetype");
//!   const font = try stb.Font.init(bytes);

const binding_mod = @import("src/binding.zig");
const types_mod = @import("src/types.zig");

pub const FontInfo = binding_mod.FontInfo;
pub const Font = @import("src/Font.zig");
pub const VMetrics = types_mod.VMetrics;
pub const HMetrics = types_mod.HMetrics;
pub const BitmapBox = types_mod.BitmapBox;

pub const test_runner = struct {
    pub const unit = @import("test_runner/unit.zig");
    pub const integration = @import("test_runner/integration.zig");
};

test "stb_truetype/unit_tests" {
    _ = @import("src/binding.zig");
    _ = @import("src/types.zig");
    _ = @import("src/Font.zig");
}

test "stb_truetype/integration_tests/embed" {
    const lib = @import("embed_std").std;
    const testing = @import("testing");

    var t = testing.T.new(lib, .stb_truetype_integration_embed);
    defer t.deinit();

    t.run("stb_truetype", test_runner.integration.make(lib));
    if (!t.wait()) return error.TestFailed;
}

test "stb_truetype/integration_tests/std" {
    const lib = @import("std");
    const testing = @import("testing");

    var t = testing.T.new(lib, .stb_truetype_integration_std);
    defer t.deinit();

    t.run("stb_truetype", test_runner.integration.make(lib));
    if (!t.wait()) return error.TestFailed;
}
