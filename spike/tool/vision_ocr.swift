// Faz 0 desktop OCR probe for Rafça.
//
// Reads an image, rotates it clockwise by the requested amount, runs Apple
// Vision text recognition on the rotated pixels and prints word level
// observations as JSON on stdout.
//
// Coordinates are emitted in the ROTATED image's pixel space with the origin
// at the top left. Mapping them back to the original image is done in Dart by
// `unrotatePoint`, which is unit tested; keeping that arithmetic in one tested
// place is the whole reason this tool does not try to be clever.
//
// Build: swiftc -O -o spike/tool/vision_ocr spike/tool/vision_ocr.swift

import Foundation
import CoreGraphics
import ImageIO
import Vision

struct CliError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

func loadImage(path: String) throws -> CGImage {
    let url = URL(fileURLWithPath: path)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
        throw CliError("cannot open image source: \(path)")
    }
    guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        throw CliError("cannot decode image: \(path)")
    }
    return image
}

func rotate(_ image: CGImage, clockwiseDegrees: Int) throws -> CGImage {
    if clockwiseDegrees == 0 { return image }

    let w = image.width
    let h = image.height
    let swapped = clockwiseDegrees == 90 || clockwiseDegrees == 270
    let outW = swapped ? h : w
    let outH = swapped ? w : h

    guard let context = CGContext(
        data: nil,
        width: outW,
        height: outH,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw CliError("cannot create \(outW)x\(outH) bitmap context")
    }

    // CGContext has a bottom-left origin, so a positive angle here turns the
    // content counter-clockwise on screen. Negate it to rotate clockwise, the
    // convention `unrotatePoint` on the Dart side is tested against.
    context.translateBy(x: CGFloat(outW) / 2, y: CGFloat(outH) / 2)
    context.rotate(by: -CGFloat(clockwiseDegrees) * .pi / 180)
    context.translateBy(x: -CGFloat(w) / 2, y: -CGFloat(h) / 2)
    context.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))

    guard let rotated = context.makeImage() else {
        throw CliError("rotation produced no image")
    }
    return rotated
}

/// Vision reports normalised coordinates with the origin at the bottom left.
/// Convert to pixels with the origin at the top left, which is what every
/// other part of the pipeline uses.
func toPixels(_ point: CGPoint, width: Int, height: Int) -> [String: Double] {
    return [
        "x": Double(point.x) * Double(width),
        "y": (1.0 - Double(point.y)) * Double(height),
    ]
}

func recognize(
    image: CGImage,
    languages: [String],
    languageCorrection: Bool
) throws -> [[String: Any]] {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = languageCorrection
    request.recognitionLanguages = languages
    request.minimumTextHeight = 0.0

    let handler = VNImageRequestHandler(cgImage: image, options: [:])
    try handler.perform([request])

    guard let observations = request.results else { return [] }

    var elements: [[String: Any]] = []
    for observation in observations {
        guard let candidate = observation.topCandidates(1).first else { continue }
        let text = candidate.string

        // Split into words and ask Vision for each word's own quad. Spine
        // clustering works on words, not on whole recognised lines.
        var searchStart = text.startIndex
        for token in text.split(separator: " ", omittingEmptySubsequences: true) {
            guard let range = text.range(of: String(token), range: searchStart ..< text.endIndex) else {
                continue
            }
            searchStart = range.upperBound

            let quad: VNRectangleObservation
            if let box = try? candidate.boundingBox(for: range) {
                quad = box
            } else {
                quad = observation
            }

            elements.append([
                "text": String(token),
                "confidence": Double(candidate.confidence),
                "corners": [
                    toPixels(quad.topLeft, width: image.width, height: image.height),
                    toPixels(quad.topRight, width: image.width, height: image.height),
                    toPixels(quad.bottomRight, width: image.width, height: image.height),
                    toPixels(quad.bottomLeft, width: image.width, height: image.height),
                ],
            ])
        }
    }
    return elements
}

// --- argument parsing -------------------------------------------------------

var imagePath: String?
var rotation = 0
var languages = ["tr-TR", "en-US"]
var languageCorrection = false

var argIndex = 1
let args = CommandLine.arguments
while argIndex < args.count {
    switch args[argIndex] {
    case "--image":
        argIndex += 1
        imagePath = argIndex < args.count ? args[argIndex] : nil
    case "--rotation":
        argIndex += 1
        rotation = argIndex < args.count ? (Int(args[argIndex]) ?? 0) : 0
    case "--languages":
        argIndex += 1
        if argIndex < args.count {
            languages = args[argIndex].split(separator: ",").map(String.init)
        }
    case "--language-correction":
        languageCorrection = true
    default:
        FileHandle.standardError.write("unknown argument: \(args[argIndex])\n".data(using: .utf8)!)
        exit(2)
    }
    argIndex += 1
}

do {
    guard let imagePath else {
        throw CliError("--image <path> is required")
    }
    guard [0, 90, 180, 270].contains(rotation) else {
        throw CliError("--rotation must be one of 0, 90, 180, 270; got \(rotation)")
    }

    let original = try loadImage(path: imagePath)
    let rotated = try rotate(original, clockwiseDegrees: rotation)
    let elements = try recognize(
        image: rotated,
        languages: languages,
        languageCorrection: languageCorrection
    )

    let payload: [String: Any] = [
        "rotation": rotation,
        "originalWidth": original.width,
        "originalHeight": original.height,
        "rotatedWidth": rotated.width,
        "rotatedHeight": rotated.height,
        "elements": elements,
    ]
    let json = try JSONSerialization.data(withJSONObject: payload, options: [])
    FileHandle.standardOutput.write(json)
} catch {
    FileHandle.standardError.write("vision_ocr failed: \(error)\n".data(using: .utf8)!)
    exit(1)
}
