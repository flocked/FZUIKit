//
//  HTTPCookie+.swift
//  FZUIKit
//
//  Created by Florian Zand on 13.11.25.
//

#if os(macOS) || os(iOS)
import WebKit

extension HTTPCookiePropertyKey: Swift.Codable { }

extension HTTPCookie: Swift.Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode((properties ?? [:]).mapValues({"\($0)"}))
    }
}

extension Decodable where Self: HTTPCookie {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let properties: [HTTPCookiePropertyKey: String] = try container.decode()
        guard let cookie = HTTPCookie(properties: properties) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid cookie properties")
        }
        self = cookie as! Self
    }
}

public extension Sequence where Element == HTTPCookie {
    /**
     Converts the cookie array into the Netscape HTTP Cookie File format.

     The output matches the format used by browsers and tools such as `curl` and `wget`.

     Example output:
     ```
     # Netscape HTTP Cookie File
     # https://curl.haxx.se/rfc/cookie_spec.html
     # This is a generated file! Do not edit.

     .example.com    TRUE    /    FALSE    1672531199    sessionid    abcd1234
     ```
     - Returns: A `String` containing all cookies in Netscape format.
     */
    func netscapeString() -> String {
        var output = "# Netscape HTTP Cookie File\n"
        output += "# https://curl.haxx.se/rfc/cookie_spec.html\n"
        output += "# This is a generated file! Do not edit.\n"
        output += "\n"

        for cookie in self {
            // Ensure the domain begins with a dot for subdomains
            let domain = cookie.domain.hasPrefix(".") ? cookie.domain : ".\(cookie.domain)"
            let includeSubdomains = domain.hasPrefix(".") ? "TRUE" : "FALSE"
            let path = cookie.path
            let secure = cookie.isSecure ? "TRUE" : "FALSE"
            let expires = Int(cookie.expiresDate?.timeIntervalSince1970 ?? 0)

            // Follow standard tab-separated field order
            output += "\(domain)\t\(includeSubdomains)\t\(path)\t\(secure)\t\(expires)\t\(cookie.name)\t\(cookie.value)\n"
        }

        return output
    }

    /**
     Converts the cookie array into a pretty-printed JSON string.

     Each cookie is represented as a dictionary with keys: `name`, `value`, `domain`, `path`, `secure`, `expires`

     Example output:
     ```json
     [
       {
         "name": "sessionid",
         "value": "abcd1234",
         "domain": ".example.com",
         "path": "/",
         "secure": false,
         "expires": 1672531199
       }
     ]
     ```
     - Returns: A JSON-formatted `String` representing the cookies.
     */
    func jsonString() -> String {
        let array = self.map { cookie in
            [
                "name": cookie.name,
                "value": cookie.value,
                "domain": cookie.domain,
                "path": cookie.path,
                "secure": cookie.isSecure,
                "expires": Int(cookie.expiresDate?.timeIntervalSince1970 ?? 0)
            ] as [String: Any]
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted])
            return String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            return "[]"
        }
    }
}

#endif
