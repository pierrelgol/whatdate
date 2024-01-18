// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   whatdate.zig                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: plgol.perso <pollivie@student.42.fr>       +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/01/17 14:08:16 by plgol.perso       #+#    #+#             //
//   Updated: 2024/01/17 14:08:17 by plgol.perso      ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");
const epoch = std.time.epoch;
const time = std.time;
const print = std.debug.print;
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const impl = @import("implementation.zig").DateImplementation();

/// Implemenation of this paper : chrono-Compatible Low-Level Date Algorithms
/// from : Howard Hinnant
/// http://howardhinnant.github.io/date_algorithms.html#last_day_of_month
/// Date() returns a struct type containing the following fields :
/// seconds: u64,
/// minutes: u64,
/// hours  : u64,
/// days   : u64,
/// weeks  : u64,
/// months : u64,
/// years  : u64,
/// day    : Day,
/// month  : Month,
pub fn Date() type {
    return struct {
        const Self = @This();
        const epoch_year = epoch.epoch_year;

        seconds: u64,
        minutes: u64,
        hours: u64,
        days: u64,
        weeks: u64,
        months: u64,
        years: u64,
        day: Day,
        month: Month,

        /// returns a Date struct with fields all init with the total
        pub fn initTotal() Self {
            return Self{
                .seconds = totalSeconds(),
                .minutes = totalMinutes(),
                .hours = totalHours(),
                .days = totalDays(),
                .weeks = totalWeeks(),
                .months = totalMonths(),
                .years = totalYears(),
                .day = undefined,
                .month = undefined,
            };
        }

        /// returns a Date struct with fields all init with the current
        pub fn initCurrent() Self {
            return Self{
                .seconds = currentSeconds(),
                .minutes = currentMinutes(),
                .hours = currentHours(),
                .days = currentDays(),
                .weeks = currentWeeks(),
                .months = currentMonths(),
                .years = currentYears(),
                .day = undefined,
                .month = undefined,
            };
        }

        /// returns the total amount of seconds
        pub fn totalSeconds() u64 {
            const sec: u64 = @intCast(std.time.timestamp());
            return (sec);
        }

        /// returns the total amount of minutes
        pub fn totalMinutes() u64 {
            return (@divFloor(totalSeconds(), 60));
        }

        /// returns the total amount of hours
        pub fn totalHours() u64 {
            return (@divFloor(totalSeconds(), 3600));
        }

        /// returns the total amount of days
        pub fn totalDays() u64 {
            return (@divFloor(totalSeconds(), 86400));
        }

        /// returns the total amount of weeks
        pub fn totalWeeks() u64 {
            return (@divFloor(totalSeconds(), 604800));
        }

        /// returns the total amount of months
        pub fn totalMonths() u64 {
            const sec: f64 = @floatFromInt(totalSeconds());
            const magic: f64 = 30.44 * 86400;
            return (@intFromFloat(@divFloor(sec, magic)));
        }

        /// returns the total amount of years
        pub fn totalYears() u64 {
            const sec: f64 = @floatFromInt(totalSeconds());
            const magic: f64 = 365.25 * 86400;
            return (@intFromFloat(@divFloor(sec, magic)));
        }

        /// returns the current seconds
        pub fn currentSeconds() u64 {
            return @mod(totalSeconds(), 60);
        }

        /// returns the current minutes
        pub fn currentMinutes() u64 {
            return @mod(@divFloor(totalSeconds(), 60), 60);
        }

        /// returns the current hours
        pub fn currentHours() u64 {
            return @mod(@divFloor(totalSeconds(), 3600), 24);
        }

        /// returns the current day
        pub fn currentDays() u64 {
            const days: i32 = @intCast(totalDays());
            const s = impl.civilFromDays(days);
            return (s.d);
        }

        /// returns the current weeks
        pub fn currentWeeks() u64 {
            return @mod(@divFloor(totalSeconds(), 604800), 7);
        }

        /// returns the current months
        pub fn currentMonths() u64 {
            const days: i32 = @intCast(totalDays());
            const s = impl.civilFromDays(days);
            return (s.m);
        }

        /// return the current years
        pub fn currentYears() u64 {
            const days: i32 = @intCast(totalDays());
            const s = impl.civilFromDays(days);
            return (@intCast(s.y));
        }
    };
}

/// enum(u4) Jan starts at 1
const Month = enum(u4) {
    const Self = @This();

    Jan = 1,
    Feb,
    Mar,
    Apr,
    May,
    Jun,
    Jul,
    Aug,
    Sep,
    Oct,
    Nov,
    Dec,

    /// converts an enum to it's decimal representation
    pub fn toDec(month: Month) u4 {
        return (@intFromEnum(month));
    }

    /// converts a decimal value in range to it's enum representation
    pub fn toEnum(month: u4) error{NotInBound}!Month {
        return if (month < 1 or month > 12)
            error{NotInBound}
        else
            @enumFromInt(month);
    }

    /// from a given Month enum returns the next month
    /// wraps around .Dec => .Jan
    pub fn next(self: Self) Month {
        return switch (self) {
            .Jan => .Feb,
            .Feb => .Mar,
            .Mar => .Apr,
            .Apr => .May,
            .May => .Jun,
            .Jun => .Jul,
            .Jul => .Aug,
            .Aug => .Sep,
            .Sep => .Oct,
            .Oct => .Nov,
            .Nov => .Dec,
            .Dec => .Jan,
        };
    }

    /// from a given Month enum returns the prev month
    /// wraps around .Jan => .Dec
    pub fn prev(self: Self) Month {
        return switch (self) {
            .Feb => .Jan,
            .Mar => .Feb,
            .Apr => .Mar,
            .May => .Apr,
            .Jun => .May,
            .Jul => .Jun,
            .Aug => .Jul,
            .Sep => .Aug,
            .Oct => .Sep,
            .Nov => .Oct,
            .Dec => .Nov,
            .Jan => .Dec,
        };
    }

    /// given an enum value returns it's string representation in lowercase
    pub fn toString(self: Self, allocator: Allocator) ![]const u8 {
        const index = toDec(self) - 1;
        const result = try allocator.alloc(u8, MONTH_STRING[index].len);
        @memcpy(result, MONTH_STRING[index]);
        return result;
    }

    /// given an enum value and a year returns the number of days in current month
    /// { 31, 28, 31 , 30 , 31 , 30 , 31 , 31 , 30 , 31 , 30 , 31 , };
    pub fn daysInMonth(month: Month, year: u16) u8 {
        const index = toDec(month) - 1;

        if (impl.isLeapYear(year) == true and month == .Feb)
            return MONTH_DAYS[index] + 1
        else
            return MONTH_DAYS[index];
    }

    /// given an enum value and a year returns the number of days until current month
    /// { 0 , 31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334, };
    pub fn daysSinceYearStart(month: Month, year: u16) u16 {
        const index = toDec(month) - 1;
        if (impl.isLeapYear(year) and month == .Feb)
            return DAYS_SINCE[index] + 1
        else
            return DAYS_SINCE[index];
    }

    const MONTH_STRING = [_][]const u8{
        "january",   "february", "march",    "april",
        "may",       "june",     "july",     "august",
        "september", "october",  "november", "december",
    };

    const MONTH_DAYS = [_]u8{
        31, 28, 31, 30,
        31, 30, 31, 31,
        30, 31, 30, 31,
    };

    const DAYS_SINCE = [_]u16{
        0,   31,  59,  90,
        120, 151, 181, 212,
        243, 273, 304, 334,
    };
};

/// enum(u4) Monday starts at 1
const Day = enum(u4) {
    const Self = @This();
    Monday = 1,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
    Sunday,

    /// converts an enum to it's decimal representation
    pub fn toDec(day: Day) u4 {
        return (@intFromEnum(day));
    }

    /// converts a decimal value return its enum representation
    pub fn toEnum(day: u4) Day {
        return if (day < 1 or day > 12)
            .Jan
        else
            @enumFromInt(day);
    }

    /// from a given Day enum returns the next day
    /// wraps around .Sunday => .Monday
    pub fn next(self: Self) Day {
        const day = impl.nextWeekday(@intFromEnum(self) - 1);
        return (toEnum(day));
    }

    /// from a given Day enum returns the prev day
    /// wraps around .Monday => .Sunday
    pub fn prev(self: Self) Month {
        const day = impl.prevWeekday(@intFromEnum(self) - 1);
        return (toEnum(day));
    }

    /// converts an enum to it's string representation in lowercase
    pub fn toString(self: Self, allocator: Allocator) ![]const u8 {
        const index = toDec(self) - 1;
        const result = try allocator.alloc(u8, DAY_STRING[index].len);
        @memcpy(result, DAY_STRING[index]);
        return result;
    }

    const DAY_STRING = [_][]const u8{
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday",
    };
};
