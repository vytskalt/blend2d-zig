const std = @import("std");
const c = @cImport(@cInclude("blend2d.h"));

pub fn main() !void {
    var img: c.BLImageCore = undefined;
    try blErr(c.blImageInitAs(&img, 1080, 1920, c.BL_FORMAT_PRGB32));
    defer _ = c.blImageDestroy(&img);

    var ctx: c.BLContextCore = undefined;
    try blErr(c.blContextInitAs(&ctx, &img, null));
    defer _ = c.blContextDestroy(&ctx);

    try blErr(c.blContextSetFillStyleRgba32(&ctx, 0xFFFFFFFF));
    try blErr(c.blContextFillRectI(&ctx, &c.BLRectI{
        .x = 50,
        .y = 50,
        .w = 500,
        .h = 500,
    }));
    try blErr(c.blContextEnd(&ctx));

    try blErr(c.blImageWriteToFile(&img, "output.png", null));
}

pub fn blErr(err: c.BLResult) !void {
    switch (err) {
        c.BL_SUCCESS => {},
        else => return error.Unknown,
    }
}
