#!/usr/bin/swift

import AppKit
import Foundation

let mainScreen = NSScreen.main
let displays: [[String: Any]] = NSScreen.screens.enumerated().map { index, screen in
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

let json = try JSONSerialization.data(
    withJSONObject: displays,
    options: [.prettyPrinted, .sortedKeys]
)
print(String(data: json, encoding: .utf8)!)
