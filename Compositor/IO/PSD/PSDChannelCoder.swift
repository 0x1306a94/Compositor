import CoreGraphics
import Foundation

nonisolated enum PSDChannelCoder {
    static func decode(compression: Int, width: Int, height: Int, data: Data) throws -> [UInt8] {
        guard width > 0, height > 0 else { return [] }
        let expected = width * height
        switch compression {
        case 0:
            guard data.count >= expected else { throw PSDError.truncated }
            return Array(data.prefix(expected))
        case 1:
            return try unpackRLE(width: width, height: height, data: data)
        default:
            throw PSDError.unsupportedCompression
        }
    }

    static func encode(_ plane: [UInt8], width: Int, height: Int) -> (compression: UInt16, data: Data) {
        guard width > 0, height > 0, plane.count >= width * height else {
            return (0, Data())
        }
        var counts = Data()
        var packed = Data()
        counts.reserveCapacity(height * 2)
        for row in 0..<height {
            let slice = plane[row * width ..< (row + 1) * width]
            let encoded = packBits(Array(slice))
            counts.append(UInt8(truncatingIfNeeded: encoded.count >> 8))
            counts.append(UInt8(truncatingIfNeeded: encoded.count))
            packed.append(encoded)
        }
        var data = counts
        data.append(packed)
        return (1, data)
    }

    static func rgbaImage(width: Int, height: Int, red: [UInt8], green: [UInt8], blue: [UInt8], alpha: [UInt8]) throws -> CGImage {
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let count = width * height
        for i in 0..<count {
            let a = alpha[i]
            pixels[i * 4] = UInt8((UInt16(red[i]) * UInt16(a) + 127) / 255)
            pixels[i * 4 + 1] = UInt8((UInt16(green[i]) * UInt16(a) + 127) / 255)
            pixels[i * 4 + 2] = UInt8((UInt16(blue[i]) * UInt16(a) + 127) / 255)
            pixels[i * 4 + 3] = a
        }
        return try image(width: width, height: height, rgba: pixels)
    }

    static func image(width: Int, height: Int, rgba: [UInt8]) throws -> CGImage {
        let bytesPerRow = width * 4
        let data = Data(rgba)
        guard let provider = CGDataProvider(data: data as CFData),
              let image = CGImage(
                width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: bytesPerRow,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue),
                provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        else { throw PSDError.truncated }
        return image
    }

    static func maskImage(width: Int, height: Int, gray: [UInt8]) throws -> CGImage {
        let data = Data(gray)
        guard let provider = CGDataProvider(data: data as CFData),
              let image = CGImage(
                width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
                provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        else { throw PSDError.truncated }
        return image
    }

    /// Premultiplied RGBA, first row at the top of the image.
    static func planes(from image: CGImage) throws -> (red: [UInt8], green: [UInt8], blue: [UInt8], alpha: [UInt8]) {
        let width = image.width, height = image.height
        let context = try BrushRaster.context(width: width, height: height, mask: false)
        BrushRaster.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height), mask: false, context: context)
        guard let data = context.data?.assumingMemoryBound(to: UInt8.self) else { throw ExportError.render }
        var red = [UInt8](repeating: 0, count: width * height)
        var green = [UInt8](repeating: 0, count: width * height)
        var blue = [UInt8](repeating: 0, count: width * height)
        var alpha = [UInt8](repeating: 0, count: width * height)
        let stride = context.bytesPerRow
        for y in 0..<height {
            for x in 0..<width {
                let i = y * width + x
                let p = y * stride + x * 4
                let r = data[p], g = data[p + 1], b = data[p + 2], a = data[p + 3]
                alpha[i] = a
                if a == 0 {
                    red[i] = 0; green[i] = 0; blue[i] = 0
                } else {
                    red[i] = UInt8(min(255, (Int(r) * 255 + Int(a) / 2) / Int(a)))
                    green[i] = UInt8(min(255, (Int(g) * 255 + Int(a) / 2) / Int(a)))
                    blue[i] = UInt8(min(255, (Int(b) * 255 + Int(a) / 2) / Int(a)))
                }
            }
        }
        return (red, green, blue, alpha)
    }

    static func grayPlane(from image: CGImage) throws -> [UInt8] {
        let width = image.width, height = image.height
        let context = try BrushRaster.context(width: width, height: height, mask: true)
        BrushRaster.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height), mask: true, context: context)
        guard let data = context.data?.assumingMemoryBound(to: UInt8.self) else { throw ExportError.render }
        var plane = [UInt8](repeating: 0, count: width * height)
        let stride = context.bytesPerRow
        for y in 0..<height {
            for x in 0..<width { plane[y * width + x] = data[y * stride + x] }
        }
        return plane
    }

    private static func unpackRLE(width: Int, height: Int, data: Data) throws -> [UInt8] {
        var offset = 0
        func next() throws -> UInt8 {
            guard offset < data.count else { throw PSDError.truncated }
            defer { offset += 1 }
            return data[offset]
        }
        var counts = [Int](repeating: 0, count: height)
        for row in 0..<height {
            let hi = try next(), lo = try next()
            counts[row] = Int(hi) << 8 | Int(lo)
        }
        var plane = [UInt8](repeating: 0, count: width * height)
        for row in 0..<height {
            let end = offset + counts[row]
            guard end <= data.count else { throw PSDError.truncated }
            var written = 0
            while written < width {
                guard offset < end else { throw PSDError.truncated }
                let n = Int8(bitPattern: data[offset])
                offset += 1
                if n >= 0 {
                    let count = Int(n) + 1
                    guard written + count <= width, offset + count <= end else { throw PSDError.truncated }
                    for i in 0..<count { plane[row * width + written + i] = data[offset + i] }
                    offset += count
                    written += count
                } else if n != -128 {
                    let count = 1 - Int(n)
                    guard written + count <= width, offset < end else { throw PSDError.truncated }
                    let value = data[offset]
                    offset += 1
                    for i in 0..<count { plane[row * width + written + i] = value }
                    written += count
                }
            }
            offset = end
        }
        return plane
    }

    private static func packBits(_ row: [UInt8]) -> Data {
        var output = Data()
        var i = 0
        while i < row.count {
            if i + 1 < row.count, row[i] == row[i + 1] {
                var run = 2
                while i + run < row.count, row[i + run] == row[i], run < 128 { run += 1 }
                output.append(UInt8(bitPattern: Int8(1 - run)))
                output.append(row[i])
                i += run
            } else {
                let start = i
                i += 1
                while i < row.count, i - start < 128 {
                    if i + 1 < row.count, row[i] == row[i + 1] { break }
                    i += 1
                }
                output.append(UInt8(i - start - 1))
                output.append(contentsOf: row[start..<i])
            }
        }
        return output
    }
}
