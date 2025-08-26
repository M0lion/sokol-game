const std = @import("std");
const math = std.math;
const Vec = @import("vector.zig").Vec;

// 2D Transformation Matrix (3x3 for homogeneous coordinates)
pub const Transform2D = struct {
    // Matrix stored in column-major order
    // [0][1][2]
    // [3][4][5]
    // [6][7][8]
    m: [9]f32,

    // Create identity matrix
    pub fn identity() Transform2D {
        return Transform2D{
            .m = [9]f32{
                1.0, 0.0, 0.0, // Column 0
                0.0, 1.0, 0.0, // Column 1
                0.0, 0.0, 1.0, // Column 2
            },
        };
    }

    // Create translation matrix
    pub fn translation(tx: f32, ty: f32) Transform2D {
        return Transform2D{
            .m = [9]f32{
                1.0, 0.0, 0.0, // Column 0
                0.0, 1.0, 0.0, // Column 1
                tx, ty, 1.0, // Column 2 (translation)
            },
        };
    }

    // Create uniform scale matrix
    pub fn scale(s: f32) Transform2D {
        return scaleNonUniform(s, s);
    }

    // Create non-uniform scale matrix
    pub fn scaleNonUniform(sx: f32, sy: f32) Transform2D {
        return Transform2D{
            .m = [9]f32{
                sx, 0.0, 0.0, // Column 0
                0.0, sy, 0.0, // Column 1
                0.0, 0.0, 1.0, // Column 2
            },
        };
    }

    // Create rotation matrix (angle in radians)
    pub fn rotation(angle: f32) Transform2D {
        const cos_a = math.cos(angle);
        const sin_a = math.sin(angle);

        return Transform2D{
            .m = [9]f32{
                cos_a, sin_a, 0.0, // Column 0
                -sin_a, cos_a, 0.0, // Column 1
                0.0, 0.0, 1.0, // Column 2
            },
        };
    }

    // Create a combined transform: translate then scale
    pub fn translateScale(tx: f32, ty: f32, sx: f32, sy: f32) Transform2D {
        return Transform2D{
            .m = [9]f32{
                sx, 0.0, 0.0, // Column 0
                0.0, sy, 0.0, // Column 1
                tx, ty, 1.0, // Column 2
            },
        };
    }

    // Matrix multiplication
    pub fn multiply(self: Transform2D, other: Transform2D) Transform2D {
        var result: Transform2D = undefined;

        // Multiply 3x3 matrices
        for (0..3) |col| {
            for (0..3) |row| {
                var sum: f32 = 0.0;
                for (0..3) |k| {
                    sum += self.m[row + k * 3] * other.m[k + col * 3];
                }
                result.m[row + col * 3] = sum;
            }
        }

        return result;
    }

    // Transform a 2D point
    pub fn transformPoint(self: Transform2D, point: Vec) Vec {
        const x = self.m[0] * point.x + self.m[3] * point.y + self.m[6];
        const y = self.m[1] * point.x + self.m[4] * point.y + self.m[7];
        return Vec{ .x = x, .y = y };
    }

    // Transform a 2D vector (ignores translation)
    pub fn transformVector(self: Transform2D, vector: Vec) Vec {
        const x = self.m[0] * vector.x + self.m[3] * vector.y;
        const y = self.m[1] * vector.x + self.m[4] * vector.y;
        return Vec{ .x = x, .y = y };
    }

    // Get translation component
    pub fn getTranslation(self: Transform2D) Vec {
        return Vec{ .x = self.m[6], .y = self.m[7] };
    }

    // Set translation component
    pub fn setTranslation(self: *Transform2D, tx: f32, ty: f32) void {
        self.m[6] = tx;
        self.m[7] = ty;
    }

    // Apply translation
    pub fn translate(self: Transform2D, tx: f32, ty: f32) Transform2D {
        return self.multiply(translation(tx, ty));
    }

    // Apply scaling
    pub fn applyScale(self: Transform2D, sx: f32, sy: f32) Transform2D {
        return self.multiply(scaleNonUniform(sx, sy));
    }

    // Apply rotation
    pub fn rotate(self: Transform2D, angle: f32) Transform2D {
        return self.multiply(rotation(angle));
    }

    // Print matrix for debugging
    pub fn print(self: Transform2D) void {
        std.debug.print("Transform2D:\n");
        std.debug.print("[{d:6.3}, {d:6.3}, {d:6.3}]\n", .{ self.m[0], self.m[3], self.m[6] });
        std.debug.print("[{d:6.3}, {d:6.3}, {d:6.3}]\n", .{ self.m[1], self.m[4], self.m[7] });
        std.debug.print("[{d:6.3}, {d:6.3}, {d:6.3}]\n", .{ self.m[2], self.m[5], self.m[8] });
    }

    pub fn toMat4(self: Transform2D) [16]f32 {
        return [16]f32{
            // Column 0
            self.m[0], self.m[3], 0.0, self.m[6],
            // Column 1
            self.m[1], self.m[4], 0.0, self.m[7],
            // Column 2
            0.0,       0.0,       1.0, 0.0,
            // Column 3
            self.m[2], self.m[5], 0.0, self.m[8],
        };
    }
};
