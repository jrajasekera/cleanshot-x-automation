#!/usr/bin/swift

import AppKit
import Foundation

let mainScreen = NSScreen.main
let screens = NSScreen.screens
let displays: [[String: Any]] = screens.enumerated().map { index, screen in
    let frame = screen.frame
    let scale = screen.backingScaleFactor
    return [
        "display": index + 1,
        "main": screen === mainScreen,
        "origin_x": Int(frame.origin.x),
        "origin_y": Int(frame.origin.y),
        "logical_width": Int(frame.width),
        "logical_height": Int(frame.height),
        "backing_scale_factor": scale,
        "capture_pixel_width": Int((frame.width * scale).rounded()),
        "capture_pixel_height": Int((frame.height * scale).rounded()),
    ]
}

let arguments = Array(CommandLine.arguments.dropFirst())

func argumentValue(_ name: String) -> String? {
    guard let index = arguments.firstIndex(of: name), arguments.indices.contains(index + 1) else {
        return nil
    }
    return arguments[index + 1]
}

let outputObject: Any
if let pixelWidthText = argumentValue("--plan-pixel-width"),
   let pixelHeightText = argumentValue("--plan-pixel-height") {
    guard let pixelWidth = Int(pixelWidthText), pixelWidth > 0,
          let pixelHeight = Int(pixelHeightText), pixelHeight > 0 else {
        fputs("display-info: requested pixel dimensions must be positive integers\n", stderr)
        exit(2)
    }
    let displayNumber = Int(argumentValue("--display") ?? "1") ?? 0
    guard displayNumber > 0, screens.indices.contains(displayNumber - 1) else {
        fputs("display-info: display \(displayNumber) is not available\n", stderr)
        exit(2)
    }
    let screen = screens[displayNumber - 1]
    let frame = screen.frame
    let scale = screen.backingScaleFactor
    let targetDPR: Double
    if let targetDPRText = argumentValue("--device-pixel-ratio") {
        targetDPR = Double(targetDPRText) ?? 0
    } else {
        targetDPR = Double(scale)
    }
    guard targetDPR > 0 else {
        fputs("display-info: --device-pixel-ratio must be a positive number\n", stderr)
        exit(2)
    }
    let logicalWidth = Double(pixelWidth) / targetDPR
    let logicalHeight = Double(pixelHeight) / targetDPR
    let fitsLogicalSurface = logicalWidth <= frame.width && logicalHeight <= frame.height
    let dprMatchesDisplay = abs(targetDPR - scale) < 0.001
    let fits = fitsLogicalSurface && dprMatchesDisplay
    let reason: String
    if fits {
        reason = "The target logical canvas fits this physical display and its DPR matches the display backing scale."
    } else if !fitsLogicalSurface && !dprMatchesDisplay {
        reason = "The target logical canvas exceeds this physical display and its DPR differs from the display backing scale; a fixed CleanShot area would render the wrong responsive surface and pixel density."
    } else if !fitsLogicalSurface {
        reason = "The target logical canvas exceeds this physical display; a fixed CleanShot area would clip or scale it."
    } else {
        reason = "The target DPR differs from the display backing scale; a fixed CleanShot area would produce different output pixels or require scaling."
    }
    outputObject = [
        "display": displayNumber,
        "display_logical_width": Int(frame.width),
        "display_logical_height": Int(frame.height),
        "display_capture_pixel_width": Int((frame.width * scale).rounded()),
        "display_capture_pixel_height": Int((frame.height * scale).rounded()),
        "backing_scale_factor": scale,
        "target_device_pixel_ratio": targetDPR,
        "requested_pixel_width": pixelWidth,
        "requested_pixel_height": pixelHeight,
        "required_logical_width": logicalWidth,
        "required_logical_height": logicalHeight,
        "fits_logical_surface": fitsLogicalSurface,
        "dpr_matches_display": dprMatchesDisplay,
        "capture_pixel_width_at_display_scale": Int((logicalWidth * scale).rounded()),
        "capture_pixel_height_at_display_scale": Int((logicalHeight * scale).rounded()),
        "fits_fixed_area": fits,
        "recommended_capture_path": fits ? "cleanshot-fixed-area" : "virtual-renderer",
        "reason": reason
    ] as [String: Any]
} else if arguments.isEmpty {
    outputObject = displays
} else {
    fputs("display-info: use no arguments or --plan-pixel-width N --plan-pixel-height N [--device-pixel-ratio N] [--display N]\n", stderr)
    exit(2)
}

let json = try JSONSerialization.data(
    withJSONObject: outputObject,
    options: [.prettyPrinted, .sortedKeys]
)
print(String(data: json, encoding: .utf8)!)
