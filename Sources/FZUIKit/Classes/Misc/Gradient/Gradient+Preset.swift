//
//  Gradient+Preset.swift
//
//
//  Created by Florian Zand on 13.05.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension Gradient {
    /// A gradient preset.
    public struct Preset: CaseIterable {
        /// The name of the preset.
        public let name: String

        /// The colors of the preset.
        public let colors: [NSUIColor]

        /// Creates a preset with the specified name and colors.
        public init(name: String, colors: [NSUIColor]) {
            self.name = name
            self.colors = colors
        }

        private init(_ name: String, _ colors: [NSUIColor]) {
            self.name = name
            self.colors = colors
        }

        /// Omolon
        public static let omolon = Self("Omolon", [NSUIColor(red: 0.03529411764705882, green: 0.11764705882352941, blue: 0.22745098039215686, alpha: 1.0), NSUIColor(red: 0.1843137254901961, green: 0.5019607843137255, blue: 0.9294117647058824, alpha: 1.0), NSUIColor(red: 0.17647058823529413, green: 0.6196078431372549, blue: 0.8784313725490196, alpha: 1.0)])

        /// Farhan
        public static let farhan = Self("Farhan", [NSUIColor(red: 0.5803921568627451, green: 0.0, blue: 0.8274509803921568, alpha: 1.0), NSUIColor(red: 0.29411764705882354, green: 0.0, blue: 0.5098039215686274, alpha: 1.0)])

        /// Purple
        public static let purple = Self("Purple", [NSUIColor(red: 0.7843137254901961, green: 0.3058823529411765, blue: 0.5372549019607843, alpha: 1.0), NSUIColor(red: 0.9450980392156862, green: 0.37254901960784315, blue: 0.4745098039215686, alpha: 1.0)])

        /// Ibtesam
        public static let ibtesam = Self("Ibtesam", [NSUIColor(red: 0.0, green: 0.9607843137254902, blue: 0.6274509803921569, alpha: 1.0), NSUIColor(red: 0.0, green: 0.8509803921568627, blue: 0.9607843137254902, alpha: 1.0)])

        /// Radioactive Heat
        public static let radioactiveHeat = Self("Radioactive Heat", [NSUIColor(red: 0.9686274509803922, green: 0.5803921568627451, blue: 0.11764705882352941, alpha: 1.0), NSUIColor(red: 0.4470588235294118, green: 0.7764705882352941, blue: 0.9372549019607843, alpha: 1.0), NSUIColor(red: 0.0, green: 0.6509803921568628, blue: 0.3176470588235294, alpha: 1.0)])

        /// The Sky And The Sea
        public static let theSkyAndTheSea = Self("The Sky And The Sea", [NSUIColor(red: 0.9686274509803922, green: 0.5803921568627451, blue: 0.11764705882352941, alpha: 1.0), NSUIColor(red: 0.0, green: 0.3058823529411765, blue: 0.5607843137254902, alpha: 1.0)])

        /// From Ice To Fire
        public static let fromIceToFire = Self("From Ice To Fire", [NSUIColor(red: 0.4470588235294118, green: 0.7764705882352941, blue: 0.9372549019607843, alpha: 1.0), NSUIColor(red: 0.0, green: 0.3058823529411765, blue: 0.5607843137254902, alpha: 1.0)])

        /// Blue Orange
        public static let blueOrange = Self("Blue Orange", [NSUIColor(red: 0.9921568627450981, green: 0.5058823529411764, blue: 0.07058823529411765, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5215686274509804, blue: 0.792156862745098, alpha: 1.0)])

        /// Purple Dream
        public static let purpleDream = Self("Purple Dream", [NSUIColor(red: 0.7490196078431373, green: 0.35294117647058826, blue: 0.8784313725490196, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.06666666666666667, blue: 0.8549019607843137, alpha: 1.0)])

        /// Blu
        public static let blu = Self("Blu", [NSUIColor(red: 0.0, green: 0.2549019607843137, blue: 0.41568627450980394, alpha: 1.0), NSUIColor(red: 0.8941176470588236, green: 0.8980392156862745, blue: 0.9019607843137255, alpha: 1.0)])

        /// Summer Breeze
        public static let summerBreeze = Self("Summer Breeze", [NSUIColor(red: 0.984313725490196, green: 0.9294117647058824, blue: 0.5882352941176471, alpha: 1.0), NSUIColor(red: 0.6705882352941176, green: 0.9254901960784314, blue: 0.8392156862745098, alpha: 1.0)])

        /// Ver
        public static let ver = Self("Ver", [NSUIColor(red: 1.0, green: 0.8784313725490196, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.4745098039215686, green: 0.6235294117647059, blue: 0.047058823529411764, alpha: 1.0)])

        /// Ver Black
        public static let verBlack = Self("Ver Black", [NSUIColor(red: 0.9686274509803922, green: 0.9725490196078431, blue: 0.9725490196078431, alpha: 1.0), NSUIColor(red: 0.6745098039215687, green: 0.7333333333333333, blue: 0.47058823529411764, alpha: 1.0)])

        /// Combi
        public static let combi = Self("Combi", [NSUIColor(red: 0.0, green: 0.2549019607843137, blue: 0.41568627450980394, alpha: 1.0), NSUIColor(red: 0.4745098039215686, green: 0.6235294117647059, blue: 0.047058823529411764, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8784313725490196, blue: 0.0, alpha: 1.0)])

        /// Anwar
        public static let anwar = Self("Anwar", [NSUIColor(red: 0.2, green: 0.30196078431372547, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.796078431372549, green: 0.792156862745098, blue: 0.6470588235294118, alpha: 1.0)])

        /// Bluelagoo
        public static let bluelagoo = Self("Bluelagoo", [NSUIColor(red: 0.0, green: 0.3215686274509804, blue: 0.8313725490196079, alpha: 1.0), NSUIColor(red: 0.2627450980392157, green: 0.39215686274509803, blue: 0.9686274509803922, alpha: 1.0), NSUIColor(red: 0.43529411764705883, green: 0.6941176470588235, blue: 0.9882352941176471, alpha: 1.0)])

        /// Lunada
        public static let lunada = Self("Lunada", [NSUIColor(red: 0.32941176470588235, green: 0.2, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.12549019607843137, green: 0.7411764705882353, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.6470588235294118, green: 0.996078431372549, blue: 0.796078431372549, alpha: 1.0)])

        /// Reaqua
        public static let reaqua = Self("Reaqua", [NSUIColor(red: 0.4745098039215686, green: 0.6235294117647059, blue: 0.047058823529411764, alpha: 1.0), NSUIColor(red: 0.6745098039215687, green: 0.7333333333333333, blue: 0.47058823529411764, alpha: 1.0)])

        /// Mango
        public static let mango = Self("Mango", [NSUIColor(red: 1.0, green: 0.8862745098039215, blue: 0.34901960784313724, alpha: 1.0), NSUIColor(red: 1.0, green: 0.6549019607843137, blue: 0.3176470588235294, alpha: 1.0)])

        /// Bupe
        public static let bupe = Self("Bupe", [NSUIColor(red: 0.0, green: 0.2549019607843137, blue: 0.41568627450980394, alpha: 1.0), NSUIColor(red: 0.8941176470588236, green: 0.8980392156862745, blue: 0.9019607843137255, alpha: 1.0)])

        /// Rea
        public static let rea = Self("Rea", [NSUIColor(red: 1.0, green: 0.8784313725490196, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.4745098039215686, green: 0.6235294117647059, blue: 0.047058823529411764, alpha: 1.0)])

        /// Windy
        public static let windy = Self("Windy", [NSUIColor(red: 0.6745098039215687, green: 0.7137254901960784, blue: 0.8980392156862745, alpha: 1.0), NSUIColor(red: 0.5254901960784314, green: 0.9921568627450981, blue: 0.9098039215686274, alpha: 1.0)])

        /// Royal Blue
        public static let royalBlue = Self("Royal Blue", [NSUIColor(red: 0.3254901960784314, green: 0.4117647058823529, blue: 0.4627450980392157, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 0.1803921568627451, blue: 0.28627450980392155, alpha: 1.0)])

        /// Royal Blue Petrol
        public static let royalBluePetrol = Self("Royal Blue Petrol", [NSUIColor(red: 0.7333333333333333, green: 0.8235294117647058, blue: 0.7725490196078432, alpha: 1.0), NSUIColor(red: 0.3254901960784314, green: 0.4117647058823529, blue: 0.4627450980392157, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 0.1803921568627451, blue: 0.28627450980392155, alpha: 1.0)])

        /// Copper
        public static let copper = Self("Copper", [NSUIColor(red: 0.7176470588235294, green: 0.596078431372549, blue: 0.5686274509803921, alpha: 1.0), NSUIColor(red: 0.5803921568627451, green: 0.44313725490196076, blue: 0.4196078431372549, alpha: 1.0)])

        /// Anamnisar
        public static let anamnisar = Self("Anamnisar", [NSUIColor(red: 0.592156862745098, green: 0.5882352941176471, blue: 0.9411764705882353, alpha: 1.0), NSUIColor(red: 0.984313725490196, green: 0.7803921568627451, blue: 0.8313725490196079, alpha: 1.0)])

        /// Petrol
        public static let petrol = Self("Petrol", [NSUIColor(red: 0.7333333333333333, green: 0.8235294117647058, blue: 0.7725490196078432, alpha: 1.0), NSUIColor(red: 0.3254901960784314, green: 0.4117647058823529, blue: 0.4627450980392157, alpha: 1.0)])

        /// Sel
        public static let sel = Self("Sel", [NSUIColor(red: 0.0, green: 0.27450980392156865, blue: 0.4980392156862745, alpha: 1.0), NSUIColor(red: 0.6470588235294118, green: 0.8, blue: 0.5098039215686274, alpha: 1.0)])

        /// Afternoon
        public static let afternoon = Self("Afternoon", [NSUIColor(red: 0.0, green: 0.047058823529411764, blue: 0.25098039215686274, alpha: 1.0), NSUIColor(red: 0.3764705882352941, green: 0.49019607843137253, blue: 0.5450980392156862, alpha: 1.0)])

        /// Skyline
        public static let skyline = Self("Skyline", [NSUIColor(red: 0.0784313725490196, green: 0.5333333333333333, blue: 0.8, alpha: 1.0), NSUIColor(red: 0.16862745098039217, green: 0.19607843137254902, blue: 0.6980392156862745, alpha: 1.0)])

        /// D I M I G O
        public static let dIMIGO = Self("D I M I G O", [NSUIColor(red: 0.9254901960784314, green: 0.0, blue: 0.5490196078431373, alpha: 1.0), NSUIColor(red: 0.9882352941176471, green: 0.403921568627451, blue: 0.403921568627451, alpha: 1.0)])

        /// Purple Love
        public static let purpleLove = Self("Purple Love", [NSUIColor(red: 0.8, green: 0.16862745098039217, blue: 0.3686274509803922, alpha: 1.0), NSUIColor(red: 0.4588235294117647, green: 0.22745098039215686, blue: 0.5333333333333333, alpha: 1.0)])

        /// Sexy Blue
        public static let sexyBlue = Self("Sexy Blue", [NSUIColor(red: 0.12941176470588237, green: 0.5764705882352941, blue: 0.6901960784313725, alpha: 1.0), NSUIColor(red: 0.42745098039215684, green: 0.8352941176470589, blue: 0.9294117647058824, alpha: 1.0)])

        /// Blooker
        public static let blooker = Self("Blooker", [NSUIColor(red: 0.9019607843137255, green: 0.3607843137254902, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.9764705882352941, green: 0.8313725490196079, blue: 0.13725490196078433, alpha: 1.0)])

        /// Sea Blue
        public static let seaBlue = Self("Sea Blue", [NSUIColor(red: 0.16862745098039217, green: 0.34509803921568627, blue: 0.4627450980392157, alpha: 1.0), NSUIColor(red: 0.3058823529411765, green: 0.2627450980392157, blue: 0.4627450980392157, alpha: 1.0)])

        /// Nimvelo
        public static let nimvelo = Self("Nimvelo", [NSUIColor(red: 0.19215686274509805, green: 0.2784313725490196, blue: 0.3333333333333333, alpha: 1.0), NSUIColor(red: 0.14901960784313725, green: 0.6274509803921569, blue: 0.8549019607843137, alpha: 1.0)])

        /// Hazel
        public static let hazel = Self("Hazel", [NSUIColor(red: 0.4666666666666667, green: 0.6313725490196078, blue: 0.8274509803921568, alpha: 1.0), NSUIColor(red: 0.4745098039215686, green: 0.796078431372549, blue: 0.792156862745098, alpha: 1.0), NSUIColor(red: 0.9019607843137255, green: 0.5176470588235295, blue: 0.6823529411764706, alpha: 1.0)])

        /// Noonto Dusk
        public static let noontoDusk = Self("Noonto Dusk", [NSUIColor(red: 1.0, green: 0.43137254901960786, blue: 0.4980392156862745, alpha: 1.0), NSUIColor(red: 0.7490196078431373, green: 0.9137254901960784, blue: 1.0, alpha: 1.0)])

        /// You Tube
        public static let youTube = Self("You Tube", [NSUIColor(red: 0.8980392156862745, green: 0.17647058823529413, blue: 0.15294117647058825, alpha: 1.0), NSUIColor(red: 0.7019607843137254, green: 0.07058823529411765, blue: 0.09019607843137255, alpha: 1.0)])

        /// Cool Brown
        public static let coolBrown = Self("Cool Brown", [NSUIColor(red: 0.3764705882352941, green: 0.2196078431372549, blue: 0.07450980392156863, alpha: 1.0), NSUIColor(red: 0.6980392156862745, green: 0.6235294117647059, blue: 0.5803921568627451, alpha: 1.0)])

        /// Harmonic Energy
        public static let harmonicEnergy = Self("Harmonic Energy", [NSUIColor(red: 0.08627450980392157, green: 0.6274509803921569, blue: 0.5215686274509804, alpha: 1.0), NSUIColor(red: 0.9568627450980393, green: 0.8156862745098039, blue: 0.24705882352941178, alpha: 1.0)])

        /// Playingwith Reds
        public static let playingwithReds = Self("Playingwith Reds", [NSUIColor(red: 0.8274509803921568, green: 0.06274509803921569, blue: 0.15294117647058825, alpha: 1.0), NSUIColor(red: 0.9176470588235294, green: 0.2196078431372549, blue: 0.30196078431372547, alpha: 1.0)])

        /// Sunny Days
        public static let sunnyDays = Self("Sunny Days", [NSUIColor(red: 0.9294117647058824, green: 0.8980392156862745, blue: 0.4549019607843137, alpha: 1.0), NSUIColor(red: 0.8823529411764706, green: 0.9607843137254902, blue: 0.7686274509803922, alpha: 1.0)])

        /// Green Beach
        public static let greenBeach = Self("Green Beach", [NSUIColor(red: 0.00784313725490196, green: 0.6666666666666666, blue: 0.6901960784313725, alpha: 1.0), NSUIColor(red: 0.0, green: 0.803921568627451, blue: 0.6745098039215687, alpha: 1.0)])

        /// Intuitive Purple
        public static let intuitivePurple = Self("Intuitive Purple", [NSUIColor(red: 0.8549019607843137, green: 0.13333333333333333, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.592156862745098, green: 0.2, blue: 0.9333333333333333, alpha: 1.0)])

        /// Emerald Water
        public static let emeraldWater = Self("Emerald Water", [NSUIColor(red: 0.20392156862745098, green: 0.5607843137254902, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.33725490196078434, green: 0.7058823529411765, blue: 0.8274509803921568, alpha: 1.0)])

        /// Lemon Twist
        public static let lemonTwist = Self("Lemon Twist", [NSUIColor(red: 0.23529411764705882, green: 0.6470588235294118, blue: 0.3607843137254902, alpha: 1.0), NSUIColor(red: 0.7098039215686275, green: 0.6745098039215687, blue: 0.28627450980392155, alpha: 1.0)])

        /// Monte Carlo
        public static let monteCarlo = Self("Monte Carlo", [NSUIColor(red: 0.8, green: 0.5843137254901961, blue: 0.7529411764705882, alpha: 1.0), NSUIColor(red: 0.8588235294117647, green: 0.8313725490196079, blue: 0.7058823529411765, alpha: 1.0), NSUIColor(red: 0.47843137254901963, green: 0.6313725490196078, blue: 0.8235294117647058, alpha: 1.0)])

        /// Horizon
        public static let horizon = Self("Horizon", [NSUIColor(red: 0.0, green: 0.2235294117647059, blue: 0.45098039215686275, alpha: 1.0), NSUIColor(red: 0.8980392156862745, green: 0.8980392156862745, blue: 0.7450980392156863, alpha: 1.0)])

        /// Rose Water
        public static let roseWater = Self("Rose Water", [NSUIColor(red: 0.8980392156862745, green: 0.36470588235294116, blue: 0.5294117647058824, alpha: 1.0), NSUIColor(red: 0.37254901960784315, green: 0.7647058823529411, blue: 0.8941176470588236, alpha: 1.0)])

        /// Frozen
        public static let frozen = Self("Frozen", [NSUIColor(red: 0.25098039215686274, green: 0.23137254901960785, blue: 0.2901960784313726, alpha: 1.0), NSUIColor(red: 0.9058823529411765, green: 0.9137254901960784, blue: 0.7333333333333333, alpha: 1.0)])

        /// Mango Pulp
        public static let mangoPulp = Self("Mango Pulp", [NSUIColor(red: 0.9411764705882353, green: 0.596078431372549, blue: 0.09803921568627451, alpha: 1.0), NSUIColor(red: 0.9294117647058824, green: 0.8705882352941177, blue: 0.36470588235294116, alpha: 1.0)])

        /// Bloody Mary
        public static let bloodyMary = Self("Bloody Mary", [NSUIColor(red: 1.0, green: 0.3176470588235294, blue: 0.1843137254901961, alpha: 1.0), NSUIColor(red: 0.8666666666666667, green: 0.1411764705882353, blue: 0.4627450980392157, alpha: 1.0)])

        /// Aubergine
        public static let aubergine = Self("Aubergine", [NSUIColor(red: 0.6666666666666666, green: 0.027450980392156862, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.3803921568627451, green: 0.01568627450980392, blue: 0.37254901960784315, alpha: 1.0)])

        /// Aqua Marine
        public static let aquaMarine = Self("Aqua Marine", [NSUIColor(red: 0.10196078431372549, green: 0.1607843137254902, blue: 0.5019607843137255, alpha: 1.0), NSUIColor(red: 0.14901960784313725, green: 0.8156862745098039, blue: 0.807843137254902, alpha: 1.0)])

        /// Sunrise
        public static let sunrise = Self("Sunrise", [NSUIColor(red: 1.0, green: 0.3176470588235294, blue: 0.1843137254901961, alpha: 1.0), NSUIColor(red: 0.9411764705882353, green: 0.596078431372549, blue: 0.09803921568627451, alpha: 1.0)])

        /// Purple Paradise
        public static let purpleParadise = Self("Purple Paradise", [NSUIColor(red: 0.11372549019607843, green: 0.16862745098039217, blue: 0.39215686274509803, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 0.803921568627451, blue: 0.8549019607843137, alpha: 1.0)])

        /// Stripe
        public static let stripe = Self("Stripe", [NSUIColor(red: 0.12156862745098039, green: 0.6352941176470588, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.07058823529411765, green: 0.8470588235294118, blue: 0.9803921568627451, alpha: 1.0), NSUIColor(red: 0.6509803921568628, green: 1.0, blue: 0.796078431372549, alpha: 1.0)])

        /// Sea Weed
        public static let seaWeed = Self("Sea Weed", [NSUIColor(red: 0.2980392156862745, green: 0.7215686274509804, blue: 0.7686274509803922, alpha: 1.0), NSUIColor(red: 0.23529411764705882, green: 0.8274509803921568, blue: 0.6784313725490196, alpha: 1.0)])

        /// Pinky
        public static let pinky = Self("Pinky", [NSUIColor(red: 0.8666666666666667, green: 0.3686274509803922, blue: 0.5372549019607843, alpha: 1.0), NSUIColor(red: 0.9686274509803922, green: 0.7333333333333333, blue: 0.592156862745098, alpha: 1.0)])

        /// Cherry
        public static let cherry = Self("Cherry", [NSUIColor(red: 0.9215686274509803, green: 0.2, blue: 0.28627450980392155, alpha: 1.0), NSUIColor(red: 0.9568627450980393, green: 0.3607843137254902, blue: 0.2627450980392157, alpha: 1.0)])

        /// Mojito
        public static let mojito = Self("Mojito", [NSUIColor(red: 0.11372549019607843, green: 0.592156862745098, blue: 0.4235294117647059, alpha: 1.0), NSUIColor(red: 0.5764705882352941, green: 0.9764705882352941, blue: 0.7254901960784313, alpha: 1.0)])

        /// Juicy Orange
        public static let juicyOrange = Self("Juicy Orange", [NSUIColor(red: 1.0, green: 0.5019607843137255, blue: 0.03137254901960784, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7843137254901961, blue: 0.21568627450980393, alpha: 1.0)])

        /// Mirage
        public static let mirage = Self("Mirage", [NSUIColor(red: 0.08627450980392157, green: 0.13333333333333333, blue: 0.16470588235294117, alpha: 1.0), NSUIColor(red: 0.22745098039215686, green: 0.3764705882352941, blue: 0.45098039215686275, alpha: 1.0)])

        /// Steel Gray
        public static let steelGray = Self("Steel Gray", [NSUIColor(red: 0.12156862745098039, green: 0.10980392156862745, blue: 0.17254901960784313, alpha: 1.0), NSUIColor(red: 0.5725490196078431, green: 0.5529411764705883, blue: 0.6705882352941176, alpha: 1.0)])

        /// Kashmir
        public static let kashmir = Self("Kashmir", [NSUIColor(red: 0.3803921568627451, green: 0.2627450980392157, blue: 0.5215686274509804, alpha: 1.0), NSUIColor(red: 0.3176470588235294, green: 0.38823529411764707, blue: 0.5843137254901961, alpha: 1.0)])

        /// Electric Violet
        public static let electricViolet = Self("Electric Violet", [NSUIColor(red: 0.2784313725490196, green: 0.4627450980392157, blue: 0.9019607843137255, alpha: 1.0), NSUIColor(red: 0.5568627450980392, green: 0.32941176470588235, blue: 0.9137254901960784, alpha: 1.0)])

        /// Venice Blue
        public static let veniceBlue = Self("Venice Blue", [NSUIColor(red: 0.03137254901960784, green: 0.3137254901960784, blue: 0.47058823529411764, alpha: 1.0), NSUIColor(red: 0.5215686274509804, green: 0.8470588235294118, blue: 0.807843137254902, alpha: 1.0)])

        /// Bora Bora
        public static let boraBora = Self("Bora Bora", [NSUIColor(red: 0.16862745098039217, green: 0.7529411764705882, blue: 0.8941176470588236, alpha: 1.0), NSUIColor(red: 0.9176470588235294, green: 0.9254901960784314, blue: 0.7764705882352941, alpha: 1.0)])

        /// Moss
        public static let moss = Self("Moss", [NSUIColor(red: 0.07450980392156863, green: 0.3058823529411765, blue: 0.3686274509803922, alpha: 1.0), NSUIColor(red: 0.44313725490196076, green: 0.6980392156862745, blue: 0.5019607843137255, alpha: 1.0)])

        /// Shroom Haze
        public static let shroomHaze = Self("Shroom Haze", [NSUIColor(red: 0.3607843137254902, green: 0.1450980392156863, blue: 0.5529411764705883, alpha: 1.0), NSUIColor(red: 0.2627450980392157, green: 0.5372549019607843, blue: 0.6352941176470588, alpha: 1.0)])

        /// Mystic
        public static let mystic = Self("Mystic", [NSUIColor(red: 0.4588235294117647, green: 0.4980392156862745, blue: 0.6039215686274509, alpha: 1.0), NSUIColor(red: 0.8431372549019608, green: 0.8666666666666667, blue: 0.9098039215686274, alpha: 1.0)])

        /// Midnight City
        public static let midnightCity = Self("Midnight City", [NSUIColor(red: 0.13725490196078433, green: 0.1450980392156863, blue: 0.14901960784313725, alpha: 1.0), NSUIColor(red: 0.2549019607843137, green: 0.2627450980392157, blue: 0.27058823529411763, alpha: 1.0)])

        /// Sea Blizz
        public static let seaBlizz = Self("Sea Blizz", [NSUIColor(red: 0.10980392156862745, green: 0.8470588235294118, blue: 0.8235294117647058, alpha: 1.0), NSUIColor(red: 0.5764705882352941, green: 0.9294117647058824, blue: 0.7803921568627451, alpha: 1.0)])

        /// Opa
        public static let opa = Self("Opa", [NSUIColor(red: 0.23921568627450981, green: 0.49411764705882355, blue: 0.6666666666666666, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8941176470588236, blue: 0.47843137254901963, alpha: 1.0)])

        /// Titanium
        public static let titanium = Self("Titanium", [NSUIColor(red: 0.1568627450980392, green: 0.18823529411764706, blue: 0.2823529411764706, alpha: 1.0), NSUIColor(red: 0.5215686274509804, green: 0.5764705882352941, blue: 0.596078431372549, alpha: 1.0)])

        /// Mantle
        public static let mantle = Self("Mantle", [NSUIColor(red: 0.1411764705882353, green: 0.7764705882352941, blue: 0.8627450980392157, alpha: 1.0), NSUIColor(red: 0.3176470588235294, green: 0.2901960784313726, blue: 0.615686274509804, alpha: 1.0)])

        /// Dracula
        public static let dracula = Self("Dracula", [NSUIColor(red: 0.8627450980392157, green: 0.1411764705882353, blue: 0.1411764705882353, alpha: 1.0), NSUIColor(red: 0.2901960784313726, green: 0.33725490196078434, blue: 0.615686274509804, alpha: 1.0)])

        /// Peach
        public static let peach = Self("Peach", [NSUIColor(red: 0.9294117647058824, green: 0.25882352941176473, blue: 0.39215686274509803, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9294117647058824, blue: 0.7372549019607844, alpha: 1.0)])

        /// Moonrise
        public static let moonrise = Self("Moonrise", [NSUIColor(red: 0.8549019607843137, green: 0.8862745098039215, blue: 0.9725490196078431, alpha: 1.0), NSUIColor(red: 0.8392156862745098, green: 0.6431372549019608, blue: 0.6431372549019608, alpha: 1.0)])

        /// Clouds
        public static let clouds = Self("Clouds", [NSUIColor(red: 0.9254901960784314, green: 0.9137254901960784, blue: 0.9019607843137255, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])

        /// Stellar
        public static let stellar = Self("Stellar", [NSUIColor(red: 0.4549019607843137, green: 0.4549019607843137, blue: 0.7490196078431373, alpha: 1.0), NSUIColor(red: 0.20392156862745098, green: 0.5411764705882353, blue: 0.7803921568627451, alpha: 1.0)])

        /// Bourbon
        public static let bourbon = Self("Bourbon", [NSUIColor(red: 0.9254901960784314, green: 0.43529411764705883, blue: 0.4, alpha: 1.0), NSUIColor(red: 0.9529411764705882, green: 0.6313725490196078, blue: 0.5137254901960784, alpha: 1.0)])

        /// Calm Darya
        public static let calmDarya = Self("Calm Darya", [NSUIColor(red: 0.37254901960784315, green: 0.17254901960784313, blue: 0.5098039215686274, alpha: 1.0), NSUIColor(red: 0.28627450980392155, green: 0.6274509803921569, blue: 0.615686274509804, alpha: 1.0)])

        /// Influenza
        public static let influenza = Self("Influenza", [NSUIColor(red: 0.7529411764705882, green: 0.2823529411764706, blue: 0.2823529411764706, alpha: 1.0), NSUIColor(red: 0.2823529411764706, green: 0.0, blue: 0.2823529411764706, alpha: 1.0)])

        /// Shrimpy
        public static let shrimpy = Self("Shrimpy", [NSUIColor(red: 0.8941176470588236, green: 0.22745098039215686, blue: 0.08235294117647059, alpha: 1.0), NSUIColor(red: 0.9019607843137255, green: 0.3215686274509804, blue: 0.27058823529411763, alpha: 1.0)])

        /// Army
        public static let army = Self("Army", [NSUIColor(red: 0.2549019607843137, green: 0.30196078431372547, blue: 0.043137254901960784, alpha: 1.0), NSUIColor(red: 0.4470588235294118, green: 0.47843137254901963, blue: 0.09019607843137255, alpha: 1.0)])

        /// Miaka
        public static let miaka = Self("Miaka", [NSUIColor(red: 0.9882352941176471, green: 0.20784313725490197, blue: 0.2980392156862745, alpha: 1.0), NSUIColor(red: 0.0392156862745098, green: 0.7490196078431373, blue: 0.7372549019607844, alpha: 1.0)])

        /// Pinot Noir
        public static let pinotNoir = Self("Pinot Noir", [NSUIColor(red: 0.29411764705882354, green: 0.4235294117647059, blue: 0.7176470588235294, alpha: 1.0), NSUIColor(red: 0.09411764705882353, green: 0.1568627450980392, blue: 0.2823529411764706, alpha: 1.0)])

        /// Day Tripper
        public static let dayTripper = Self("Day Tripper", [NSUIColor(red: 0.9725490196078431, green: 0.3411764705882353, blue: 0.6509803921568628, alpha: 1.0), NSUIColor(red: 1.0, green: 0.34509803921568627, blue: 0.34509803921568627, alpha: 1.0)])

        /// Namn
        public static let namn = Self("Namn", [NSUIColor(red: 0.6549019607843137, green: 0.21568627450980393, blue: 0.21568627450980393, alpha: 1.0), NSUIColor(red: 0.47843137254901963, green: 0.1568627450980392, blue: 0.1568627450980392, alpha: 1.0)])

        /// Blurry Beach
        public static let blurryBeach = Self("Blurry Beach", [NSUIColor(red: 0.8352941176470589, green: 0.2, blue: 0.4117647058823529, alpha: 1.0), NSUIColor(red: 0.796078431372549, green: 0.6784313725490196, blue: 0.42745098039215684, alpha: 1.0)])

        /// Vasily
        public static let vasily = Self("Vasily", [NSUIColor(red: 0.9137254901960784, green: 0.8274509803921568, blue: 0.3843137254901961, alpha: 1.0), NSUIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)])

        /// A Lost Memory
        public static let aLostMemory = Self("A Lost Memory", [NSUIColor(red: 0.8705882352941177, green: 0.3843137254901961, blue: 0.3843137254901961, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7215686274509804, blue: 0.5490196078431373, alpha: 1.0)])

        /// Petrichor
        public static let petrichor = Self("Petrichor", [NSUIColor(red: 0.4, green: 0.4, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.6, green: 0.6, blue: 0.4, alpha: 1.0)])

        /// Jonquil
        public static let jonquil = Self("Jonquil", [NSUIColor(red: 1.0, green: 0.9333333333333333, blue: 0.9333333333333333, alpha: 1.0), NSUIColor(red: 0.8666666666666667, green: 0.9372549019607843, blue: 0.7333333333333333, alpha: 1.0)])

        /// Sirius Tamed
        public static let siriusTamed = Self("Sirius Tamed", [NSUIColor(red: 0.9372549019607843, green: 0.9372549019607843, blue: 0.7333333333333333, alpha: 1.0), NSUIColor(red: 0.8313725490196079, green: 0.8274509803921568, blue: 0.8666666666666667, alpha: 1.0)])

        /// Kyoto
        public static let kyoto = Self("Kyoto", [NSUIColor(red: 0.7607843137254902, green: 0.08235294117647059, blue: 0.0, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7725490196078432, blue: 0.0, alpha: 1.0)])

        /// Misty Meadow
        public static let mistyMeadow = Self("Misty Meadow", [NSUIColor(red: 0.12941176470588237, green: 0.37254901960784315, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.8941176470588236, green: 0.8941176470588236, blue: 0.8509803921568627, alpha: 1.0)])

        /// Aqualicious
        public static let aqualicious = Self("Aqualicious", [NSUIColor(red: 0.3137254901960784, green: 0.788235294117647, blue: 0.7647058823529411, alpha: 1.0), NSUIColor(red: 0.5882352941176471, green: 0.8705882352941177, blue: 0.8549019607843137, alpha: 1.0)])

        /// Moor
        public static let moor = Self("Moor", [NSUIColor(red: 0.3803921568627451, green: 0.3803921568627451, blue: 0.3803921568627451, alpha: 1.0), NSUIColor(red: 0.6078431372549019, green: 0.7725490196078432, blue: 0.7647058823529411, alpha: 1.0)])

        /// Almost
        public static let almost = Self("Almost", [NSUIColor(red: 0.8666666666666667, green: 0.8392156862745098, blue: 0.9529411764705882, alpha: 1.0), NSUIColor(red: 0.9803921568627451, green: 0.6745098039215687, blue: 0.6588235294117647, alpha: 1.0)])

        /// Forever Lost
        public static let foreverLost = Self("Forever Lost", [NSUIColor(red: 0.36470588235294116, green: 0.2549019607843137, blue: 0.3411764705882353, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.792156862745098, blue: 0.7294117647058823, alpha: 1.0)])

        /// Winter
        public static let winter = Self("Winter", [NSUIColor(red: 0.9019607843137255, green: 0.8549019607843137, blue: 0.8549019607843137, alpha: 1.0), NSUIColor(red: 0.15294117647058825, green: 0.25098039215686274, blue: 0.27450980392156865, alpha: 1.0)])

        /// Nelson
        public static let nelson = Self("Nelson", [NSUIColor(red: 0.9490196078431372, green: 0.4392156862745098, blue: 0.611764705882353, alpha: 1.0), NSUIColor(red: 1.0, green: 0.5803921568627451, blue: 0.4470588235294118, alpha: 1.0)])

        /// Autumn
        public static let autumn = Self("Autumn", [NSUIColor(red: 0.8549019607843137, green: 0.8235294117647058, blue: 0.6, alpha: 1.0), NSUIColor(red: 0.6901960784313725, green: 0.8549019607843137, blue: 0.7254901960784313, alpha: 1.0)])

        /// Candy
        public static let candy = Self("Candy", [NSUIColor(red: 0.8274509803921568, green: 0.5843137254901961, blue: 0.6078431372549019, alpha: 1.0), NSUIColor(red: 0.7490196078431373, green: 0.9019607843137255, blue: 0.7294117647058823, alpha: 1.0)])

        /// Reef
        public static let reef = Self("Reef", [NSUIColor(red: 0.0, green: 0.8235294117647058, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.22745098039215686, green: 0.4823529411764706, blue: 0.8352941176470589, alpha: 1.0)])

        /// The Strain
        public static let theStrain = Self("The Strain", [NSUIColor(red: 0.5294117647058824, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.09803921568627451, green: 0.0392156862745098, blue: 0.0196078431372549, alpha: 1.0)])

        /// Dirty Fog
        public static let dirtyFog = Self("Dirty Fog", [NSUIColor(red: 0.7254901960784313, green: 0.5764705882352941, blue: 0.8392156862745098, alpha: 1.0), NSUIColor(red: 0.5490196078431373, green: 0.6509803921568628, blue: 0.8588235294117647, alpha: 1.0)])

        /// Earthly
        public static let earthly = Self("Earthly", [NSUIColor(red: 0.39215686274509803, green: 0.5686274509803921, blue: 0.45098039215686275, alpha: 1.0), NSUIColor(red: 0.8588235294117647, green: 0.8352941176470589, blue: 0.6431372549019608, alpha: 1.0)])

        /// Virgin
        public static let virgin = Self("Virgin", [NSUIColor(red: 0.788235294117647, green: 1.0, blue: 0.7490196078431373, alpha: 1.0), NSUIColor(red: 1.0, green: 0.6862745098039216, blue: 0.7411764705882353, alpha: 1.0)])

        /// Ash
        public static let ash = Self("Ash", [NSUIColor(red: 0.3764705882352941, green: 0.4235294117647059, blue: 0.5333333333333333, alpha: 1.0), NSUIColor(red: 0.24705882352941178, green: 0.2980392156862745, blue: 0.4196078431372549, alpha: 1.0)])

        /// Cherryblossoms
        public static let cherryblossoms = Self("Cherryblossoms", [NSUIColor(red: 0.984313725490196, green: 0.8274509803921568, blue: 0.9137254901960784, alpha: 1.0), NSUIColor(red: 0.7333333333333333, green: 0.21568627450980393, blue: 0.49019607843137253, alpha: 1.0)])

        /// Parklife
        public static let parklife = Self("Parklife", [NSUIColor(red: 0.6784313725490196, green: 0.8196078431372549, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.4823529411764706, green: 0.5725490196078431, blue: 0.0392156862745098, alpha: 1.0)])

        /// Dance To Forget
        public static let danceToForget = Self("Dance To Forget", [NSUIColor(red: 1.0, green: 0.3058823529411765, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.9764705882352941, green: 0.8313725490196079, blue: 0.13725490196078433, alpha: 1.0)])

        /// Starfall
        public static let starfall = Self("Starfall", [NSUIColor(red: 0.9411764705882353, green: 0.7607843137254902, blue: 0.4823529411764706, alpha: 1.0), NSUIColor(red: 0.29411764705882354, green: 0.07058823529411765, blue: 0.2823529411764706, alpha: 1.0)])

        /// Red Mist
        public static let redMist = Self("Red Mist", [NSUIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.9058823529411765, green: 0.2980392156862745, blue: 0.23529411764705882, alpha: 1.0)])

        /// Teal Love
        public static let tealLove = Self("Teal Love", [NSUIColor(red: 0.6666666666666666, green: 1.0, blue: 0.6627450980392157, alpha: 1.0), NSUIColor(red: 0.06666666666666667, green: 1.0, blue: 0.7411764705882353, alpha: 1.0)])

        /// Neon Life
        public static let neonLife = Self("Neon Life", [NSUIColor(red: 0.7019607843137254, green: 1.0, blue: 0.6705882352941176, alpha: 1.0), NSUIColor(red: 0.07058823529411765, green: 1.0, blue: 0.9686274509803922, alpha: 1.0)])

        /// Manof Steel
        public static let manofSteel = Self("Manof Steel", [NSUIColor(red: 0.47058823529411764, green: 0.00784313725490196, blue: 0.023529411764705882, alpha: 1.0), NSUIColor(red: 0.023529411764705882, green: 0.06666666666666667, blue: 0.3803921568627451, alpha: 1.0)])

        /// Amethyst
        public static let amethyst = Self("Amethyst", [NSUIColor(red: 0.615686274509804, green: 0.3137254901960784, blue: 0.7333333333333333, alpha: 1.0), NSUIColor(red: 0.43137254901960786, green: 0.2823529411764706, blue: 0.6666666666666666, alpha: 1.0)])

        /// Cheer Up Emo Kid
        public static let cheerUpEmoKid = Self("Cheer Up Emo Kid", [NSUIColor(red: 0.3333333333333333, green: 0.3843137254901961, blue: 0.4392156862745098, alpha: 1.0), NSUIColor(red: 1.0, green: 0.4196078431372549, blue: 0.4196078431372549, alpha: 1.0)])

        /// Shore
        public static let shore = Self("Shore", [NSUIColor(red: 0.4392156862745098, green: 0.8823529411764706, blue: 0.9607843137254902, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8196078431372549, blue: 0.5803921568627451, alpha: 1.0)])

        /// Facebook Messenger
        public static let facebookMessenger = Self("Facebook Messenger", [NSUIColor(red: 0.0, green: 0.7764705882352941, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.0, green: 0.4470588235294118, blue: 1.0, alpha: 1.0)])

        /// Sound Cloud
        public static let soundCloud = Self("Sound Cloud", [NSUIColor(red: 0.996078431372549, green: 0.5490196078431373, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 0.21176470588235294, blue: 0.0, alpha: 1.0)])

        /// Behongo
        public static let behongo = Self("Behongo", [NSUIColor(red: 0.3215686274509804, green: 0.7607843137254902, blue: 0.20392156862745098, alpha: 1.0), NSUIColor(red: 0.023529411764705882, green: 0.09019607843137255, blue: 0.0, alpha: 1.0)])

        /// Serv Quick
        public static let servQuick = Self("Serv Quick", [NSUIColor(red: 0.2823529411764706, green: 0.3333333333333333, blue: 0.38823529411764707, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 0.19607843137254902, blue: 0.23529411764705882, alpha: 1.0)])

        /// Friday
        public static let friday = Self("Friday", [NSUIColor(red: 0.5137254901960784, green: 0.6431372549019608, blue: 0.8313725490196079, alpha: 1.0), NSUIColor(red: 0.7137254901960784, green: 0.984313725490196, blue: 1.0, alpha: 1.0)])

        /// Martini
        public static let martini = Self("Martini", [NSUIColor(red: 0.9921568627450981, green: 0.9882352941176471, blue: 0.2784313725490196, alpha: 1.0), NSUIColor(red: 0.1411764705882353, green: 0.996078431372549, blue: 0.2549019607843137, alpha: 1.0)])

        /// Metallic Toad
        public static let metallicToad = Self("Metallic Toad", [NSUIColor(red: 0.6705882352941176, green: 0.7294117647058823, blue: 0.6705882352941176, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])

        /// Between The Clouds
        public static let betweenTheClouds = Self("Between The Clouds", [NSUIColor(red: 0.45098039215686275, green: 0.7843137254901961, blue: 0.6627450980392157, alpha: 1.0), NSUIColor(red: 0.21568627450980393, green: 0.23137254901960785, blue: 0.26666666666666666, alpha: 1.0)])

        /// Crazy Orange I
        public static let crazyOrangeI = Self("Crazy Orange I", [NSUIColor(red: 0.8274509803921568, green: 0.5137254901960784, blue: 0.07058823529411765, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.19607843137254902, blue: 0.4745098039215686, alpha: 1.0)])

        /// Hersheys
        public static let hersheys = Self("Hersheys", [NSUIColor(red: 0.11764705882352941, green: 0.07450980392156863, blue: 0.047058823529411764, alpha: 1.0), NSUIColor(red: 0.6039215686274509, green: 0.5176470588235295, blue: 0.47058823529411764, alpha: 1.0)])

        /// Talking To Mice Elf
        public static let talkingToMiceElf = Self("Talking To Mice Elf", [NSUIColor(red: 0.5803921568627451, green: 0.5568627450980392, blue: 0.6, alpha: 1.0), NSUIColor(red: 0.1803921568627451, green: 0.0784313725490196, blue: 0.21568627450980393, alpha: 1.0)])

        /// Purple Bliss
        public static let purpleBliss = Self("Purple Bliss", [NSUIColor(red: 0.21176470588235294, green: 0.0, blue: 0.2, alpha: 1.0), NSUIColor(red: 0.043137254901960784, green: 0.5294117647058824, blue: 0.5764705882352941, alpha: 1.0)])

        /// Predawn
        public static let predawn = Self("Predawn", [NSUIColor(red: 1.0, green: 0.6313725490196078, blue: 0.4980392156862745, alpha: 1.0), NSUIColor(red: 0.0, green: 0.13333333333333333, blue: 0.24313725490196078, alpha: 1.0)])

        /// Endless River
        public static let endlessRiver = Self("Endless River", [NSUIColor(red: 0.2627450980392157, green: 0.807843137254902, blue: 0.6352941176470588, alpha: 1.0), NSUIColor(red: 0.09411764705882353, green: 0.35294117647058826, blue: 0.615686274509804, alpha: 1.0)])

        /// Pastel Orangeatthe Sun
        public static let pastelOrangeattheSun = Self("Pastel Orangeatthe Sun", [NSUIColor(red: 1.0, green: 0.7019607843137254, blue: 0.2784313725490196, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)])

        /// Twitch
        public static let twitch = Self("Twitch", [NSUIColor(red: 0.39215686274509803, green: 0.2549019607843137, blue: 0.6470588235294118, alpha: 1.0), NSUIColor(red: 0.16470588235294117, green: 0.03137254901960784, blue: 0.27058823529411763, alpha: 1.0)])

        /// Atlas
        public static let atlas = Self("Atlas", [NSUIColor(red: 0.996078431372549, green: 0.6745098039215687, blue: 0.3686274509803922, alpha: 1.0), NSUIColor(red: 0.7803921568627451, green: 0.4745098039215686, blue: 0.8156862745098039, alpha: 1.0), NSUIColor(red: 0.29411764705882354, green: 0.7529411764705882, blue: 0.7843137254901961, alpha: 1.0)])

        /// Instagram
        public static let instagram = Self("Instagram", [NSUIColor(red: 0.5137254901960784, green: 0.22745098039215686, blue: 0.7058823529411765, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.11372549019607843, blue: 0.11372549019607843, alpha: 1.0), NSUIColor(red: 0.9882352941176471, green: 0.6901960784313725, blue: 0.27058823529411763, alpha: 1.0)])

        /// Flickr
        public static let flickr = Self("Flickr", [NSUIColor(red: 1.0, green: 0.0, blue: 0.5176470588235295, alpha: 1.0), NSUIColor(red: 0.2, green: 0.0, blue: 0.10588235294117647, alpha: 1.0)])

        /// Vine
        public static let vine = Self("Vine", [NSUIColor(red: 0.0, green: 0.7490196078431373, blue: 0.5607843137254902, alpha: 1.0), NSUIColor(red: 0.0, green: 0.08235294117647059, blue: 0.06274509803921569, alpha: 1.0)])

        /// Turquoiseflow
        public static let turquoiseflow = Self("Turquoiseflow", [NSUIColor(red: 0.07450980392156863, green: 0.41568627450980394, blue: 0.5411764705882353, alpha: 1.0), NSUIColor(red: 0.14901960784313725, green: 0.47058823529411764, blue: 0.44313725490196076, alpha: 1.0)])

        /// Portrait
        public static let portrait = Self("Portrait", [NSUIColor(red: 0.5568627450980392, green: 0.6196078431372549, blue: 0.6705882352941176, alpha: 1.0), NSUIColor(red: 0.9333333333333333, green: 0.9490196078431372, blue: 0.9529411764705882, alpha: 1.0)])

        /// Virgin America
        public static let virginAmerica = Self("Virgin America", [NSUIColor(red: 0.4823529411764706, green: 0.2627450980392157, blue: 0.592156862745098, alpha: 1.0), NSUIColor(red: 0.8627450980392157, green: 0.1411764705882353, blue: 0.18823529411764706, alpha: 1.0)])

        /// Koko Caramel
        public static let kokoCaramel = Self("Koko Caramel", [NSUIColor(red: 0.8196078431372549, green: 0.5686274509803921, blue: 0.23529411764705882, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8196078431372549, blue: 0.5803921568627451, alpha: 1.0)])

        /// Fresh Turboscent
        public static let freshTurboscent = Self("Fresh Turboscent", [NSUIColor(red: 0.9450980392156862, green: 0.9490196078431372, blue: 0.7098039215686275, alpha: 1.0), NSUIColor(red: 0.07450980392156863, green: 0.3137254901960784, blue: 0.34509803921568627, alpha: 1.0)])

        /// Greentodark
        public static let greentodark = Self("Greentodark", [NSUIColor(red: 0.41568627450980394, green: 0.5686274509803921, blue: 0.07450980392156863, alpha: 1.0), NSUIColor(red: 0.0784313725490196, green: 0.08235294117647059, blue: 0.09019607843137255, alpha: 1.0)])

        /// Ukraine
        public static let ukraine = Self("Ukraine", [NSUIColor(red: 0.0, green: 0.30980392156862746, blue: 0.9764705882352941, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9764705882352941, blue: 0.2980392156862745, alpha: 1.0)])

        /// Curiosityblue
        public static let curiosityblue = Self("Curiosityblue", [NSUIColor(red: 0.3215686274509804, green: 0.3215686274509804, blue: 0.3215686274509804, alpha: 1.0), NSUIColor(red: 0.23921568627450981, green: 0.4470588235294118, blue: 0.7058823529411765, alpha: 1.0)])

        /// Dark Knight
        public static let darkKnight = Self("Dark Knight", [NSUIColor(red: 0.7294117647058823, green: 0.5450980392156862, blue: 0.00784313725490196, alpha: 1.0), NSUIColor(red: 0.09411764705882353, green: 0.09411764705882353, blue: 0.09411764705882353, alpha: 1.0)])

        /// Piglet
        public static let piglet = Self("Piglet", [NSUIColor(red: 0.9333333333333333, green: 0.611764705882353, blue: 0.6549019607843137, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8666666666666667, blue: 0.8823529411764706, alpha: 1.0)])

        /// Lizard
        public static let lizard = Self("Lizard", [NSUIColor(red: 0.18823529411764706, green: 0.2627450980392157, blue: 0.3215686274509804, alpha: 1.0), NSUIColor(red: 0.8431372549019608, green: 0.8235294117647058, blue: 0.8, alpha: 1.0)])

        /// Sage Persuasion
        public static let sagePersuasion = Self("Sage Persuasion", [NSUIColor(red: 0.8, green: 0.8, blue: 0.6980392156862745, alpha: 1.0), NSUIColor(red: 0.4588235294117647, green: 0.4588235294117647, blue: 0.09803921568627451, alpha: 1.0)])

        /// Between Nightand Day
        public static let betweenNightandDay = Self("Between Nightand Day", [NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.20392156862745098, green: 0.596078431372549, blue: 0.8588235294117647, alpha: 1.0)])

        /// Timber
        public static let timber = Self("Timber", [NSUIColor(red: 0.9882352941176471, green: 0.0, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.0, green: 0.8588235294117647, blue: 0.8705882352941177, alpha: 1.0)])

        /// Passion
        public static let passion = Self("Passion", [NSUIColor(red: 0.8980392156862745, green: 0.2235294117647059, blue: 0.20784313725490197, alpha: 1.0), NSUIColor(red: 0.8901960784313725, green: 0.36470588235294116, blue: 0.3568627450980392, alpha: 1.0)])

        /// Clear Sky
        public static let clearSky = Self("Clear Sky", [NSUIColor(red: 0.0, green: 0.3607843137254902, blue: 0.592156862745098, alpha: 1.0), NSUIColor(red: 0.21176470588235294, green: 0.21568627450980393, blue: 0.5843137254901961, alpha: 1.0)])

        /// Master Card
        public static let masterCard = Self("Master Card", [NSUIColor(red: 0.9568627450980393, green: 0.4196078431372549, blue: 0.27058823529411763, alpha: 1.0), NSUIColor(red: 0.9333333333333333, green: 0.6588235294117647, blue: 0.28627450980392155, alpha: 1.0)])

        /// Back To Earth
        public static let backToEarth = Self("Back To Earth", [NSUIColor(red: 0.0, green: 0.788235294117647, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.5725490196078431, green: 0.996078431372549, blue: 0.615686274509804, alpha: 1.0)])

        /// Deep Purple
        public static let deepPurple = Self("Deep Purple", [NSUIColor(red: 0.403921568627451, green: 0.22745098039215686, blue: 0.7176470588235294, alpha: 1.0), NSUIColor(red: 0.3176470588235294, green: 0.17647058823529413, blue: 0.6588235294117647, alpha: 1.0)])

        /// Little Leaf
        public static let littleLeaf = Self("Little Leaf", [NSUIColor(red: 0.4627450980392157, green: 0.7215686274509804, blue: 0.3215686274509804, alpha: 1.0), NSUIColor(red: 0.5529411764705883, green: 0.7607843137254902, blue: 0.43529411764705883, alpha: 1.0)])

        /// Netflix
        public static let netflix = Self("Netflix", [NSUIColor(red: 0.5568627450980392, green: 0.054901960784313725, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.12156862745098039, green: 0.10980392156862745, blue: 0.09411764705882353, alpha: 1.0)])

        /// Light Orange
        public static let lightOrange = Self("Light Orange", [NSUIColor(red: 1.0, green: 0.7176470588235294, blue: 0.3686274509803922, alpha: 1.0), NSUIColor(red: 0.9294117647058824, green: 0.5607843137254902, blue: 0.011764705882352941, alpha: 1.0)])

        /// Greenand Blue
        public static let greenandBlue = Self("Greenand Blue", [NSUIColor(red: 0.7607843137254902, green: 0.8980392156862745, blue: 0.611764705882353, alpha: 1.0), NSUIColor(red: 0.39215686274509803, green: 0.7019607843137254, blue: 0.9568627450980393, alpha: 1.0)])

        /// Poncho
        public static let poncho = Self("Poncho", [NSUIColor(red: 0.25098039215686274, green: 0.22745098039215686, blue: 0.24313725490196078, alpha: 1.0), NSUIColor(red: 0.7450980392156863, green: 0.34509803921568627, blue: 0.4117647058823529, alpha: 1.0)])

        /// Backtothe Future
        public static let backtotheFuture = Self("Backtothe Future", [NSUIColor(red: 0.7529411764705882, green: 0.1411764705882353, blue: 0.1450980392156863, alpha: 1.0), NSUIColor(red: 0.9411764705882353, green: 0.796078431372549, blue: 0.20784313725490197, alpha: 1.0)])

        /// Blush
        public static let blush = Self("Blush", [NSUIColor(red: 0.6980392156862745, green: 0.27058823529411763, blue: 0.5725490196078431, alpha: 1.0), NSUIColor(red: 0.9450980392156862, green: 0.37254901960784315, blue: 0.4745098039215686, alpha: 1.0)])

        /// Inbox
        public static let inbox = Self("Inbox", [NSUIColor(red: 0.27058823529411763, green: 0.4980392156862745, blue: 0.792156862745098, alpha: 1.0), NSUIColor(red: 0.33725490196078434, green: 0.5686274509803921, blue: 0.7843137254901961, alpha: 1.0)])

        /// Purplin
        public static let purplin = Self("Purplin", [NSUIColor(red: 0.41568627450980394, green: 0.18823529411764706, blue: 0.5764705882352941, alpha: 1.0), NSUIColor(red: 0.6274509803921569, green: 0.26666666666666666, blue: 1.0, alpha: 1.0)])

        /// Pale Wood
        public static let paleWood = Self("Pale Wood", [NSUIColor(red: 0.9176470588235294, green: 0.803921568627451, blue: 0.6392156862745098, alpha: 1.0), NSUIColor(red: 0.8392156862745098, green: 0.6823529411764706, blue: 0.4823529411764706, alpha: 1.0)])

        /// Haikus
        public static let haikus = Self("Haikus", [NSUIColor(red: 0.9921568627450981, green: 0.4549019607843137, blue: 0.4235294117647059, alpha: 1.0), NSUIColor(red: 1.0, green: 0.5647058823529412, blue: 0.40784313725490196, alpha: 1.0)])

        /// Pizelex
        public static let pizelex = Self("Pizelex", [NSUIColor(red: 0.06666666666666667, green: 0.2627450980392157, blue: 0.3411764705882353, alpha: 1.0), NSUIColor(red: 0.9490196078431372, green: 0.5803921568627451, blue: 0.5725490196078431, alpha: 1.0)])

        /// Joomla
        public static let joomla = Self("Joomla", [NSUIColor(red: 0.11764705882352941, green: 0.23529411764705882, blue: 0.4470588235294118, alpha: 1.0), NSUIColor(red: 0.16470588235294117, green: 0.3215686274509804, blue: 0.596078431372549, alpha: 1.0)])

        /// Christmas
        public static let christmas = Self("Christmas", [NSUIColor(red: 0.1843137254901961, green: 0.45098039215686275, blue: 0.21176470588235294, alpha: 1.0), NSUIColor(red: 0.6666666666666666, green: 0.22745098039215686, blue: 0.2196078431372549, alpha: 1.0)])

        /// Minnesota Vikings
        public static let minnesotaVikings = Self("Minnesota Vikings", [NSUIColor(red: 0.33725490196078434, green: 0.0784313725490196, blue: 0.6901960784313725, alpha: 1.0), NSUIColor(red: 0.8588235294117647, green: 0.8392156862745098, blue: 0.3607843137254902, alpha: 1.0)])

        /// Miami Dolphins
        public static let miamiDolphins = Self("Miami Dolphins", [NSUIColor(red: 0.30196078431372547, green: 0.6274509803921569, blue: 0.6901960784313725, alpha: 1.0), NSUIColor(red: 0.8274509803921568, green: 0.615686274509804, blue: 0.2196078431372549, alpha: 1.0)])

        /// Forest
        public static let forest = Self("Forest", [NSUIColor(red: 0.35294117647058826, green: 0.24705882352941178, blue: 0.21568627450980393, alpha: 1.0), NSUIColor(red: 0.17254901960784313, green: 0.4666666666666667, blue: 0.26666666666666666, alpha: 1.0)])

        /// Nighthawk
        public static let nighthawk = Self("Nighthawk", [NSUIColor(red: 0.1607843137254902, green: 0.5019607843137255, blue: 0.7254901960784313, alpha: 1.0), NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0)])

        /// Superman
        public static let superman = Self("Superman", [NSUIColor(red: 0.0, green: 0.6, blue: 0.9686274509803922, alpha: 1.0), NSUIColor(red: 0.9450980392156862, green: 0.09019607843137255, blue: 0.07058823529411765, alpha: 1.0)])

        /// Suzy
        public static let suzy = Self("Suzy", [NSUIColor(red: 0.5137254901960784, green: 0.30196078431372547, blue: 0.6078431372549019, alpha: 1.0), NSUIColor(red: 0.8156862745098039, green: 0.3058823529411765, blue: 0.8392156862745098, alpha: 1.0)])

        /// Dark Skies
        public static let darkSkies = Self("Dark Skies", [NSUIColor(red: 0.29411764705882354, green: 0.4745098039215686, blue: 0.6313725490196078, alpha: 1.0), NSUIColor(red: 0.1568627450980392, green: 0.24313725490196078, blue: 0.3176470588235294, alpha: 1.0)])

        /// Deep Space
        public static let deepSpace = Self("Deep Space", [NSUIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.2627450980392157, green: 0.2627450980392157, blue: 0.2627450980392157, alpha: 1.0)])

        /// Decent
        public static let decent = Self("Decent", [NSUIColor(red: 0.2980392156862745, green: 0.6313725490196078, blue: 0.6862745098039216, alpha: 1.0), NSUIColor(red: 0.7686274509803922, green: 0.8784313725490196, blue: 0.8980392156862745, alpha: 1.0)])

        /// Colors Of Sky
        public static let colorsOfSky = Self("Colors Of Sky", [NSUIColor(red: 0.8784313725490196, green: 0.9176470588235294, blue: 0.9882352941176471, alpha: 1.0), NSUIColor(red: 0.8117647058823529, green: 0.8705882352941177, blue: 0.9529411764705882, alpha: 1.0)])

        /// Purple White
        public static let purpleWhite = Self("Purple White", [NSUIColor(red: 0.7294117647058823, green: 0.3254901960784314, blue: 0.4392156862745098, alpha: 1.0), NSUIColor(red: 0.9568627450980393, green: 0.8862745098039215, blue: 0.8470588235294118, alpha: 1.0)])

        /// Ali
        public static let ali = Self("Ali", [NSUIColor(red: 1.0, green: 0.29411764705882354, blue: 0.12156862745098039, alpha: 1.0), NSUIColor(red: 0.12156862745098039, green: 0.8666666666666667, blue: 1.0, alpha: 1.0)])

        /// Alihossein
        public static let alihossein = Self("Alihossein", [NSUIColor(red: 0.9686274509803922, green: 1.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.8588235294117647, green: 0.21176470588235294, blue: 0.6431372549019608, alpha: 1.0)])

        /// Shahabi
        public static let shahabi = Self("Shahabi", [NSUIColor(red: 0.6588235294117647, green: 0.0, blue: 0.4666666666666667, alpha: 1.0), NSUIColor(red: 0.4, green: 1.0, blue: 0.0, alpha: 1.0)])

        /// Red Ocean
        public static let redOcean = Self("Red Ocean", [NSUIColor(red: 0.11372549019607843, green: 0.2627450980392157, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.6431372549019608, green: 0.2235294117647059, blue: 0.19215686274509805, alpha: 1.0)])

        /// Tranquil
        public static let tranquil = Self("Tranquil", [NSUIColor(red: 0.9333333333333333, green: 0.803921568627451, blue: 0.6392156862745098, alpha: 1.0), NSUIColor(red: 0.9372549019607843, green: 0.3843137254901961, blue: 0.6235294117647059, alpha: 1.0)])

        /// Transfile
        public static let transfile = Self("Transfile", [NSUIColor(red: 0.08627450980392157, green: 0.7490196078431373, blue: 0.9921568627450981, alpha: 1.0), NSUIColor(red: 0.796078431372549, green: 0.18823529411764706, blue: 0.4, alpha: 1.0)])

        /// Sylvia
        public static let sylvia = Self("Sylvia", [NSUIColor(red: 1.0, green: 0.29411764705882354, blue: 0.12156862745098039, alpha: 1.0), NSUIColor(red: 1.0, green: 0.5647058823529412, blue: 0.40784313725490196, alpha: 1.0)])

        /// Sweet Morning
        public static let sweetMorning = Self("Sweet Morning", [NSUIColor(red: 1.0, green: 0.37254901960784315, blue: 0.42745098039215684, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7647058823529411, blue: 0.44313725490196076, alpha: 1.0)])

        /// Politics
        public static let politics = Self("Politics", [NSUIColor(red: 0.12941176470588237, green: 0.5882352941176471, blue: 0.9529411764705882, alpha: 1.0), NSUIColor(red: 0.9568627450980393, green: 0.2627450980392157, blue: 0.21176470588235294, alpha: 1.0)])

        /// Bright Vault
        public static let brightVault = Self("Bright Vault", [NSUIColor(red: 0.0, green: 0.8235294117647058, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.5725490196078431, green: 0.5529411764705883, blue: 0.6705882352941176, alpha: 1.0)])

        /// Solid Vault
        public static let solidVault = Self("Solid Vault", [NSUIColor(red: 0.22745098039215686, green: 0.4823529411764706, blue: 0.8352941176470589, alpha: 1.0), NSUIColor(red: 0.22745098039215686, green: 0.3764705882352941, blue: 0.45098039215686275, alpha: 1.0)])

        /// Sunset
        public static let sunset = Self("Sunset", [NSUIColor(red: 0.043137254901960784, green: 0.2823529411764706, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.9607843137254902, green: 0.3843137254901961, blue: 0.09019607843137255, alpha: 1.0)])

        /// Grapefruit Sunset
        public static let grapefruitSunset = Self("Grapefruit Sunset", [NSUIColor(red: 0.9137254901960784, green: 0.39215686274509803, blue: 0.2627450980392157, alpha: 1.0), NSUIColor(red: 0.5647058823529412, green: 0.3058823529411765, blue: 0.5843137254901961, alpha: 1.0)])

        /// Deep Sea Space
        public static let deepSeaSpace = Self("Deep Sea Space", [NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.2980392156862745, green: 0.6313725490196078, blue: 0.6862745098039216, alpha: 1.0)])

        /// Dusk
        public static let dusk = Self("Dusk", [NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.4549019607843137, blue: 0.4235294117647059, alpha: 1.0)])

        /// Minimal Red
        public static let minimalRed = Self("Minimal Red", [NSUIColor(red: 0.9411764705882353, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.8627450980392157, green: 0.1568627450980392, blue: 0.11764705882352941, alpha: 1.0)])

        /// Royal
        public static let royal = Self("Royal", [NSUIColor(red: 0.0784313725490196, green: 0.11764705882352941, blue: 0.18823529411764706, alpha: 1.0), NSUIColor(red: 0.1411764705882353, green: 0.23137254901960785, blue: 0.3333333333333333, alpha: 1.0)])

        /// Mauve
        public static let mauve = Self("Mauve", [NSUIColor(red: 0.25882352941176473, green: 0.15294117647058825, blue: 0.35294117647058826, alpha: 1.0), NSUIColor(red: 0.45098039215686275, green: 0.29411764705882354, blue: 0.42745098039215684, alpha: 1.0)])

        /// Frost
        public static let frost = Self("Frost", [NSUIColor(red: 0.0, green: 0.01568627450980392, blue: 0.1568627450980392, alpha: 1.0), NSUIColor(red: 0.0, green: 0.3058823529411765, blue: 0.5725490196078431, alpha: 1.0)])

        /// Lush
        public static let lush = Self("Lush", [NSUIColor(red: 0.33725490196078434, green: 0.6705882352941176, blue: 0.1843137254901961, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.8784313725490196, blue: 0.38823529411764707, alpha: 1.0)])

        /// Firewatch
        public static let firewatch = Self("Firewatch", [NSUIColor(red: 0.796078431372549, green: 0.17647058823529413, blue: 0.24313725490196078, alpha: 1.0), NSUIColor(red: 0.9372549019607843, green: 0.2784313725490196, blue: 0.22745098039215686, alpha: 1.0)])

        /// Sherbert
        public static let sherbert = Self("Sherbert", [NSUIColor(red: 0.9686274509803922, green: 0.615686274509804, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.39215686274509803, green: 0.9529411764705882, blue: 0.5490196078431373, alpha: 1.0)])

        /// Blood Red
        public static let bloodRed = Self("Blood Red", [NSUIColor(red: 0.9725490196078431, green: 0.3137254901960784, blue: 0.19607843137254902, alpha: 1.0), NSUIColor(red: 0.9058823529411765, green: 0.2196078431372549, blue: 0.15294117647058825, alpha: 1.0)])

        /// Sunonthe Horizon
        public static let sunontheHorizon = Self("Sunonthe Horizon", [NSUIColor(red: 0.9882352941176471, green: 0.9176470588235294, blue: 0.7333333333333333, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 0.7098039215686275, blue: 0.0, alpha: 1.0)])

        /// I I I T Delhi
        public static let iIITDelhi = Self("I I I T Delhi", [NSUIColor(red: 0.5019607843137255, green: 0.5019607843137255, blue: 0.5019607843137255, alpha: 1.0), NSUIColor(red: 0.24705882352941178, green: 0.6784313725490196, blue: 0.6588235294117647, alpha: 1.0)])

        /// Jupiter
        public static let jupiter = Self("Jupiter", [NSUIColor(red: 1.0, green: 0.8470588235294118, blue: 0.6078431372549019, alpha: 1.0), NSUIColor(red: 0.09803921568627451, green: 0.32941176470588235, blue: 0.4823529411764706, alpha: 1.0)])

        /// Shadesof Grey
        public static let shadesofGrey = Self("Shadesof Grey", [NSUIColor(red: 0.7411764705882353, green: 0.7647058823529411, blue: 0.7803921568627451, alpha: 1.0), NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0)])

        /// Dania
        public static let dania = Self("Dania", [NSUIColor(red: 0.7450980392156863, green: 0.5764705882352941, blue: 0.7725490196078432, alpha: 1.0), NSUIColor(red: 0.4823529411764706, green: 0.7764705882352941, blue: 0.8, alpha: 1.0)])

        /// Limeade
        public static let limeade = Self("Limeade", [NSUIColor(red: 0.6313725490196078, green: 1.0, blue: 0.807843137254902, alpha: 1.0), NSUIColor(red: 0.9803921568627451, green: 1.0, blue: 0.8196078431372549, alpha: 1.0)])

        /// Disco
        public static let disco = Self("Disco", [NSUIColor(red: 0.3058823529411765, green: 0.803921568627451, blue: 0.7686274509803922, alpha: 1.0), NSUIColor(red: 0.3333333333333333, green: 0.3843137254901961, blue: 0.4392156862745098, alpha: 1.0)])

        /// Love Couple
        public static let loveCouple = Self("Love Couple", [NSUIColor(red: 0.22745098039215686, green: 0.3803921568627451, blue: 0.5254901960784314, alpha: 1.0), NSUIColor(red: 0.5372549019607843, green: 0.1450980392156863, blue: 0.24313725490196078, alpha: 1.0)])

        /// Azure Pop
        public static let azurePop = Self("Azure Pop", [NSUIColor(red: 0.9372549019607843, green: 0.19607843137254902, blue: 0.8509803921568627, alpha: 1.0), NSUIColor(red: 0.5372549019607843, green: 1.0, blue: 0.9921568627450981, alpha: 1.0)])

        /// Nepal
        public static let nepal = Self("Nepal", [NSUIColor(red: 0.8705882352941177, green: 0.3803921568627451, blue: 0.3803921568627451, alpha: 1.0), NSUIColor(red: 0.14901960784313725, green: 0.3411764705882353, blue: 0.9215686274509803, alpha: 1.0)])

        /// Cosmic Fusion
        public static let cosmicFusion = Self("Cosmic Fusion", [NSUIColor(red: 1.0, green: 0.0, blue: 0.8, alpha: 1.0), NSUIColor(red: 0.2, green: 0.2, blue: 0.6, alpha: 1.0)])

        /// Snapchat
        public static let snapchat = Self("Snapchat", [NSUIColor(red: 1.0, green: 0.9882352941176471, blue: 0.0, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])

        /// Eds Sunset Gradient
        public static let edsSunsetGradient = Self("Eds Sunset Gradient", [NSUIColor(red: 1.0, green: 0.49411764705882355, blue: 0.37254901960784315, alpha: 1.0), NSUIColor(red: 0.996078431372549, green: 0.7058823529411765, blue: 0.4823529411764706, alpha: 1.0)])

        /// Brady Brady Fun Fun
        public static let bradyBradyFunFun = Self("Brady Brady Fun Fun", [NSUIColor(red: 0.0, green: 0.7647058823529411, blue: 1.0, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 0.10980392156862745, alpha: 1.0)])

        /// Black Ros
        public static let blackRos = Self("Black Ros", [NSUIColor(red: 0.9568627450980393, green: 0.7686274509803922, blue: 0.9529411764705882, alpha: 1.0), NSUIColor(red: 0.9882352941176471, green: 0.403921568627451, blue: 0.9803921568627451, alpha: 1.0)])

        /// S Purple
        public static let sPurple = Self("S Purple", [NSUIColor(red: 0.2549019607843137, green: 0.1607843137254902, blue: 0.35294117647058826, alpha: 1.0), NSUIColor(red: 0.1843137254901961, green: 0.027450980392156862, blue: 0.2627450980392157, alpha: 1.0)])

        /// Radar
        public static let radar = Self("Radar", [NSUIColor(red: 0.6549019607843137, green: 0.4392156862745098, blue: 0.9372549019607843, alpha: 1.0), NSUIColor(red: 0.8117647058823529, green: 0.5450980392156862, blue: 0.9529411764705882, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.7254901960784313, blue: 0.6078431372549019, alpha: 1.0)])

        /// Ibiza Sunset
        public static let ibizaSunset = Self("Ibiza Sunset", [NSUIColor(red: 0.9333333333333333, green: 0.03529411764705882, blue: 0.4745098039215686, alpha: 1.0), NSUIColor(red: 1.0, green: 0.41568627450980394, blue: 0.0, alpha: 1.0)])

        /// Dawn
        public static let dawn = Self("Dawn", [NSUIColor(red: 0.9529411764705882, green: 0.5647058823529412, blue: 0.30980392156862746, alpha: 1.0), NSUIColor(red: 0.23137254901960785, green: 0.2627450980392157, blue: 0.44313725490196076, alpha: 1.0)])

        /// Mild
        public static let mild = Self("Mild", [NSUIColor(red: 0.403921568627451, green: 0.6980392156862745, blue: 0.43529411764705883, alpha: 1.0), NSUIColor(red: 0.2980392156862745, green: 0.6352941176470588, blue: 0.803921568627451, alpha: 1.0)])

        /// Vice City
        public static let viceCity = Self("Vice City", [NSUIColor(red: 0.20392156862745098, green: 0.5803921568627451, blue: 0.9019607843137255, alpha: 1.0), NSUIColor(red: 0.9254901960784314, green: 0.43137254901960786, blue: 0.6784313725490196, alpha: 1.0)])

        /// Jaipur
        public static let jaipur = Self("Jaipur", [NSUIColor(red: 0.8588235294117647, green: 0.9019607843137255, blue: 0.9647058823529412, alpha: 1.0), NSUIColor(red: 0.7725490196078432, green: 0.4745098039215686, blue: 0.42745098039215684, alpha: 1.0)])

        /// Jodhpur
        public static let jodhpur = Self("Jodhpur", [NSUIColor(red: 0.611764705882353, green: 0.9254901960784314, blue: 0.984313725490196, alpha: 1.0), NSUIColor(red: 0.396078431372549, green: 0.7803921568627451, blue: 0.9686274509803922, alpha: 1.0), NSUIColor(red: 0.0, green: 0.3215686274509804, blue: 0.8313725490196079, alpha: 1.0)])

        /// Cocoaa Ice
        public static let cocoaaIce = Self("Cocoaa Ice", [NSUIColor(red: 0.7529411764705882, green: 0.7529411764705882, blue: 0.6666666666666666, alpha: 1.0), NSUIColor(red: 0.10980392156862745, green: 0.9372549019607843, blue: 1.0, alpha: 1.0)])

        /// Easy Med
        public static let easyMed = Self("Easy Med", [NSUIColor(red: 0.8627450980392157, green: 0.8901960784313725, blue: 0.3568627450980392, alpha: 1.0), NSUIColor(red: 0.27058823529411763, green: 0.7137254901960784, blue: 0.28627450980392155, alpha: 1.0)])

        /// Rose Colored Lenses
        public static let roseColoredLenses = Self("Rose Colored Lenses", [NSUIColor(red: 0.9098039215686274, green: 0.796078431372549, blue: 0.7529411764705882, alpha: 1.0), NSUIColor(red: 0.38823529411764707, green: 0.43529411764705883, blue: 0.6431372549019608, alpha: 1.0)])

        /// Whatlies Beyond
        public static let whatliesBeyond = Self("Whatlies Beyond", [NSUIColor(red: 0.9411764705882353, green: 0.9490196078431372, blue: 0.9411764705882353, alpha: 1.0), NSUIColor(red: 0.0, green: 0.047058823529411764, blue: 0.25098039215686274, alpha: 1.0)])

        /// Roseanna
        public static let roseanna = Self("Roseanna", [NSUIColor(red: 1.0, green: 0.6862745098039216, blue: 0.7411764705882353, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7647058823529411, blue: 0.6274509803921569, alpha: 1.0)])

        /// Honey Dew
        public static let honeyDew = Self("Honey Dew", [NSUIColor(red: 0.2627450980392157, green: 0.7764705882352941, blue: 0.6745098039215687, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 1.0, blue: 0.6823529411764706, alpha: 1.0)])

        /// Underthe Lake
        public static let undertheLake = Self("Underthe Lake", [NSUIColor(red: 0.03529411764705882, green: 0.18823529411764706, blue: 0.1568627450980392, alpha: 1.0), NSUIColor(red: 0.13725490196078433, green: 0.47843137254901963, blue: 0.3411764705882353, alpha: 1.0)])

        /// The Blue Lagoon
        public static let theBlueLagoon = Self("The Blue Lagoon", [NSUIColor(red: 0.2627450980392157, green: 0.7764705882352941, blue: 0.6745098039215687, alpha: 1.0), NSUIColor(red: 0.09803921568627451, green: 0.08627450980392157, blue: 0.32941176470588235, alpha: 1.0)])

        /// Can You Feel The Love Tonight
        public static let canYouFeelTheLoveTonight = Self("Can You Feel The Love Tonight", [NSUIColor(red: 0.27058823529411763, green: 0.40784313725490196, blue: 0.8627450980392157, alpha: 1.0), NSUIColor(red: 0.6901960784313725, green: 0.41568627450980394, blue: 0.7019607843137254, alpha: 1.0)])

        /// Very Blue
        public static let veryBlue = Self("Very Blue", [NSUIColor(red: 0.0196078431372549, green: 0.4588235294117647, blue: 0.9019607843137255, alpha: 1.0), NSUIColor(red: 0.00784313725490196, green: 0.10588235294117647, blue: 0.4745098039215686, alpha: 1.0)])

        /// Loveand Liberty
        public static let loveandLiberty = Self("Loveand Liberty", [NSUIColor(red: 0.12549019607843137, green: 0.00392156862745098, blue: 0.13333333333333333, alpha: 1.0), NSUIColor(red: 0.43529411764705883, green: 0.0, blue: 0.0, alpha: 1.0)])

        /// Orca
        public static let orca = Self("Orca", [NSUIColor(red: 0.26666666666666666, green: 0.6274509803921569, blue: 0.5529411764705883, alpha: 1.0), NSUIColor(red: 0.03529411764705882, green: 0.21176470588235294, blue: 0.21568627450980393, alpha: 1.0)])

        /// Venice
        public static let venice = Self("Venice", [NSUIColor(red: 0.3803921568627451, green: 0.5647058823529412, blue: 0.9098039215686274, alpha: 1.0), NSUIColor(red: 0.6549019607843137, green: 0.7490196078431373, blue: 0.9098039215686274, alpha: 1.0)])

        /// Pacific Dream
        public static let pacificDream = Self("Pacific Dream", [NSUIColor(red: 0.20392156862745098, green: 0.9098039215686274, blue: 0.6196078431372549, alpha: 1.0), NSUIColor(red: 0.058823529411764705, green: 0.20392156862745098, blue: 0.2627450980392157, alpha: 1.0)])

        /// Learningand Leading
        public static let learningandLeading = Self("Learningand Leading", [NSUIColor(red: 0.9686274509803922, green: 0.592156862745098, blue: 0.11764705882352941, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8235294117647058, blue: 0.0, alpha: 1.0)])

        /// Celestial
        public static let celestial = Self("Celestial", [NSUIColor(red: 0.7647058823529411, green: 0.21568627450980393, blue: 0.39215686274509803, alpha: 1.0), NSUIColor(red: 0.11372549019607843, green: 0.14901960784313725, blue: 0.44313725490196076, alpha: 1.0)])

        /// Purplepine
        public static let purplepine = Self("Purplepine", [NSUIColor(red: 0.12549019607843137, green: 0.0, blue: 0.17254901960784313, alpha: 1.0), NSUIColor(red: 0.796078431372549, green: 0.7058823529411765, blue: 0.8313725490196079, alpha: 1.0)])

        /// Shalala
        public static let shalala = Self("Shalala", [NSUIColor(red: 0.8392156862745098, green: 0.42745098039215684, blue: 0.4588235294117647, alpha: 1.0), NSUIColor(red: 0.8862745098039215, green: 0.5843137254901961, blue: 0.5294117647058824, alpha: 1.0)])

        /// Mini
        public static let mini = Self("Mini", [NSUIColor(red: 0.18823529411764706, green: 0.9098039215686274, blue: 0.7490196078431373, alpha: 1.0), NSUIColor(red: 1.0, green: 0.5098039215686274, blue: 0.20784313725490197, alpha: 1.0)])

        /// Maldives
        public static let maldives = Self("Maldives", [NSUIColor(red: 0.6980392156862745, green: 0.996078431372549, blue: 0.9803921568627451, alpha: 1.0), NSUIColor(red: 0.054901960784313725, green: 0.8235294117647058, blue: 0.9686274509803922, alpha: 1.0)])

        /// Cinnamint
        public static let cinnamint = Self("Cinnamint", [NSUIColor(red: 0.2901960784313726, green: 0.7607843137254902, blue: 0.6039215686274509, alpha: 1.0), NSUIColor(red: 0.7411764705882353, green: 1.0, blue: 0.9529411764705882, alpha: 1.0)])

        /// Html
        public static let html = Self("Html", [NSUIColor(red: 0.8941176470588236, green: 0.30196078431372547, blue: 0.14901960784313725, alpha: 1.0), NSUIColor(red: 0.9450980392156862, green: 0.396078431372549, blue: 0.1607843137254902, alpha: 1.0)])

        /// Coal
        public static let coal = Self("Coal", [NSUIColor(red: 0.9215686274509803, green: 0.3411764705882353, blue: 0.3411764705882353, alpha: 1.0), NSUIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)])

        /// Sunkist
        public static let sunkist = Self("Sunkist", [NSUIColor(red: 0.9490196078431372, green: 0.6, blue: 0.2901960784313726, alpha: 1.0), NSUIColor(red: 0.9490196078431372, green: 0.788235294117647, blue: 0.2980392156862745, alpha: 1.0)])

        /// Blue Skies
        public static let blueSkies = Self("Blue Skies", [NSUIColor(red: 0.33725490196078434, green: 0.8, blue: 0.9490196078431372, alpha: 1.0), NSUIColor(red: 0.1843137254901961, green: 0.5019607843137255, blue: 0.9294117647058824, alpha: 1.0)])

        /// Chitty Chitty Bang Bang
        public static let chittyChittyBangBang = Self("Chitty Chitty Bang Bang", [NSUIColor(red: 0.0, green: 0.4745098039215686, blue: 0.5686274509803921, alpha: 1.0), NSUIColor(red: 0.47058823529411764, green: 1.0, blue: 0.8392156862745098, alpha: 1.0)])

        /// Visionsof Grandeur
        public static let visionsofGrandeur = Self("Visionsof Grandeur", [NSUIColor(red: 0.0, green: 0.0, blue: 0.27450980392156865, alpha: 1.0), NSUIColor(red: 0.10980392156862745, green: 0.7098039215686275, blue: 0.8784313725490196, alpha: 1.0)])

        /// Crystal Clear
        public static let crystalClear = Self("Crystal Clear", [NSUIColor(red: 0.08235294117647059, green: 0.6, blue: 0.3411764705882353, alpha: 1.0), NSUIColor(red: 0.08235294117647059, green: 0.3411764705882353, blue: 0.6, alpha: 1.0)])

        /// Mello
        public static let mello = Self("Mello", [NSUIColor(red: 0.7529411764705882, green: 0.2235294117647059, blue: 0.16862745098039217, alpha: 1.0), NSUIColor(red: 0.5568627450980392, green: 0.26666666666666666, blue: 0.6784313725490196, alpha: 1.0)])

        /// Compare Now
        public static let compareNow = Self("Compare Now", [NSUIColor(red: 0.9372549019607843, green: 0.23137254901960785, blue: 0.21176470588235294, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])

        /// Meridian
        public static let meridian = Self("Meridian", [NSUIColor(red: 0.1568627450980392, green: 0.23529411764705882, blue: 0.5254901960784314, alpha: 1.0), NSUIColor(red: 0.27058823529411763, green: 0.6352941176470588, blue: 0.2784313725490196, alpha: 1.0)])

        /// Relay
        public static let relay = Self("Relay", [NSUIColor(red: 0.22745098039215686, green: 0.10980392156862745, blue: 0.44313725490196076, alpha: 1.0), NSUIColor(red: 0.8431372549019608, green: 0.42745098039215684, blue: 0.4666666666666667, alpha: 1.0), NSUIColor(red: 1.0, green: 0.6862745098039216, blue: 0.4823529411764706, alpha: 1.0)])

        /// Alive
        public static let alive = Self("Alive", [NSUIColor(red: 0.796078431372549, green: 0.20784313725490197, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.7411764705882353, green: 0.24705882352941178, blue: 0.19607843137254902, alpha: 1.0)])

        /// Scooter
        public static let scooter = Self("Scooter", [NSUIColor(red: 0.21176470588235294, green: 0.8196078431372549, blue: 0.8627450980392157, alpha: 1.0), NSUIColor(red: 0.3568627450980392, green: 0.5254901960784314, blue: 0.8980392156862745, alpha: 1.0)])

        /// Terminal
        public static let terminal = Self("Terminal", [NSUIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.058823529411764705, green: 0.6078431372549019, blue: 0.058823529411764705, alpha: 1.0)])

        /// Telegram
        public static let telegram = Self("Telegram", [NSUIColor(red: 0.10980392156862745, green: 0.5725490196078431, blue: 0.8235294117647058, alpha: 1.0), NSUIColor(red: 0.9490196078431372, green: 0.9882352941176471, blue: 0.996078431372549, alpha: 1.0)])

        /// Crimson Tide
        public static let crimsonTide = Self("Crimson Tide", [NSUIColor(red: 0.39215686274509803, green: 0.16862745098039217, blue: 0.45098039215686275, alpha: 1.0), NSUIColor(red: 0.7764705882352941, green: 0.25882352941176473, blue: 0.43137254901960786, alpha: 1.0)])

        /// Socialive
        public static let socialive = Self("Socialive", [NSUIColor(red: 0.023529411764705882, green: 0.7450980392156863, blue: 0.7137254901960784, alpha: 1.0), NSUIColor(red: 0.2823529411764706, green: 0.6941176470588235, blue: 0.7490196078431373, alpha: 1.0)])

        /// Subu
        public static let subu = Self("Subu", [NSUIColor(red: 0.047058823529411764, green: 0.9215686274509803, blue: 0.9215686274509803, alpha: 1.0), NSUIColor(red: 0.12549019607843137, green: 0.8901960784313725, blue: 0.6980392156862745, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 1.0, blue: 0.7764705882352941, alpha: 1.0)])

        /// Broken Hearts
        public static let brokenHearts = Self("Broken Hearts", [NSUIColor(red: 0.8509803921568627, green: 0.6549019607843137, blue: 0.7803921568627451, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9882352941176471, blue: 0.8627450980392157, alpha: 1.0)])

        /// Kimoby Is The New Blue
        public static let kimobyIsTheNewBlue = Self("Kimoby Is The New Blue", [NSUIColor(red: 0.2235294117647059, green: 0.41568627450980394, blue: 0.9882352941176471, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 0.2823529411764706, blue: 1.0, alpha: 1.0)])

        /// Dull
        public static let dull = Self("Dull", [NSUIColor(red: 0.788235294117647, green: 0.8392156862745098, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.8862745098039215, green: 0.8862745098039215, blue: 0.8862745098039215, alpha: 1.0)])

        /// Purpink
        public static let purpink = Self("Purpink", [NSUIColor(red: 0.4980392156862745, green: 0.0, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.8823529411764706, green: 0.0, blue: 1.0, alpha: 1.0)])

        /// Orange Coral
        public static let orangeCoral = Self("Orange Coral", [NSUIColor(red: 1.0, green: 0.6, blue: 0.4, alpha: 1.0), NSUIColor(red: 1.0, green: 0.3686274509803922, blue: 0.3843137254901961, alpha: 1.0)])

        /// Summer
        public static let summer = Self("Summer", [NSUIColor(red: 0.13333333333333333, green: 0.7568627450980392, blue: 0.7647058823529411, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.7333333333333333, blue: 0.17647058823529413, alpha: 1.0)])

        /// King Yna
        public static let kingYna = Self("King Yna", [NSUIColor(red: 0.10196078431372549, green: 0.16470588235294117, blue: 0.4235294117647059, alpha: 1.0), NSUIColor(red: 0.6980392156862745, green: 0.12156862745098039, blue: 0.12156862745098039, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.7333333333333333, blue: 0.17647058823529413, alpha: 1.0)])

        /// Velvet Sun
        public static let velvetSun = Self("Velvet Sun", [NSUIColor(red: 0.8823529411764706, green: 0.9333333333333333, blue: 0.7647058823529411, alpha: 1.0), NSUIColor(red: 0.9411764705882353, green: 0.3137254901960784, blue: 0.3254901960784314, alpha: 1.0)])

        /// Zinc
        public static let zinc = Self("Zinc", [NSUIColor(red: 0.6784313725490196, green: 0.6627450980392157, blue: 0.5882352941176471, alpha: 1.0), NSUIColor(red: 0.9490196078431372, green: 0.9490196078431372, blue: 0.9490196078431372, alpha: 1.0), NSUIColor(red: 0.8588235294117647, green: 0.8588235294117647, blue: 0.8588235294117647, alpha: 1.0), NSUIColor(red: 0.9176470588235294, green: 0.9176470588235294, blue: 0.9176470588235294, alpha: 1.0)])

        /// Hydrogen
        public static let hydrogen = Self("Hydrogen", [NSUIColor(red: 0.4, green: 0.49019607843137253, blue: 0.7137254901960784, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5098039215686274, blue: 0.7843137254901961, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5098039215686274, blue: 0.7843137254901961, alpha: 1.0), NSUIColor(red: 0.4, green: 0.49019607843137253, blue: 0.7137254901960784, alpha: 1.0)])

        /// Argon
        public static let argon = Self("Argon", [NSUIColor(red: 0.011764705882352941, green: 0.0, blue: 0.11764705882352941, alpha: 1.0), NSUIColor(red: 0.45098039215686275, green: 0.011764705882352941, blue: 0.7529411764705882, alpha: 1.0), NSUIColor(red: 0.9254901960784314, green: 0.2196078431372549, blue: 0.7372549019607844, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.9372549019607843, blue: 0.9764705882352941, alpha: 1.0)])

        /// Lithium
        public static let lithium = Self("Lithium", [NSUIColor(red: 0.42745098039215684, green: 0.3764705882352941, blue: 0.15294117647058825, alpha: 1.0), NSUIColor(red: 0.8274509803921568, green: 0.796078431372549, blue: 0.7215686274509804, alpha: 1.0)])

        /// Digital Water
        public static let digitalWater = Self("Digital Water", [NSUIColor(red: 0.4549019607843137, green: 0.9215686274509803, blue: 0.8352941176470589, alpha: 1.0), NSUIColor(red: 0.6745098039215687, green: 0.7137254901960784, blue: 0.8980392156862745, alpha: 1.0)])

        /// Orange Fun
        public static let orangeFun = Self("Orange Fun", [NSUIColor(red: 0.9882352941176471, green: 0.2901960784313726, blue: 0.10196078431372549, alpha: 1.0), NSUIColor(red: 0.9686274509803922, green: 0.7176470588235294, blue: 0.2, alpha: 1.0)])

        /// Rainbow Blue
        public static let rainbowBlue = Self("Rainbow Blue", [NSUIColor(red: 0.0, green: 0.9490196078431372, blue: 0.3764705882352941, alpha: 1.0), NSUIColor(red: 0.0196078431372549, green: 0.4588235294117647, blue: 0.9019607843137255, alpha: 1.0)])

        /// Pink Flavour
        public static let pinkFlavour = Self("Pink Flavour", [NSUIColor(red: 0.5019607843137255, green: 0.0, blue: 0.5019607843137255, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7529411764705882, blue: 0.796078431372549, alpha: 1.0)])

        /// Sulphur
        public static let sulphur = Self("Sulphur", [NSUIColor(red: 0.792156862745098, green: 0.7725490196078432, blue: 0.19215686274509805, alpha: 1.0), NSUIColor(red: 0.9529411764705882, green: 0.9764705882352941, blue: 0.6549019607843137, alpha: 1.0)])

        /// Selenium
        public static let selenium = Self("Selenium", [NSUIColor(red: 0.23529411764705882, green: 0.23137254901960785, blue: 0.24705882352941178, alpha: 1.0), NSUIColor(red: 0.3764705882352941, green: 0.3607843137254902, blue: 0.23529411764705882, alpha: 1.0)])

        /// Delicate
        public static let delicate = Self("Delicate", [NSUIColor(red: 0.8274509803921568, green: 0.8, blue: 0.8901960784313725, alpha: 1.0), NSUIColor(red: 0.9137254901960784, green: 0.8941176470588236, blue: 0.9411764705882353, alpha: 1.0)])

        /// Ohhappiness
        public static let ohhappiness = Self("Ohhappiness", [NSUIColor(red: 0.0, green: 0.6901960784313725, blue: 0.6078431372549019, alpha: 1.0), NSUIColor(red: 0.5882352941176471, green: 0.788235294117647, blue: 0.23921568627450981, alpha: 1.0)])

        /// Lawrencium
        public static let lawrencium = Self("Lawrencium", [NSUIColor(red: 0.058823529411764705, green: 0.047058823529411764, blue: 0.1607843137254902, alpha: 1.0), NSUIColor(red: 0.18823529411764706, green: 0.16862745098039217, blue: 0.38823529411764707, alpha: 1.0), NSUIColor(red: 0.1411764705882353, green: 0.1411764705882353, blue: 0.24313725490196078, alpha: 1.0)])

        /// Relaxingred
        public static let relaxingred = Self("Relaxingred", [NSUIColor(red: 1.0, green: 0.984313725490196, blue: 0.8352941176470589, alpha: 1.0), NSUIColor(red: 0.6980392156862745, green: 0.0392156862745098, blue: 0.17254901960784313, alpha: 1.0)])

        /// Taran Tado
        public static let taranTado = Self("Taran Tado", [NSUIColor(red: 0.13725490196078433, green: 0.027450980392156862, blue: 0.30196078431372547, alpha: 1.0), NSUIColor(red: 0.8, green: 0.3254901960784314, blue: 0.2, alpha: 1.0)])

        /// Bighead
        public static let bighead = Self("Bighead", [NSUIColor(red: 0.788235294117647, green: 0.29411764705882354, blue: 0.29411764705882354, alpha: 1.0), NSUIColor(red: 0.29411764705882354, green: 0.07450980392156863, blue: 0.30980392156862746, alpha: 1.0)])

        /// Sublime Vivid
        public static let sublimeVivid = Self("Sublime Vivid", [NSUIColor(red: 0.9882352941176471, green: 0.27450980392156865, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.24705882352941178, green: 0.3686274509803922, blue: 0.984313725490196, alpha: 1.0)])

        /// Sublime Light
        public static let sublimeLight = Self("Sublime Light", [NSUIColor(red: 0.9882352941176471, green: 0.3607843137254902, blue: 0.49019607843137253, alpha: 1.0), NSUIColor(red: 0.41568627450980394, green: 0.5098039215686274, blue: 0.984313725490196, alpha: 1.0)])

        /// Pun Yeta
        public static let punYeta = Self("Pun Yeta", [NSUIColor(red: 0.06274509803921569, green: 0.5529411764705883, blue: 0.7803921568627451, alpha: 1.0), NSUIColor(red: 0.9372549019607843, green: 0.5568627450980392, blue: 0.2196078431372549, alpha: 1.0)])

        /// Quepal
        public static let quepal = Self("Quepal", [NSUIColor(red: 0.06666666666666667, green: 0.6, blue: 0.5568627450980392, alpha: 1.0), NSUIColor(red: 0.2196078431372549, green: 0.9372549019607843, blue: 0.49019607843137253, alpha: 1.0)])

        /// Sandto Blue
        public static let sandtoBlue = Self("Sandto Blue", [NSUIColor(red: 0.24313725490196078, green: 0.3176470588235294, blue: 0.3176470588235294, alpha: 1.0), NSUIColor(red: 0.8705882352941177, green: 0.796078431372549, blue: 0.6431372549019608, alpha: 1.0)])

        /// Wedding Day Blues
        public static let weddingDayBlues = Self("Wedding Day Blues", [NSUIColor(red: 0.25098039215686274, green: 0.8784313725490196, blue: 0.8156862745098039, alpha: 1.0), NSUIColor(red: 1.0, green: 0.5490196078431373, blue: 0.0, alpha: 1.0), NSUIColor(red: 1.0, green: 0.0, blue: 0.5019607843137255, alpha: 1.0)])

        /// Shifter
        public static let shifter = Self("Shifter", [NSUIColor(red: 0.7372549019607844, green: 0.3058823529411765, blue: 0.611764705882353, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 0.027450980392156862, blue: 0.34901960784313724, alpha: 1.0)])

        /// Red Sunset
        public static let redSunset = Self("Red Sunset", [NSUIColor(red: 0.20784313725490197, green: 0.3607843137254902, blue: 0.49019607843137253, alpha: 1.0), NSUIColor(red: 0.4235294117647059, green: 0.3568627450980392, blue: 0.4823529411764706, alpha: 1.0), NSUIColor(red: 0.7529411764705882, green: 0.4235294117647059, blue: 0.5176470588235295, alpha: 1.0)])

        /// Moon Purple
        public static let moonPurple = Self("Moon Purple", [NSUIColor(red: 0.3058823529411765, green: 0.32941176470588235, blue: 0.7843137254901961, alpha: 1.0), NSUIColor(red: 0.5607843137254902, green: 0.5803921568627451, blue: 0.984313725490196, alpha: 1.0)])

        /// Pure Lust
        public static let pureLust = Self("Pure Lust", [NSUIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), NSUIColor(red: 0.8666666666666667, green: 0.09411764705882353, blue: 0.09411764705882353, alpha: 1.0)])

        /// Slight Ocean View
        public static let slightOceanView = Self("Slight Ocean View", [NSUIColor(red: 0.6588235294117647, green: 0.7529411764705882, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.24705882352941178, green: 0.16862745098039217, blue: 0.5882352941176471, alpha: 1.0)])

        /// E Xpresso
        public static let eXpresso = Self("E Xpresso", [NSUIColor(red: 0.6784313725490196, green: 0.3254901960784314, blue: 0.5372549019607843, alpha: 1.0), NSUIColor(red: 0.23529411764705882, green: 0.06274509803921569, blue: 0.3254901960784314, alpha: 1.0)])

        /// Shifty
        public static let shifty = Self("Shifty", [NSUIColor(red: 0.38823529411764707, green: 0.38823529411764707, blue: 0.38823529411764707, alpha: 1.0), NSUIColor(red: 0.6352941176470588, green: 0.6705882352941176, blue: 0.34509803921568627, alpha: 1.0)])

        /// Vanusa
        public static let vanusa = Self("Vanusa", [NSUIColor(red: 0.8549019607843137, green: 0.26666666666666666, blue: 0.3254901960784314, alpha: 1.0), NSUIColor(red: 0.5372549019607843, green: 0.12941176470588237, blue: 0.4196078431372549, alpha: 1.0)])

        /// Evening Night
        public static let eveningNight = Self("Evening Night", [NSUIColor(red: 0.0, green: 0.35294117647058826, blue: 0.6549019607843137, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9921568627450981, blue: 0.8941176470588236, alpha: 1.0)])

        /// Magic
        public static let magic = Self("Magic", [NSUIColor(red: 0.34901960784313724, green: 0.7568627450980392, blue: 0.45098039215686275, alpha: 1.0), NSUIColor(red: 0.6313725490196078, green: 0.4980392156862745, blue: 0.8784313725490196, alpha: 1.0), NSUIColor(red: 0.36470588235294116, green: 0.14901960784313725, blue: 0.7568627450980392, alpha: 1.0)])

        /// Margo
        public static let margo = Self("Margo", [NSUIColor(red: 1.0, green: 0.9372549019607843, blue: 0.7294117647058823, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])

        /// Blue Raspberry
        public static let blueRaspberry = Self("Blue Raspberry", [NSUIColor(red: 0.0, green: 0.7058823529411765, blue: 0.8588235294117647, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5137254901960784, blue: 0.6901960784313725, alpha: 1.0)])

        /// Citrus Peel
        public static let citrusPeel = Self("Citrus Peel", [NSUIColor(red: 0.9921568627450981, green: 0.7843137254901961, blue: 0.18823529411764706, alpha: 1.0), NSUIColor(red: 0.9529411764705882, green: 0.45098039215686275, blue: 0.20784313725490197, alpha: 1.0)])

        /// Sin City Red
        public static let sinCityRed = Self("Sin City Red", [NSUIColor(red: 0.9294117647058824, green: 0.12941176470588237, blue: 0.22745098039215686, alpha: 1.0), NSUIColor(red: 0.5764705882352941, green: 0.1607843137254902, blue: 0.11764705882352941, alpha: 1.0)])

        /// Rastafari
        public static let rastafari = Self("Rastafari", [NSUIColor(red: 0.11764705882352941, green: 0.5882352941176471, blue: 0.0, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9490196078431372, blue: 0.0, alpha: 1.0), NSUIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)])

        /// Summer Dog
        public static let summerDog = Self("Summer Dog", [NSUIColor(red: 0.6588235294117647, green: 1.0, blue: 0.47058823529411764, alpha: 1.0), NSUIColor(red: 0.47058823529411764, green: 1.0, blue: 0.8392156862745098, alpha: 1.0)])

        /// Wiretap
        public static let wiretap = Self("Wiretap", [NSUIColor(red: 0.5411764705882353, green: 0.13725490196078433, blue: 0.5294117647058824, alpha: 1.0), NSUIColor(red: 0.9137254901960784, green: 0.25098039215686274, blue: 0.3411764705882353, alpha: 1.0), NSUIColor(red: 0.9490196078431372, green: 0.44313725490196076, blue: 0.12941176470588237, alpha: 1.0)])

        /// Burning Orange
        public static let burningOrange = Self("Burning Orange", [NSUIColor(red: 1.0, green: 0.2549019607843137, blue: 0.4235294117647059, alpha: 1.0), NSUIColor(red: 1.0, green: 0.29411764705882354, blue: 0.16862745098039217, alpha: 1.0)])

        /// Ultra Voilet
        public static let ultraVoilet = Self("Ultra Voilet", [NSUIColor(red: 0.396078431372549, green: 0.3058823529411765, blue: 0.6392156862745098, alpha: 1.0), NSUIColor(red: 0.9176470588235294, green: 0.6862745098039216, blue: 0.7843137254901961, alpha: 1.0)])

        /// By Design
        public static let byDesign = Self("By Design", [NSUIColor(red: 0.0, green: 0.6235294117647059, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.9254901960784314, green: 0.1843137254901961, blue: 0.29411764705882354, alpha: 1.0)])

        /// Kyoo Tah
        public static let kyooTah = Self("Kyoo Tah", [NSUIColor(red: 0.32941176470588235, green: 0.2901960784313726, blue: 0.49019607843137253, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8313725490196079, blue: 0.3215686274509804, alpha: 1.0)])

        /// Kye Meh
        public static let kyeMeh = Self("Kye Meh", [NSUIColor(red: 0.5137254901960784, green: 0.3764705882352941, blue: 0.7647058823529411, alpha: 1.0), NSUIColor(red: 0.1803921568627451, green: 0.7490196078431373, blue: 0.5686274509803921, alpha: 1.0)])

        /// Kyoo Pal
        public static let kyooPal = Self("Kyoo Pal", [NSUIColor(red: 0.8666666666666667, green: 0.24313725490196078, blue: 0.32941176470588235, alpha: 1.0), NSUIColor(red: 0.4196078431372549, green: 0.8980392156862745, blue: 0.5215686274509804, alpha: 1.0)])

        /// Metapolis
        public static let metapolis = Self("Metapolis", [NSUIColor(red: 0.396078431372549, green: 0.6, blue: 0.6, alpha: 1.0), NSUIColor(red: 0.9568627450980393, green: 0.4745098039215686, blue: 0.12156862745098039, alpha: 1.0)])

        /// Flare
        public static let flare = Self("Flare", [NSUIColor(red: 0.9450980392156862, green: 0.15294117647058825, blue: 0.06666666666666667, alpha: 1.0), NSUIColor(red: 0.9607843137254902, green: 0.6862745098039216, blue: 0.09803921568627451, alpha: 1.0)])

        /// Witching Hour
        public static let witchingHour = Self("Witching Hour", [NSUIColor(red: 0.7647058823529411, green: 0.0784313725490196, blue: 0.19607843137254902, alpha: 1.0), NSUIColor(red: 0.1411764705882353, green: 0.043137254901960784, blue: 0.21176470588235294, alpha: 1.0)])

        /// Azur Lane
        public static let azurLane = Self("Azur Lane", [NSUIColor(red: 0.4980392156862745, green: 0.4980392156862745, blue: 0.8352941176470589, alpha: 1.0), NSUIColor(red: 0.5254901960784314, green: 0.6588235294117647, blue: 0.9058823529411765, alpha: 1.0), NSUIColor(red: 0.5686274509803921, green: 0.9176470588235294, blue: 0.8941176470588236, alpha: 1.0)])

        /// Neuromancer
        public static let neuromancer = Self("Neuromancer", [NSUIColor(red: 0.9764705882352941, green: 0.3254901960784314, blue: 0.7764705882352941, alpha: 1.0), NSUIColor(red: 0.7254901960784313, green: 0.11372549019607843, blue: 0.45098039215686275, alpha: 1.0)])

        /// Harvey
        public static let harvey = Self("Harvey", [NSUIColor(red: 0.12156862745098039, green: 0.25098039215686274, blue: 0.21568627450980393, alpha: 1.0), NSUIColor(red: 0.6, green: 0.9490196078431372, blue: 0.7843137254901961, alpha: 1.0)])

        /// Amin
        public static let amin = Self("Amin", [NSUIColor(red: 0.5568627450980392, green: 0.17647058823529413, blue: 0.8862745098039215, alpha: 1.0), NSUIColor(red: 0.2901960784313726, green: 0.0, blue: 0.8784313725490196, alpha: 1.0)])

        /// Memariani
        public static let memariani = Self("Memariani", [NSUIColor(red: 0.6666666666666666, green: 0.29411764705882354, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.4196078431372549, green: 0.4196078431372549, blue: 0.5137254901960784, alpha: 1.0), NSUIColor(red: 0.23137254901960785, green: 0.5529411764705883, blue: 0.6, alpha: 1.0)])

        /// Yoda
        public static let yoda = Self("Yoda", [NSUIColor(red: 1.0, green: 0.0, blue: 0.6, alpha: 1.0), NSUIColor(red: 0.28627450980392155, green: 0.19607843137254902, blue: 0.25098039215686274, alpha: 1.0)])

        /// Cool Sky
        public static let coolSky = Self("Cool Sky", [NSUIColor(red: 0.1607843137254902, green: 0.5019607843137255, blue: 0.7254901960784313, alpha: 1.0), NSUIColor(red: 0.42745098039215684, green: 0.8352941176470589, blue: 0.9803921568627451, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])

        /// Dark Ocean
        public static let darkOcean = Self("Dark Ocean", [NSUIColor(red: 0.21568627450980393, green: 0.23137254901960785, blue: 0.26666666666666666, alpha: 1.0), NSUIColor(red: 0.25882352941176473, green: 0.5254901960784314, blue: 0.9568627450980393, alpha: 1.0)])

        /// Evening Sunshine
        public static let eveningSunshine = Self("Evening Sunshine", [NSUIColor(red: 0.7254901960784313, green: 0.16862745098039217, blue: 0.15294117647058825, alpha: 1.0), NSUIColor(red: 0.08235294117647059, green: 0.396078431372549, blue: 0.7529411764705882, alpha: 1.0)])

        /// J Shine
        public static let jShine = Self("J Shine", [NSUIColor(red: 0.07058823529411765, green: 0.7607843137254902, blue: 0.9137254901960784, alpha: 1.0), NSUIColor(red: 0.7686274509803922, green: 0.44313725490196076, blue: 0.9294117647058824, alpha: 1.0), NSUIColor(red: 0.9647058823529412, green: 0.30980392156862746, blue: 0.34901960784313724, alpha: 1.0)])

        /// Moonlit Asteroid
        public static let moonlitAsteroid = Self("Moonlit Asteroid", [NSUIColor(red: 0.058823529411764705, green: 0.12549019607843137, blue: 0.15294117647058825, alpha: 1.0), NSUIColor(red: 0.12549019607843137, green: 0.22745098039215686, blue: 0.2627450980392157, alpha: 1.0), NSUIColor(red: 0.17254901960784313, green: 0.3254901960784314, blue: 0.39215686274509803, alpha: 1.0)])

        /// Mega Tron
        public static let megaTron = Self("Mega Tron", [NSUIColor(red: 0.7764705882352941, green: 1.0, blue: 0.8666666666666667, alpha: 1.0), NSUIColor(red: 0.984313725490196, green: 0.8431372549019608, blue: 0.5254901960784314, alpha: 1.0), NSUIColor(red: 0.9686274509803922, green: 0.4745098039215686, blue: 0.49019607843137253, alpha: 1.0)])

        /// Cool Blues
        public static let coolBlues = Self("Cool Blues", [NSUIColor(red: 0.12941176470588237, green: 0.5764705882352941, blue: 0.6901960784313725, alpha: 1.0), NSUIColor(red: 0.42745098039215684, green: 0.8352941176470589, blue: 0.9294117647058824, alpha: 1.0)])

        /// Piggy Pink
        public static let piggyPink = Self("Piggy Pink", [NSUIColor(red: 0.9333333333333333, green: 0.611764705882353, blue: 0.6549019607843137, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8666666666666667, blue: 0.8823529411764706, alpha: 1.0)])

        /// Grade Grey
        public static let gradeGrey = Self("Grade Grey", [NSUIColor(red: 0.7411764705882353, green: 0.7647058823529411, blue: 0.7803921568627451, alpha: 1.0), NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0)])

        /// Telko
        public static let telko = Self("Telko", [NSUIColor(red: 0.9529411764705882, green: 0.3843137254901961, blue: 0.13333333333333333, alpha: 1.0), NSUIColor(red: 0.3607843137254902, green: 0.7137254901960784, blue: 0.26666666666666666, alpha: 1.0), NSUIColor(red: 0.0, green: 0.4980392156862745, blue: 0.7647058823529411, alpha: 1.0)])

        /// Zenta
        public static let zenta = Self("Zenta", [NSUIColor(red: 0.16470588235294117, green: 0.17647058823529413, blue: 0.24313725490196078, alpha: 1.0), NSUIColor(red: 0.996078431372549, green: 0.796078431372549, blue: 0.43137254901960786, alpha: 1.0)])

        /// Electric Peacock
        public static let electricPeacock = Self("Electric Peacock", [NSUIColor(red: 0.5411764705882353, green: 0.16862745098039217, blue: 0.8862745098039215, alpha: 1.0), NSUIColor(red: 0.0, green: 0.0, blue: 0.803921568627451, alpha: 1.0), NSUIColor(red: 0.13333333333333333, green: 0.5450980392156862, blue: 0.13333333333333333, alpha: 1.0), NSUIColor(red: 0.8, green: 1.0, blue: 0.0, alpha: 1.0)])

        /// Under Blue Green
        public static let underBlueGreen = Self("Under Blue Green", [NSUIColor(red: 0.0196078431372549, green: 0.09803921568627451, blue: 0.21568627450980393, alpha: 1.0), NSUIColor(red: 0.0, green: 0.30196078431372547, blue: 0.47843137254901963, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5294117647058824, blue: 0.5764705882352941, alpha: 1.0), NSUIColor(red: 0.0, green: 0.7490196078431373, blue: 0.4470588235294118, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.9215686274509803, blue: 0.07058823529411765, alpha: 1.0)])

        /// Lensod
        public static let lensod = Self("Lensod", [NSUIColor(red: 0.3764705882352941, green: 0.1450980392156863, blue: 0.9607843137254902, alpha: 1.0), NSUIColor(red: 1.0, green: 0.3333333333333333, blue: 0.3333333333333333, alpha: 1.0)])

        /// Newspaper
        public static let newspaper = Self("Newspaper", [NSUIColor(red: 0.5411764705882353, green: 0.16862745098039217, blue: 0.8862745098039215, alpha: 1.0), NSUIColor(red: 1.0, green: 0.6470588235294118, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 0.9725490196078431, blue: 1.0, alpha: 1.0)])

        /// Dark Blue Gradient
        public static let darkBlueGradient = Self("Dark Blue Gradient", [NSUIColor(red: 0.15294117647058825, green: 0.4549019607843137, blue: 0.6823529411764706, alpha: 1.0), NSUIColor(red: 0.0, green: 0.1803921568627451, blue: 0.36470588235294116, alpha: 1.0), NSUIColor(red: 0.0, green: 0.1803921568627451, blue: 0.36470588235294116, alpha: 1.0)])

        /// Dark Blu Two
        public static let darkBluTwo = Self("Dark Blu Two", [NSUIColor(red: 0.0, green: 0.27450980392156865, blue: 0.5019607843137255, alpha: 1.0), NSUIColor(red: 0.26666666666666666, green: 0.5176470588235295, blue: 0.7294117647058823, alpha: 1.0)])

        /// Lemon Lime
        public static let lemonLime = Self("Lemon Lime", [NSUIColor(red: 0.49411764705882355, green: 0.7764705882352941, blue: 0.7372549019607844, alpha: 1.0), NSUIColor(red: 0.9215686274509803, green: 0.9058823529411765, blue: 0.09019607843137255, alpha: 1.0)])

        /// Beleko
        public static let beleko = Self("Beleko", [NSUIColor(red: 1.0, green: 0.11764705882352941, blue: 0.33725490196078434, alpha: 1.0), NSUIColor(red: 0.9764705882352941, green: 0.788235294117647, blue: 0.25882352941176473, alpha: 1.0), NSUIColor(red: 0.11764705882352941, green: 0.5647058823529412, blue: 1.0, alpha: 1.0)])

        /// Mango Papaya
        public static let mangoPapaya = Self("Mango Papaya", [NSUIColor(red: 0.8705882352941177, green: 0.5411764705882353, blue: 0.2549019607843137, alpha: 1.0), NSUIColor(red: 0.16470588235294117, green: 0.8549019607843137, blue: 0.3254901960784314, alpha: 1.0)])

        /// Unicorn Rainbow
        public static let unicornRainbow = Self("Unicorn Rainbow", [NSUIColor(red: 0.9686274509803922, green: 0.9411764705882353, blue: 0.6745098039215687, alpha: 1.0), NSUIColor(red: 0.6745098039215687, green: 0.9686274509803922, blue: 0.9411764705882353, alpha: 1.0), NSUIColor(red: 0.9411764705882353, green: 0.6745098039215687, blue: 0.9686274509803922, alpha: 1.0)])

        /// Flame
        public static let flame = Self("Flame", [NSUIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.8117647058823529, blue: 0.34509803921568627, alpha: 1.0)])

        /// Blue Red
        public static let blueRed = Self("Blue Red", [NSUIColor(red: 0.21176470588235294, green: 0.6941176470588235, blue: 0.7803921568627451, alpha: 1.0), NSUIColor(red: 0.5882352941176471, green: 0.043137254901960784, blue: 0.2, alpha: 1.0)])

        /// Twitter
        public static let twitter = Self("Twitter", [NSUIColor(red: 0.11372549019607843, green: 0.6313725490196078, blue: 0.9490196078431372, alpha: 1.0), NSUIColor(red: 0.0, green: 0.6235294117647059, blue: 0.9882352941176471, alpha: 1.0)])

        /// Blooze
        public static let blooze = Self("Blooze", [NSUIColor(red: 0.42745098039215684, green: 0.6509803921568628, blue: 0.7450980392156863, alpha: 1.0), NSUIColor(red: 0.29411764705882354, green: 0.5215686274509804, blue: 0.6196078431372549, alpha: 1.0), NSUIColor(red: 0.42745098039215684, green: 0.6509803921568628, blue: 0.7450980392156863, alpha: 1.0)])

        /// Blue Slate
        public static let blueSlate = Self("Blue Slate", [NSUIColor(red: 0.7098039215686275, green: 0.7254901960784313, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.16862745098039217, green: 0.17254901960784313, blue: 0.28627450980392155, alpha: 1.0)])

        /// Space Light Green
        public static let spaceLightGreen = Self("Space Light Green", [NSUIColor(red: 0.6235294117647059, green: 0.6274509803921569, blue: 0.6588235294117647, alpha: 1.0), NSUIColor(red: 0.3607843137254902, green: 0.47058823529411764, blue: 0.3215686274509804, alpha: 1.0)])

        /// Flower
        public static let flower = Self("Flower", [NSUIColor(red: 0.8627450980392157, green: 1.0, blue: 0.7411764705882353, alpha: 1.0), NSUIColor(red: 0.8, green: 0.5254901960784314, blue: 0.8196078431372549, alpha: 1.0)])

        /// Elate The Euge
        public static let elateTheEuge = Self("Elate The Euge", [NSUIColor(red: 0.5450980392156862, green: 0.8705882352941177, blue: 0.8549019607843137, alpha: 1.0), NSUIColor(red: 0.2627450980392157, green: 0.6784313725490196, blue: 0.8156862745098039, alpha: 1.0), NSUIColor(red: 0.6, green: 0.5568627450980392, blue: 0.8784313725490196, alpha: 1.0), NSUIColor(red: 0.8823529411764706, green: 0.49019607843137253, blue: 0.7607843137254902, alpha: 1.0), NSUIColor(red: 0.9372549019607843, green: 0.5764705882352941, blue: 0.5764705882352941, alpha: 1.0)])

        /// Peach Sea
        public static let peachSea = Self("Peach Sea", [NSUIColor(red: 0.9019607843137255, green: 0.6823529411764706, blue: 0.5490196078431373, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.807843137254902, blue: 0.8117647058823529, alpha: 1.0)])

        /// Abbas
        public static let abbas = Self("Abbas", [NSUIColor(red: 0.0, green: 1.0, blue: 0.9411764705882353, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5137254901960784, blue: 0.996078431372549, alpha: 1.0)])

        /// Winter Woods
        public static let winterWoods = Self("Winter Woods", [NSUIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), NSUIColor(red: 0.6352941176470588, green: 0.6705882352941176, blue: 0.34509803921568627, alpha: 1.0), NSUIColor(red: 0.6431372549019608, green: 0.2235294117647059, blue: 0.19215686274509805, alpha: 1.0)])

        /// Ameena
        public static let ameena = Self("Ameena", [NSUIColor(red: 0.047058823529411764, green: 0.047058823529411764, blue: 0.42745098039215684, alpha: 1.0), NSUIColor(red: 0.8705882352941177, green: 0.3176470588235294, blue: 0.16862745098039217, alpha: 1.0), NSUIColor(red: 0.596078431372549, green: 0.8156862745098039, blue: 0.7568627450980392, alpha: 1.0), NSUIColor(red: 0.3568627450980392, green: 0.6980392156862745, blue: 0.14901960784313725, alpha: 1.0), NSUIColor(red: 0.00784313725490196, green: 0.23529411764705882, blue: 0.050980392156862744, alpha: 1.0)])

        /// Emerald Sea
        public static let emeraldSea = Self("Emerald Sea", [NSUIColor(red: 0.0196078431372549, green: 0.2196078431372549, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.3607843137254902, green: 0.8588235294117647, blue: 0.5843137254901961, alpha: 1.0)])

        /// Bleem
        public static let bleem = Self("Bleem", [NSUIColor(red: 0.25882352941176473, green: 0.5176470588235295, blue: 0.8588235294117647, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 0.9176470588235294, blue: 0.7686274509803922, alpha: 1.0)])

        /// Coffee Gold
        public static let coffeeGold = Self("Coffee Gold", [NSUIColor(red: 0.3333333333333333, green: 0.25098039215686274, blue: 0.13725490196078433, alpha: 1.0), NSUIColor(red: 0.788235294117647, green: 0.596078431372549, blue: 0.27450980392156865, alpha: 1.0)])

        /// Compass
        public static let compass = Self("Compass", [NSUIColor(red: 0.3176470588235294, green: 0.4196078431372549, blue: 0.5450980392156862, alpha: 1.0), NSUIColor(red: 0.0196078431372549, green: 0.4196078431372549, blue: 0.23137254901960785, alpha: 1.0)])

        /// Andreuzzas
        public static let andreuzzas = Self("Andreuzzas", [NSUIColor(red: 0.8431372549019608, green: 0.023529411764705882, blue: 0.3215686274509804, alpha: 1.0), NSUIColor(red: 1.0, green: 0.00784313725490196, blue: 0.3686274509803922, alpha: 1.0)])

        /// Moonwalker
        public static let moonwalker = Self("Moonwalker", [NSUIColor(red: 0.08235294117647059, green: 0.13725490196078433, blue: 0.19215686274509805, alpha: 1.0), NSUIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)])

        /// Whinehouse
        public static let whinehouse = Self("Whinehouse", [NSUIColor(red: 0.9686274509803922, green: 0.9686274509803922, blue: 0.9686274509803922, alpha: 1.0), NSUIColor(red: 0.7254901960784313, green: 0.6274509803921569, blue: 0.6274509803921569, alpha: 1.0), NSUIColor(red: 0.4745098039215686, green: 0.2784313725490196, blue: 0.2784313725490196, alpha: 1.0), NSUIColor(red: 0.3058823529411765, green: 0.12549019607843137, blue: 0.12549019607843137, alpha: 1.0), NSUIColor(red: 0.06666666666666667, green: 0.06666666666666667, blue: 0.06666666666666667, alpha: 1.0)])

        /// Hyper Blue
        public static let hyperBlue = Self("Hyper Blue", [NSUIColor(red: 0.34901960784313724, green: 0.803921568627451, blue: 0.9137254901960784, alpha: 1.0), NSUIColor(red: 0.0392156862745098, green: 0.16470588235294117, blue: 0.5333333333333333, alpha: 1.0)])

        /// Racker
        public static let racker = Self("Racker", [NSUIColor(red: 0.9215686274509803, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.5843137254901961, green: 0.0, blue: 0.5411764705882353, alpha: 1.0), NSUIColor(red: 0.2, green: 0.0, blue: 0.9882352941176471, alpha: 1.0)])

        /// Afterthe Rain
        public static let aftertheRain = Self("Afterthe Rain", [NSUIColor(red: 1.0, green: 0.4588235294117647, blue: 0.7647058823529411, alpha: 1.0), NSUIColor(red: 1.0, green: 0.6509803921568628, blue: 0.2784313725490196, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9098039215686274, blue: 0.24705882352941178, alpha: 1.0), NSUIColor(red: 0.6235294117647059, green: 1.0, blue: 0.3568627450980392, alpha: 1.0), NSUIColor(red: 0.4392156862745098, green: 0.8862745098039215, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.803921568627451, green: 0.5764705882352941, blue: 1.0, alpha: 1.0)])

        /// Neon Green
        public static let neonGreen = Self("Neon Green", [NSUIColor(red: 0.5058823529411764, green: 1.0, blue: 0.5411764705882353, alpha: 1.0), NSUIColor(red: 0.39215686274509803, green: 0.5882352941176471, blue: 0.3686274509803922, alpha: 1.0)])

        /// Dusty Grass
        public static let dustyGrass = Self("Dusty Grass", [NSUIColor(red: 0.8313725490196079, green: 0.9882352941176471, blue: 0.4745098039215686, alpha: 1.0), NSUIColor(red: 0.5882352941176471, green: 0.9019607843137255, blue: 0.6313725490196078, alpha: 1.0)])

        /// Visual Blue
        public static let visualBlue = Self("Visual Blue", [NSUIColor(red: 0.0, green: 0.23921568627450981, blue: 0.30196078431372547, alpha: 1.0), NSUIColor(red: 0.0, green: 0.788235294117647, blue: 0.5882352941176471, alpha: 1.0)])

        public static let allCases: [Self] = [.omolon, .farhan, .purple, .ibtesam, .radioactiveHeat, .theSkyAndTheSea, .fromIceToFire, .blueOrange, .purpleDream, .blu, .summerBreeze, .ver, .verBlack, .combi, .anwar, .bluelagoo, .lunada, .reaqua, .mango, .bupe, .rea, .windy, .royalBlue, .royalBluePetrol, .copper, .anamnisar, .petrol, .sel, .afternoon, .skyline, .dIMIGO, .purpleLove, .sexyBlue, .blooker, .seaBlue, .nimvelo, .hazel, .noontoDusk, .youTube, .coolBrown, .harmonicEnergy, .playingwithReds, .sunnyDays, .greenBeach, .intuitivePurple, .emeraldWater, .lemonTwist, .monteCarlo, .horizon, .roseWater, .frozen, .mangoPulp, .bloodyMary, .aubergine, .aquaMarine, .sunrise, .purpleParadise, .stripe, .seaWeed, .pinky, .cherry, .mojito, .juicyOrange, .mirage, .steelGray, .kashmir, .electricViolet, .veniceBlue, .boraBora, .moss, .shroomHaze, .mystic, .midnightCity, .seaBlizz, .opa, .titanium, .mantle, .dracula, .peach, .moonrise, .clouds, .stellar, .bourbon, .calmDarya, .influenza, .shrimpy, .army, .miaka, .pinotNoir, .dayTripper, .namn, .blurryBeach, .vasily, .aLostMemory, .petrichor, .jonquil, .siriusTamed, .kyoto, .mistyMeadow, .aqualicious, .moor, .almost, .foreverLost, .winter, .nelson, .autumn, .candy, .reef, .theStrain, .dirtyFog, .earthly, .virgin, .ash, .cherryblossoms, .parklife, .danceToForget, .starfall, .redMist, .tealLove, .neonLife, .manofSteel, .amethyst, .cheerUpEmoKid, .shore, .facebookMessenger, .soundCloud, .behongo, .servQuick, .friday, .martini, .metallicToad, .betweenTheClouds, .crazyOrangeI, .hersheys, .talkingToMiceElf, .purpleBliss, .predawn, .endlessRiver, .pastelOrangeattheSun, .twitch, .atlas, .instagram, .flickr, .vine, .turquoiseflow, .portrait, .virginAmerica, .kokoCaramel, .freshTurboscent, .greentodark, .ukraine, .curiosityblue, .darkKnight, .piglet, .lizard, .sagePersuasion, .betweenNightandDay, .timber, .passion, .clearSky, .masterCard, .backToEarth, .deepPurple, .littleLeaf, .netflix, .lightOrange, .greenandBlue, .poncho, .backtotheFuture, .blush, .inbox, .purplin, .paleWood, .haikus, .pizelex, .joomla, .christmas, .minnesotaVikings, .miamiDolphins, .forest, .nighthawk, .superman, .suzy, .darkSkies, .deepSpace, .decent, .colorsOfSky, .purpleWhite, .ali, .alihossein, .shahabi, .redOcean, .tranquil, .transfile, .sylvia, .sweetMorning, .politics, .brightVault, .solidVault, .sunset, .grapefruitSunset, .deepSeaSpace, .dusk, .minimalRed, .royal, .mauve, .frost, .lush, .firewatch, .sherbert, .bloodRed, .sunontheHorizon, .iIITDelhi, .jupiter, .shadesofGrey, .dania, .limeade, .disco, .loveCouple, .azurePop, .nepal, .cosmicFusion, .snapchat, .edsSunsetGradient, .bradyBradyFunFun, .blackRos, .sPurple, .radar, .ibizaSunset, .dawn, .mild, .viceCity, .jaipur, .jodhpur, .cocoaaIce, .easyMed, .roseColoredLenses, .whatliesBeyond, .roseanna, .honeyDew, .undertheLake, .theBlueLagoon, .canYouFeelTheLoveTonight, .veryBlue, .loveandLiberty, .orca, .venice, .pacificDream, .learningandLeading, .celestial, .purplepine, .shalala, .mini, .maldives, .cinnamint, .html, .coal, .sunkist, .blueSkies, .chittyChittyBangBang, .visionsofGrandeur, .crystalClear, .mello, .compareNow, .meridian, .relay, .alive, .scooter, .terminal, .telegram, .crimsonTide, .socialive, .subu, .brokenHearts, .kimobyIsTheNewBlue, .dull, .purpink, .orangeCoral, .summer, .kingYna, .velvetSun, .zinc, .hydrogen, .argon, .lithium, .digitalWater, .orangeFun, .rainbowBlue, .pinkFlavour, .sulphur, .selenium, .delicate, .ohhappiness, .lawrencium, .relaxingred, .taranTado, .bighead, .sublimeVivid, .sublimeLight, .punYeta, .quepal, .sandtoBlue, .weddingDayBlues, .shifter, .redSunset, .moonPurple, .pureLust, .slightOceanView, .eXpresso, .shifty, .vanusa, .eveningNight, .magic, .margo, .blueRaspberry, .citrusPeel, .sinCityRed, .rastafari, .summerDog, .wiretap, .burningOrange, .ultraVoilet, .byDesign, .kyooTah, .kyeMeh, .kyooPal, .metapolis, .flare, .witchingHour, .azurLane, .neuromancer, .harvey, .amin, .memariani, .yoda, .coolSky, .darkOcean, .eveningSunshine, .jShine, .moonlitAsteroid, .megaTron, .coolBlues, .piggyPink, .gradeGrey, .telko, .zenta, .electricPeacock, .underBlueGreen, .lensod, .newspaper, .darkBlueGradient, .darkBluTwo, .lemonLime, .beleko, .mangoPapaya, .unicornRainbow, .flame, .blueRed, .twitter, .blooze, .blueSlate, .spaceLightGreen, .flower, .elateTheEuge, .peachSea, .abbas, .winterWoods, .ameena, .emeraldSea, .bleem, .coffeeGold, .compass, .andreuzzas, .moonwalker, .whinehouse, .hyperBlue, .racker, .aftertheRain, .neonGreen, .dustyGrass, .visualBlue]
    }
}

#endif
