/**
 Copyright 2022 PhotoRoom Inc.

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#-----

 This is a fine pile of tricks to animate any custom property (uncorrelated
 from `UIView`/`CALayer`) with animation blocks like `UIView.animate { ... }`.

 This is useful for when a drawing process somewhere in the app is so far
 removed from `UIView`/`CALayer` that a custom layer doesn't really make sense,
 but you still want the convenience and expressiveness of the short syntax.

 CPU usage should be minimal and framerate smooth since this uses the native
 `CAAnimation` mechanism rather than relying on custom timers or display links
 and manually perform our interpolation.

 In theory it should work correctly (and respect easing, call any completion
 blocks, etc), and can notify you whenever you should redraw your hierarchy.
 It will also create a view and its layer for every animator, so you know...
 don't create 100 of those.
 */

import Foundation
import UIKit

final class CustomPropertyAnimator {
    private final class CustomProperyAnimatorLayer: CALayer {
        @NSManaged var value: CGFloat

        override init() {
            super.init()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        override init(layer: Any) {
            super.init(layer: layer)
            if let animatorLayer = layer as? CustomProperyAnimatorLayer {
                value = animatorLayer.value
            }
        }

        private var currentAnimationContext: CAAnimation? {
            action(forKey: #keyPath(backgroundColor)) as? CAAnimation
        }

        override class func needsDisplay(forKey key: String) -> Bool {
            guard key == #keyPath(value) else {
                return super.needsDisplay(forKey: key)
            }
            return true
        }

        override func action(forKey key: String) -> CAAction? {
            guard key == #keyPath(value) else {
                return super.action(forKey: key)
            }

            guard let action = currentAnimationContext else {
                return nil
            }

            let animation = CABasicAnimation()
            animation.keyPath = key
            animation.toValue = nil
            if let from = presentation()?.value(forKey: key) {
                animation.fromValue = from
            }

            // CAMediatiming attributes
            animation.beginTime = action.beginTime
            animation.duration = action.duration
            animation.speed = action.speed
            animation.timeOffset = action.timeOffset
            animation.repeatCount = action.repeatCount
            animation.repeatDuration = action.repeatDuration
            animation.autoreverses = action.autoreverses
            animation.fillMode = action.fillMode

            // CAAnimation attributes
            animation.timingFunction = action.timingFunction
            animation.delegate = action.delegate

            return animation
        }
    }

    private final class CustomProperyAnimatorView: UIView {
        var udpateHandler: (() -> Void)?

        override class var layerClass: AnyClass {
            return CustomProperyAnimatorLayer.self
        }

        private var animatorLayer: CustomProperyAnimatorLayer {
            return layer as! CustomProperyAnimatorLayer
        }

        var value: CGFloat {
            get { animatorLayer.presentation()?.value ?? animatorLayer.value }
            set { animatorLayer.value = newValue }
        }

        override func layerWillDraw(_ layer: CALayer) {
            super.layerWillDraw(layer)
            guard layer == animatorLayer else { return }
            DispatchQueue.main.async { self.udpateHandler?() }
        }
    }

    private let view = CustomProperyAnimatorView()

    var value: CGFloat {
        get { view.value }
        set { view.value = newValue }
    }

    var animationInProgress: Bool {
        return view.animationInProgress
    }

    init(initial: CGFloat, udpateHandler: (() -> Void)? = nil) {
        view.value = initial
        view.backgroundColor = .clear
        view.frame = CGRect(x: -.infinity, y: -.infinity, width: 1, height: 1)
        view.udpateHandler = udpateHandler
        UIWindow.key?.addSubview(view)
    }

    deinit {
        view.removeFromSuperview()
    }
}
