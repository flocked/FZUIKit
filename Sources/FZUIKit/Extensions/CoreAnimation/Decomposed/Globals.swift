//
//  Globals.swift
//
//
//  Created by Adam Bell on 5/20/20.
//

#if canImport(QuartzCore)

    import QuartzCore

    // The amount of accuracy that should be used when comparing floating point values.
    let SupportedAccuracy = 0.0001

    let DisableActions = { (changes: () -> Void) in
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        changes()
        CATransaction.commit()
    }

#endif
