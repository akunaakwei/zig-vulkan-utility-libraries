const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(std.builtin.LinkMode, "linkage", "Linkage type for the library") orelse .static;

    const vulkan_utility_libraries_dep = b.dependency("vulkan_utility_libraries", .{});
    const vulkan_headers_dep = b.dependency("vulkan_headers", .{});

    const vulkan_safe_struct_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });
    vulkan_safe_struct_mod.addIncludePath(vulkan_utility_libraries_dep.path("include"));
    vulkan_safe_struct_mod.addIncludePath(vulkan_headers_dep.path("include"));
    vulkan_safe_struct_mod.addCSourceFiles(.{
        .root = vulkan_utility_libraries_dep.path("src/vulkan"),
        .files = &.{
            "vk_safe_struct_core.cpp",
            "vk_safe_struct_ext.cpp",
            "vk_safe_struct_khr.cpp",
            "vk_safe_struct_utils.cpp",
            "vk_safe_struct_vendor.cpp",
            "vk_safe_struct_manual.cpp",
        },
    });

    const vulkan_safe_struct = b.addLibrary(.{
        .name = "VulkanSafeStruct",
        .linkage = linkage,
        .root_module = vulkan_safe_struct_mod,
    });
    vulkan_safe_struct.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/utility/vk_safe_struct.hpp"),
        "vulkan/utility/vk_safe_struct.hpp",
    );
    vulkan_safe_struct.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/utility/vk_safe_struct_utils.hpp"),
        "vulkan/utility/vk_safe_struct_utils.hpp",
    );
    b.installArtifact(vulkan_safe_struct);

    const vulkan_layer_settings_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });
    vulkan_layer_settings_mod.addIncludePath(vulkan_utility_libraries_dep.path("include"));
    vulkan_layer_settings_mod.addIncludePath(vulkan_headers_dep.path("include"));
    vulkan_layer_settings_mod.addCSourceFiles(.{
        .root = vulkan_utility_libraries_dep.path("src/layer"),
        .files = &.{
            "vk_layer_settings.cpp",
            "vk_layer_settings_helper.cpp",
            "layer_settings_manager.cpp",
            "layer_settings_util.cpp",
        },
    });

    const vulkan_layer_settings = b.addLibrary(.{
        .name = "VulkanLayerSettings",
        .linkage = linkage,
        .root_module = vulkan_layer_settings_mod,
    });
    vulkan_layer_settings.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/layer/vk_layer_settings.h"),
        "vulkan/layer/vk_layer_settings.h",
    );
    vulkan_layer_settings.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/layer/vk_layer_settings.hpp"),
        "vulkan/layer/vk_layer_settings.hpp",
    );
    b.installArtifact(vulkan_layer_settings);

    const vulkan_utility_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    // this is a header only library, but to expose an artifact we need atleast a single object file
    // exposing a header makes including all the installed headers easy
    const empty_wf = b.addWriteFile("empty.cc", "");
    const empty = empty_wf.getDirectory().path(b, "empty.cc");
    vulkan_utility_mod.addCSourceFile(.{ .file = empty });

    const vulkan_utility = b.addLibrary(.{
        .name = "VulkanUtility",
        .root_module = vulkan_utility_mod,
    });
    vulkan_utility.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/layer/vk_layer_settings.h"),
        "vulkan/layer/vk_layer_settings.h",
    );

    vulkan_utility.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/vk_enum_string_helper.h"),
        "vulkan/vk_enum_string_helper.h",
    );
    vulkan_utility.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/utility/vk_concurrent_unordered_map.hpp"),
        "vulkan/utility/vk_concurrent_unordered_map.hpp",
    );
    vulkan_utility.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/utility/vk_dispatch_table.h"),
        "vulkan/utility/vk_dispatch_table.h",
    );
    vulkan_utility.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/utility/vk_format_utils.h"),
        "vulkan/utility/vk_format_utils.h",
    );
    vulkan_utility.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/utility/vk_small_containers.hpp"),
        "vulkan/utility/vk_small_containers.hpp",
    );
    vulkan_utility.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/utility/vk_sparse_range_map.hpp"),
        "vulkan/utility/vk_sparse_range_map.hpp",
    );
    vulkan_utility.installHeader(
        vulkan_utility_libraries_dep.path("include/vulkan/utility/vk_struct_helper.hpp"),
        "vulkan/utility/vk_struct_helper.hpp",
    );
    b.installArtifact(vulkan_utility);
}
