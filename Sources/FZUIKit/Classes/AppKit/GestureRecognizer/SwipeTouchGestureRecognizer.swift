#if os(macOS)
import AppKit

public class SwipeTouchGestureRecognizer: NSGestureRecognizer {
    public enum Direction {
        case right, left, up, down
    }

    public var numberOfTouchesRequired: Int = 2
    public var direction: Direction = .left

    internal var twoFingersTouches: [String: NSTouch]?

    override public init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)
        if event.type == .gesture {
            let touches = event.touches(matching: .any, in: view)
            if touches.count == numberOfTouchesRequired {
                twoFingersTouches = [:]
                touches.forEach {
                    self.twoFingersTouches?[$0.identity.description] = $0
                }
            }
        }
    }

    internal let kSwipeMinimumLength: Float = 0.12

    override public func touchesMoved(with event: NSEvent) {
        super.touchesMoved(with: event)
        let touches = event.touches(matching: .moved, in: view)
        guard touches.count == numberOfTouchesRequired else { return }
        guard let beginTouches = twoFingersTouches else { return }

        var xMagnitudes: [Float] = []
        var yMagnitudes: [Float] = []
        for touch in touches {
            guard let beginTouch = beginTouches[touch.identity.description] else { continue }
            let xMagnitude = Float(touch.normalizedPosition.x - beginTouch.normalizedPosition.x)
            let yMagnitude = Float(touch.normalizedPosition.y - beginTouch.normalizedPosition.y)
            xMagnitudes.append(xMagnitude)
            yMagnitudes.append(yMagnitude)
        }

        let xSum = xMagnitudes.reduce(0, +)
        let ySum = yMagnitudes.reduce(0, +)

        // See if absolute sum is long enough to be considered a complete gesture
        let xAbsoluteSum = fabsf(xSum)
        let yAbsoluteSum = fabsf(ySum)

        var happened = false

        // Handle the actual swipe
        if xAbsoluteSum >= kSwipeMinimumLength {
            happened = true
            // This might need to be > (i am using flipped coordinates)
            if xSum > 0 {
                happenedRight()
            } else {
                happenedLeft()
            }
        }
        if yAbsoluteSum >= kSwipeMinimumLength {
            happened = true
            if ySum > 0 {
                happenedUp()
            } else {
                happenedDown()
            }
        }
        if happened {
            twoFingersTouches = nil
        }
    }

    func happenedLeft() {
        guard direction == .left, let action = action else { return }
        _ = target?.perform(action, with: self)
    }

    func happenedRight() {
        guard direction == .right, let action = action else { return }
        _ = target?.perform(action, with: self)
    }

    func happenedUp() {
        guard direction == .up, let action = action else { return }
        _ = target?.perform(action, with: self)
    }

    func happenedDown() {
        guard direction == .down, let action = action else { return }
        _ = target?.perform(action, with: self)
    }

    override public func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)
    }

    override public func touchesCancelled(with event: NSEvent) {
        super.touchesCancelled(with: event)
    }
}

extension SwipeTouchGestureRecognizer: TargetActionProtocol {}
public extension SwipeTouchGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}
#endif
