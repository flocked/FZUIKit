//
//  WKWebView+HTML.swift
//  
//
//  Created by Florian Zand on 17.04.25.
//

#if os(macOS) || os(iOS)
import FZSwiftUtils
import WebKit

extension WKWebView {
    /// The HTML of the current website.
    public var html: HTML {
        HTML(self)
    }
    
    /// The HTML of the current website of a webview.
    public class HTML {
        private weak var webView: WKWebView?

        /**
         Returns the html string of the current website to the specified completion block.
         
         - Parameter completion: The handler that returns the html string, or `nil` if no html string is available.
         */
        public func string(completion: @escaping (_ htmlString: String?) -> Void) {
            evalute("document.body.innerHTML", completion: completion)
        }
                
        /// The element with the specified identifier.
        public func element(id: String) -> Element {
            Element(self, id: id)
        }
        
        /// The element with the specified name.
        public func element(name: String) -> Element {
            Element(self, name: name)
        }
        
        /// The button with the specified identifier.
        public func button(id: String) -> Button {
            Button(self, id: id)
        }
        
        /// The name with the specified name.
        public func button(name: String) -> Button {
            Button(self, name: name)
        }
        
        /// The button with the specified identifier.
        public func input(id: String) -> Input {
            Input(self, id: id)
        }
        
        /// The name with the specified name.
        public func input(name: String) -> Input {
            Input(self, name: name)
        }
        
        private func evalute<ReturnType>(_ js: String, completion: @escaping (ReturnType?) -> Void) {
            guard let webView = webView else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                webView.evaluateJavaScript(js) { result, _ in
                    DispatchQueue.main.async {
                        completion(result as? ReturnType)
                    }
                }
            }
        }
        
        private func evalute(_ js: String, completion: @escaping (Bool) -> Void) {
            guard let webView = webView else {
                completion(false)
                return
            }
            DispatchQueue.main.async {
                webView.evaluateJavaScript(js) { result, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error setting value: \(error)")
                            completion(false)
                        } else {
                            completion((result as? Bool) ?? (result as? NSNumber)?.safeBoolValue ?? false)
                        }
                    }
                }
            }
        }
        
        init(_ webView: WKWebView) {
            self.webView = webView
        }
    }
}

extension WKWebView.HTML {
    /// A HTML element.
    public class Element {
        let interaction: WKWebView.HTML
        let value: String
        let valueString: String
        
        /// The attribute with the specified name.
        public func attribute(_ name: String) -> Attribute {
            Attribute(self, name: name)
        }
        
        /**
         Returns the value of the element to the specified completion block.
         
         - Parameter completion: The handler that returns the value, or `nil` if the element doesn't exist or the value is `nil`.
         */
        public func value(completion: @escaping (_ value: String?) -> Void) {
            let script = """
            var element = \(valueString)[0];
            if (element) {
                element.value;
            } else {
                null;
            }
            """
            interaction.evalute(script, completion: completion)
        }
    
        /**
         Sets the value of the element.
         
         - Parameter completion: The handler that returns a Boolean value indiciating whether the value was set.
         */
        public func setValue(_ value: String, completion: @escaping (_ didSet: Bool) -> Void) {
            guard let value = value.jsEscaped else {
                completion(false)
                return
            }
            let script = """
            var element = \(valueString)[0];
            if (element) {
                element.value = '\(value)';
                true;
            } else {
                false;
            }
            """
            interaction.evalute(script, completion: completion)
        }
        
        /**
         Returns the text content of the element to the specified completion block.
         
         - Parameter completion: The handler that returns the text, or `nil` if the element doesn't contain text or doesn't exist.
         */
        func textContent(completion: @escaping (_ text: String?) -> Void) {
            let script = """
            var element = \(valueString)[0];
            if (element) {
                element.textContent;
            } else {
                null;
            }
            """
            interaction.evalute(script, completion: completion)
        }
        
        /**
         Sets the text content of the element.
         
         - Parameter completion: The handler that returns a Boolean value indiciating whether the text was set.
         */
        public func setTextContent(_ textContent: String, completion: @escaping (_ didSet: Bool) -> Void) {
            guard let textContent = textContent.jsEscaped else {
                completion(false)
                return
            }
            
            let script = """
            var element = \(valueString)[0];
            if (element) {
                element.textContent = '\(textContent)';
                true;
            } else {
                false;
            }
            """
            interaction.evalute(script, completion: completion)
        }
        
        init(_ interaction: WKWebView.HTML, id: String) {
            value = id
            valueString = "document.getElementById('\(id)')"
            self.interaction = interaction
        }
        
        init(_ interaction: WKWebView.HTML, name: String) {
            value = name
            valueString = "document.getElementsByName('\(name)')"
            self.interaction = interaction
        }
    }
}

extension WKWebView.HTML {
    /// A button HTML element.
    public class Button: Element {
        /// Presses the button.
        public func press(completion: @escaping (_ didPress: Bool) -> Void) {
            let script = """
            var element = \(valueString)[0];
            if (element && element.tagName === 'BUTTON') {
                element.click();
                true;
            } else {
                false;
            }
            """
            interaction.evalute(script, completion: completion)
        }
    }
    
    /// An input HTML element.
    public class Input: Element {
        /**
         Sets the value of the attribute.
         
         - Parameters:
            - input: The input to set.
            - pressEnter: A Boolean value indicating whether to press enter enter after setting the input value.
            - completion: The handler that returns a Boolean value indiciating whether the value was set.
         */
        public func setValue(_ value: String, pressEnter: Bool, completion: @escaping (_ didSet: Bool) -> Void) {
             let valueJS = value.jsEscaped ?? value
             let pressEnterJS = pressEnter ? "true" : "false"
             let script = """
             (() => {
               const value = \(valueJS);
               const pressEnter = \(pressEnterJS);

                var el = \(valueString)[0];
                if (!el) return false;

               if (!(el instanceof HTMLInputElement)) return false;

               // Native setter (more reliable with frameworks like React).
               const proto = Object.getPrototypeOf(el);
               const desc =
                   Object.getOwnPropertyDescriptor(proto, "value") ||
                   Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, "value");
               const setter = desc && desc.set;
               if (!setter) return false;

               el.focus();
               setter.call(el, value);

               // Notify listeners/frameworks.
               el.dispatchEvent(new Event("input",  { bubbles: true }));
               el.dispatchEvent(new Event("change", { bubbles: true }));

               if (pressEnter) {
                 // Prefer actual form submission over synthetic key events.
                 if (el.form) {
                   if (typeof el.form.requestSubmit === "function") {
                     el.form.requestSubmit();
                   } else if (typeof el.form.submit === "function") {
                     el.form.submit();
                   }
                 } else {
                   const keyInit = { key: "Enter", code: "Enter", keyCode: 13, which: 13, bubbles: true, cancelable: true };
                   el.dispatchEvent(new KeyboardEvent("keydown", keyInit));
                   el.dispatchEvent(new KeyboardEvent("keypress", keyInit));
                   el.dispatchEvent(new KeyboardEvent("keyup", keyInit));
                 }
               }

               el.blur();
               return true;
             })();
             """
            interaction.evalute(script, completion: completion)
         }
    }

    /// A checkbox HTML element.
    public class Checkbox: Element {
        /**
         Returns the state of the checkbox to the specified completion block.
         
         - Parameter completion: The handler that returns the state of the checkbox, or `nil` if the checkbox doesn't exist.
         */
        func state(completion: @escaping (_ state: Bool?) -> Void) {
            let script = """
            var element = \(valueString)[0];
            if (element && element.type === 'checkbox') {
                element.checked;
            } else {
                null;
            }
            """
            interaction.evalute(script, completion: completion)
        }
        
        /**
         Sets the state of the checkbox.
         
         - Parameter completion: The handler that returns a Boolean value indiciating whether the state was set.
         */
        func setState(_ checked: Bool, completion: @escaping (_ didSetState: Bool) -> Void) {
            let script = """
            var element = \(valueString)[0];
            if (element && element.type === 'checkbox') {
                element.checked = \(checked);
                true;
            } else {
                false;
            }
            """
            interaction.evalute(script, completion: completion)
        }
    }
}

extension WKWebView.HTML.Element {
    /// A HTML attribute.
    public class Attribute {
        let name: String
        let element: WKWebView.HTML.Element
        
        /**
         Returns the value of the attribute to the specified completion block.
         
         - Parameter completion: The handler that returns the value, or `nil` if the attribute doesn't exist.
         */
        public func value(completion: @escaping (_ value: String?) -> Void) {
            let script = """
            var element = \(element.valueString)[0];
            if (element) {
                element.getAttribute('\(name)');
            } else {
                null;
            }
            """
            element.interaction.evalute(script, completion: completion)
        }
        
        /**
         Sets the value of the attribute.
         
         - Parameters:
            - input: The input to set.
            - completion: The handler that returns a Boolean value indiciating whether the value was set.
         */
        public func setValue(_ value: String, completion: @escaping (_ didSetValue: Bool) -> Void) {
            guard let value = value.jsEscaped else {
                completion(false)
                return
            }
            let script = """
            var element = \(element.valueString)[0];
            if (element) {
                element.setAttribute('\(name)', '\(value)');
                true;
            } else {
                false;
            }
            """
            element.interaction.evalute(script, completion: completion)
        }
        
        init(_  element: WKWebView.HTML.Element, name: String) {
            self.name = name
            self.element = element
        }
    }
}

fileprivate extension String {
    var jsEscaped: String? {
        if let escapedText = try? JSONEncoder().encode(self), let textJS = String(data: escapedText, encoding: .utf8) {
            return textJS
        }
        return nil
    }
}

#endif
