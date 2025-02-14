//
//  CALayerExtensions.swift
//
//
//  Created by Adam Bell on 5/26/20.
//

#if canImport(QuartzCore)

    import Foundation
    import QuartzCore
import FZSwiftUtils

    // MARK: - Interaction Enhancements

    /// This class exposes properties to manipulate the transform of a `CALayer` directly with implicit actions (animations) disabled.
    public extension CALayer {
        /// The translation of the layer's transform (X and Y) as a CGPoint.
        var translation: CGPoint {
            get {
                let translation = transform.translation
                return CGPoint(x: translation.x, y: translation.y)
            }
            set {
                transform.translation = Translation(newValue.x, newValue.y, transform.translation.z)
            }
        }

        /// The translation of the layer's transform (X, Y, and Z).
        var translationXYZ: Translation {
            get { transform.translation }
            set {
                CATransaction.disabledActions {
                    transform.translation = newValue
                }
            }
        }

        /// The scale of the layer's transform.
        var scale: Scale {
            get { transform.scale.scale }
            set {
                CATransaction.disabledActions {
                    transform.scale = newValue.vector
                }
            }
        }

        /// The rotation of the layer's transform, in degrees.
        var rotation: Rotation {
            get { transform.eulerAnglesDegrees.rotation }
            set {
                CATransaction.disabledActions {
                    transform.eulerAnglesDegrees = newValue.vector
                }
            }
        }

        /// The rotation of the layer's transform, in radians.
        var rotationInRadians: Rotation {
            get { transform.eulerAngles.rotation }
            set {
                CATransaction.disabledActions {
                    transform.eulerAngles = newValue.vector
                }
            }
        }

        /// The shearing of the layer's transform.
        var skew: Skew {
            get { transform.skew }
            set {
                CATransaction.disabledActions {
                    transform.skew = newValue
                }
            }
        }

        /// The perspective of the layer's transform (e.g. .m34).
        var perspective: Perspective {
            get { transform.perspective }
            set {
                CATransaction.disabledActions {
                    transform.perspective = newValue
                }
            }
        }
    }


#endif
