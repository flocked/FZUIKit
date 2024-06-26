//
//  LaunchAtLogin.swift
//
//  Parts taken from:
//  Copyright (c) Sindre Sorhus
//
//  Created by Florian Zand on 18.04.24.
//

#if os(macOS) || targetEnvironment(macCatalyst)
import SwiftUI
import ServiceManagement
import AppKit

@available(macOS 13.0, *)
public enum LaunchAtLogin {
	/// A Boolean value that indicates whether the app automatically launches at login.
	public static var isEnabled: Bool {
		get { SMAppService.mainApp.status == .enabled }
		set {
			observable.objectWillChange.send()

			do {
				if newValue {
					if SMAppService.mainApp.status == .enabled {
						try? SMAppService.mainApp.unregister()
					}

					try SMAppService.mainApp.register()
				} else {
					try SMAppService.mainApp.unregister()
				}
			} catch {
                debugPrint("Failed to \(newValue ? "enable" : "disable") launch at login: \(error.localizedDescription)")
			}
		}
	}

	/**
     A Boolean value that indicates whether the app was launchedx at login.

	- Important: This property must only be checked in `NSApplicationDelegate#applicationDidFinishLaunching`.
	*/
	public static var wasLaunchedAtLogin: Bool {
		let event = NSAppleEventManager.shared().currentAppleEvent
		return event?.eventID == kAEOpenApplication
			&& event?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
	}
    
    /// Returns the localized string of "Launch at Login" for the specified language, or English if no translation for the language could be found..
    public static func localizedString(for locale: Locale = .current) -> String {
        guard let languageCode = locale.language.languageCode?.identifier else { return launchAtLoginTranslations["en"]! }
        return launchAtLoginTranslations[languageCode] ?? launchAtLoginTranslations["en"]!
    }
    
    /// Returns a checbox button for the specified language that toggles “launch at login” for your app.
    public static func checkboxButton(for locale: Locale = .current) -> NSButton {
        let button = NSButton(checkboxWithTitle: localizedString(for: locale), target: nil, action: nil).state(isEnabled ? .on : .off)
        button.actionBlock = { button in
            self.isEnabled = button.state == .off ? false : true
            button.state = self.isEnabled ? .on : .off
        }
        return button
    }
    
    fileprivate static let observable = Observable()
    
    fileprivate static let launchAtLoginTranslations: [String: String] = [
        "en": "Launch At Login",            // English
        "es": "Iniciar al Iniciar Sesión",  // Spanish
        "fr": "Lancer à la Connexion",      // French
        "de": "Beim Anmelden Starten",      // German
        "zh": "登录时启动",                  // Chinese (Simplified)
        "ja": "ログイン時に起動",            // Japanese
        "ko": "로그인 시 실행",              // Korean
        "it": "Avvia al Login",             // Italian
        "pt": "Iniciar ao Login",           // Portuguese
        "ru": "Запуск при Входе",           // Russian
        "ar": "تشغيل عند تسجيل الدخول",      // Arabic
        "nl": "Starten bij Inloggen",       // Dutch
        "sv": "Starta vid Inloggning",      // Swedish
        "da": "Start ved Login",            // Danish
        "nb": "Start ved Innlogging",       // Norwegian (Bokmål)
        "fi": "Käynnistä Kirjautuessa",     // Finnish
        "tr": "Girişte Başlat"              // Turkish
    ]
}

@available(macOS 13.0, *)
extension LaunchAtLogin {
	final class Observable: ObservableObject {
		var isEnabled: Bool {
			get { LaunchAtLogin.isEnabled }
			set {
				LaunchAtLogin.isEnabled = newValue
			}
		}
	}
}

@available(macOS 13.0, *)
extension LaunchAtLogin {
	/**
	A `Toggle` view with a predefined binding and label that toggles “launch at login” for your app.

	```
	struct ContentView: View {
		var body: some View {
			LaunchAtLogin.Toggle()
		}
	}
	```

	The default label tries to find a tanslation of `"Launch at login"` for the current language of the app, or english if no translation for the current language could be found.. It can be overridden for localization and other needs:

	```
	struct ContentView: View {
		var body: some View {
			LaunchAtLogin.Toggle {
				Text("Launch at login")
			}
		}
	}
	```
	*/
	public struct Toggle<Label: View>: View {
		@ObservedObject private var launchAtLogin = LaunchAtLogin.observable
		private let label: Label

		/**
		Creates a toggle that displays a custom label.

		- Parameters:
			- label: A view that describes the purpose of the toggle.
		*/
		public init(@ViewBuilder label: () -> Label) {
			self.label = label()
		}

		public var body: some View {
			SwiftUI.Toggle(isOn: $launchAtLogin.isEnabled) { label }
		}
	}
}

@available(macOS 13.0, *)
extension LaunchAtLogin.Toggle<Text> {
	/**
	Creates a toggle that generates its label from a localized string key.

	This initializer creates a ``Text`` view on your behalf with the provided `titleKey`.

	- Parameters:
		- titleKey: The key for the toggle's localized title, that describes the purpose of the toggle.
	*/
	public init(_ titleKey: LocalizedStringKey) {
		label = Text(titleKey)
	}

	/**
	Creates a toggle that generates its label from a string.

	This initializer creates a `Text` view on your behalf with the provided `title`.

	- Parameters:
		- title: A string that describes the purpose of the toggle.
	*/
	public init(_ title: some StringProtocol) {
		label = Text(title)
	}

	/// Creates a toggle with the default title of `Launch at login`.
	public init() {
		self.init(LaunchAtLogin.localizedString())
	}
}
#endif
