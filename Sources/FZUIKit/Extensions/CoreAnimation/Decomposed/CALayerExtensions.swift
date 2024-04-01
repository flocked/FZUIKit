//
//  CALayerExtensions.swift
//
//
//  Created by Adam Bell on 5/26/20.
//

#if canImport(QuartzCore)

    import Foundation
    import QuartzCore

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
            get {
                transform.translation
            }
            set {
                DisableActions {
                    transform.translation = newValue
                }
            }
        }

        /// The scale of the layer's transform (X and Y) as a CGPoint.
        var scale: CGPoint {
            get {
                let scale = transform.scale
                return CGPoint(x: scale.x, y: scale.y)
            }
            set {
                DisableActions {
                    transform.scale = Scale(newValue.x, newValue.y, transform.scale.z)
                }
            }
        }

        /// The scale of the layer's transform (X, Y, and Z).
        var scaleXYZ: Scale {
            get {
                transform.scale
            }
            set {
                DisableActions {
                    transform.scale = newValue
                }
            }
        }

        /// The rotation of the layer's transform (expressed as a quaternion).
        var rotation: CGQuaternion {
            get {
                transform.rotation
            }
            set {
                DisableActions {
                    transform.rotation = newValue
                }
            }
        }

        /// The rotation of the layer's transform (expressed as euler angles, in radians).
        var eulerAngles: CGVector3 {
            get {
                transform.eulerAngles
            }
            set {
                DisableActions {
                    transform.eulerAngles = newValue
                }
            }
        }

        /// The shearing of the layer's transform.
        var skew: Skew {
            get {
                transform.skew
            }
            set {
                DisableActions {
                    transform.skew = newValue
                }
            }
        }

        /// The perspective of the layer's transform (e.g. .m34).
        var perspective: Perspective {
            get {
                transform.perspective
            }
            set {
                DisableActions {
                    transform.perspective = newValue
                }
            }
        }
    }


#endif
