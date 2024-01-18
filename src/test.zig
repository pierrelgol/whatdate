const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const match = mem.eql;
const expect = std.testing.expect;
const time = std.time;
const date = @import("whatdate.zig");
const impl = @import("implementation.zig").DateImplementation();

test "basic test : total_seconds" {
    const total = date.Date().initTotal();
    const expected = time.timestamp();
    const actual = total.seconds;
    expect(expected == actual) catch |err| {
        print("error {any} expected {d} : actual {d}\n", .{ err, expected, actual });
    };
}

test "basic test : total_minutes" {
    const total = date.Date().initTotal();
    const expected = @divFloor(time.timestamp(), 60);
    const actual = total.minutes;
    expect(expected == actual) catch |err| {
        print("error {any} expected {d} : actual {d}\n", .{ err, expected, actual });
    };
}

test "basic test : total_hours" {
    const total = date.Date().initTotal();
    const expected = @divFloor(time.timestamp(), 3600);
    const actual = total.hours;
    expect(expected == actual) catch |err| {
        print("error {any} expected {d} : actual {d}\n", .{ err, expected, actual });
    };
}

test "basic test : total_days" {
    const total = date.Date().initTotal();
    const expected = @divFloor(time.timestamp(), 86400);
    const actual = total.days;
    expect(expected == actual) catch |err| {
        print("error {any} expected {d} : actual {d}\n", .{ err, expected, actual });
    };
}

test "basic test : total_weeks" {
    const total = date.Date().initTotal();
    const expected = @divFloor(time.timestamp(), 604800);
    const actual = total.weeks;
    expect(expected == actual) catch |err| {
        print("error {any} expected {d} : actual {d}\n", .{ err, expected, actual });
    };
}

test "basic test : total_months" {
    const total = date.Date().initTotal();
    const sec: f64 = @floatFromInt(time.timestamp());
    const magic: f64 = 30.44 * 86400;
    const expected: u64 = @intFromFloat(@divFloor(sec, magic));
    const actual = total.months;
    expect(expected == actual) catch |err| {
        print("error {any} expected {d} : actual {d}\n", .{ err, expected, actual });
    };
}

test "basic test : total_years" {
    const total = date.Date().initTotal();
    const sec: f64 = @floatFromInt(time.timestamp());
    const magic: f64 = 365.25 * 86400;
    const expected: u64 = (@intFromFloat(@divFloor(sec, magic)));
    const actual = total.years;
    expect(expected == actual) catch |err| {
        print("error {any} expected {d} : actual {d}\n", .{ err, expected, actual });
    };
}

test "basic test : current_seconds" {
    const current = date.Date().initCurrent();
    const expected = @mod(time.timestamp(), 60);
    const actual = current.seconds;
    expect(expected == actual) catch |err| {
        print("error {any} expected {d} : actual {d}\n", .{ err, expected, actual });
    };
}

test "basic test : current_minutes" {
    const current = date.Date().initCurrent();
    const expected = @mod(@divFloor(time.timestamp(), 60), 60);
    const actual = current.minutes;
    expect(expected == actual) catch |err| {
        print("error {any} expected {d} : actual {d}\n", .{ err, expected, actual });
    };
}

test "basic test : current_hours" {
    const current = date.Date().initCurrent();
    const expected = @mod(@divFloor(time.timestamp(), 3600), 24);
    const actual = current.hours;
    expect(expected == actual) catch |err| {
        print("error {any} expected {d} : actual {d}\n", .{ err, expected, actual });
    };
}

test "basic test : current_days" {
    const total = date.Date().initTotal();
    const current = date.Date().initCurrent();
    const expected = impl.civilFromDays(@intCast(total.days));
    const actual = current.days;
    try expect(expected.d == actual);
}

test "basic test : current_weeks" {
    const current = date.Date().initCurrent();
    const expected = @mod(@divFloor(time.timestamp(), 604800), 7);
    const actual = current.weeks;
    try expect(expected == actual);
}

test "basic test : current_months" {
    const total = date.Date().initTotal();
    const current = date.Date().initCurrent();
    const expected = impl.civilFromDays(@intCast(total.days));
    const actual = current.months;
    try expect(expected.m == actual);
}

test "basic test : current_years" {
    const total = date.Date().initTotal();
    const current = date.Date().initCurrent();
    const expected = impl.civilFromDays(@intCast(total.days));
    const actual = current.years;
    try expect(@as(u64, @intCast(expected.y)) == actual);
}
