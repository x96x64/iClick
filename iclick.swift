// iClick: draw a fading ring wherever the mouse is clicked, like the click
// highlight in macOS screen recordings, but all the time.
//
// Runs as a background agent with no Dock icon or menu. A transparent window
// that ignores the mouse covers each display, and a global event monitor
// animates a ring at the pointer on every mouse-down. Watching mouse events
// needs no Accessibility or Input Monitoring permission.
//
// Built and kept running by install.zsh as the LaunchAgent local.iclick.
// To change the look, edit the constants below and run install.zsh again.

import AppKit

// Sizes are in points. Measured frame by frame from the click ring in a
// Screen Studio-style app demo (x.com/ClaudeDevs/status/2124978802006851961,
// scaled with the window buttons): a thin mid-gray ring with no fill or shadow
// grows from 18 to 43 pt with ease-out while fading out linearly in 0.27 s.
// Mid gray stays visible on both light and dark backgrounds.
let ringDiameter: CGFloat = 43  // at the end of the animation
let ringWidth: CGFloat = 2
let ringStroke = NSColor(white: 0.5, alpha: 1)
let ringStartScale = 18.0 / 43
let ringDuration: CFTimeInterval = 0.27

final class Overlay {
    private var windows: [NSWindow] = []

    init() {
        rebuild()
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in self?.rebuild() }
    }

    // One overlay window per display, recreated when displays change.
    private func rebuild() {
        windows.forEach { $0.orderOut(nil) }
        windows = NSScreen.screens.map { screen in
            let window = NSWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.ignoresMouseEvents = true
            window.isReleasedWhenClosed = false
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
            window.contentView?.wantsLayer = true
            window.setFrame(screen.frame, display: false)
            window.orderFrontRegardless()
            return window
        }
    }

    // `point` is in global screen coordinates, as from NSEvent.mouseLocation.
    func ring(at point: NSPoint) {
        guard let window = windows.first(where: { NSMouseInRect(point, $0.frame, false) }),
              let host = window.contentView?.layer else { return }

        let radius = ringDiameter / 2
        let layer = CAShapeLayer()
        layer.frame = CGRect(
            x: point.x - window.frame.minX - radius, y: point.y - window.frame.minY - radius,
            width: ringDiameter, height: ringDiameter)
        layer.path = CGPath(ellipseIn: layer.bounds.insetBy(dx: ringWidth / 2, dy: ringWidth / 2), transform: nil)
        layer.fillColor = nil
        layer.strokeColor = ringStroke.cgColor
        layer.lineWidth = ringWidth
        layer.opacity = 0  // final state; the animation below fades in from 1
        host.addSublayer(layer)

        let grow = CABasicAnimation(keyPath: "transform.scale")
        grow.fromValue = ringStartScale
        grow.toValue = 1
        grow.timingFunction = CAMediaTimingFunction(name: .easeOut)
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1
        fade.toValue = 0
        let group = CAAnimationGroup()
        group.animations = [grow, fade]
        group.duration = ringDuration

        CATransaction.begin()
        CATransaction.setCompletionBlock { layer.removeFromSuperlayer() }
        layer.add(group, forKey: nil)
        CATransaction.commit()
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let overlay = Overlay()
NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { event in
    overlay.ring(at: NSEvent.mouseLocation)
}
app.run()
