// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   implementation.zig                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: plgol.perso <pollivie@student.42.fr>       +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/01/18 09:38:14 by plgol.perso       #+#    #+#             //
//   Updated: 2024/01/18 09:38:16 by plgol.perso      ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

// Implemenation of this paper : chrono-Compatible Low-Level Date Algorithms
// from : Howard Hinnant
// http://howardhinnant.github.io/date_algorithms.html#last_day_of_month

pub fn DateImplementation() type {
    return struct {
        /// Returns number of days since civil 1970-01-01.
        /// Negative values indicate days prior to 1970-01-01.
        pub fn daysFromCivil(year: i32, month: i32, day: i32) i32 {
            const y: i32 = if (month <= 2) year - 1 else year;
            const era: i32 = @divTrunc((if (y >= 0) y else y - 399), 400);
            const yoe: u32 = @intCast((y - era * 400));
            const doy: u32 = @intCast(@divTrunc((153 * (if (month > 2) month - 3 else month + 9) + 2), 5) + day - 1);
            const doe: u32 = yoe * 365 + yoe / 4 - yoe / 100 + doy;
            return era * 146097 + @as(i32, @intCast(doe)) - 719468;
        }

        /// Returns struct {year, month, day} triple in civil calendar
        /// Preconditions: days is number of days since 1970-01-01 and is in the range:
        pub fn civilFromDays(days: i32) struct { y: i32, m: u32, d: u32 } {
            const z: i32 = days + 719468;
            const era: i32 = @divFloor(if (z >= 0) z else z - 146096, 146097);
            const doe: u32 = @intCast(z - era * 146097);
            const yoe: u32 = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
            const y: i32 = @as(i32, @intCast(yoe)) + era * 400;
            const doy: u32 = doe - (365 * yoe + yoe / 4 - yoe / 100);
            const mp: u32 = (5 * doy + 2) / 153;
            const d: u32 = doy - (153 * mp + 2) / 5 + 1;
            const m: u32 = (if (mp < 10) mp + 3 else mp - 9);

            return .{
                .y = y + @intFromBool(m <= 2),
                .m = m,
                .d = d,
            };
        }

        /// Returns true if year is leap else false
        pub fn isLeapYear(year: i32) bool {
            return (@mod(year, 4) == 0 and (@mod(year, 100) != 0 or @mod(year, 400) == 0));
        }

        /// Return the day count of the current month for a non leap year
        pub fn lasDayOfMonthCommonYear(month: i32) u8 {
            const days_in_month = [_]u8{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
            return days_in_month[@intCast(month - 1)];
        }

        /// Return the day count of the current month for a leap year
        pub fn lastDayOfMonthLeapYear(month: i32) u8 {
            const days_in_month = [_]u8{ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
            return days_in_month[@intCast(month - 1)];
        }

        /// Return the day count of the current month
        /// for a year independant of the type of year
        pub fn lastDayOfMonth(year: i32, month: i32) u8 {
            if (month != 2 and isLeapYear(year))
                return (29)
            else
                return (lasDayOfMonthCommonYear(month));
        }

        /// Return the current weekday from the total number of days since epoch
        pub fn weekdayFromDays(z: i32) u32 {
            return @intCast(if (z >= -4) @mod(z + 4, 7) else @mod(z + 5, 7) + 6);
        }

        /// Return the difference between two weekday
        pub fn weekdayDifference(start: u32, end: u32) u32 {
            const x = start - end;
            return if (x <= 6) x else x + 7;
        }

        /// Return the next weekday (wrapping behaviour)
        pub fn nextWeekday(weekday: u32) u32 {
            return if (weekday < 6) weekday + 1 else 0;
        }

        /// Return the prev weekday (wrapping behaviour)
        pub fn prevWeekday(weekday: u32) u32 {
            return if (weekday > 0) weekday - 1 else 6;
        }
    };
}
