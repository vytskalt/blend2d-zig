const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream_blend2d = b.dependency("blend2d", .{});
    const upstream_asmjit = b.dependency("asmjit", .{});

    const lib = b.addStaticLibrary(.{
        .name = "blend2d",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.linkLibCpp();

    // https://blend2d.com/doc/build-instructions.html

    var flags = std.ArrayList([]const u8).init(b.allocator);
    flags.appendSlice(&.{
        "-DNDEBUG",
        "-fvisibility=hidden",
        "-fno-exceptions",
        "-fno-rtti",
        "-fno-math-errno",
        "-fno-semantic-interposition",
        "-fno-threadsafe-statics",
        "-fmerge-all-constants",
        "-ftree-vectorize",
    }) catch @panic("OOM");

    if (target.result.cpu.arch.isX86()) {
        const x86 = std.Target.x86;

        if (x86.featureSetHas(target.result.cpu.features, .sse2)) {
            flags.append("-DBL_BUILD_OPT_SSE2") catch @panic("OOM");
        }

        if (x86.featureSetHas(target.result.cpu.features, .sse3)) {
            flags.append("-DBL_BUILD_OPT_SSE3") catch @panic("OOM");
        }

        if (x86.featureSetHas(target.result.cpu.features, .ssse3)) {
            flags.append("-DBL_BUILD_OPT_SSSE3") catch @panic("OOM");
        }

        if (x86.featureSetHas(target.result.cpu.features, .sse4_1)) {
            flags.append("-DBL_BUILD_OPT_SSE4_1") catch @panic("OOM");
        }

        if (x86.featureSetHas(target.result.cpu.features, .sse4_2)) {
            flags.append("-DBL_BUILD_OPT_SSE4_2") catch @panic("OOM");
        }

        if (x86.featureSetHas(target.result.cpu.features, .avx)) {
            flags.append("-DBL_BUILD_OPT_AVX") catch @panic("OOM");
        }

        if (x86.featureSetHas(target.result.cpu.features, .avx2)) {
            flags.append("-DBL_BUILD_OPT_AVX2") catch @panic("OOM");
        }

        if (x86.featureSetHasAny(target.result.cpu.features, .{ .avx512f, .avx512bw, .avx512dq, .avx512cd, .avx512vl })) {
            flags.append("-DBL_BUILD_OPT_AVX512") catch @panic("OOM");
        }
    }

    switch (target.result.cpu.arch) {
        .x86, .x86_64, .aarch64 => {
            flags.append("-DASMJIT_STATIC") catch @panic("OOM");
            lib.addCSourceFiles(.{
                .root = upstream_asmjit.path("src/asmjit"),
                .files = &.{
                    "arm/a64assembler.cpp",
                    "arm/a64builder.cpp",
                    "arm/a64compiler.cpp",
                    "arm/a64emithelper.cpp",
                    "arm/a64formatter.cpp",
                    "arm/a64func.cpp",
                    "arm/a64instapi.cpp",
                    "arm/a64instdb.cpp",
                    "arm/a64operand.cpp",
                    "arm/a64rapass.cpp",
                    "arm/armformatter.cpp",
                    "core/archtraits.cpp",
                    "core/assembler.cpp",
                    "core/builder.cpp",
                    "core/codeholder.cpp",
                    "core/codewriter.cpp",
                    "core/compiler.cpp",
                    "core/constpool.cpp",
                    "core/cpuinfo.cpp",
                    "core/emithelper.cpp",
                    "core/emitter.cpp",
                    "core/emitterutils.cpp",
                    "core/environment.cpp",
                    "core/errorhandler.cpp",
                    "core/formatter.cpp",
                    "core/func.cpp",
                    "core/funcargscontext.cpp",
                    "core/globals.cpp",
                    "core/inst.cpp",
                    "core/instdb.cpp",
                    "core/jitallocator.cpp",
                    "core/jitruntime.cpp",
                    "core/logger.cpp",
                    "core/operand.cpp",
                    "core/osutils.cpp",
                    "core/ralocal.cpp",
                    "core/rapass.cpp",
                    "core/rastack.cpp",
                    "core/string.cpp",
                    "core/support.cpp",
                    "core/target.cpp",
                    "core/type.cpp",
                    "core/virtmem.cpp",
                    "core/zone.cpp",
                    "core/zonehash.cpp",
                    "core/zonelist.cpp",
                    "core/zonestack.cpp",
                    "core/zonetree.cpp",
                    "core/zonevector.cpp",
                    "x86/x86assembler.cpp",
                    "x86/x86builder.cpp",
                    "x86/x86compiler.cpp",
                    "x86/x86emithelper.cpp",
                    "x86/x86formatter.cpp",
                    "x86/x86func.cpp",
                    "x86/x86instapi.cpp",
                    "x86/x86instdb.cpp",
                    "x86/x86operand.cpp",
                    "x86/x86rapass.cpp",
                },
                .flags = flags.items,
            });
            lib.addIncludePath(upstream_asmjit.path("src"));
        },
        else => {
            flags.append("-DBL_BUILD_NO_JIT") catch @panic("OOM");
        },
    }

    lib.addCSourceFiles(.{
        .root = upstream_blend2d.path("src/blend2d"),
        .files = &.{
            "api-globals.cpp",
            "api-nocxx.cpp",
            "array.cpp",
            "array_test.cpp",
            "bitarray.cpp",
            "bitarray_test.cpp",
            "bitset.cpp",
            "bitset_test.cpp",
            "codec/bmpcodec.cpp",
            "codec/jpegcodec.cpp",
            "codec/jpeghuffman.cpp",
            "codec/jpegops.cpp",
            "codec/jpegops_sse2.cpp",
            "codec/pngcodec.cpp",
            "codec/pngops.cpp",
            "codec/pngops_sse2.cpp",
            "codec/qoicodec.cpp",
            "compopinfo.cpp",
            "compression/checksum.cpp",
            "compression/checksum_test.cpp",
            "compression/deflatedecoder.cpp",
            "compression/deflateencoder.cpp",
            "context.cpp",
            "context_test.cpp",
            "filesystem.cpp",
            "font.cpp",
            "font_test.cpp",
            "fontdata.cpp",
            "fontface.cpp",
            "fontfeaturesettings.cpp",
            "fontfeaturesettings_test.cpp",
            "fontmanager.cpp",
            "fonttagdataids.cpp",
            "fonttagdataids_test.cpp",
            "fonttagdatainfo.cpp",
            "fonttagdatainfo_test.cpp",
            "fonttagset.cpp",
            "fontvariationsettings.cpp",
            "fontvariationsettings_test.cpp",
            "format.cpp",
            "geometry.cpp",
            "glyphbuffer.cpp",
            "gradient.cpp",
            "gradient_test.cpp",
            "image.cpp",
            "image_test.cpp",
            "imagecodec.cpp",
            "imagecodec_test.cpp",
            "imagedecoder.cpp",
            "imageencoder.cpp",
            "imagescale.cpp",
            "matrix.cpp",
            "matrix_avx.cpp",
            "matrix_sse2.cpp",
            "matrix_test.cpp",
            "object.cpp",
            "opentype/otcff.cpp",
            "opentype/otcff_test.cpp",
            "opentype/otcmap.cpp",
            "opentype/otcore.cpp",
            "opentype/otface.cpp",
            "opentype/otglyf.cpp",
            "opentype/otglyf_asimd.cpp",
            "opentype/otglyf_avx2.cpp",
            "opentype/otglyf_sse4_2.cpp",
            "opentype/otglyfsimddata.cpp",
            "opentype/otkern.cpp",
            "opentype/otlayout.cpp",
            "opentype/otmetrics.cpp",
            "opentype/otname.cpp",
            "path.cpp",
            "path_test.cpp",
            "pathstroke.cpp",
            "pattern.cpp",
            "pipeline/jit/compoppart.cpp",
            "pipeline/jit/fetchgradientpart.cpp",
            "pipeline/jit/fetchpart.cpp",
            "pipeline/jit/fetchpatternpart.cpp",
            "pipeline/jit/fetchpixelptrpart.cpp",
            "pipeline/jit/fetchsolidpart.cpp",
            "pipeline/jit/fetchutilsinlineloops.cpp",
            "pipeline/jit/fetchutilspixelaccess.cpp",
            "pipeline/jit/fetchutilspixelgather.cpp",
            "pipeline/jit/fillpart.cpp",
            "pipeline/jit/pipecompiler_a64.cpp",
            "pipeline/jit/pipecompiler_test.cpp",
            "pipeline/jit/pipecompiler_test_avx2fma.cpp",
            "pipeline/jit/pipecompiler_test_sse2.cpp",
            "pipeline/jit/pipecompiler_x86.cpp",
            "pipeline/jit/pipecomposer.cpp",
            "pipeline/jit/pipefunction.cpp",
            "pipeline/jit/pipegenruntime.cpp",
            "pipeline/jit/pipepart.cpp",
            "pipeline/jit/pipeprimitives.cpp",
            "pipeline/pipedefs.cpp",
            "pipeline/piperuntime.cpp",
            "pipeline/reference/fixedpiperuntime.cpp",
            "pixelconverter.cpp",
            "pixelconverter_avx2.cpp",
            "pixelconverter_sse2.cpp",
            "pixelconverter_ssse3.cpp",
            "pixelconverter_test.cpp",
            "pixelops/funcs.cpp",
            "pixelops/interpolation.cpp",
            "pixelops/interpolation_avx2.cpp",
            "pixelops/interpolation_sse2.cpp",
            "pixelops/scalar_test.cpp",
            "random.cpp",
            "random_test.cpp",
            "raster/analyticrasterizer_test.cpp",
            "raster/rastercontext.cpp",
            "raster/rastercontextops.cpp",
            "raster/renderfetchdata.cpp",
            "raster/rendertargetinfo.cpp",
            "raster/workdata.cpp",
            "raster/workermanager.cpp",
            "raster/workerproc.cpp",
            "raster/workersynchronization.cpp",
            "rgba_test.cpp",
            "runtime.cpp",
            "runtimescope.cpp",
            "simd/simd_test.cpp",
            "simd/simdarm_test_asimd.cpp",
            "simd/simdx86_test_avx.cpp",
            "simd/simdx86_test_avx2.cpp",
            "simd/simdx86_test_avx512.cpp",
            "simd/simdx86_test_sse2.cpp",
            "simd/simdx86_test_sse4_1.cpp",
            "simd/simdx86_test_sse4_2.cpp",
            "simd/simdx86_test_ssse3.cpp",
            "string.cpp",
            "string_test.cpp",
            "support/algorithm_test.cpp",
            "support/arenaallocator.cpp",
            "support/arenabitarray_test.cpp",
            "support/arenahashmap.cpp",
            "support/arenahashmap_test.cpp",
            "support/arenalist_test.cpp",
            "support/arenatree_test.cpp",
            "support/bitops_test.cpp",
            "support/intops_test.cpp",
            "support/math.cpp",
            "support/math_test.cpp",
            "support/memops_test.cpp",
            "support/ptrops_test.cpp",
            "support/scopedallocator.cpp",
            "support/zeroallocator.cpp",
            "support/zeroallocator_test.cpp",
            "tables/tables.cpp",
            "tables/tables_test.cpp",
            "threading/futex.cpp",
            "threading/thread.cpp",
            "threading/threadpool.cpp",
            "threading/threadpool_test.cpp",
            "threading/uniqueidgenerator.cpp",
            "trace.cpp",
            "unicode/unicode.cpp",
            "unicode/unicode_test.cpp",
            "var.cpp",
            "var_test.cpp",
        },
        .flags = flags.items,
    });
    lib.installHeadersDirectory(upstream_blend2d.path("src"), "", .{});

    b.installArtifact(lib);
}
