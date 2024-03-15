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

    public extension Gradient {
        enum Preset: CaseIterable {
            case omolon
            case farhan
            case purple
            case ibtesam
            case radioactiveHeat
            case theSkyAndTheSea
            case fromIceToFire
            case blueOrange
            case purpleDream
            case blu
            case summerBreeze
            case ver
            case verBlack
            case combi
            case anwar
            case bluelagoo
            case lunada
            case reaqua
            case mango
            case bupe
            case rea
            case windy
            case royalBlue
            case royalBluePetrol
            case copper
            case anamnisar
            case petrol
            case sel
            case afternoon
            case skyline
            case dIMIGO
            case purpleLove
            case sexyBlue
            case blooker
            case seaBlue
            case nimvelo
            case hazel
            case noontoDusk
            case youTube
            case coolBrown
            case harmonicEnergy
            case playingwithReds
            case sunnyDays
            case greenBeach
            case intuitivePurple
            case emeraldWater
            case lemonTwist
            case monteCarlo
            case horizon
            case roseWater
            case frozen
            case mangoPulp
            case bloodyMary
            case aubergine
            case aquaMarine
            case sunrise
            case purpleParadise
            case stripe
            case seaWeed
            case pinky
            case cherry
            case mojito
            case juicyOrange
            case mirage
            case steelGray
            case kashmir
            case electricViolet
            case veniceBlue
            case boraBora
            case moss
            case shroomHaze
            case mystic
            case midnightCity
            case seaBlizz
            case opa
            case titanium
            case mantle
            case dracula
            case peach
            case moonrise
            case clouds
            case stellar
            case bourbon
            case calmDarya
            case influenza
            case shrimpy
            case army
            case miaka
            case pinotNoir
            case dayTripper
            case namn
            case blurryBeach
            case vasily
            case aLostMemory
            case petrichor
            case jonquil
            case siriusTamed
            case kyoto
            case mistyMeadow
            case aqualicious
            case moor
            case almost
            case foreverLost
            case winter
            case nelson
            case autumn
            case candy
            case reef
            case theStrain
            case dirtyFog
            case earthly
            case virgin
            case ash
            case cherryblossoms
            case parklife
            case danceToForget
            case starfall
            case redMist
            case tealLove
            case neonLife
            case manofSteel
            case amethyst
            case cheerUpEmoKid
            case shore
            case facebookMessenger
            case soundCloud
            case behongo
            case servQuick
            case friday
            case martini
            case metallicToad
            case betweenTheClouds
            case crazyOrangeI
            case hersheys
            case talkingToMiceElf
            case purpleBliss
            case predawn
            case endlessRiver
            case pastelOrangeattheSun
            case twitch
            case atlas
            case instagram
            case flickr
            case vine
            case turquoiseflow
            case portrait
            case virginAmerica
            case kokoCaramel
            case freshTurboscent
            case greentodark
            case ukraine
            case curiosityblue
            case darkKnight
            case piglet
            case lizard
            case sagePersuasion
            case betweenNightandDay
            case timber
            case passion
            case clearSky
            case masterCard
            case backToEarth
            case deepPurple
            case littleLeaf
            case netflix
            case lightOrange
            case greenandBlue
            case poncho
            case backtotheFuture
            case blush
            case inbox
            case purplin
            case paleWood
            case haikus
            case pizelex
            case joomla
            case christmas
            case minnesotaVikings
            case miamiDolphins
            case forest
            case nighthawk
            case superman
            case suzy
            case darkSkies
            case deepSpace
            case decent
            case colorsOfSky
            case purpleWhite
            case ali
            case alihossein
            case shahabi
            case redOcean
            case tranquil
            case transfile
            case sylvia
            case sweetMorning
            case politics
            case brightVault
            case solidVault
            case sunset
            case grapefruitSunset
            case deepSeaSpace
            case dusk
            case minimalRed
            case royal
            case mauve
            case frost
            case lush
            case firewatch
            case sherbert
            case bloodRed
            case sunontheHorizon
            case iIITDelhi
            case jupiter
            case shadesofGrey
            case dania
            case limeade
            case disco
            case loveCouple
            case azurePop
            case nepal
            case cosmicFusion
            case snapchat
            case edsSunsetGradient
            case bradyBradyFunFun
            case blackRos
            case sPurple
            case radar
            case ibizaSunset
            case dawn
            case mild
            case viceCity
            case jaipur
            case jodhpur
            case cocoaaIce
            case easyMed
            case roseColoredLenses
            case whatliesBeyond
            case roseanna
            case honeyDew
            case undertheLake
            case theBlueLagoon
            case canYouFeelTheLoveTonight
            case veryBlue
            case loveandLiberty
            case orca
            case venice
            case pacificDream
            case learningandLeading
            case celestial
            case purplepine
            case shalala
            case mini
            case maldives
            case cinnamint
            case html
            case coal
            case sunkist
            case blueSkies
            case chittyChittyBangBang
            case visionsofGrandeur
            case crystalClear
            case mello
            case compareNow
            case meridian
            case relay
            case alive
            case scooter
            case terminal
            case telegram
            case crimsonTide
            case socialive
            case subu
            case brokenHearts
            case kimobyIsTheNewBlue
            case dull
            case purpink
            case orangeCoral
            case summer
            case kingYna
            case velvetSun
            case zinc
            case hydrogen
            case argon
            case lithium
            case digitalWater
            case orangeFun
            case rainbowBlue
            case pinkFlavour
            case sulphur
            case selenium
            case delicate
            case ohhappiness
            case lawrencium
            case relaxingred
            case taranTado
            case bighead
            case sublimeVivid
            case sublimeLight
            case punYeta
            case quepal
            case sandtoBlue
            case weddingDayBlues
            case shifter
            case redSunset
            case moonPurple
            case pureLust
            case slightOceanView
            case eXpresso
            case shifty
            case vanusa
            case eveningNight
            case magic
            case margo
            case blueRaspberry
            case citrusPeel
            case sinCityRed
            case rastafari
            case summerDog
            case wiretap
            case burningOrange
            case ultraVoilet
            case byDesign
            case kyooTah
            case kyeMeh
            case kyooPal
            case metapolis
            case flare
            case witchingHour
            case azurLane
            case neuromancer
            case harvey
            case amin
            case memariani
            case yoda
            case coolSky
            case darkOcean
            case eveningSunshine
            case jShine
            case moonlitAsteroid
            case megaTron
            case coolBlues
            case piggyPink
            case gradeGrey
            case telko
            case zenta
            case electricPeacock
            case underBlueGreen
            case lensod
            case newspaper
            case darkBlueGradient
            case darkBluTwo
            case lemonLime
            case beleko
            case mangoPapaya
            case unicornRainbow
            case flame
            case blueRed
            case twitter
            case blooze
            case blueSlate
            case spaceLightGreen
            case flower
            case elateTheEuge
            case peachSea
            case abbas
            case winterWoods
            case ameena
            case emeraldSea
            case bleem
            case coffeeGold
            case compass
            case andreuzzas
            case moonwalker
            case whinehouse
            case hyperBlue
            case racker
            case aftertheRain
            case neonGreen
            case dustyGrass
            case visualBlue

            public var colors: [NSUIColor] {
                switch self {
                case .omolon:
                    return [NSUIColor(red: 0.03529411764705882, green: 0.11764705882352941, blue: 0.22745098039215686, alpha: 1.0), NSUIColor(red: 0.1843137254901961, green: 0.5019607843137255, blue: 0.9294117647058824, alpha: 1.0), NSUIColor(red: 0.17647058823529413, green: 0.6196078431372549, blue: 0.8784313725490196, alpha: 1.0)]
                case .farhan:
                    return [NSUIColor(red: 0.5803921568627451, green: 0.0, blue: 0.8274509803921568, alpha: 1.0), NSUIColor(red: 0.29411764705882354, green: 0.0, blue: 0.5098039215686274, alpha: 1.0)]
                case .purple:
                    return [NSUIColor(red: 0.7843137254901961, green: 0.3058823529411765, blue: 0.5372549019607843, alpha: 1.0), NSUIColor(red: 0.9450980392156862, green: 0.37254901960784315, blue: 0.4745098039215686, alpha: 1.0)]
                case .ibtesam:
                    return [NSUIColor(red: 0.0, green: 0.9607843137254902, blue: 0.6274509803921569, alpha: 1.0), NSUIColor(red: 0.0, green: 0.8509803921568627, blue: 0.9607843137254902, alpha: 1.0)]
                case .radioactiveHeat:
                    return [NSUIColor(red: 0.9686274509803922, green: 0.5803921568627451, blue: 0.11764705882352941, alpha: 1.0), NSUIColor(red: 0.4470588235294118, green: 0.7764705882352941, blue: 0.9372549019607843, alpha: 1.0), NSUIColor(red: 0.0, green: 0.6509803921568628, blue: 0.3176470588235294, alpha: 1.0)]
                case .theSkyAndTheSea:
                    return [NSUIColor(red: 0.9686274509803922, green: 0.5803921568627451, blue: 0.11764705882352941, alpha: 1.0), NSUIColor(red: 0.0, green: 0.3058823529411765, blue: 0.5607843137254902, alpha: 1.0)]
                case .fromIceToFire:
                    return [NSUIColor(red: 0.4470588235294118, green: 0.7764705882352941, blue: 0.9372549019607843, alpha: 1.0), NSUIColor(red: 0.0, green: 0.3058823529411765, blue: 0.5607843137254902, alpha: 1.0)]
                case .blueOrange:
                    return [NSUIColor(red: 0.9921568627450981, green: 0.5058823529411764, blue: 0.07058823529411765, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5215686274509804, blue: 0.792156862745098, alpha: 1.0)]
                case .purpleDream:
                    return [NSUIColor(red: 0.7490196078431373, green: 0.35294117647058826, blue: 0.8784313725490196, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.06666666666666667, blue: 0.8549019607843137, alpha: 1.0)]
                case .blu:
                    return [NSUIColor(red: 0.0, green: 0.2549019607843137, blue: 0.41568627450980394, alpha: 1.0), NSUIColor(red: 0.8941176470588236, green: 0.8980392156862745, blue: 0.9019607843137255, alpha: 1.0)]
                case .summerBreeze:
                    return [NSUIColor(red: 0.984313725490196, green: 0.9294117647058824, blue: 0.5882352941176471, alpha: 1.0), NSUIColor(red: 0.6705882352941176, green: 0.9254901960784314, blue: 0.8392156862745098, alpha: 1.0)]
                case .ver:
                    return [NSUIColor(red: 1.0, green: 0.8784313725490196, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.4745098039215686, green: 0.6235294117647059, blue: 0.047058823529411764, alpha: 1.0)]
                case .verBlack:
                    return [NSUIColor(red: 0.9686274509803922, green: 0.9725490196078431, blue: 0.9725490196078431, alpha: 1.0), NSUIColor(red: 0.6745098039215687, green: 0.7333333333333333, blue: 0.47058823529411764, alpha: 1.0)]
                case .combi:
                    return [NSUIColor(red: 0.0, green: 0.2549019607843137, blue: 0.41568627450980394, alpha: 1.0), NSUIColor(red: 0.4745098039215686, green: 0.6235294117647059, blue: 0.047058823529411764, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8784313725490196, blue: 0.0, alpha: 1.0)]
                case .anwar:
                    return [NSUIColor(red: 0.2, green: 0.30196078431372547, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.796078431372549, green: 0.792156862745098, blue: 0.6470588235294118, alpha: 1.0)]
                case .bluelagoo:
                    return [NSUIColor(red: 0.0, green: 0.3215686274509804, blue: 0.8313725490196079, alpha: 1.0), NSUIColor(red: 0.2627450980392157, green: 0.39215686274509803, blue: 0.9686274509803922, alpha: 1.0), NSUIColor(red: 0.43529411764705883, green: 0.6941176470588235, blue: 0.9882352941176471, alpha: 1.0)]
                case .lunada:
                    return [NSUIColor(red: 0.32941176470588235, green: 0.2, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.12549019607843137, green: 0.7411764705882353, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.6470588235294118, green: 0.996078431372549, blue: 0.796078431372549, alpha: 1.0)]
                case .reaqua:
                    return [NSUIColor(red: 0.4745098039215686, green: 0.6235294117647059, blue: 0.047058823529411764, alpha: 1.0), NSUIColor(red: 0.6745098039215687, green: 0.7333333333333333, blue: 0.47058823529411764, alpha: 1.0)]
                case .mango:
                    return [NSUIColor(red: 1.0, green: 0.8862745098039215, blue: 0.34901960784313724, alpha: 1.0), NSUIColor(red: 1.0, green: 0.6549019607843137, blue: 0.3176470588235294, alpha: 1.0)]
                case .bupe:
                    return [NSUIColor(red: 0.0, green: 0.2549019607843137, blue: 0.41568627450980394, alpha: 1.0), NSUIColor(red: 0.8941176470588236, green: 0.8980392156862745, blue: 0.9019607843137255, alpha: 1.0)]
                case .rea:
                    return [NSUIColor(red: 1.0, green: 0.8784313725490196, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.4745098039215686, green: 0.6235294117647059, blue: 0.047058823529411764, alpha: 1.0)]
                case .windy:
                    return [NSUIColor(red: 0.6745098039215687, green: 0.7137254901960784, blue: 0.8980392156862745, alpha: 1.0), NSUIColor(red: 0.5254901960784314, green: 0.9921568627450981, blue: 0.9098039215686274, alpha: 1.0)]
                case .royalBlue:
                    return [NSUIColor(red: 0.3254901960784314, green: 0.4117647058823529, blue: 0.4627450980392157, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 0.1803921568627451, blue: 0.28627450980392155, alpha: 1.0)]
                case .royalBluePetrol:
                    return [NSUIColor(red: 0.7333333333333333, green: 0.8235294117647058, blue: 0.7725490196078432, alpha: 1.0), NSUIColor(red: 0.3254901960784314, green: 0.4117647058823529, blue: 0.4627450980392157, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 0.1803921568627451, blue: 0.28627450980392155, alpha: 1.0)]
                case .copper:
                    return [NSUIColor(red: 0.7176470588235294, green: 0.596078431372549, blue: 0.5686274509803921, alpha: 1.0), NSUIColor(red: 0.5803921568627451, green: 0.44313725490196076, blue: 0.4196078431372549, alpha: 1.0)]
                case .anamnisar:
                    return [NSUIColor(red: 0.592156862745098, green: 0.5882352941176471, blue: 0.9411764705882353, alpha: 1.0), NSUIColor(red: 0.984313725490196, green: 0.7803921568627451, blue: 0.8313725490196079, alpha: 1.0)]
                case .petrol:
                    return [NSUIColor(red: 0.7333333333333333, green: 0.8235294117647058, blue: 0.7725490196078432, alpha: 1.0), NSUIColor(red: 0.3254901960784314, green: 0.4117647058823529, blue: 0.4627450980392157, alpha: 1.0)]
                case .sel:
                    return [NSUIColor(red: 0.0, green: 0.27450980392156865, blue: 0.4980392156862745, alpha: 1.0), NSUIColor(red: 0.6470588235294118, green: 0.8, blue: 0.5098039215686274, alpha: 1.0)]
                case .afternoon:
                    return [NSUIColor(red: 0.0, green: 0.047058823529411764, blue: 0.25098039215686274, alpha: 1.0), NSUIColor(red: 0.3764705882352941, green: 0.49019607843137253, blue: 0.5450980392156862, alpha: 1.0)]
                case .skyline:
                    return [NSUIColor(red: 0.0784313725490196, green: 0.5333333333333333, blue: 0.8, alpha: 1.0), NSUIColor(red: 0.16862745098039217, green: 0.19607843137254902, blue: 0.6980392156862745, alpha: 1.0)]
                case .dIMIGO:
                    return [NSUIColor(red: 0.9254901960784314, green: 0.0, blue: 0.5490196078431373, alpha: 1.0), NSUIColor(red: 0.9882352941176471, green: 0.403921568627451, blue: 0.403921568627451, alpha: 1.0)]
                case .purpleLove:
                    return [NSUIColor(red: 0.8, green: 0.16862745098039217, blue: 0.3686274509803922, alpha: 1.0), NSUIColor(red: 0.4588235294117647, green: 0.22745098039215686, blue: 0.5333333333333333, alpha: 1.0)]
                case .sexyBlue:
                    return [NSUIColor(red: 0.12941176470588237, green: 0.5764705882352941, blue: 0.6901960784313725, alpha: 1.0), NSUIColor(red: 0.42745098039215684, green: 0.8352941176470589, blue: 0.9294117647058824, alpha: 1.0)]
                case .blooker:
                    return [NSUIColor(red: 0.9019607843137255, green: 0.3607843137254902, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.9764705882352941, green: 0.8313725490196079, blue: 0.13725490196078433, alpha: 1.0)]
                case .seaBlue:
                    return [NSUIColor(red: 0.16862745098039217, green: 0.34509803921568627, blue: 0.4627450980392157, alpha: 1.0), NSUIColor(red: 0.3058823529411765, green: 0.2627450980392157, blue: 0.4627450980392157, alpha: 1.0)]
                case .nimvelo:
                    return [NSUIColor(red: 0.19215686274509805, green: 0.2784313725490196, blue: 0.3333333333333333, alpha: 1.0), NSUIColor(red: 0.14901960784313725, green: 0.6274509803921569, blue: 0.8549019607843137, alpha: 1.0)]
                case .hazel:
                    return [NSUIColor(red: 0.4666666666666667, green: 0.6313725490196078, blue: 0.8274509803921568, alpha: 1.0), NSUIColor(red: 0.4745098039215686, green: 0.796078431372549, blue: 0.792156862745098, alpha: 1.0), NSUIColor(red: 0.9019607843137255, green: 0.5176470588235295, blue: 0.6823529411764706, alpha: 1.0)]
                case .noontoDusk:
                    return [NSUIColor(red: 1.0, green: 0.43137254901960786, blue: 0.4980392156862745, alpha: 1.0), NSUIColor(red: 0.7490196078431373, green: 0.9137254901960784, blue: 1.0, alpha: 1.0)]
                case .youTube:
                    return [NSUIColor(red: 0.8980392156862745, green: 0.17647058823529413, blue: 0.15294117647058825, alpha: 1.0), NSUIColor(red: 0.7019607843137254, green: 0.07058823529411765, blue: 0.09019607843137255, alpha: 1.0)]
                case .coolBrown:
                    return [NSUIColor(red: 0.3764705882352941, green: 0.2196078431372549, blue: 0.07450980392156863, alpha: 1.0), NSUIColor(red: 0.6980392156862745, green: 0.6235294117647059, blue: 0.5803921568627451, alpha: 1.0)]
                case .harmonicEnergy:
                    return [NSUIColor(red: 0.08627450980392157, green: 0.6274509803921569, blue: 0.5215686274509804, alpha: 1.0), NSUIColor(red: 0.9568627450980393, green: 0.8156862745098039, blue: 0.24705882352941178, alpha: 1.0)]
                case .playingwithReds:
                    return [NSUIColor(red: 0.8274509803921568, green: 0.06274509803921569, blue: 0.15294117647058825, alpha: 1.0), NSUIColor(red: 0.9176470588235294, green: 0.2196078431372549, blue: 0.30196078431372547, alpha: 1.0)]
                case .sunnyDays:
                    return [NSUIColor(red: 0.9294117647058824, green: 0.8980392156862745, blue: 0.4549019607843137, alpha: 1.0), NSUIColor(red: 0.8823529411764706, green: 0.9607843137254902, blue: 0.7686274509803922, alpha: 1.0)]
                case .greenBeach:
                    return [NSUIColor(red: 0.00784313725490196, green: 0.6666666666666666, blue: 0.6901960784313725, alpha: 1.0), NSUIColor(red: 0.0, green: 0.803921568627451, blue: 0.6745098039215687, alpha: 1.0)]
                case .intuitivePurple:
                    return [NSUIColor(red: 0.8549019607843137, green: 0.13333333333333333, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.592156862745098, green: 0.2, blue: 0.9333333333333333, alpha: 1.0)]
                case .emeraldWater:
                    return [NSUIColor(red: 0.20392156862745098, green: 0.5607843137254902, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.33725490196078434, green: 0.7058823529411765, blue: 0.8274509803921568, alpha: 1.0)]
                case .lemonTwist:
                    return [NSUIColor(red: 0.23529411764705882, green: 0.6470588235294118, blue: 0.3607843137254902, alpha: 1.0), NSUIColor(red: 0.7098039215686275, green: 0.6745098039215687, blue: 0.28627450980392155, alpha: 1.0)]
                case .monteCarlo:
                    return [NSUIColor(red: 0.8, green: 0.5843137254901961, blue: 0.7529411764705882, alpha: 1.0), NSUIColor(red: 0.8588235294117647, green: 0.8313725490196079, blue: 0.7058823529411765, alpha: 1.0), NSUIColor(red: 0.47843137254901963, green: 0.6313725490196078, blue: 0.8235294117647058, alpha: 1.0)]
                case .horizon:
                    return [NSUIColor(red: 0.0, green: 0.2235294117647059, blue: 0.45098039215686275, alpha: 1.0), NSUIColor(red: 0.8980392156862745, green: 0.8980392156862745, blue: 0.7450980392156863, alpha: 1.0)]
                case .roseWater:
                    return [NSUIColor(red: 0.8980392156862745, green: 0.36470588235294116, blue: 0.5294117647058824, alpha: 1.0), NSUIColor(red: 0.37254901960784315, green: 0.7647058823529411, blue: 0.8941176470588236, alpha: 1.0)]
                case .frozen:
                    return [NSUIColor(red: 0.25098039215686274, green: 0.23137254901960785, blue: 0.2901960784313726, alpha: 1.0), NSUIColor(red: 0.9058823529411765, green: 0.9137254901960784, blue: 0.7333333333333333, alpha: 1.0)]
                case .mangoPulp:
                    return [NSUIColor(red: 0.9411764705882353, green: 0.596078431372549, blue: 0.09803921568627451, alpha: 1.0), NSUIColor(red: 0.9294117647058824, green: 0.8705882352941177, blue: 0.36470588235294116, alpha: 1.0)]
                case .bloodyMary:
                    return [NSUIColor(red: 1.0, green: 0.3176470588235294, blue: 0.1843137254901961, alpha: 1.0), NSUIColor(red: 0.8666666666666667, green: 0.1411764705882353, blue: 0.4627450980392157, alpha: 1.0)]
                case .aubergine:
                    return [NSUIColor(red: 0.6666666666666666, green: 0.027450980392156862, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.3803921568627451, green: 0.01568627450980392, blue: 0.37254901960784315, alpha: 1.0)]
                case .aquaMarine:
                    return [NSUIColor(red: 0.10196078431372549, green: 0.1607843137254902, blue: 0.5019607843137255, alpha: 1.0), NSUIColor(red: 0.14901960784313725, green: 0.8156862745098039, blue: 0.807843137254902, alpha: 1.0)]
                case .sunrise:
                    return [NSUIColor(red: 1.0, green: 0.3176470588235294, blue: 0.1843137254901961, alpha: 1.0), NSUIColor(red: 0.9411764705882353, green: 0.596078431372549, blue: 0.09803921568627451, alpha: 1.0)]
                case .purpleParadise:
                    return [NSUIColor(red: 0.11372549019607843, green: 0.16862745098039217, blue: 0.39215686274509803, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 0.803921568627451, blue: 0.8549019607843137, alpha: 1.0)]
                case .stripe:
                    return [NSUIColor(red: 0.12156862745098039, green: 0.6352941176470588, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.07058823529411765, green: 0.8470588235294118, blue: 0.9803921568627451, alpha: 1.0), NSUIColor(red: 0.6509803921568628, green: 1.0, blue: 0.796078431372549, alpha: 1.0)]
                case .seaWeed:
                    return [NSUIColor(red: 0.2980392156862745, green: 0.7215686274509804, blue: 0.7686274509803922, alpha: 1.0), NSUIColor(red: 0.23529411764705882, green: 0.8274509803921568, blue: 0.6784313725490196, alpha: 1.0)]
                case .pinky:
                    return [NSUIColor(red: 0.8666666666666667, green: 0.3686274509803922, blue: 0.5372549019607843, alpha: 1.0), NSUIColor(red: 0.9686274509803922, green: 0.7333333333333333, blue: 0.592156862745098, alpha: 1.0)]
                case .cherry:
                    return [NSUIColor(red: 0.9215686274509803, green: 0.2, blue: 0.28627450980392155, alpha: 1.0), NSUIColor(red: 0.9568627450980393, green: 0.3607843137254902, blue: 0.2627450980392157, alpha: 1.0)]
                case .mojito:
                    return [NSUIColor(red: 0.11372549019607843, green: 0.592156862745098, blue: 0.4235294117647059, alpha: 1.0), NSUIColor(red: 0.5764705882352941, green: 0.9764705882352941, blue: 0.7254901960784313, alpha: 1.0)]
                case .juicyOrange:
                    return [NSUIColor(red: 1.0, green: 0.5019607843137255, blue: 0.03137254901960784, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7843137254901961, blue: 0.21568627450980393, alpha: 1.0)]
                case .mirage:
                    return [NSUIColor(red: 0.08627450980392157, green: 0.13333333333333333, blue: 0.16470588235294117, alpha: 1.0), NSUIColor(red: 0.22745098039215686, green: 0.3764705882352941, blue: 0.45098039215686275, alpha: 1.0)]
                case .steelGray:
                    return [NSUIColor(red: 0.12156862745098039, green: 0.10980392156862745, blue: 0.17254901960784313, alpha: 1.0), NSUIColor(red: 0.5725490196078431, green: 0.5529411764705883, blue: 0.6705882352941176, alpha: 1.0)]
                case .kashmir:
                    return [NSUIColor(red: 0.3803921568627451, green: 0.2627450980392157, blue: 0.5215686274509804, alpha: 1.0), NSUIColor(red: 0.3176470588235294, green: 0.38823529411764707, blue: 0.5843137254901961, alpha: 1.0)]
                case .electricViolet:
                    return [NSUIColor(red: 0.2784313725490196, green: 0.4627450980392157, blue: 0.9019607843137255, alpha: 1.0), NSUIColor(red: 0.5568627450980392, green: 0.32941176470588235, blue: 0.9137254901960784, alpha: 1.0)]
                case .veniceBlue:
                    return [NSUIColor(red: 0.03137254901960784, green: 0.3137254901960784, blue: 0.47058823529411764, alpha: 1.0), NSUIColor(red: 0.5215686274509804, green: 0.8470588235294118, blue: 0.807843137254902, alpha: 1.0)]
                case .boraBora:
                    return [NSUIColor(red: 0.16862745098039217, green: 0.7529411764705882, blue: 0.8941176470588236, alpha: 1.0), NSUIColor(red: 0.9176470588235294, green: 0.9254901960784314, blue: 0.7764705882352941, alpha: 1.0)]
                case .moss:
                    return [NSUIColor(red: 0.07450980392156863, green: 0.3058823529411765, blue: 0.3686274509803922, alpha: 1.0), NSUIColor(red: 0.44313725490196076, green: 0.6980392156862745, blue: 0.5019607843137255, alpha: 1.0)]
                case .shroomHaze:
                    return [NSUIColor(red: 0.3607843137254902, green: 0.1450980392156863, blue: 0.5529411764705883, alpha: 1.0), NSUIColor(red: 0.2627450980392157, green: 0.5372549019607843, blue: 0.6352941176470588, alpha: 1.0)]
                case .mystic:
                    return [NSUIColor(red: 0.4588235294117647, green: 0.4980392156862745, blue: 0.6039215686274509, alpha: 1.0), NSUIColor(red: 0.8431372549019608, green: 0.8666666666666667, blue: 0.9098039215686274, alpha: 1.0)]
                case .midnightCity:
                    return [NSUIColor(red: 0.13725490196078433, green: 0.1450980392156863, blue: 0.14901960784313725, alpha: 1.0), NSUIColor(red: 0.2549019607843137, green: 0.2627450980392157, blue: 0.27058823529411763, alpha: 1.0)]
                case .seaBlizz:
                    return [NSUIColor(red: 0.10980392156862745, green: 0.8470588235294118, blue: 0.8235294117647058, alpha: 1.0), NSUIColor(red: 0.5764705882352941, green: 0.9294117647058824, blue: 0.7803921568627451, alpha: 1.0)]
                case .opa:
                    return [NSUIColor(red: 0.23921568627450981, green: 0.49411764705882355, blue: 0.6666666666666666, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8941176470588236, blue: 0.47843137254901963, alpha: 1.0)]
                case .titanium:
                    return [NSUIColor(red: 0.1568627450980392, green: 0.18823529411764706, blue: 0.2823529411764706, alpha: 1.0), NSUIColor(red: 0.5215686274509804, green: 0.5764705882352941, blue: 0.596078431372549, alpha: 1.0)]
                case .mantle:
                    return [NSUIColor(red: 0.1411764705882353, green: 0.7764705882352941, blue: 0.8627450980392157, alpha: 1.0), NSUIColor(red: 0.3176470588235294, green: 0.2901960784313726, blue: 0.615686274509804, alpha: 1.0)]
                case .dracula:
                    return [NSUIColor(red: 0.8627450980392157, green: 0.1411764705882353, blue: 0.1411764705882353, alpha: 1.0), NSUIColor(red: 0.2901960784313726, green: 0.33725490196078434, blue: 0.615686274509804, alpha: 1.0)]
                case .peach:
                    return [NSUIColor(red: 0.9294117647058824, green: 0.25882352941176473, blue: 0.39215686274509803, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9294117647058824, blue: 0.7372549019607844, alpha: 1.0)]
                case .moonrise:
                    return [NSUIColor(red: 0.8549019607843137, green: 0.8862745098039215, blue: 0.9725490196078431, alpha: 1.0), NSUIColor(red: 0.8392156862745098, green: 0.6431372549019608, blue: 0.6431372549019608, alpha: 1.0)]
                case .clouds:
                    return [NSUIColor(red: 0.9254901960784314, green: 0.9137254901960784, blue: 0.9019607843137255, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
                case .stellar:
                    return [NSUIColor(red: 0.4549019607843137, green: 0.4549019607843137, blue: 0.7490196078431373, alpha: 1.0), NSUIColor(red: 0.20392156862745098, green: 0.5411764705882353, blue: 0.7803921568627451, alpha: 1.0)]
                case .bourbon:
                    return [NSUIColor(red: 0.9254901960784314, green: 0.43529411764705883, blue: 0.4, alpha: 1.0), NSUIColor(red: 0.9529411764705882, green: 0.6313725490196078, blue: 0.5137254901960784, alpha: 1.0)]
                case .calmDarya:
                    return [NSUIColor(red: 0.37254901960784315, green: 0.17254901960784313, blue: 0.5098039215686274, alpha: 1.0), NSUIColor(red: 0.28627450980392155, green: 0.6274509803921569, blue: 0.615686274509804, alpha: 1.0)]
                case .influenza:
                    return [NSUIColor(red: 0.7529411764705882, green: 0.2823529411764706, blue: 0.2823529411764706, alpha: 1.0), NSUIColor(red: 0.2823529411764706, green: 0.0, blue: 0.2823529411764706, alpha: 1.0)]
                case .shrimpy:
                    return [NSUIColor(red: 0.8941176470588236, green: 0.22745098039215686, blue: 0.08235294117647059, alpha: 1.0), NSUIColor(red: 0.9019607843137255, green: 0.3215686274509804, blue: 0.27058823529411763, alpha: 1.0)]
                case .army:
                    return [NSUIColor(red: 0.2549019607843137, green: 0.30196078431372547, blue: 0.043137254901960784, alpha: 1.0), NSUIColor(red: 0.4470588235294118, green: 0.47843137254901963, blue: 0.09019607843137255, alpha: 1.0)]
                case .miaka:
                    return [NSUIColor(red: 0.9882352941176471, green: 0.20784313725490197, blue: 0.2980392156862745, alpha: 1.0), NSUIColor(red: 0.0392156862745098, green: 0.7490196078431373, blue: 0.7372549019607844, alpha: 1.0)]
                case .pinotNoir:
                    return [NSUIColor(red: 0.29411764705882354, green: 0.4235294117647059, blue: 0.7176470588235294, alpha: 1.0), NSUIColor(red: 0.09411764705882353, green: 0.1568627450980392, blue: 0.2823529411764706, alpha: 1.0)]
                case .dayTripper:
                    return [NSUIColor(red: 0.9725490196078431, green: 0.3411764705882353, blue: 0.6509803921568628, alpha: 1.0), NSUIColor(red: 1.0, green: 0.34509803921568627, blue: 0.34509803921568627, alpha: 1.0)]
                case .namn:
                    return [NSUIColor(red: 0.6549019607843137, green: 0.21568627450980393, blue: 0.21568627450980393, alpha: 1.0), NSUIColor(red: 0.47843137254901963, green: 0.1568627450980392, blue: 0.1568627450980392, alpha: 1.0)]
                case .blurryBeach:
                    return [NSUIColor(red: 0.8352941176470589, green: 0.2, blue: 0.4117647058823529, alpha: 1.0), NSUIColor(red: 0.796078431372549, green: 0.6784313725490196, blue: 0.42745098039215684, alpha: 1.0)]
                case .vasily:
                    return [NSUIColor(red: 0.9137254901960784, green: 0.8274509803921568, blue: 0.3843137254901961, alpha: 1.0), NSUIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)]
                case .aLostMemory:
                    return [NSUIColor(red: 0.8705882352941177, green: 0.3843137254901961, blue: 0.3843137254901961, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7215686274509804, blue: 0.5490196078431373, alpha: 1.0)]
                case .petrichor:
                    return [NSUIColor(red: 0.4, green: 0.4, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.6, green: 0.6, blue: 0.4, alpha: 1.0)]
                case .jonquil:
                    return [NSUIColor(red: 1.0, green: 0.9333333333333333, blue: 0.9333333333333333, alpha: 1.0), NSUIColor(red: 0.8666666666666667, green: 0.9372549019607843, blue: 0.7333333333333333, alpha: 1.0)]
                case .siriusTamed:
                    return [NSUIColor(red: 0.9372549019607843, green: 0.9372549019607843, blue: 0.7333333333333333, alpha: 1.0), NSUIColor(red: 0.8313725490196079, green: 0.8274509803921568, blue: 0.8666666666666667, alpha: 1.0)]
                case .kyoto:
                    return [NSUIColor(red: 0.7607843137254902, green: 0.08235294117647059, blue: 0.0, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7725490196078432, blue: 0.0, alpha: 1.0)]
                case .mistyMeadow:
                    return [NSUIColor(red: 0.12941176470588237, green: 0.37254901960784315, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.8941176470588236, green: 0.8941176470588236, blue: 0.8509803921568627, alpha: 1.0)]
                case .aqualicious:
                    return [NSUIColor(red: 0.3137254901960784, green: 0.788235294117647, blue: 0.7647058823529411, alpha: 1.0), NSUIColor(red: 0.5882352941176471, green: 0.8705882352941177, blue: 0.8549019607843137, alpha: 1.0)]
                case .moor:
                    return [NSUIColor(red: 0.3803921568627451, green: 0.3803921568627451, blue: 0.3803921568627451, alpha: 1.0), NSUIColor(red: 0.6078431372549019, green: 0.7725490196078432, blue: 0.7647058823529411, alpha: 1.0)]
                case .almost:
                    return [NSUIColor(red: 0.8666666666666667, green: 0.8392156862745098, blue: 0.9529411764705882, alpha: 1.0), NSUIColor(red: 0.9803921568627451, green: 0.6745098039215687, blue: 0.6588235294117647, alpha: 1.0)]
                case .foreverLost:
                    return [NSUIColor(red: 0.36470588235294116, green: 0.2549019607843137, blue: 0.3411764705882353, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.792156862745098, blue: 0.7294117647058823, alpha: 1.0)]
                case .winter:
                    return [NSUIColor(red: 0.9019607843137255, green: 0.8549019607843137, blue: 0.8549019607843137, alpha: 1.0), NSUIColor(red: 0.15294117647058825, green: 0.25098039215686274, blue: 0.27450980392156865, alpha: 1.0)]
                case .nelson:
                    return [NSUIColor(red: 0.9490196078431372, green: 0.4392156862745098, blue: 0.611764705882353, alpha: 1.0), NSUIColor(red: 1.0, green: 0.5803921568627451, blue: 0.4470588235294118, alpha: 1.0)]
                case .autumn:
                    return [NSUIColor(red: 0.8549019607843137, green: 0.8235294117647058, blue: 0.6, alpha: 1.0), NSUIColor(red: 0.6901960784313725, green: 0.8549019607843137, blue: 0.7254901960784313, alpha: 1.0)]
                case .candy:
                    return [NSUIColor(red: 0.8274509803921568, green: 0.5843137254901961, blue: 0.6078431372549019, alpha: 1.0), NSUIColor(red: 0.7490196078431373, green: 0.9019607843137255, blue: 0.7294117647058823, alpha: 1.0)]
                case .reef:
                    return [NSUIColor(red: 0.0, green: 0.8235294117647058, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.22745098039215686, green: 0.4823529411764706, blue: 0.8352941176470589, alpha: 1.0)]
                case .theStrain:
                    return [NSUIColor(red: 0.5294117647058824, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.09803921568627451, green: 0.0392156862745098, blue: 0.0196078431372549, alpha: 1.0)]
                case .dirtyFog:
                    return [NSUIColor(red: 0.7254901960784313, green: 0.5764705882352941, blue: 0.8392156862745098, alpha: 1.0), NSUIColor(red: 0.5490196078431373, green: 0.6509803921568628, blue: 0.8588235294117647, alpha: 1.0)]
                case .earthly:
                    return [NSUIColor(red: 0.39215686274509803, green: 0.5686274509803921, blue: 0.45098039215686275, alpha: 1.0), NSUIColor(red: 0.8588235294117647, green: 0.8352941176470589, blue: 0.6431372549019608, alpha: 1.0)]
                case .virgin:
                    return [NSUIColor(red: 0.788235294117647, green: 1.0, blue: 0.7490196078431373, alpha: 1.0), NSUIColor(red: 1.0, green: 0.6862745098039216, blue: 0.7411764705882353, alpha: 1.0)]
                case .ash:
                    return [NSUIColor(red: 0.3764705882352941, green: 0.4235294117647059, blue: 0.5333333333333333, alpha: 1.0), NSUIColor(red: 0.24705882352941178, green: 0.2980392156862745, blue: 0.4196078431372549, alpha: 1.0)]
                case .cherryblossoms:
                    return [NSUIColor(red: 0.984313725490196, green: 0.8274509803921568, blue: 0.9137254901960784, alpha: 1.0), NSUIColor(red: 0.7333333333333333, green: 0.21568627450980393, blue: 0.49019607843137253, alpha: 1.0)]
                case .parklife:
                    return [NSUIColor(red: 0.6784313725490196, green: 0.8196078431372549, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.4823529411764706, green: 0.5725490196078431, blue: 0.0392156862745098, alpha: 1.0)]
                case .danceToForget:
                    return [NSUIColor(red: 1.0, green: 0.3058823529411765, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.9764705882352941, green: 0.8313725490196079, blue: 0.13725490196078433, alpha: 1.0)]
                case .starfall:
                    return [NSUIColor(red: 0.9411764705882353, green: 0.7607843137254902, blue: 0.4823529411764706, alpha: 1.0), NSUIColor(red: 0.29411764705882354, green: 0.07058823529411765, blue: 0.2823529411764706, alpha: 1.0)]
                case .redMist:
                    return [NSUIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.9058823529411765, green: 0.2980392156862745, blue: 0.23529411764705882, alpha: 1.0)]
                case .tealLove:
                    return [NSUIColor(red: 0.6666666666666666, green: 1.0, blue: 0.6627450980392157, alpha: 1.0), NSUIColor(red: 0.06666666666666667, green: 1.0, blue: 0.7411764705882353, alpha: 1.0)]
                case .neonLife:
                    return [NSUIColor(red: 0.7019607843137254, green: 1.0, blue: 0.6705882352941176, alpha: 1.0), NSUIColor(red: 0.07058823529411765, green: 1.0, blue: 0.9686274509803922, alpha: 1.0)]
                case .manofSteel:
                    return [NSUIColor(red: 0.47058823529411764, green: 0.00784313725490196, blue: 0.023529411764705882, alpha: 1.0), NSUIColor(red: 0.023529411764705882, green: 0.06666666666666667, blue: 0.3803921568627451, alpha: 1.0)]
                case .amethyst:
                    return [NSUIColor(red: 0.615686274509804, green: 0.3137254901960784, blue: 0.7333333333333333, alpha: 1.0), NSUIColor(red: 0.43137254901960786, green: 0.2823529411764706, blue: 0.6666666666666666, alpha: 1.0)]
                case .cheerUpEmoKid:
                    return [NSUIColor(red: 0.3333333333333333, green: 0.3843137254901961, blue: 0.4392156862745098, alpha: 1.0), NSUIColor(red: 1.0, green: 0.4196078431372549, blue: 0.4196078431372549, alpha: 1.0)]
                case .shore:
                    return [NSUIColor(red: 0.4392156862745098, green: 0.8823529411764706, blue: 0.9607843137254902, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8196078431372549, blue: 0.5803921568627451, alpha: 1.0)]
                case .facebookMessenger:
                    return [NSUIColor(red: 0.0, green: 0.7764705882352941, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.0, green: 0.4470588235294118, blue: 1.0, alpha: 1.0)]
                case .soundCloud:
                    return [NSUIColor(red: 0.996078431372549, green: 0.5490196078431373, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 0.21176470588235294, blue: 0.0, alpha: 1.0)]
                case .behongo:
                    return [NSUIColor(red: 0.3215686274509804, green: 0.7607843137254902, blue: 0.20392156862745098, alpha: 1.0), NSUIColor(red: 0.023529411764705882, green: 0.09019607843137255, blue: 0.0, alpha: 1.0)]
                case .servQuick:
                    return [NSUIColor(red: 0.2823529411764706, green: 0.3333333333333333, blue: 0.38823529411764707, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 0.19607843137254902, blue: 0.23529411764705882, alpha: 1.0)]
                case .friday:
                    return [NSUIColor(red: 0.5137254901960784, green: 0.6431372549019608, blue: 0.8313725490196079, alpha: 1.0), NSUIColor(red: 0.7137254901960784, green: 0.984313725490196, blue: 1.0, alpha: 1.0)]
                case .martini:
                    return [NSUIColor(red: 0.9921568627450981, green: 0.9882352941176471, blue: 0.2784313725490196, alpha: 1.0), NSUIColor(red: 0.1411764705882353, green: 0.996078431372549, blue: 0.2549019607843137, alpha: 1.0)]
                case .metallicToad:
                    return [NSUIColor(red: 0.6705882352941176, green: 0.7294117647058823, blue: 0.6705882352941176, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
                case .betweenTheClouds:
                    return [NSUIColor(red: 0.45098039215686275, green: 0.7843137254901961, blue: 0.6627450980392157, alpha: 1.0), NSUIColor(red: 0.21568627450980393, green: 0.23137254901960785, blue: 0.26666666666666666, alpha: 1.0)]
                case .crazyOrangeI:
                    return [NSUIColor(red: 0.8274509803921568, green: 0.5137254901960784, blue: 0.07058823529411765, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.19607843137254902, blue: 0.4745098039215686, alpha: 1.0)]
                case .hersheys:
                    return [NSUIColor(red: 0.11764705882352941, green: 0.07450980392156863, blue: 0.047058823529411764, alpha: 1.0), NSUIColor(red: 0.6039215686274509, green: 0.5176470588235295, blue: 0.47058823529411764, alpha: 1.0)]
                case .talkingToMiceElf:
                    return [NSUIColor(red: 0.5803921568627451, green: 0.5568627450980392, blue: 0.6, alpha: 1.0), NSUIColor(red: 0.1803921568627451, green: 0.0784313725490196, blue: 0.21568627450980393, alpha: 1.0)]
                case .purpleBliss:
                    return [NSUIColor(red: 0.21176470588235294, green: 0.0, blue: 0.2, alpha: 1.0), NSUIColor(red: 0.043137254901960784, green: 0.5294117647058824, blue: 0.5764705882352941, alpha: 1.0)]
                case .predawn:
                    return [NSUIColor(red: 1.0, green: 0.6313725490196078, blue: 0.4980392156862745, alpha: 1.0), NSUIColor(red: 0.0, green: 0.13333333333333333, blue: 0.24313725490196078, alpha: 1.0)]
                case .endlessRiver:
                    return [NSUIColor(red: 0.2627450980392157, green: 0.807843137254902, blue: 0.6352941176470588, alpha: 1.0), NSUIColor(red: 0.09411764705882353, green: 0.35294117647058826, blue: 0.615686274509804, alpha: 1.0)]
                case .pastelOrangeattheSun:
                    return [NSUIColor(red: 1.0, green: 0.7019607843137254, blue: 0.2784313725490196, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)]
                case .twitch:
                    return [NSUIColor(red: 0.39215686274509803, green: 0.2549019607843137, blue: 0.6470588235294118, alpha: 1.0), NSUIColor(red: 0.16470588235294117, green: 0.03137254901960784, blue: 0.27058823529411763, alpha: 1.0)]
                case .atlas:
                    return [NSUIColor(red: 0.996078431372549, green: 0.6745098039215687, blue: 0.3686274509803922, alpha: 1.0), NSUIColor(red: 0.7803921568627451, green: 0.4745098039215686, blue: 0.8156862745098039, alpha: 1.0), NSUIColor(red: 0.29411764705882354, green: 0.7529411764705882, blue: 0.7843137254901961, alpha: 1.0)]
                case .instagram:
                    return [NSUIColor(red: 0.5137254901960784, green: 0.22745098039215686, blue: 0.7058823529411765, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.11372549019607843, blue: 0.11372549019607843, alpha: 1.0), NSUIColor(red: 0.9882352941176471, green: 0.6901960784313725, blue: 0.27058823529411763, alpha: 1.0)]
                case .flickr:
                    return [NSUIColor(red: 1.0, green: 0.0, blue: 0.5176470588235295, alpha: 1.0), NSUIColor(red: 0.2, green: 0.0, blue: 0.10588235294117647, alpha: 1.0)]
                case .vine:
                    return [NSUIColor(red: 0.0, green: 0.7490196078431373, blue: 0.5607843137254902, alpha: 1.0), NSUIColor(red: 0.0, green: 0.08235294117647059, blue: 0.06274509803921569, alpha: 1.0)]
                case .turquoiseflow:
                    return [NSUIColor(red: 0.07450980392156863, green: 0.41568627450980394, blue: 0.5411764705882353, alpha: 1.0), NSUIColor(red: 0.14901960784313725, green: 0.47058823529411764, blue: 0.44313725490196076, alpha: 1.0)]
                case .portrait:
                    return [NSUIColor(red: 0.5568627450980392, green: 0.6196078431372549, blue: 0.6705882352941176, alpha: 1.0), NSUIColor(red: 0.9333333333333333, green: 0.9490196078431372, blue: 0.9529411764705882, alpha: 1.0)]
                case .virginAmerica:
                    return [NSUIColor(red: 0.4823529411764706, green: 0.2627450980392157, blue: 0.592156862745098, alpha: 1.0), NSUIColor(red: 0.8627450980392157, green: 0.1411764705882353, blue: 0.18823529411764706, alpha: 1.0)]
                case .kokoCaramel:
                    return [NSUIColor(red: 0.8196078431372549, green: 0.5686274509803921, blue: 0.23529411764705882, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8196078431372549, blue: 0.5803921568627451, alpha: 1.0)]
                case .freshTurboscent:
                    return [NSUIColor(red: 0.9450980392156862, green: 0.9490196078431372, blue: 0.7098039215686275, alpha: 1.0), NSUIColor(red: 0.07450980392156863, green: 0.3137254901960784, blue: 0.34509803921568627, alpha: 1.0)]
                case .greentodark:
                    return [NSUIColor(red: 0.41568627450980394, green: 0.5686274509803921, blue: 0.07450980392156863, alpha: 1.0), NSUIColor(red: 0.0784313725490196, green: 0.08235294117647059, blue: 0.09019607843137255, alpha: 1.0)]
                case .ukraine:
                    return [NSUIColor(red: 0.0, green: 0.30980392156862746, blue: 0.9764705882352941, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9764705882352941, blue: 0.2980392156862745, alpha: 1.0)]
                case .curiosityblue:
                    return [NSUIColor(red: 0.3215686274509804, green: 0.3215686274509804, blue: 0.3215686274509804, alpha: 1.0), NSUIColor(red: 0.23921568627450981, green: 0.4470588235294118, blue: 0.7058823529411765, alpha: 1.0)]
                case .darkKnight:
                    return [NSUIColor(red: 0.7294117647058823, green: 0.5450980392156862, blue: 0.00784313725490196, alpha: 1.0), NSUIColor(red: 0.09411764705882353, green: 0.09411764705882353, blue: 0.09411764705882353, alpha: 1.0)]
                case .piglet:
                    return [NSUIColor(red: 0.9333333333333333, green: 0.611764705882353, blue: 0.6549019607843137, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8666666666666667, blue: 0.8823529411764706, alpha: 1.0)]
                case .lizard:
                    return [NSUIColor(red: 0.18823529411764706, green: 0.2627450980392157, blue: 0.3215686274509804, alpha: 1.0), NSUIColor(red: 0.8431372549019608, green: 0.8235294117647058, blue: 0.8, alpha: 1.0)]
                case .sagePersuasion:
                    return [NSUIColor(red: 0.8, green: 0.8, blue: 0.6980392156862745, alpha: 1.0), NSUIColor(red: 0.4588235294117647, green: 0.4588235294117647, blue: 0.09803921568627451, alpha: 1.0)]
                case .betweenNightandDay:
                    return [NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.20392156862745098, green: 0.596078431372549, blue: 0.8588235294117647, alpha: 1.0)]
                case .timber:
                    return [NSUIColor(red: 0.9882352941176471, green: 0.0, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.0, green: 0.8588235294117647, blue: 0.8705882352941177, alpha: 1.0)]
                case .passion:
                    return [NSUIColor(red: 0.8980392156862745, green: 0.2235294117647059, blue: 0.20784313725490197, alpha: 1.0), NSUIColor(red: 0.8901960784313725, green: 0.36470588235294116, blue: 0.3568627450980392, alpha: 1.0)]
                case .clearSky:
                    return [NSUIColor(red: 0.0, green: 0.3607843137254902, blue: 0.592156862745098, alpha: 1.0), NSUIColor(red: 0.21176470588235294, green: 0.21568627450980393, blue: 0.5843137254901961, alpha: 1.0)]
                case .masterCard:
                    return [NSUIColor(red: 0.9568627450980393, green: 0.4196078431372549, blue: 0.27058823529411763, alpha: 1.0), NSUIColor(red: 0.9333333333333333, green: 0.6588235294117647, blue: 0.28627450980392155, alpha: 1.0)]
                case .backToEarth:
                    return [NSUIColor(red: 0.0, green: 0.788235294117647, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.5725490196078431, green: 0.996078431372549, blue: 0.615686274509804, alpha: 1.0)]
                case .deepPurple:
                    return [NSUIColor(red: 0.403921568627451, green: 0.22745098039215686, blue: 0.7176470588235294, alpha: 1.0), NSUIColor(red: 0.3176470588235294, green: 0.17647058823529413, blue: 0.6588235294117647, alpha: 1.0)]
                case .littleLeaf:
                    return [NSUIColor(red: 0.4627450980392157, green: 0.7215686274509804, blue: 0.3215686274509804, alpha: 1.0), NSUIColor(red: 0.5529411764705883, green: 0.7607843137254902, blue: 0.43529411764705883, alpha: 1.0)]
                case .netflix:
                    return [NSUIColor(red: 0.5568627450980392, green: 0.054901960784313725, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.12156862745098039, green: 0.10980392156862745, blue: 0.09411764705882353, alpha: 1.0)]
                case .lightOrange:
                    return [NSUIColor(red: 1.0, green: 0.7176470588235294, blue: 0.3686274509803922, alpha: 1.0), NSUIColor(red: 0.9294117647058824, green: 0.5607843137254902, blue: 0.011764705882352941, alpha: 1.0)]
                case .greenandBlue:
                    return [NSUIColor(red: 0.7607843137254902, green: 0.8980392156862745, blue: 0.611764705882353, alpha: 1.0), NSUIColor(red: 0.39215686274509803, green: 0.7019607843137254, blue: 0.9568627450980393, alpha: 1.0)]
                case .poncho:
                    return [NSUIColor(red: 0.25098039215686274, green: 0.22745098039215686, blue: 0.24313725490196078, alpha: 1.0), NSUIColor(red: 0.7450980392156863, green: 0.34509803921568627, blue: 0.4117647058823529, alpha: 1.0)]
                case .backtotheFuture:
                    return [NSUIColor(red: 0.7529411764705882, green: 0.1411764705882353, blue: 0.1450980392156863, alpha: 1.0), NSUIColor(red: 0.9411764705882353, green: 0.796078431372549, blue: 0.20784313725490197, alpha: 1.0)]
                case .blush:
                    return [NSUIColor(red: 0.6980392156862745, green: 0.27058823529411763, blue: 0.5725490196078431, alpha: 1.0), NSUIColor(red: 0.9450980392156862, green: 0.37254901960784315, blue: 0.4745098039215686, alpha: 1.0)]
                case .inbox:
                    return [NSUIColor(red: 0.27058823529411763, green: 0.4980392156862745, blue: 0.792156862745098, alpha: 1.0), NSUIColor(red: 0.33725490196078434, green: 0.5686274509803921, blue: 0.7843137254901961, alpha: 1.0)]
                case .purplin:
                    return [NSUIColor(red: 0.41568627450980394, green: 0.18823529411764706, blue: 0.5764705882352941, alpha: 1.0), NSUIColor(red: 0.6274509803921569, green: 0.26666666666666666, blue: 1.0, alpha: 1.0)]
                case .paleWood:
                    return [NSUIColor(red: 0.9176470588235294, green: 0.803921568627451, blue: 0.6392156862745098, alpha: 1.0), NSUIColor(red: 0.8392156862745098, green: 0.6823529411764706, blue: 0.4823529411764706, alpha: 1.0)]
                case .haikus:
                    return [NSUIColor(red: 0.9921568627450981, green: 0.4549019607843137, blue: 0.4235294117647059, alpha: 1.0), NSUIColor(red: 1.0, green: 0.5647058823529412, blue: 0.40784313725490196, alpha: 1.0)]
                case .pizelex:
                    return [NSUIColor(red: 0.06666666666666667, green: 0.2627450980392157, blue: 0.3411764705882353, alpha: 1.0), NSUIColor(red: 0.9490196078431372, green: 0.5803921568627451, blue: 0.5725490196078431, alpha: 1.0)]
                case .joomla:
                    return [NSUIColor(red: 0.11764705882352941, green: 0.23529411764705882, blue: 0.4470588235294118, alpha: 1.0), NSUIColor(red: 0.16470588235294117, green: 0.3215686274509804, blue: 0.596078431372549, alpha: 1.0)]
                case .christmas:
                    return [NSUIColor(red: 0.1843137254901961, green: 0.45098039215686275, blue: 0.21176470588235294, alpha: 1.0), NSUIColor(red: 0.6666666666666666, green: 0.22745098039215686, blue: 0.2196078431372549, alpha: 1.0)]
                case .minnesotaVikings:
                    return [NSUIColor(red: 0.33725490196078434, green: 0.0784313725490196, blue: 0.6901960784313725, alpha: 1.0), NSUIColor(red: 0.8588235294117647, green: 0.8392156862745098, blue: 0.3607843137254902, alpha: 1.0)]
                case .miamiDolphins:
                    return [NSUIColor(red: 0.30196078431372547, green: 0.6274509803921569, blue: 0.6901960784313725, alpha: 1.0), NSUIColor(red: 0.8274509803921568, green: 0.615686274509804, blue: 0.2196078431372549, alpha: 1.0)]
                case .forest:
                    return [NSUIColor(red: 0.35294117647058826, green: 0.24705882352941178, blue: 0.21568627450980393, alpha: 1.0), NSUIColor(red: 0.17254901960784313, green: 0.4666666666666667, blue: 0.26666666666666666, alpha: 1.0)]
                case .nighthawk:
                    return [NSUIColor(red: 0.1607843137254902, green: 0.5019607843137255, blue: 0.7254901960784313, alpha: 1.0), NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0)]
                case .superman:
                    return [NSUIColor(red: 0.0, green: 0.6, blue: 0.9686274509803922, alpha: 1.0), NSUIColor(red: 0.9450980392156862, green: 0.09019607843137255, blue: 0.07058823529411765, alpha: 1.0)]
                case .suzy:
                    return [NSUIColor(red: 0.5137254901960784, green: 0.30196078431372547, blue: 0.6078431372549019, alpha: 1.0), NSUIColor(red: 0.8156862745098039, green: 0.3058823529411765, blue: 0.8392156862745098, alpha: 1.0)]
                case .darkSkies:
                    return [NSUIColor(red: 0.29411764705882354, green: 0.4745098039215686, blue: 0.6313725490196078, alpha: 1.0), NSUIColor(red: 0.1568627450980392, green: 0.24313725490196078, blue: 0.3176470588235294, alpha: 1.0)]
                case .deepSpace:
                    return [NSUIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.2627450980392157, green: 0.2627450980392157, blue: 0.2627450980392157, alpha: 1.0)]
                case .decent:
                    return [NSUIColor(red: 0.2980392156862745, green: 0.6313725490196078, blue: 0.6862745098039216, alpha: 1.0), NSUIColor(red: 0.7686274509803922, green: 0.8784313725490196, blue: 0.8980392156862745, alpha: 1.0)]
                case .colorsOfSky:
                    return [NSUIColor(red: 0.8784313725490196, green: 0.9176470588235294, blue: 0.9882352941176471, alpha: 1.0), NSUIColor(red: 0.8117647058823529, green: 0.8705882352941177, blue: 0.9529411764705882, alpha: 1.0)]
                case .purpleWhite:
                    return [NSUIColor(red: 0.7294117647058823, green: 0.3254901960784314, blue: 0.4392156862745098, alpha: 1.0), NSUIColor(red: 0.9568627450980393, green: 0.8862745098039215, blue: 0.8470588235294118, alpha: 1.0)]
                case .ali:
                    return [NSUIColor(red: 1.0, green: 0.29411764705882354, blue: 0.12156862745098039, alpha: 1.0), NSUIColor(red: 0.12156862745098039, green: 0.8666666666666667, blue: 1.0, alpha: 1.0)]
                case .alihossein:
                    return [NSUIColor(red: 0.9686274509803922, green: 1.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.8588235294117647, green: 0.21176470588235294, blue: 0.6431372549019608, alpha: 1.0)]
                case .shahabi:
                    return [NSUIColor(red: 0.6588235294117647, green: 0.0, blue: 0.4666666666666667, alpha: 1.0), NSUIColor(red: 0.4, green: 1.0, blue: 0.0, alpha: 1.0)]
                case .redOcean:
                    return [NSUIColor(red: 0.11372549019607843, green: 0.2627450980392157, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.6431372549019608, green: 0.2235294117647059, blue: 0.19215686274509805, alpha: 1.0)]
                case .tranquil:
                    return [NSUIColor(red: 0.9333333333333333, green: 0.803921568627451, blue: 0.6392156862745098, alpha: 1.0), NSUIColor(red: 0.9372549019607843, green: 0.3843137254901961, blue: 0.6235294117647059, alpha: 1.0)]
                case .transfile:
                    return [NSUIColor(red: 0.08627450980392157, green: 0.7490196078431373, blue: 0.9921568627450981, alpha: 1.0), NSUIColor(red: 0.796078431372549, green: 0.18823529411764706, blue: 0.4, alpha: 1.0)]
                case .sylvia:
                    return [NSUIColor(red: 1.0, green: 0.29411764705882354, blue: 0.12156862745098039, alpha: 1.0), NSUIColor(red: 1.0, green: 0.5647058823529412, blue: 0.40784313725490196, alpha: 1.0)]
                case .sweetMorning:
                    return [NSUIColor(red: 1.0, green: 0.37254901960784315, blue: 0.42745098039215684, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7647058823529411, blue: 0.44313725490196076, alpha: 1.0)]
                case .politics:
                    return [NSUIColor(red: 0.12941176470588237, green: 0.5882352941176471, blue: 0.9529411764705882, alpha: 1.0), NSUIColor(red: 0.9568627450980393, green: 0.2627450980392157, blue: 0.21176470588235294, alpha: 1.0)]
                case .brightVault:
                    return [NSUIColor(red: 0.0, green: 0.8235294117647058, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.5725490196078431, green: 0.5529411764705883, blue: 0.6705882352941176, alpha: 1.0)]
                case .solidVault:
                    return [NSUIColor(red: 0.22745098039215686, green: 0.4823529411764706, blue: 0.8352941176470589, alpha: 1.0), NSUIColor(red: 0.22745098039215686, green: 0.3764705882352941, blue: 0.45098039215686275, alpha: 1.0)]
                case .sunset:
                    return [NSUIColor(red: 0.043137254901960784, green: 0.2823529411764706, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.9607843137254902, green: 0.3843137254901961, blue: 0.09019607843137255, alpha: 1.0)]
                case .grapefruitSunset:
                    return [NSUIColor(red: 0.9137254901960784, green: 0.39215686274509803, blue: 0.2627450980392157, alpha: 1.0), NSUIColor(red: 0.5647058823529412, green: 0.3058823529411765, blue: 0.5843137254901961, alpha: 1.0)]
                case .deepSeaSpace:
                    return [NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.2980392156862745, green: 0.6313725490196078, blue: 0.6862745098039216, alpha: 1.0)]
                case .dusk:
                    return [NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.4549019607843137, blue: 0.4235294117647059, alpha: 1.0)]
                case .minimalRed:
                    return [NSUIColor(red: 0.9411764705882353, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.8627450980392157, green: 0.1568627450980392, blue: 0.11764705882352941, alpha: 1.0)]
                case .royal:
                    return [NSUIColor(red: 0.0784313725490196, green: 0.11764705882352941, blue: 0.18823529411764706, alpha: 1.0), NSUIColor(red: 0.1411764705882353, green: 0.23137254901960785, blue: 0.3333333333333333, alpha: 1.0)]
                case .mauve:
                    return [NSUIColor(red: 0.25882352941176473, green: 0.15294117647058825, blue: 0.35294117647058826, alpha: 1.0), NSUIColor(red: 0.45098039215686275, green: 0.29411764705882354, blue: 0.42745098039215684, alpha: 1.0)]
                case .frost:
                    return [NSUIColor(red: 0.0, green: 0.01568627450980392, blue: 0.1568627450980392, alpha: 1.0), NSUIColor(red: 0.0, green: 0.3058823529411765, blue: 0.5725490196078431, alpha: 1.0)]
                case .lush:
                    return [NSUIColor(red: 0.33725490196078434, green: 0.6705882352941176, blue: 0.1843137254901961, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.8784313725490196, blue: 0.38823529411764707, alpha: 1.0)]
                case .firewatch:
                    return [NSUIColor(red: 0.796078431372549, green: 0.17647058823529413, blue: 0.24313725490196078, alpha: 1.0), NSUIColor(red: 0.9372549019607843, green: 0.2784313725490196, blue: 0.22745098039215686, alpha: 1.0)]
                case .sherbert:
                    return [NSUIColor(red: 0.9686274509803922, green: 0.615686274509804, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.39215686274509803, green: 0.9529411764705882, blue: 0.5490196078431373, alpha: 1.0)]
                case .bloodRed:
                    return [NSUIColor(red: 0.9725490196078431, green: 0.3137254901960784, blue: 0.19607843137254902, alpha: 1.0), NSUIColor(red: 0.9058823529411765, green: 0.2196078431372549, blue: 0.15294117647058825, alpha: 1.0)]
                case .sunontheHorizon:
                    return [NSUIColor(red: 0.9882352941176471, green: 0.9176470588235294, blue: 0.7333333333333333, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 0.7098039215686275, blue: 0.0, alpha: 1.0)]
                case .iIITDelhi:
                    return [NSUIColor(red: 0.5019607843137255, green: 0.5019607843137255, blue: 0.5019607843137255, alpha: 1.0), NSUIColor(red: 0.24705882352941178, green: 0.6784313725490196, blue: 0.6588235294117647, alpha: 1.0)]
                case .jupiter:
                    return [NSUIColor(red: 1.0, green: 0.8470588235294118, blue: 0.6078431372549019, alpha: 1.0), NSUIColor(red: 0.09803921568627451, green: 0.32941176470588235, blue: 0.4823529411764706, alpha: 1.0)]
                case .shadesofGrey:
                    return [NSUIColor(red: 0.7411764705882353, green: 0.7647058823529411, blue: 0.7803921568627451, alpha: 1.0), NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0)]
                case .dania:
                    return [NSUIColor(red: 0.7450980392156863, green: 0.5764705882352941, blue: 0.7725490196078432, alpha: 1.0), NSUIColor(red: 0.4823529411764706, green: 0.7764705882352941, blue: 0.8, alpha: 1.0)]
                case .limeade:
                    return [NSUIColor(red: 0.6313725490196078, green: 1.0, blue: 0.807843137254902, alpha: 1.0), NSUIColor(red: 0.9803921568627451, green: 1.0, blue: 0.8196078431372549, alpha: 1.0)]
                case .disco:
                    return [NSUIColor(red: 0.3058823529411765, green: 0.803921568627451, blue: 0.7686274509803922, alpha: 1.0), NSUIColor(red: 0.3333333333333333, green: 0.3843137254901961, blue: 0.4392156862745098, alpha: 1.0)]
                case .loveCouple:
                    return [NSUIColor(red: 0.22745098039215686, green: 0.3803921568627451, blue: 0.5254901960784314, alpha: 1.0), NSUIColor(red: 0.5372549019607843, green: 0.1450980392156863, blue: 0.24313725490196078, alpha: 1.0)]
                case .azurePop:
                    return [NSUIColor(red: 0.9372549019607843, green: 0.19607843137254902, blue: 0.8509803921568627, alpha: 1.0), NSUIColor(red: 0.5372549019607843, green: 1.0, blue: 0.9921568627450981, alpha: 1.0)]
                case .nepal:
                    return [NSUIColor(red: 0.8705882352941177, green: 0.3803921568627451, blue: 0.3803921568627451, alpha: 1.0), NSUIColor(red: 0.14901960784313725, green: 0.3411764705882353, blue: 0.9215686274509803, alpha: 1.0)]
                case .cosmicFusion:
                    return [NSUIColor(red: 1.0, green: 0.0, blue: 0.8, alpha: 1.0), NSUIColor(red: 0.2, green: 0.2, blue: 0.6, alpha: 1.0)]
                case .snapchat:
                    return [NSUIColor(red: 1.0, green: 0.9882352941176471, blue: 0.0, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
                case .edsSunsetGradient:
                    return [NSUIColor(red: 1.0, green: 0.49411764705882355, blue: 0.37254901960784315, alpha: 1.0), NSUIColor(red: 0.996078431372549, green: 0.7058823529411765, blue: 0.4823529411764706, alpha: 1.0)]
                case .bradyBradyFunFun:
                    return [NSUIColor(red: 0.0, green: 0.7647058823529411, blue: 1.0, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 0.10980392156862745, alpha: 1.0)]
                case .blackRos:
                    return [NSUIColor(red: 0.9568627450980393, green: 0.7686274509803922, blue: 0.9529411764705882, alpha: 1.0), NSUIColor(red: 0.9882352941176471, green: 0.403921568627451, blue: 0.9803921568627451, alpha: 1.0)]
                case .sPurple:
                    return [NSUIColor(red: 0.2549019607843137, green: 0.1607843137254902, blue: 0.35294117647058826, alpha: 1.0), NSUIColor(red: 0.1843137254901961, green: 0.027450980392156862, blue: 0.2627450980392157, alpha: 1.0)]
                case .radar:
                    return [NSUIColor(red: 0.6549019607843137, green: 0.4392156862745098, blue: 0.9372549019607843, alpha: 1.0), NSUIColor(red: 0.8117647058823529, green: 0.5450980392156862, blue: 0.9529411764705882, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.7254901960784313, blue: 0.6078431372549019, alpha: 1.0)]
                case .ibizaSunset:
                    return [NSUIColor(red: 0.9333333333333333, green: 0.03529411764705882, blue: 0.4745098039215686, alpha: 1.0), NSUIColor(red: 1.0, green: 0.41568627450980394, blue: 0.0, alpha: 1.0)]
                case .dawn:
                    return [NSUIColor(red: 0.9529411764705882, green: 0.5647058823529412, blue: 0.30980392156862746, alpha: 1.0), NSUIColor(red: 0.23137254901960785, green: 0.2627450980392157, blue: 0.44313725490196076, alpha: 1.0)]
                case .mild:
                    return [NSUIColor(red: 0.403921568627451, green: 0.6980392156862745, blue: 0.43529411764705883, alpha: 1.0), NSUIColor(red: 0.2980392156862745, green: 0.6352941176470588, blue: 0.803921568627451, alpha: 1.0)]
                case .viceCity:
                    return [NSUIColor(red: 0.20392156862745098, green: 0.5803921568627451, blue: 0.9019607843137255, alpha: 1.0), NSUIColor(red: 0.9254901960784314, green: 0.43137254901960786, blue: 0.6784313725490196, alpha: 1.0)]
                case .jaipur:
                    return [NSUIColor(red: 0.8588235294117647, green: 0.9019607843137255, blue: 0.9647058823529412, alpha: 1.0), NSUIColor(red: 0.7725490196078432, green: 0.4745098039215686, blue: 0.42745098039215684, alpha: 1.0)]
                case .jodhpur:
                    return [NSUIColor(red: 0.611764705882353, green: 0.9254901960784314, blue: 0.984313725490196, alpha: 1.0), NSUIColor(red: 0.396078431372549, green: 0.7803921568627451, blue: 0.9686274509803922, alpha: 1.0), NSUIColor(red: 0.0, green: 0.3215686274509804, blue: 0.8313725490196079, alpha: 1.0)]
                case .cocoaaIce:
                    return [NSUIColor(red: 0.7529411764705882, green: 0.7529411764705882, blue: 0.6666666666666666, alpha: 1.0), NSUIColor(red: 0.10980392156862745, green: 0.9372549019607843, blue: 1.0, alpha: 1.0)]
                case .easyMed:
                    return [NSUIColor(red: 0.8627450980392157, green: 0.8901960784313725, blue: 0.3568627450980392, alpha: 1.0), NSUIColor(red: 0.27058823529411763, green: 0.7137254901960784, blue: 0.28627450980392155, alpha: 1.0)]
                case .roseColoredLenses:
                    return [NSUIColor(red: 0.9098039215686274, green: 0.796078431372549, blue: 0.7529411764705882, alpha: 1.0), NSUIColor(red: 0.38823529411764707, green: 0.43529411764705883, blue: 0.6431372549019608, alpha: 1.0)]
                case .whatliesBeyond:
                    return [NSUIColor(red: 0.9411764705882353, green: 0.9490196078431372, blue: 0.9411764705882353, alpha: 1.0), NSUIColor(red: 0.0, green: 0.047058823529411764, blue: 0.25098039215686274, alpha: 1.0)]
                case .roseanna:
                    return [NSUIColor(red: 1.0, green: 0.6862745098039216, blue: 0.7411764705882353, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7647058823529411, blue: 0.6274509803921569, alpha: 1.0)]
                case .honeyDew:
                    return [NSUIColor(red: 0.2627450980392157, green: 0.7764705882352941, blue: 0.6745098039215687, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 1.0, blue: 0.6823529411764706, alpha: 1.0)]
                case .undertheLake:
                    return [NSUIColor(red: 0.03529411764705882, green: 0.18823529411764706, blue: 0.1568627450980392, alpha: 1.0), NSUIColor(red: 0.13725490196078433, green: 0.47843137254901963, blue: 0.3411764705882353, alpha: 1.0)]
                case .theBlueLagoon:
                    return [NSUIColor(red: 0.2627450980392157, green: 0.7764705882352941, blue: 0.6745098039215687, alpha: 1.0), NSUIColor(red: 0.09803921568627451, green: 0.08627450980392157, blue: 0.32941176470588235, alpha: 1.0)]
                case .canYouFeelTheLoveTonight:
                    return [NSUIColor(red: 0.27058823529411763, green: 0.40784313725490196, blue: 0.8627450980392157, alpha: 1.0), NSUIColor(red: 0.6901960784313725, green: 0.41568627450980394, blue: 0.7019607843137254, alpha: 1.0)]
                case .veryBlue:
                    return [NSUIColor(red: 0.0196078431372549, green: 0.4588235294117647, blue: 0.9019607843137255, alpha: 1.0), NSUIColor(red: 0.00784313725490196, green: 0.10588235294117647, blue: 0.4745098039215686, alpha: 1.0)]
                case .loveandLiberty:
                    return [NSUIColor(red: 0.12549019607843137, green: 0.00392156862745098, blue: 0.13333333333333333, alpha: 1.0), NSUIColor(red: 0.43529411764705883, green: 0.0, blue: 0.0, alpha: 1.0)]
                case .orca:
                    return [NSUIColor(red: 0.26666666666666666, green: 0.6274509803921569, blue: 0.5529411764705883, alpha: 1.0), NSUIColor(red: 0.03529411764705882, green: 0.21176470588235294, blue: 0.21568627450980393, alpha: 1.0)]
                case .venice:
                    return [NSUIColor(red: 0.3803921568627451, green: 0.5647058823529412, blue: 0.9098039215686274, alpha: 1.0), NSUIColor(red: 0.6549019607843137, green: 0.7490196078431373, blue: 0.9098039215686274, alpha: 1.0)]
                case .pacificDream:
                    return [NSUIColor(red: 0.20392156862745098, green: 0.9098039215686274, blue: 0.6196078431372549, alpha: 1.0), NSUIColor(red: 0.058823529411764705, green: 0.20392156862745098, blue: 0.2627450980392157, alpha: 1.0)]
                case .learningandLeading:
                    return [NSUIColor(red: 0.9686274509803922, green: 0.592156862745098, blue: 0.11764705882352941, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8235294117647058, blue: 0.0, alpha: 1.0)]
                case .celestial:
                    return [NSUIColor(red: 0.7647058823529411, green: 0.21568627450980393, blue: 0.39215686274509803, alpha: 1.0), NSUIColor(red: 0.11372549019607843, green: 0.14901960784313725, blue: 0.44313725490196076, alpha: 1.0)]
                case .purplepine:
                    return [NSUIColor(red: 0.12549019607843137, green: 0.0, blue: 0.17254901960784313, alpha: 1.0), NSUIColor(red: 0.796078431372549, green: 0.7058823529411765, blue: 0.8313725490196079, alpha: 1.0)]
                case .shalala:
                    return [NSUIColor(red: 0.8392156862745098, green: 0.42745098039215684, blue: 0.4588235294117647, alpha: 1.0), NSUIColor(red: 0.8862745098039215, green: 0.5843137254901961, blue: 0.5294117647058824, alpha: 1.0)]
                case .mini:
                    return [NSUIColor(red: 0.18823529411764706, green: 0.9098039215686274, blue: 0.7490196078431373, alpha: 1.0), NSUIColor(red: 1.0, green: 0.5098039215686274, blue: 0.20784313725490197, alpha: 1.0)]
                case .maldives:
                    return [NSUIColor(red: 0.6980392156862745, green: 0.996078431372549, blue: 0.9803921568627451, alpha: 1.0), NSUIColor(red: 0.054901960784313725, green: 0.8235294117647058, blue: 0.9686274509803922, alpha: 1.0)]
                case .cinnamint:
                    return [NSUIColor(red: 0.2901960784313726, green: 0.7607843137254902, blue: 0.6039215686274509, alpha: 1.0), NSUIColor(red: 0.7411764705882353, green: 1.0, blue: 0.9529411764705882, alpha: 1.0)]
                case .html:
                    return [NSUIColor(red: 0.8941176470588236, green: 0.30196078431372547, blue: 0.14901960784313725, alpha: 1.0), NSUIColor(red: 0.9450980392156862, green: 0.396078431372549, blue: 0.1607843137254902, alpha: 1.0)]
                case .coal:
                    return [NSUIColor(red: 0.9215686274509803, green: 0.3411764705882353, blue: 0.3411764705882353, alpha: 1.0), NSUIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)]
                case .sunkist:
                    return [NSUIColor(red: 0.9490196078431372, green: 0.6, blue: 0.2901960784313726, alpha: 1.0), NSUIColor(red: 0.9490196078431372, green: 0.788235294117647, blue: 0.2980392156862745, alpha: 1.0)]
                case .blueSkies:
                    return [NSUIColor(red: 0.33725490196078434, green: 0.8, blue: 0.9490196078431372, alpha: 1.0), NSUIColor(red: 0.1843137254901961, green: 0.5019607843137255, blue: 0.9294117647058824, alpha: 1.0)]
                case .chittyChittyBangBang:
                    return [NSUIColor(red: 0.0, green: 0.4745098039215686, blue: 0.5686274509803921, alpha: 1.0), NSUIColor(red: 0.47058823529411764, green: 1.0, blue: 0.8392156862745098, alpha: 1.0)]
                case .visionsofGrandeur:
                    return [NSUIColor(red: 0.0, green: 0.0, blue: 0.27450980392156865, alpha: 1.0), NSUIColor(red: 0.10980392156862745, green: 0.7098039215686275, blue: 0.8784313725490196, alpha: 1.0)]
                case .crystalClear:
                    return [NSUIColor(red: 0.08235294117647059, green: 0.6, blue: 0.3411764705882353, alpha: 1.0), NSUIColor(red: 0.08235294117647059, green: 0.3411764705882353, blue: 0.6, alpha: 1.0)]
                case .mello:
                    return [NSUIColor(red: 0.7529411764705882, green: 0.2235294117647059, blue: 0.16862745098039217, alpha: 1.0), NSUIColor(red: 0.5568627450980392, green: 0.26666666666666666, blue: 0.6784313725490196, alpha: 1.0)]
                case .compareNow:
                    return [NSUIColor(red: 0.9372549019607843, green: 0.23137254901960785, blue: 0.21176470588235294, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
                case .meridian:
                    return [NSUIColor(red: 0.1568627450980392, green: 0.23529411764705882, blue: 0.5254901960784314, alpha: 1.0), NSUIColor(red: 0.27058823529411763, green: 0.6352941176470588, blue: 0.2784313725490196, alpha: 1.0)]
                case .relay:
                    return [NSUIColor(red: 0.22745098039215686, green: 0.10980392156862745, blue: 0.44313725490196076, alpha: 1.0), NSUIColor(red: 0.8431372549019608, green: 0.42745098039215684, blue: 0.4666666666666667, alpha: 1.0), NSUIColor(red: 1.0, green: 0.6862745098039216, blue: 0.4823529411764706, alpha: 1.0)]
                case .alive:
                    return [NSUIColor(red: 0.796078431372549, green: 0.20784313725490197, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.7411764705882353, green: 0.24705882352941178, blue: 0.19607843137254902, alpha: 1.0)]
                case .scooter:
                    return [NSUIColor(red: 0.21176470588235294, green: 0.8196078431372549, blue: 0.8627450980392157, alpha: 1.0), NSUIColor(red: 0.3568627450980392, green: 0.5254901960784314, blue: 0.8980392156862745, alpha: 1.0)]
                case .terminal:
                    return [NSUIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.058823529411764705, green: 0.6078431372549019, blue: 0.058823529411764705, alpha: 1.0)]
                case .telegram:
                    return [NSUIColor(red: 0.10980392156862745, green: 0.5725490196078431, blue: 0.8235294117647058, alpha: 1.0), NSUIColor(red: 0.9490196078431372, green: 0.9882352941176471, blue: 0.996078431372549, alpha: 1.0)]
                case .crimsonTide:
                    return [NSUIColor(red: 0.39215686274509803, green: 0.16862745098039217, blue: 0.45098039215686275, alpha: 1.0), NSUIColor(red: 0.7764705882352941, green: 0.25882352941176473, blue: 0.43137254901960786, alpha: 1.0)]
                case .socialive:
                    return [NSUIColor(red: 0.023529411764705882, green: 0.7450980392156863, blue: 0.7137254901960784, alpha: 1.0), NSUIColor(red: 0.2823529411764706, green: 0.6941176470588235, blue: 0.7490196078431373, alpha: 1.0)]
                case .subu:
                    return [NSUIColor(red: 0.047058823529411764, green: 0.9215686274509803, blue: 0.9215686274509803, alpha: 1.0), NSUIColor(red: 0.12549019607843137, green: 0.8901960784313725, blue: 0.6980392156862745, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 1.0, blue: 0.7764705882352941, alpha: 1.0)]
                case .brokenHearts:
                    return [NSUIColor(red: 0.8509803921568627, green: 0.6549019607843137, blue: 0.7803921568627451, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9882352941176471, blue: 0.8627450980392157, alpha: 1.0)]
                case .kimobyIsTheNewBlue:
                    return [NSUIColor(red: 0.2235294117647059, green: 0.41568627450980394, blue: 0.9882352941176471, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 0.2823529411764706, blue: 1.0, alpha: 1.0)]
                case .dull:
                    return [NSUIColor(red: 0.788235294117647, green: 0.8392156862745098, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.8862745098039215, green: 0.8862745098039215, blue: 0.8862745098039215, alpha: 1.0)]
                case .purpink:
                    return [NSUIColor(red: 0.4980392156862745, green: 0.0, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.8823529411764706, green: 0.0, blue: 1.0, alpha: 1.0)]
                case .orangeCoral:
                    return [NSUIColor(red: 1.0, green: 0.6, blue: 0.4, alpha: 1.0), NSUIColor(red: 1.0, green: 0.3686274509803922, blue: 0.3843137254901961, alpha: 1.0)]
                case .summer:
                    return [NSUIColor(red: 0.13333333333333333, green: 0.7568627450980392, blue: 0.7647058823529411, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.7333333333333333, blue: 0.17647058823529413, alpha: 1.0)]
                case .kingYna:
                    return [NSUIColor(red: 0.10196078431372549, green: 0.16470588235294117, blue: 0.4235294117647059, alpha: 1.0), NSUIColor(red: 0.6980392156862745, green: 0.12156862745098039, blue: 0.12156862745098039, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.7333333333333333, blue: 0.17647058823529413, alpha: 1.0)]
                case .velvetSun:
                    return [NSUIColor(red: 0.8823529411764706, green: 0.9333333333333333, blue: 0.7647058823529411, alpha: 1.0), NSUIColor(red: 0.9411764705882353, green: 0.3137254901960784, blue: 0.3254901960784314, alpha: 1.0)]
                case .zinc:
                    return [NSUIColor(red: 0.6784313725490196, green: 0.6627450980392157, blue: 0.5882352941176471, alpha: 1.0), NSUIColor(red: 0.9490196078431372, green: 0.9490196078431372, blue: 0.9490196078431372, alpha: 1.0), NSUIColor(red: 0.8588235294117647, green: 0.8588235294117647, blue: 0.8588235294117647, alpha: 1.0), NSUIColor(red: 0.9176470588235294, green: 0.9176470588235294, blue: 0.9176470588235294, alpha: 1.0)]
                case .hydrogen:
                    return [NSUIColor(red: 0.4, green: 0.49019607843137253, blue: 0.7137254901960784, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5098039215686274, blue: 0.7843137254901961, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5098039215686274, blue: 0.7843137254901961, alpha: 1.0), NSUIColor(red: 0.4, green: 0.49019607843137253, blue: 0.7137254901960784, alpha: 1.0)]
                case .argon:
                    return [NSUIColor(red: 0.011764705882352941, green: 0.0, blue: 0.11764705882352941, alpha: 1.0), NSUIColor(red: 0.45098039215686275, green: 0.011764705882352941, blue: 0.7529411764705882, alpha: 1.0), NSUIColor(red: 0.9254901960784314, green: 0.2196078431372549, blue: 0.7372549019607844, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.9372549019607843, blue: 0.9764705882352941, alpha: 1.0)]
                case .lithium:
                    return [NSUIColor(red: 0.42745098039215684, green: 0.3764705882352941, blue: 0.15294117647058825, alpha: 1.0), NSUIColor(red: 0.8274509803921568, green: 0.796078431372549, blue: 0.7215686274509804, alpha: 1.0)]
                case .digitalWater:
                    return [NSUIColor(red: 0.4549019607843137, green: 0.9215686274509803, blue: 0.8352941176470589, alpha: 1.0), NSUIColor(red: 0.6745098039215687, green: 0.7137254901960784, blue: 0.8980392156862745, alpha: 1.0)]
                case .orangeFun:
                    return [NSUIColor(red: 0.9882352941176471, green: 0.2901960784313726, blue: 0.10196078431372549, alpha: 1.0), NSUIColor(red: 0.9686274509803922, green: 0.7176470588235294, blue: 0.2, alpha: 1.0)]
                case .rainbowBlue:
                    return [NSUIColor(red: 0.0, green: 0.9490196078431372, blue: 0.3764705882352941, alpha: 1.0), NSUIColor(red: 0.0196078431372549, green: 0.4588235294117647, blue: 0.9019607843137255, alpha: 1.0)]
                case .pinkFlavour:
                    return [NSUIColor(red: 0.5019607843137255, green: 0.0, blue: 0.5019607843137255, alpha: 1.0), NSUIColor(red: 1.0, green: 0.7529411764705882, blue: 0.796078431372549, alpha: 1.0)]
                case .sulphur:
                    return [NSUIColor(red: 0.792156862745098, green: 0.7725490196078432, blue: 0.19215686274509805, alpha: 1.0), NSUIColor(red: 0.9529411764705882, green: 0.9764705882352941, blue: 0.6549019607843137, alpha: 1.0)]
                case .selenium:
                    return [NSUIColor(red: 0.23529411764705882, green: 0.23137254901960785, blue: 0.24705882352941178, alpha: 1.0), NSUIColor(red: 0.3764705882352941, green: 0.3607843137254902, blue: 0.23529411764705882, alpha: 1.0)]
                case .delicate:
                    return [NSUIColor(red: 0.8274509803921568, green: 0.8, blue: 0.8901960784313725, alpha: 1.0), NSUIColor(red: 0.9137254901960784, green: 0.8941176470588236, blue: 0.9411764705882353, alpha: 1.0)]
                case .ohhappiness:
                    return [NSUIColor(red: 0.0, green: 0.6901960784313725, blue: 0.6078431372549019, alpha: 1.0), NSUIColor(red: 0.5882352941176471, green: 0.788235294117647, blue: 0.23921568627450981, alpha: 1.0)]
                case .lawrencium:
                    return [NSUIColor(red: 0.058823529411764705, green: 0.047058823529411764, blue: 0.1607843137254902, alpha: 1.0), NSUIColor(red: 0.18823529411764706, green: 0.16862745098039217, blue: 0.38823529411764707, alpha: 1.0), NSUIColor(red: 0.1411764705882353, green: 0.1411764705882353, blue: 0.24313725490196078, alpha: 1.0)]
                case .relaxingred:
                    return [NSUIColor(red: 1.0, green: 0.984313725490196, blue: 0.8352941176470589, alpha: 1.0), NSUIColor(red: 0.6980392156862745, green: 0.0392156862745098, blue: 0.17254901960784313, alpha: 1.0)]
                case .taranTado:
                    return [NSUIColor(red: 0.13725490196078433, green: 0.027450980392156862, blue: 0.30196078431372547, alpha: 1.0), NSUIColor(red: 0.8, green: 0.3254901960784314, blue: 0.2, alpha: 1.0)]
                case .bighead:
                    return [NSUIColor(red: 0.788235294117647, green: 0.29411764705882354, blue: 0.29411764705882354, alpha: 1.0), NSUIColor(red: 0.29411764705882354, green: 0.07450980392156863, blue: 0.30980392156862746, alpha: 1.0)]
                case .sublimeVivid:
                    return [NSUIColor(red: 0.9882352941176471, green: 0.27450980392156865, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.24705882352941178, green: 0.3686274509803922, blue: 0.984313725490196, alpha: 1.0)]
                case .sublimeLight:
                    return [NSUIColor(red: 0.9882352941176471, green: 0.3607843137254902, blue: 0.49019607843137253, alpha: 1.0), NSUIColor(red: 0.41568627450980394, green: 0.5098039215686274, blue: 0.984313725490196, alpha: 1.0)]
                case .punYeta:
                    return [NSUIColor(red: 0.06274509803921569, green: 0.5529411764705883, blue: 0.7803921568627451, alpha: 1.0), NSUIColor(red: 0.9372549019607843, green: 0.5568627450980392, blue: 0.2196078431372549, alpha: 1.0)]
                case .quepal:
                    return [NSUIColor(red: 0.06666666666666667, green: 0.6, blue: 0.5568627450980392, alpha: 1.0), NSUIColor(red: 0.2196078431372549, green: 0.9372549019607843, blue: 0.49019607843137253, alpha: 1.0)]
                case .sandtoBlue:
                    return [NSUIColor(red: 0.24313725490196078, green: 0.3176470588235294, blue: 0.3176470588235294, alpha: 1.0), NSUIColor(red: 0.8705882352941177, green: 0.796078431372549, blue: 0.6431372549019608, alpha: 1.0)]
                case .weddingDayBlues:
                    return [NSUIColor(red: 0.25098039215686274, green: 0.8784313725490196, blue: 0.8156862745098039, alpha: 1.0), NSUIColor(red: 1.0, green: 0.5490196078431373, blue: 0.0, alpha: 1.0), NSUIColor(red: 1.0, green: 0.0, blue: 0.5019607843137255, alpha: 1.0)]
                case .shifter:
                    return [NSUIColor(red: 0.7372549019607844, green: 0.3058823529411765, blue: 0.611764705882353, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 0.027450980392156862, blue: 0.34901960784313724, alpha: 1.0)]
                case .redSunset:
                    return [NSUIColor(red: 0.20784313725490197, green: 0.3607843137254902, blue: 0.49019607843137253, alpha: 1.0), NSUIColor(red: 0.4235294117647059, green: 0.3568627450980392, blue: 0.4823529411764706, alpha: 1.0), NSUIColor(red: 0.7529411764705882, green: 0.4235294117647059, blue: 0.5176470588235295, alpha: 1.0)]
                case .moonPurple:
                    return [NSUIColor(red: 0.3058823529411765, green: 0.32941176470588235, blue: 0.7843137254901961, alpha: 1.0), NSUIColor(red: 0.5607843137254902, green: 0.5803921568627451, blue: 0.984313725490196, alpha: 1.0)]
                case .pureLust:
                    return [NSUIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), NSUIColor(red: 0.8666666666666667, green: 0.09411764705882353, blue: 0.09411764705882353, alpha: 1.0)]
                case .slightOceanView:
                    return [NSUIColor(red: 0.6588235294117647, green: 0.7529411764705882, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.24705882352941178, green: 0.16862745098039217, blue: 0.5882352941176471, alpha: 1.0)]
                case .eXpresso:
                    return [NSUIColor(red: 0.6784313725490196, green: 0.3254901960784314, blue: 0.5372549019607843, alpha: 1.0), NSUIColor(red: 0.23529411764705882, green: 0.06274509803921569, blue: 0.3254901960784314, alpha: 1.0)]
                case .shifty:
                    return [NSUIColor(red: 0.38823529411764707, green: 0.38823529411764707, blue: 0.38823529411764707, alpha: 1.0), NSUIColor(red: 0.6352941176470588, green: 0.6705882352941176, blue: 0.34509803921568627, alpha: 1.0)]
                case .vanusa:
                    return [NSUIColor(red: 0.8549019607843137, green: 0.26666666666666666, blue: 0.3254901960784314, alpha: 1.0), NSUIColor(red: 0.5372549019607843, green: 0.12941176470588237, blue: 0.4196078431372549, alpha: 1.0)]
                case .eveningNight:
                    return [NSUIColor(red: 0.0, green: 0.35294117647058826, blue: 0.6549019607843137, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9921568627450981, blue: 0.8941176470588236, alpha: 1.0)]
                case .magic:
                    return [NSUIColor(red: 0.34901960784313724, green: 0.7568627450980392, blue: 0.45098039215686275, alpha: 1.0), NSUIColor(red: 0.6313725490196078, green: 0.4980392156862745, blue: 0.8784313725490196, alpha: 1.0), NSUIColor(red: 0.36470588235294116, green: 0.14901960784313725, blue: 0.7568627450980392, alpha: 1.0)]
                case .margo:
                    return [NSUIColor(red: 1.0, green: 0.9372549019607843, blue: 0.7294117647058823, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
                case .blueRaspberry:
                    return [NSUIColor(red: 0.0, green: 0.7058823529411765, blue: 0.8588235294117647, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5137254901960784, blue: 0.6901960784313725, alpha: 1.0)]
                case .citrusPeel:
                    return [NSUIColor(red: 0.9921568627450981, green: 0.7843137254901961, blue: 0.18823529411764706, alpha: 1.0), NSUIColor(red: 0.9529411764705882, green: 0.45098039215686275, blue: 0.20784313725490197, alpha: 1.0)]
                case .sinCityRed:
                    return [NSUIColor(red: 0.9294117647058824, green: 0.12941176470588237, blue: 0.22745098039215686, alpha: 1.0), NSUIColor(red: 0.5764705882352941, green: 0.1607843137254902, blue: 0.11764705882352941, alpha: 1.0)]
                case .rastafari:
                    return [NSUIColor(red: 0.11764705882352941, green: 0.5882352941176471, blue: 0.0, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9490196078431372, blue: 0.0, alpha: 1.0), NSUIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)]
                case .summerDog:
                    return [NSUIColor(red: 0.6588235294117647, green: 1.0, blue: 0.47058823529411764, alpha: 1.0), NSUIColor(red: 0.47058823529411764, green: 1.0, blue: 0.8392156862745098, alpha: 1.0)]
                case .wiretap:
                    return [NSUIColor(red: 0.5411764705882353, green: 0.13725490196078433, blue: 0.5294117647058824, alpha: 1.0), NSUIColor(red: 0.9137254901960784, green: 0.25098039215686274, blue: 0.3411764705882353, alpha: 1.0), NSUIColor(red: 0.9490196078431372, green: 0.44313725490196076, blue: 0.12941176470588237, alpha: 1.0)]
                case .burningOrange:
                    return [NSUIColor(red: 1.0, green: 0.2549019607843137, blue: 0.4235294117647059, alpha: 1.0), NSUIColor(red: 1.0, green: 0.29411764705882354, blue: 0.16862745098039217, alpha: 1.0)]
                case .ultraVoilet:
                    return [NSUIColor(red: 0.396078431372549, green: 0.3058823529411765, blue: 0.6392156862745098, alpha: 1.0), NSUIColor(red: 0.9176470588235294, green: 0.6862745098039216, blue: 0.7843137254901961, alpha: 1.0)]
                case .byDesign:
                    return [NSUIColor(red: 0.0, green: 0.6235294117647059, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.9254901960784314, green: 0.1843137254901961, blue: 0.29411764705882354, alpha: 1.0)]
                case .kyooTah:
                    return [NSUIColor(red: 0.32941176470588235, green: 0.2901960784313726, blue: 0.49019607843137253, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8313725490196079, blue: 0.3215686274509804, alpha: 1.0)]
                case .kyeMeh:
                    return [NSUIColor(red: 0.5137254901960784, green: 0.3764705882352941, blue: 0.7647058823529411, alpha: 1.0), NSUIColor(red: 0.1803921568627451, green: 0.7490196078431373, blue: 0.5686274509803921, alpha: 1.0)]
                case .kyooPal:
                    return [NSUIColor(red: 0.8666666666666667, green: 0.24313725490196078, blue: 0.32941176470588235, alpha: 1.0), NSUIColor(red: 0.4196078431372549, green: 0.8980392156862745, blue: 0.5215686274509804, alpha: 1.0)]
                case .metapolis:
                    return [NSUIColor(red: 0.396078431372549, green: 0.6, blue: 0.6, alpha: 1.0), NSUIColor(red: 0.9568627450980393, green: 0.4745098039215686, blue: 0.12156862745098039, alpha: 1.0)]
                case .flare:
                    return [NSUIColor(red: 0.9450980392156862, green: 0.15294117647058825, blue: 0.06666666666666667, alpha: 1.0), NSUIColor(red: 0.9607843137254902, green: 0.6862745098039216, blue: 0.09803921568627451, alpha: 1.0)]
                case .witchingHour:
                    return [NSUIColor(red: 0.7647058823529411, green: 0.0784313725490196, blue: 0.19607843137254902, alpha: 1.0), NSUIColor(red: 0.1411764705882353, green: 0.043137254901960784, blue: 0.21176470588235294, alpha: 1.0)]
                case .azurLane:
                    return [NSUIColor(red: 0.4980392156862745, green: 0.4980392156862745, blue: 0.8352941176470589, alpha: 1.0), NSUIColor(red: 0.5254901960784314, green: 0.6588235294117647, blue: 0.9058823529411765, alpha: 1.0), NSUIColor(red: 0.5686274509803921, green: 0.9176470588235294, blue: 0.8941176470588236, alpha: 1.0)]
                case .neuromancer:
                    return [NSUIColor(red: 0.9764705882352941, green: 0.3254901960784314, blue: 0.7764705882352941, alpha: 1.0), NSUIColor(red: 0.7254901960784313, green: 0.11372549019607843, blue: 0.45098039215686275, alpha: 1.0)]
                case .harvey:
                    return [NSUIColor(red: 0.12156862745098039, green: 0.25098039215686274, blue: 0.21568627450980393, alpha: 1.0), NSUIColor(red: 0.6, green: 0.9490196078431372, blue: 0.7843137254901961, alpha: 1.0)]
                case .amin:
                    return [NSUIColor(red: 0.5568627450980392, green: 0.17647058823529413, blue: 0.8862745098039215, alpha: 1.0), NSUIColor(red: 0.2901960784313726, green: 0.0, blue: 0.8784313725490196, alpha: 1.0)]
                case .memariani:
                    return [NSUIColor(red: 0.6666666666666666, green: 0.29411764705882354, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.4196078431372549, green: 0.4196078431372549, blue: 0.5137254901960784, alpha: 1.0), NSUIColor(red: 0.23137254901960785, green: 0.5529411764705883, blue: 0.6, alpha: 1.0)]
                case .yoda:
                    return [NSUIColor(red: 1.0, green: 0.0, blue: 0.6, alpha: 1.0), NSUIColor(red: 0.28627450980392155, green: 0.19607843137254902, blue: 0.25098039215686274, alpha: 1.0)]
                case .coolSky:
                    return [NSUIColor(red: 0.1607843137254902, green: 0.5019607843137255, blue: 0.7254901960784313, alpha: 1.0), NSUIColor(red: 0.42745098039215684, green: 0.8352941176470589, blue: 0.9803921568627451, alpha: 1.0), NSUIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
                case .darkOcean:
                    return [NSUIColor(red: 0.21568627450980393, green: 0.23137254901960785, blue: 0.26666666666666666, alpha: 1.0), NSUIColor(red: 0.25882352941176473, green: 0.5254901960784314, blue: 0.9568627450980393, alpha: 1.0)]
                case .eveningSunshine:
                    return [NSUIColor(red: 0.7254901960784313, green: 0.16862745098039217, blue: 0.15294117647058825, alpha: 1.0), NSUIColor(red: 0.08235294117647059, green: 0.396078431372549, blue: 0.7529411764705882, alpha: 1.0)]
                case .jShine:
                    return [NSUIColor(red: 0.07058823529411765, green: 0.7607843137254902, blue: 0.9137254901960784, alpha: 1.0), NSUIColor(red: 0.7686274509803922, green: 0.44313725490196076, blue: 0.9294117647058824, alpha: 1.0), NSUIColor(red: 0.9647058823529412, green: 0.30980392156862746, blue: 0.34901960784313724, alpha: 1.0)]
                case .moonlitAsteroid:
                    return [NSUIColor(red: 0.058823529411764705, green: 0.12549019607843137, blue: 0.15294117647058825, alpha: 1.0), NSUIColor(red: 0.12549019607843137, green: 0.22745098039215686, blue: 0.2627450980392157, alpha: 1.0), NSUIColor(red: 0.17254901960784313, green: 0.3254901960784314, blue: 0.39215686274509803, alpha: 1.0)]
                case .megaTron:
                    return [NSUIColor(red: 0.7764705882352941, green: 1.0, blue: 0.8666666666666667, alpha: 1.0), NSUIColor(red: 0.984313725490196, green: 0.8431372549019608, blue: 0.5254901960784314, alpha: 1.0), NSUIColor(red: 0.9686274509803922, green: 0.4745098039215686, blue: 0.49019607843137253, alpha: 1.0)]
                case .coolBlues:
                    return [NSUIColor(red: 0.12941176470588237, green: 0.5764705882352941, blue: 0.6901960784313725, alpha: 1.0), NSUIColor(red: 0.42745098039215684, green: 0.8352941176470589, blue: 0.9294117647058824, alpha: 1.0)]
                case .piggyPink:
                    return [NSUIColor(red: 0.9333333333333333, green: 0.611764705882353, blue: 0.6549019607843137, alpha: 1.0), NSUIColor(red: 1.0, green: 0.8666666666666667, blue: 0.8823529411764706, alpha: 1.0)]
                case .gradeGrey:
                    return [NSUIColor(red: 0.7411764705882353, green: 0.7647058823529411, blue: 0.7803921568627451, alpha: 1.0), NSUIColor(red: 0.17254901960784313, green: 0.24313725490196078, blue: 0.3137254901960784, alpha: 1.0)]
                case .telko:
                    return [NSUIColor(red: 0.9529411764705882, green: 0.3843137254901961, blue: 0.13333333333333333, alpha: 1.0), NSUIColor(red: 0.3607843137254902, green: 0.7137254901960784, blue: 0.26666666666666666, alpha: 1.0), NSUIColor(red: 0.0, green: 0.4980392156862745, blue: 0.7647058823529411, alpha: 1.0)]
                case .zenta:
                    return [NSUIColor(red: 0.16470588235294117, green: 0.17647058823529413, blue: 0.24313725490196078, alpha: 1.0), NSUIColor(red: 0.996078431372549, green: 0.796078431372549, blue: 0.43137254901960786, alpha: 1.0)]
                case .electricPeacock:
                    return [NSUIColor(red: 0.5411764705882353, green: 0.16862745098039217, blue: 0.8862745098039215, alpha: 1.0), NSUIColor(red: 0.0, green: 0.0, blue: 0.803921568627451, alpha: 1.0), NSUIColor(red: 0.13333333333333333, green: 0.5450980392156862, blue: 0.13333333333333333, alpha: 1.0), NSUIColor(red: 0.8, green: 1.0, blue: 0.0, alpha: 1.0)]
                case .underBlueGreen:
                    return [NSUIColor(red: 0.0196078431372549, green: 0.09803921568627451, blue: 0.21568627450980393, alpha: 1.0), NSUIColor(red: 0.0, green: 0.30196078431372547, blue: 0.47843137254901963, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5294117647058824, blue: 0.5764705882352941, alpha: 1.0), NSUIColor(red: 0.0, green: 0.7490196078431373, blue: 0.4470588235294118, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.9215686274509803, blue: 0.07058823529411765, alpha: 1.0)]
                case .lensod:
                    return [NSUIColor(red: 0.3764705882352941, green: 0.1450980392156863, blue: 0.9607843137254902, alpha: 1.0), NSUIColor(red: 1.0, green: 0.3333333333333333, blue: 0.3333333333333333, alpha: 1.0)]
                case .newspaper:
                    return [NSUIColor(red: 0.5411764705882353, green: 0.16862745098039217, blue: 0.8862745098039215, alpha: 1.0), NSUIColor(red: 1.0, green: 0.6470588235294118, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.9725490196078431, green: 0.9725490196078431, blue: 1.0, alpha: 1.0)]
                case .darkBlueGradient:
                    return [NSUIColor(red: 0.15294117647058825, green: 0.4549019607843137, blue: 0.6823529411764706, alpha: 1.0), NSUIColor(red: 0.0, green: 0.1803921568627451, blue: 0.36470588235294116, alpha: 1.0), NSUIColor(red: 0.0, green: 0.1803921568627451, blue: 0.36470588235294116, alpha: 1.0)]
                case .darkBluTwo:
                    return [NSUIColor(red: 0.0, green: 0.27450980392156865, blue: 0.5019607843137255, alpha: 1.0), NSUIColor(red: 0.26666666666666666, green: 0.5176470588235295, blue: 0.7294117647058823, alpha: 1.0)]
                case .lemonLime:
                    return [NSUIColor(red: 0.49411764705882355, green: 0.7764705882352941, blue: 0.7372549019607844, alpha: 1.0), NSUIColor(red: 0.9215686274509803, green: 0.9058823529411765, blue: 0.09019607843137255, alpha: 1.0)]
                case .beleko:
                    return [NSUIColor(red: 1.0, green: 0.11764705882352941, blue: 0.33725490196078434, alpha: 1.0), NSUIColor(red: 0.9764705882352941, green: 0.788235294117647, blue: 0.25882352941176473, alpha: 1.0), NSUIColor(red: 0.11764705882352941, green: 0.5647058823529412, blue: 1.0, alpha: 1.0)]
                case .mangoPapaya:
                    return [NSUIColor(red: 0.8705882352941177, green: 0.5411764705882353, blue: 0.2549019607843137, alpha: 1.0), NSUIColor(red: 0.16470588235294117, green: 0.8549019607843137, blue: 0.3254901960784314, alpha: 1.0)]
                case .unicornRainbow:
                    return [NSUIColor(red: 0.9686274509803922, green: 0.9411764705882353, blue: 0.6745098039215687, alpha: 1.0), NSUIColor(red: 0.6745098039215687, green: 0.9686274509803922, blue: 0.9411764705882353, alpha: 1.0), NSUIColor(red: 0.9411764705882353, green: 0.6745098039215687, blue: 0.9686274509803922, alpha: 1.0)]
                case .flame:
                    return [NSUIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.9921568627450981, green: 0.8117647058823529, blue: 0.34509803921568627, alpha: 1.0)]
                case .blueRed:
                    return [NSUIColor(red: 0.21176470588235294, green: 0.6941176470588235, blue: 0.7803921568627451, alpha: 1.0), NSUIColor(red: 0.5882352941176471, green: 0.043137254901960784, blue: 0.2, alpha: 1.0)]
                case .twitter:
                    return [NSUIColor(red: 0.11372549019607843, green: 0.6313725490196078, blue: 0.9490196078431372, alpha: 1.0), NSUIColor(red: 0.0, green: 0.6235294117647059, blue: 0.9882352941176471, alpha: 1.0)]
                case .blooze:
                    return [NSUIColor(red: 0.42745098039215684, green: 0.6509803921568628, blue: 0.7450980392156863, alpha: 1.0), NSUIColor(red: 0.29411764705882354, green: 0.5215686274509804, blue: 0.6196078431372549, alpha: 1.0), NSUIColor(red: 0.42745098039215684, green: 0.6509803921568628, blue: 0.7450980392156863, alpha: 1.0)]
                case .blueSlate:
                    return [NSUIColor(red: 0.7098039215686275, green: 0.7254901960784313, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.16862745098039217, green: 0.17254901960784313, blue: 0.28627450980392155, alpha: 1.0)]
                case .spaceLightGreen:
                    return [NSUIColor(red: 0.6235294117647059, green: 0.6274509803921569, blue: 0.6588235294117647, alpha: 1.0), NSUIColor(red: 0.3607843137254902, green: 0.47058823529411764, blue: 0.3215686274509804, alpha: 1.0)]
                case .flower:
                    return [NSUIColor(red: 0.8627450980392157, green: 1.0, blue: 0.7411764705882353, alpha: 1.0), NSUIColor(red: 0.8, green: 0.5254901960784314, blue: 0.8196078431372549, alpha: 1.0)]
                case .elateTheEuge:
                    return [NSUIColor(red: 0.5450980392156862, green: 0.8705882352941177, blue: 0.8549019607843137, alpha: 1.0), NSUIColor(red: 0.2627450980392157, green: 0.6784313725490196, blue: 0.8156862745098039, alpha: 1.0), NSUIColor(red: 0.6, green: 0.5568627450980392, blue: 0.8784313725490196, alpha: 1.0), NSUIColor(red: 0.8823529411764706, green: 0.49019607843137253, blue: 0.7607843137254902, alpha: 1.0), NSUIColor(red: 0.9372549019607843, green: 0.5764705882352941, blue: 0.5764705882352941, alpha: 1.0)]
                case .peachSea:
                    return [NSUIColor(red: 0.9019607843137255, green: 0.6823529411764706, blue: 0.5490196078431373, alpha: 1.0), NSUIColor(red: 0.6588235294117647, green: 0.807843137254902, blue: 0.8117647058823529, alpha: 1.0)]
                case .abbas:
                    return [NSUIColor(red: 0.0, green: 1.0, blue: 0.9411764705882353, alpha: 1.0), NSUIColor(red: 0.0, green: 0.5137254901960784, blue: 0.996078431372549, alpha: 1.0)]
                case .winterWoods:
                    return [NSUIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), NSUIColor(red: 0.6352941176470588, green: 0.6705882352941176, blue: 0.34509803921568627, alpha: 1.0), NSUIColor(red: 0.6431372549019608, green: 0.2235294117647059, blue: 0.19215686274509805, alpha: 1.0)]
                case .ameena:
                    return [NSUIColor(red: 0.047058823529411764, green: 0.047058823529411764, blue: 0.42745098039215684, alpha: 1.0), NSUIColor(red: 0.8705882352941177, green: 0.3176470588235294, blue: 0.16862745098039217, alpha: 1.0), NSUIColor(red: 0.596078431372549, green: 0.8156862745098039, blue: 0.7568627450980392, alpha: 1.0), NSUIColor(red: 0.3568627450980392, green: 0.6980392156862745, blue: 0.14901960784313725, alpha: 1.0), NSUIColor(red: 0.00784313725490196, green: 0.23529411764705882, blue: 0.050980392156862744, alpha: 1.0)]
                case .emeraldSea:
                    return [NSUIColor(red: 0.0196078431372549, green: 0.2196078431372549, blue: 0.4196078431372549, alpha: 1.0), NSUIColor(red: 0.3607843137254902, green: 0.8588235294117647, blue: 0.5843137254901961, alpha: 1.0)]
                case .bleem:
                    return [NSUIColor(red: 0.25882352941176473, green: 0.5176470588235295, blue: 0.8588235294117647, alpha: 1.0), NSUIColor(red: 0.1607843137254902, green: 0.9176470588235294, blue: 0.7686274509803922, alpha: 1.0)]
                case .coffeeGold:
                    return [NSUIColor(red: 0.3333333333333333, green: 0.25098039215686274, blue: 0.13725490196078433, alpha: 1.0), NSUIColor(red: 0.788235294117647, green: 0.596078431372549, blue: 0.27450980392156865, alpha: 1.0)]
                case .compass:
                    return [NSUIColor(red: 0.3176470588235294, green: 0.4196078431372549, blue: 0.5450980392156862, alpha: 1.0), NSUIColor(red: 0.0196078431372549, green: 0.4196078431372549, blue: 0.23137254901960785, alpha: 1.0)]
                case .andreuzzas:
                    return [NSUIColor(red: 0.8431372549019608, green: 0.023529411764705882, blue: 0.3215686274509804, alpha: 1.0), NSUIColor(red: 1.0, green: 0.00784313725490196, blue: 0.3686274509803922, alpha: 1.0)]
                case .moonwalker:
                    return [NSUIColor(red: 0.08235294117647059, green: 0.13725490196078433, blue: 0.19215686274509805, alpha: 1.0), NSUIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)]
                case .whinehouse:
                    return [NSUIColor(red: 0.9686274509803922, green: 0.9686274509803922, blue: 0.9686274509803922, alpha: 1.0), NSUIColor(red: 0.7254901960784313, green: 0.6274509803921569, blue: 0.6274509803921569, alpha: 1.0), NSUIColor(red: 0.4745098039215686, green: 0.2784313725490196, blue: 0.2784313725490196, alpha: 1.0), NSUIColor(red: 0.3058823529411765, green: 0.12549019607843137, blue: 0.12549019607843137, alpha: 1.0), NSUIColor(red: 0.06666666666666667, green: 0.06666666666666667, blue: 0.06666666666666667, alpha: 1.0)]
                case .hyperBlue:
                    return [NSUIColor(red: 0.34901960784313724, green: 0.803921568627451, blue: 0.9137254901960784, alpha: 1.0), NSUIColor(red: 0.0392156862745098, green: 0.16470588235294117, blue: 0.5333333333333333, alpha: 1.0)]
                case .racker:
                    return [NSUIColor(red: 0.9215686274509803, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor(red: 0.5843137254901961, green: 0.0, blue: 0.5411764705882353, alpha: 1.0), NSUIColor(red: 0.2, green: 0.0, blue: 0.9882352941176471, alpha: 1.0)]
                case .aftertheRain:
                    return [NSUIColor(red: 1.0, green: 0.4588235294117647, blue: 0.7647058823529411, alpha: 1.0), NSUIColor(red: 1.0, green: 0.6509803921568628, blue: 0.2784313725490196, alpha: 1.0), NSUIColor(red: 1.0, green: 0.9098039215686274, blue: 0.24705882352941178, alpha: 1.0), NSUIColor(red: 0.6235294117647059, green: 1.0, blue: 0.3568627450980392, alpha: 1.0), NSUIColor(red: 0.4392156862745098, green: 0.8862745098039215, blue: 1.0, alpha: 1.0), NSUIColor(red: 0.803921568627451, green: 0.5764705882352941, blue: 1.0, alpha: 1.0)]
                case .neonGreen:
                    return [NSUIColor(red: 0.5058823529411764, green: 1.0, blue: 0.5411764705882353, alpha: 1.0), NSUIColor(red: 0.39215686274509803, green: 0.5882352941176471, blue: 0.3686274509803922, alpha: 1.0)]
                case .dustyGrass:
                    return [NSUIColor(red: 0.8313725490196079, green: 0.9882352941176471, blue: 0.4745098039215686, alpha: 1.0), NSUIColor(red: 0.5882352941176471, green: 0.9019607843137255, blue: 0.6313725490196078, alpha: 1.0)]
                case .visualBlue:
                    return [NSUIColor(red: 0.0, green: 0.23921568627450981, blue: 0.30196078431372547, alpha: 1.0), NSUIColor(red: 0.0, green: 0.788235294117647, blue: 0.5882352941176471, alpha: 1.0)]
                }
            }

            public var name: String {
                switch self {
                case .omolon:
                    return "Omolon"
                case .farhan:
                    return "Farhan"
                case .purple:
                    return "Purple"
                case .ibtesam:
                    return "Ibtesam"
                case .radioactiveHeat:
                    return "Radioactive Heat"
                case .theSkyAndTheSea:
                    return "The Sky And The Sea"
                case .fromIceToFire:
                    return "From Ice To Fire"
                case .blueOrange:
                    return "Blue & Orange"
                case .purpleDream:
                    return "Purple Dream"
                case .blu:
                    return "Blu"
                case .summerBreeze:
                    return "Summer Breeze"
                case .ver:
                    return "Ver"
                case .verBlack:
                    return "Ver Black"
                case .combi:
                    return "Combi"
                case .anwar:
                    return "Anwar"
                case .bluelagoo:
                    return "Bluelagoo"
                case .lunada:
                    return "Lunada"
                case .reaqua:
                    return "Reaqua"
                case .mango:
                    return "Mango"
                case .bupe:
                    return "Bupe"
                case .rea:
                    return "Rea"
                case .windy:
                    return "Windy"
                case .royalBlue:
                    return "Royal Blue"
                case .royalBluePetrol:
                    return "Royal Blue + Petrol"
                case .copper:
                    return "Copper"
                case .anamnisar:
                    return "Anamnisar"
                case .petrol:
                    return "Petrol"
                case .sel:
                    return "Sel"
                case .afternoon:
                    return "Afternoon"
                case .skyline:
                    return "Skyline"
                case .dIMIGO:
                    return "DIMIGO"
                case .purpleLove:
                    return "Purple Love"
                case .sexyBlue:
                    return "Sexy Blue"
                case .blooker:
                    return "Blooker20"
                case .seaBlue:
                    return "Sea Blue"
                case .nimvelo:
                    return "Nimvelo"
                case .hazel:
                    return "Hazel"
                case .noontoDusk:
                    return "Noon to Dusk"
                case .youTube:
                    return "YouTube"
                case .coolBrown:
                    return "Cool Brown"
                case .harmonicEnergy:
                    return "Harmonic Energy"
                case .playingwithReds:
                    return "Playing with Reds"
                case .sunnyDays:
                    return "Sunny Days"
                case .greenBeach:
                    return "Green Beach"
                case .intuitivePurple:
                    return "Intuitive Purple"
                case .emeraldWater:
                    return "Emerald Water"
                case .lemonTwist:
                    return "Lemon Twist"
                case .monteCarlo:
                    return "Monte Carlo"
                case .horizon:
                    return "Horizon"
                case .roseWater:
                    return "Rose Water"
                case .frozen:
                    return "Frozen"
                case .mangoPulp:
                    return "Mango Pulp"
                case .bloodyMary:
                    return "Bloody Mary"
                case .aubergine:
                    return "Aubergine"
                case .aquaMarine:
                    return "Aqua Marine"
                case .sunrise:
                    return "Sunrise"
                case .purpleParadise:
                    return "Purple Paradise"
                case .stripe:
                    return "Stripe"
                case .seaWeed:
                    return "Sea Weed"
                case .pinky:
                    return "Pinky"
                case .cherry:
                    return "Cherry"
                case .mojito:
                    return "Mojito"
                case .juicyOrange:
                    return "Juicy Orange"
                case .mirage:
                    return "Mirage"
                case .steelGray:
                    return "Steel Gray"
                case .kashmir:
                    return "Kashmir"
                case .electricViolet:
                    return "Electric Violet"
                case .veniceBlue:
                    return "Venice Blue"
                case .boraBora:
                    return "Bora Bora"
                case .moss:
                    return "Moss"
                case .shroomHaze:
                    return "Shroom Haze"
                case .mystic:
                    return "Mystic"
                case .midnightCity:
                    return "Midnight City"
                case .seaBlizz:
                    return "Sea Blizz"
                case .opa:
                    return "Opa"
                case .titanium:
                    return "Titanium"
                case .mantle:
                    return "Mantle"
                case .dracula:
                    return "Dracula"
                case .peach:
                    return "Peach"
                case .moonrise:
                    return "Moonrise"
                case .clouds:
                    return "Clouds"
                case .stellar:
                    return "Stellar"
                case .bourbon:
                    return "Bourbon"
                case .calmDarya:
                    return "Calm Darya"
                case .influenza:
                    return "Influenza"
                case .shrimpy:
                    return "Shrimpy"
                case .army:
                    return "Army"
                case .miaka:
                    return "Miaka"
                case .pinotNoir:
                    return "Pinot Noir"
                case .dayTripper:
                    return "Day Tripper"
                case .namn:
                    return "Namn"
                case .blurryBeach:
                    return "Blurry Beach"
                case .vasily:
                    return "Vasily"
                case .aLostMemory:
                    return "A Lost Memory"
                case .petrichor:
                    return "Petrichor"
                case .jonquil:
                    return "Jonquil"
                case .siriusTamed:
                    return "Sirius Tamed"
                case .kyoto:
                    return "Kyoto"
                case .mistyMeadow:
                    return "Misty Meadow"
                case .aqualicious:
                    return "Aqualicious"
                case .moor:
                    return "Moor"
                case .almost:
                    return "Almost"
                case .foreverLost:
                    return "Forever Lost"
                case .winter:
                    return "Winter"
                case .nelson:
                    return "Nelson"
                case .autumn:
                    return "Autumn"
                case .candy:
                    return "Candy"
                case .reef:
                    return "Reef"
                case .theStrain:
                    return "The Strain"
                case .dirtyFog:
                    return "Dirty Fog"
                case .earthly:
                    return "Earthly"
                case .virgin:
                    return "Virgin"
                case .ash:
                    return "Ash"
                case .cherryblossoms:
                    return "Cherryblossoms"
                case .parklife:
                    return "Parklife"
                case .danceToForget:
                    return "Dance To Forget"
                case .starfall:
                    return "Starfall"
                case .redMist:
                    return "Red Mist"
                case .tealLove:
                    return "Teal Love"
                case .neonLife:
                    return "Neon Life"
                case .manofSteel:
                    return "Man of Steel"
                case .amethyst:
                    return "Amethyst"
                case .cheerUpEmoKid:
                    return "Cheer Up Emo Kid"
                case .shore:
                    return "Shore"
                case .facebookMessenger:
                    return "Facebook Messenger"
                case .soundCloud:
                    return "SoundCloud"
                case .behongo:
                    return "Behongo"
                case .servQuick:
                    return "ServQuick"
                case .friday:
                    return "Friday"
                case .martini:
                    return "Martini"
                case .metallicToad:
                    return "Metallic Toad"
                case .betweenTheClouds:
                    return "Between The Clouds"
                case .crazyOrangeI:
                    return "Crazy Orange I"
                case .hersheys:
                    return "Hersheys"
                case .talkingToMiceElf:
                    return "Talking To Mice Elf"
                case .purpleBliss:
                    return "Purple Bliss"
                case .predawn:
                    return "Predawn"
                case .endlessRiver:
                    return "Endless River"
                case .pastelOrangeattheSun:
                    return "Pastel Orange at the Sun"
                case .twitch:
                    return "Twitch"
                case .atlas:
                    return "Atlas"
                case .instagram:
                    return "Instagram"
                case .flickr:
                    return "Flickr"
                case .vine:
                    return "Vine"
                case .turquoiseflow:
                    return "Turquoise flow"
                case .portrait:
                    return "Portrait"
                case .virginAmerica:
                    return "Virgin America"
                case .kokoCaramel:
                    return "Koko Caramel"
                case .freshTurboscent:
                    return "Fresh Turboscent"
                case .greentodark:
                    return "Green to dark"
                case .ukraine:
                    return "Ukraine"
                case .curiosityblue:
                    return "Curiosity blue"
                case .darkKnight:
                    return "Dark Knight"
                case .piglet:
                    return "Piglet"
                case .lizard:
                    return "Lizard"
                case .sagePersuasion:
                    return "Sage Persuasion"
                case .betweenNightandDay:
                    return "Between Night and Day"
                case .timber:
                    return "Timber"
                case .passion:
                    return "Passion"
                case .clearSky:
                    return "Clear Sky"
                case .masterCard:
                    return "Master Card"
                case .backToEarth:
                    return "Back To Earth"
                case .deepPurple:
                    return "Deep Purple"
                case .littleLeaf:
                    return "Little Leaf"
                case .netflix:
                    return "Netflix"
                case .lightOrange:
                    return "Light Orange"
                case .greenandBlue:
                    return "Green and Blue"
                case .poncho:
                    return "Poncho"
                case .backtotheFuture:
                    return "Back to the Future"
                case .blush:
                    return "Blush"
                case .inbox:
                    return "Inbox"
                case .purplin:
                    return "Purplin"
                case .paleWood:
                    return "Pale Wood"
                case .haikus:
                    return "Haikus"
                case .pizelex:
                    return "Pizelex"
                case .joomla:
                    return "Joomla"
                case .christmas:
                    return "Christmas"
                case .minnesotaVikings:
                    return "Minnesota Vikings"
                case .miamiDolphins:
                    return "Miami Dolphins"
                case .forest:
                    return "Forest"
                case .nighthawk:
                    return "Nighthawk"
                case .superman:
                    return "Superman"
                case .suzy:
                    return "Suzy"
                case .darkSkies:
                    return "Dark Skies"
                case .deepSpace:
                    return "Deep Space"
                case .decent:
                    return "Decent"
                case .colorsOfSky:
                    return "Colors Of Sky"
                case .purpleWhite:
                    return "Purple White"
                case .ali:
                    return "Ali"
                case .alihossein:
                    return "Alihossein"
                case .shahabi:
                    return "Shahabi"
                case .redOcean:
                    return "Red Ocean"
                case .tranquil:
                    return "Tranquil"
                case .transfile:
                    return "Transfile"
                case .sylvia:
                    return "Sylvia"
                case .sweetMorning:
                    return "Sweet Morning"
                case .politics:
                    return "Politics"
                case .brightVault:
                    return "Bright Vault"
                case .solidVault:
                    return "Solid Vault"
                case .sunset:
                    return "Sunset"
                case .grapefruitSunset:
                    return "Grapefruit Sunset"
                case .deepSeaSpace:
                    return "Deep Sea Space"
                case .dusk:
                    return "Dusk"
                case .minimalRed:
                    return "Minimal Red"
                case .royal:
                    return "Royal"
                case .mauve:
                    return "Mauve"
                case .frost:
                    return "Frost"
                case .lush:
                    return "Lush"
                case .firewatch:
                    return "Firewatch"
                case .sherbert:
                    return "Sherbert"
                case .bloodRed:
                    return "Blood Red"
                case .sunontheHorizon:
                    return "Sun on the Horizon"
                case .iIITDelhi:
                    return "IIIT Delhi"
                case .jupiter:
                    return "Jupiter"
                case .shadesofGrey:
                    return "50 Shades of Grey"
                case .dania:
                    return "Dania"
                case .limeade:
                    return "Limeade"
                case .disco:
                    return "Disco"
                case .loveCouple:
                    return "Love Couple"
                case .azurePop:
                    return "Azure Pop"
                case .nepal:
                    return "Nepal"
                case .cosmicFusion:
                    return "Cosmic Fusion"
                case .snapchat:
                    return "Snapchat"
                case .edsSunsetGradient:
                    return "Ed's Sunset Gradient"
                case .bradyBradyFunFun:
                    return "Brady Brady Fun Fun"
                case .blackRos:
                    return "Black Rosé"
                case .sPurple:
                    return "80's Purple"
                case .radar:
                    return "Radar"
                case .ibizaSunset:
                    return "Ibiza Sunset"
                case .dawn:
                    return "Dawn"
                case .mild:
                    return "Mild"
                case .viceCity:
                    return "Vice City"
                case .jaipur:
                    return "Jaipur"
                case .jodhpur:
                    return "Jodhpur"
                case .cocoaaIce:
                    return "Cocoaa Ice"
                case .easyMed:
                    return "EasyMed"
                case .roseColoredLenses:
                    return "Rose Colored Lenses"
                case .whatliesBeyond:
                    return "What lies Beyond"
                case .roseanna:
                    return "Roseanna"
                case .honeyDew:
                    return "Honey Dew"
                case .undertheLake:
                    return "Under the Lake"
                case .theBlueLagoon:
                    return "The Blue Lagoon"
                case .canYouFeelTheLoveTonight:
                    return "Can You Feel The Love Tonight"
                case .veryBlue:
                    return "Very Blue"
                case .loveandLiberty:
                    return "Love and Liberty"
                case .orca:
                    return "Orca"
                case .venice:
                    return "Venice"
                case .pacificDream:
                    return "Pacific Dream"
                case .learningandLeading:
                    return "Learning and Leading"
                case .celestial:
                    return "Celestial"
                case .purplepine:
                    return "Purplepine"
                case .shalala:
                    return "Sha la la"
                case .mini:
                    return "Mini"
                case .maldives:
                    return "Maldives"
                case .cinnamint:
                    return "Cinnamint"
                case .html:
                    return "Html"
                case .coal:
                    return "Coal"
                case .sunkist:
                    return "Sunkist"
                case .blueSkies:
                    return "Blue Skies"
                case .chittyChittyBangBang:
                    return "Chitty Chitty Bang Bang"
                case .visionsofGrandeur:
                    return "Visions of Grandeur"
                case .crystalClear:
                    return "Crystal Clear"
                case .mello:
                    return "Mello"
                case .compareNow:
                    return "Compare Now"
                case .meridian:
                    return "Meridian"
                case .relay:
                    return "Relay"
                case .alive:
                    return "Alive"
                case .scooter:
                    return "Scooter"
                case .terminal:
                    return "Terminal"
                case .telegram:
                    return "Telegram"
                case .crimsonTide:
                    return "Crimson Tide"
                case .socialive:
                    return "Socialive"
                case .subu:
                    return "Subu"
                case .brokenHearts:
                    return "Broken Hearts"
                case .kimobyIsTheNewBlue:
                    return "Kimoby Is The New Blue"
                case .dull:
                    return "Dull"
                case .purpink:
                    return "Purpink"
                case .orangeCoral:
                    return "Orange Coral"
                case .summer:
                    return "Summer"
                case .kingYna:
                    return "King Yna"
                case .velvetSun:
                    return "Velvet Sun"
                case .zinc:
                    return "Zinc"
                case .hydrogen:
                    return "Hydrogen"
                case .argon:
                    return "Argon"
                case .lithium:
                    return "Lithium"
                case .digitalWater:
                    return "Digital Water"
                case .orangeFun:
                    return "Orange Fun"
                case .rainbowBlue:
                    return "Rainbow Blue"
                case .pinkFlavour:
                    return "Pink Flavour"
                case .sulphur:
                    return "Sulphur"
                case .selenium:
                    return "Selenium"
                case .delicate:
                    return "Delicate"
                case .ohhappiness:
                    return "Ohhappiness"
                case .lawrencium:
                    return "Lawrencium"
                case .relaxingred:
                    return "Relaxing red"
                case .taranTado:
                    return "Taran Tado"
                case .bighead:
                    return "Bighead"
                case .sublimeVivid:
                    return "Sublime Vivid"
                case .sublimeLight:
                    return "Sublime Light"
                case .punYeta:
                    return "Pun Yeta"
                case .quepal:
                    return "Quepal"
                case .sandtoBlue:
                    return "Sand to Blue"
                case .weddingDayBlues:
                    return "Wedding Day Blues"
                case .shifter:
                    return "Shifter"
                case .redSunset:
                    return "Red Sunset"
                case .moonPurple:
                    return "Moon Purple"
                case .pureLust:
                    return "Pure Lust"
                case .slightOceanView:
                    return "Slight Ocean View"
                case .eXpresso:
                    return "eXpresso"
                case .shifty:
                    return "Shifty"
                case .vanusa:
                    return "Vanusa"
                case .eveningNight:
                    return "Evening Night"
                case .magic:
                    return "Magic"
                case .margo:
                    return "Margo"
                case .blueRaspberry:
                    return "Blue Raspberry"
                case .citrusPeel:
                    return "Citrus Peel"
                case .sinCityRed:
                    return "Sin City Red"
                case .rastafari:
                    return "Rastafari"
                case .summerDog:
                    return "Summer Dog"
                case .wiretap:
                    return "Wiretap"
                case .burningOrange:
                    return "Burning Orange"
                case .ultraVoilet:
                    return "Ultra Voilet"
                case .byDesign:
                    return "By Design"
                case .kyooTah:
                    return "Kyoo Tah"
                case .kyeMeh:
                    return "Kye Meh"
                case .kyooPal:
                    return "Kyoo Pal"
                case .metapolis:
                    return "Metapolis"
                case .flare:
                    return "Flare"
                case .witchingHour:
                    return "Witching Hour"
                case .azurLane:
                    return "Azur Lane"
                case .neuromancer:
                    return "Neuromancer"
                case .harvey:
                    return "Harvey"
                case .amin:
                    return "Amin"
                case .memariani:
                    return "Memariani"
                case .yoda:
                    return "Yoda"
                case .coolSky:
                    return "Cool Sky"
                case .darkOcean:
                    return "Dark Ocean"
                case .eveningSunshine:
                    return "Evening Sunshine"
                case .jShine:
                    return "JShine"
                case .moonlitAsteroid:
                    return "Moonlit Asteroid"
                case .megaTron:
                    return "MegaTron"
                case .coolBlues:
                    return "Cool Blues"
                case .piggyPink:
                    return "Piggy Pink"
                case .gradeGrey:
                    return "Grade Grey"
                case .telko:
                    return "Telko"
                case .zenta:
                    return "Zenta"
                case .electricPeacock:
                    return "Electric Peacock"
                case .underBlueGreen:
                    return "Under Blue Green"
                case .lensod:
                    return "Lensod"
                case .newspaper:
                    return "Newspaper"
                case .darkBlueGradient:
                    return "Dark Blue Gradient"
                case .darkBluTwo:
                    return "Dark Blu Two"
                case .lemonLime:
                    return "Lemon Lime"
                case .beleko:
                    return "Beleko"
                case .mangoPapaya:
                    return "Mango Papaya"
                case .unicornRainbow:
                    return "Unicorn Rainbow"
                case .flame:
                    return "Flame"
                case .blueRed:
                    return "Blue Red"
                case .twitter:
                    return "Twitter"
                case .blooze:
                    return "Blooze"
                case .blueSlate:
                    return "Blue Slate"
                case .spaceLightGreen:
                    return "Space Light Green"
                case .flower:
                    return "Flower"
                case .elateTheEuge:
                    return "Elate The Euge"
                case .peachSea:
                    return "Peach Sea"
                case .abbas:
                    return "Abbas"
                case .winterWoods:
                    return "Winter Woods"
                case .ameena:
                    return "Ameena"
                case .emeraldSea:
                    return "Emerald Sea"
                case .bleem:
                    return "Bleem"
                case .coffeeGold:
                    return "Coffee Gold"
                case .compass:
                    return "Compass"
                case .andreuzzas:
                    return "Andreuzza's"
                case .moonwalker:
                    return "Moonwalker"
                case .whinehouse:
                    return "Whinehouse"
                case .hyperBlue:
                    return "Hyper Blue"
                case .racker:
                    return "Racker"
                case .aftertheRain:
                    return "After the Rain"
                case .neonGreen:
                    return "Neon Green"
                case .dustyGrass:
                    return "Dusty Grass"
                case .visualBlue:
                    return "Visual Blue"
                }
            }
        }
    }

#endif
