//
//  NSSound+.swift
//
//
//  Created by Florian Zand on 01.02.24.
//

#if os(macOS)
import AppKit

public extension NSSound {
    /// The name of a sound.
    enum SoundName: String, Hashable, CaseIterable {
        /// Basso
        case basso = "Basso"
        /// Blow
        case blow = "Blow"
        /// Bottle
        case bottle = "Bottle"
        /// Frog
        case frog = "Frog"
        /// Funk
        case funk = "Funk"
        /// Glass
        case glass = "Glass"
        /// Hero
        case hero = "Hero"
        /// Morse
        case morse = "Morse"
        /// Ping
        case ping = "Ping"
        /// Pop
        case pop = "Pop"
        /// Purr
        case purr = "Purr"
        /// Sosumi
        case sosumi = "Sosumi"
        /// Submarine
        case submarine = "Submarine"
        /// Tink
        case tink = "Tink"
    }
    
    /// Returns the `NSSound` instance associated with a given name.
    convenience init?(named name: SoundName) {
        self.init(named: name.rawValue)
    }
    
    /// The sound with the name "Basso".
    static let basso     = NSSound(named: .basso)
    /// The sound with the name "Blow".
    static let blow      = NSSound(named: .blow)
    /// The sound with the name "Bottle".
    static let bottle    = NSSound(named: .bottle)
    /// The sound with the name "Frog".
    static let frog      = NSSound(named: .frog)
    /// The sound with the name "Funk".
    static let funk      = NSSound(named: .funk)
    /// The sound with the name "Glass".
    static let glass     = NSSound(named: .glass)
    /// The sound with the name "Hero".
    static let hero      = NSSound(named: .hero)
    /// The sound with the name "Morse".
    static let morse     = NSSound(named: .morse)
    /// The sound with the name "Ping".
    static let ping      = NSSound(named: .ping)
    /// The sound with the name "Pop".
    static let pop       = NSSound(named: .pop)
    /// The sound with the name "Purr".
    static let purr      = NSSound(named: .purr)
    /// The sound with the name "Sosumi".
    static let sosumi    = NSSound(named: .sosumi)
    /// The sound with the name "Submarine".
    static let submarine = NSSound(named: .submarine)
    /// The sound with the name "Tink".
    static let tink      = NSSound(named: .tink)
}
#endif
