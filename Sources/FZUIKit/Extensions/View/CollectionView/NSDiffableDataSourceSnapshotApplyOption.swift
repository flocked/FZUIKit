//
//  NSDiffableDataSourceSnapshot+ApplyOption.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

#if os(macOS) || canImport(UIKit)
import Foundation

///  Options for applying a snapshot to a diffable data source.
public enum NSDiffableDataSourceSnapshotApplyOption: Hashable, Sendable {
    /**
     The snapshot gets applied animated.

     The data source computes a diff of the previous and new state and applies the new state animated with a default animation duration. Any ongoing item animations are interrupted and the content is reloaded immediately.
     */
    public static var animated: Self { .animated(duration: noAnimationDuration) }

    /**
     The snapshot gets applied animiated with the specified animation duration.

     The data source computes a diff of the previous and new state and applies the new state animated with the specified animation duration. Any ongoing item animations are interrupted and the content is reloaded immediately.
     */
    case animated(duration: TimeInterval)

    /**
     The snapshot gets applied using `reloadData()`.

     The system resets the UI to reflect the state of the data in the snapshot without computing a diff or animating the changes.
     */
    case usingReloadData
    /**
     The snapshot gets applied without any animation.

     The data source computes a diff of the previous and new state and applies the new state non animated. Any ongoing item animations are interrupted and the content is reloaded immediately.
     */
    case withoutAnimation

    static var noAnimationDuration: TimeInterval { 2_344_235 }

    var animationDuration: TimeInterval? {
        switch self {
        case let .animated(duration):
            return duration
        default:
            return nil
        }
    }
}
#endif
