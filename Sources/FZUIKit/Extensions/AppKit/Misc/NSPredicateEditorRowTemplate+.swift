//
//  NSPredicateEditorRowTemplate+.swift
//
//
//  Created by Florian Zand on 25.01.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSPredicateEditorRowTemplate {
    /// A row template that displays a seperator.
    public static func seperator() -> NSPredicateEditorRowTemplate {
        return SeparatorPredicateEditorRowTemplate()
    }
    
    /// The predicate of the row template.
    @objc open var predicate: NSPredicate {
        predicate(withSubpredicates: nil)
    }
    
    /// The initial value of the row template. The default value is `nil`.
    public var initialValue: Any? {
        get { getAssociatedValue("initialValue", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "initialValue") }
    }
    
    /**
     Initializes and returns a “pop-up-pop-up-pop-up”–style row template.

     - Parameters:
        - leftExpressions: An array of `NSExpression` objects that represent the left side of a predicate.
        - rightExpressions: An array of `NSExpression` objects that represent the right side of a predicate.
        - modifier: A modifier for the predicate. The default value is `direct`.
        - operators: Operators for the predicate.
        - options: Options for the predicate. The default value is `[]`.
        - initialValue:The initial value of the row. The default value is `nil`.
     
     - Returns: A row template of the “pop-up-pop-up-pop-up” form, with the left and right pop-ups representing the left and right expression arrays `leftExpressions` and `rightExpressions`, and the center pop-up representing the operators.
     */
    public convenience init(
        leftExpressions: [NSExpression],
        rightExpressions: [NSExpression],
        modifier: NSComparisonPredicate.Modifier = .direct,
        operators: [NSComparisonPredicate.Operator],
        options: NSComparisonPredicate.Options = [],
        initialValue: Any? = nil
    ) {
        self.init(leftExpressions: leftExpressions,
                   rightExpressions: rightExpressions,
                   modifier: modifier,
                   operators: operators.compactMap({NSNumber(value: $0.rawValue)}),
                   options: Int(options.rawValue))
        self.initialValue = initialValue
    }
    
    /**
     Initializes and returns a “pop-up-pop-up-pop-up”–style row template.

     - Parameters:
        - leftExpressions: An array of `NSExpression` objects that represent the left side of a predicate.
        - attributeType: An attribute type for the right side of a predicate. This value dictates the type of view created, and how the control’s object value is coerced before putting it into a predicate.
        - modifier: A modifier for the predicate. The default value is `direct`.
        - operators: Operators for the predicate. The default value is `[]`, which uses operators depending on the specified attribute type.
        - options: Options for the predicate. The default value is `[]`.
        - initialValue:The initial value of the row. The default value is `nil`.
     
     - Returns: A row template initialized using the specified arguments.
     */
    public convenience init(
        leftExpressions: [NSExpression],
        rightExpressionAttributeType attributeType: NSAttributeType,
        modifier: NSComparisonPredicate.Modifier = .direct,
        operators: [NSComparisonPredicate.Operator] = [],
        options: NSComparisonPredicate.Options = [],
        initialValue: Any? = nil
    ) {
        var operators = operators
        if operators == [] {
            switch attributeType {
            case .stringAttributeType, .UUIDAttributeType, .URIAttributeType, .objectIDAttributeType:
                operators = [.matches, .contains, .beginsWith, .endsWith, .equalTo, .notEqualTo]
            case .booleanAttributeType, .transformableAttributeType, .compositeAttributeType, .undefinedAttributeType:
                operators = [.equalTo, .notEqualTo]
            default:
                operators = [.equalTo, .lessThan, .greaterThan, .notEqualTo]
            }
        }
        self.init(leftExpressions: leftExpressions,
                   rightExpressionAttributeType: attributeType,
                   modifier: modifier,
                   operators: operators.compactMap({NSNumber(value: $0.rawValue)}),
                   options: Int(options.rawValue))
        self.initialValue = initialValue
    }
    
    /**
     Initializes and returns a row template suitable for displaying compound predicates.
     
     - Parameters:
        - compoundTypes:The compound predicate types.
        - initialValue:The initial value of the row. The default value is `nil`.
     
     - Returns: A row template initialized for displaying compound predicates of the types specified by `compoundTypes`.
     */
    public convenience init(compoundTypes: [NSCompoundPredicate.LogicalType], initialValue: NSCompoundPredicate.LogicalType? = nil) {
        self.init(compoundTypes: compoundTypes.compactMap({NSNumber(value: $0.rawValue)}))
        self.initialValue = initialValue
    }
    
    /**
     Initializes and returns a row template with constant values.
     
     - Parameters:
        - title: The title of the row.
        - values: The constant values of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
        - operators: The predicate operators of the row. The default value is `[.equalTo, .notEqualTo]`.
     
     - Returns: A row template initialized for displaying compound predicates with constant values.
     */
    public convenience init(constant title: String, values: [Any], initialValue: Any? = nil, operators: [NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo]) {
        self.init(constant: [title], values: values, initialValue: initialValue, operators: operators)
    }
    
    /**
     Initializes and returns a row template with constant values.
     
     - Parameters:
        - titles: The titles of the row.
        - values: The constant values of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
        - operators: The predicate operators of the row. The default value is `[.equalTo, .notEqualTo]`.
     
     - Returns: A row template initialized for displaying compound predicates with constant values.
     */
    public convenience init(constant titles: [String], values: [Any], initialValue: Any? = nil, operators: [NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo]) {
        let leftExpressions = titles.compactMap({NSExpression(forKeyPath: $0)})
        let rightExpressions = values.compactMap({NSExpression(forConstantValue: $0)})
        self.init(leftExpressions: leftExpressions,
                   rightExpressions: rightExpressions,
                   modifier: .direct,
                   operators: operators,
                   options: [])
        self.initialValue = initialValue
    }
    
    /**
     Initializes and returns a row template with string values.
     
     - Parameters:
        - title: The title of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
        - operators: The predicate operators of the row. The default value is `[.matches, .contains, .beginsWith, .endsWith, .equalTo, .notEqualTo]`.
        - options: The preficate options of the row. The default value is `[.caseInsensitive, .diacriticInsensitive]`.
     
     - Returns: A row template initialized for displaying compound predicates with string values.
     */
    public convenience init(string title: String, initialValue: String? = nil, operators: [NSComparisonPredicate.Operator] = [.matches, .contains, .beginsWith, .endsWith, .equalTo, .notEqualTo], options: NSComparisonPredicate.Options = [.caseInsensitive, .diacriticInsensitive]) {
        self.init(title, type: .stringAttributeType, operators: operators, options: options, initialValue: initialValue)
    }
    
    /**
     Initializes and returns a row template with string values.
     
     - Parameters:
        - titles: The titles of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
        - operators: The predicate operators of the row. The default value is `[.matches, .contains, .beginsWith, .endsWith, .equalTo, .notEqualTo]`.
        - options: The preficate options of the row. The default value is `[.caseInsensitive, .diacriticInsensitive]`.
     
     - Returns: A row template initialized for displaying compound predicates with string values.
     */
    public convenience init(string titles: [String], initialValue: String? = nil, operators: [NSComparisonPredicate.Operator] = [.matches, .contains, .beginsWith, .endsWith, .equalTo, .notEqualTo], options: NSComparisonPredicate.Options = [.caseInsensitive, .diacriticInsensitive]) {
        self.init(titles, type: .stringAttributeType, operators: operators, options: options, initialValue: initialValue)
    }
    
    /**
     Initializes and returns a row template with a Boolean value.
     
     - Parameters:
        - title: The title of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
     
     - Returns: A row template initialized for displaying compound predicates with a Boolean value.
     */
    public convenience init(bool title: String, initialValue: Bool? = nil) {
        self.init(constant: title, values: [NSNumber(value: true), NSNumber(value: false)], initialValue: initialValue)
    }
    
    /**
     Initializes and returns a row template with a Boolean value.
     
     - Parameters:
        - titles: The titles of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
     
     - Returns: A row template initialized for displaying compound predicates with a Boolean value.
     */
    public convenience init(bool titles: [String], initialValue: Bool? = nil, operators: [NSComparisonPredicate.Operator] = [.equalTo, .lessThan, .greaterThan, .notEqualTo]) {
        self.init(constant: titles, values: [NSNumber(value: true), NSNumber(value: false)], initialValue: initialValue)
    }
    
    /**
     Initializes and returns a row template with Integer values.
     
     - Parameters:
        - title: The title of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
        - operators: The predicate operators of the row. The default value is `[.equalTo, .lessThan, .greaterThan, .notEqualTo]`.
     
     - Returns: A row template initialized for displaying compound predicates with Integer values.
     */
    public convenience init(integer title: String, initialValue: Int? = nil, operators: [NSComparisonPredicate.Operator] = [.equalTo, .lessThan, .greaterThan, .notEqualTo]) {
        self.init(title, type: .integer16AttributeType, operators: operators, initialValue: initialValue)
    }
    
    /**
     Initializes and returns a row template with Integer values.
     
     - Parameters:
        - titles: The titles of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
        - operators: The predicate operators of the row. The default value is `[.equalTo, .lessThan, .greaterThan, .notEqualTo]`.
     
     - Returns: A row template initialized for displaying compound predicates with Integer values.
     */
    public convenience init(integer titles: [String], initialValue: Int? = nil, operators: [NSComparisonPredicate.Operator] = [.equalTo, .lessThan, .greaterThan, .notEqualTo]) {
        self.init(titles, type: .integer16AttributeType, operators: operators, initialValue: initialValue)
    }
    
    /**
     Initializes and returns a row template with Float values.
     
     - Parameters:
        - title: The title of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
        - operators: The predicate operators of the row. The default value is `[.equalTo, .lessThan, .greaterThan, .notEqualTo]`.
     
     - Returns: A row template initialized for displaying compound predicates with Float values.
     */
    public convenience init(float title: String, initialValue: Float? = nil, operators: [NSComparisonPredicate.Operator] = [.equalTo, .lessThan, .greaterThan, .notEqualTo]) {
        self.init(title, type: .floatAttributeType, operators: operators, initialValue: initialValue)
    }
    
    /**
     Initializes and returns a row template with Float values.
     
     - Parameters:
        - titles: The titles of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
        - operators: The predicate operators of the row. The default value is `[.equalTo, .lessThan, .greaterThan, .notEqualTo]`.
     
     - Returns: A row template initialized for displaying compound predicates with Float values.
     */
    public convenience init(float titles: [String], initialValue: Float? = nil, operators: [NSComparisonPredicate.Operator] = [.equalTo, .lessThan, .greaterThan, .notEqualTo]) {
        self.init(titles, type: .floatAttributeType, operators: operators, initialValue: initialValue)
    }
    
    /**
     Initializes and returns a row template with date values.
     
     - Parameters:
        - title: The title of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
        - operators: The predicate operators of the row. The default value is `[.equalTo, .lessThan, .greaterThan, .notEqualTo]`.
     
     - Returns: A row template initialized for displaying compound predicates with date values.
     */
    public convenience init(date title: String, initialValue: Date? = nil, operators: [NSComparisonPredicate.Operator] = [.equalTo, .lessThan, .greaterThan, .notEqualTo]) {
        self.init(title, type: .dateAttributeType, operators: operators, initialValue: initialValue)
    }
    
    /**
     Initializes and returns a row template with date values.
     
     - Parameters:
        - titles: The titles of the row.
        - initialValue: The initial value of the row. The default value is `nil`.
        - operators: The predicate operators of the row. The default value is `[.equalTo, .lessThan, .greaterThan, .notEqualTo]`.
     
     - Returns: A row template initialized for displaying compound predicates with date values.
     */
    public convenience init(date titles: [String], initialValue: Date? = nil, operators: [NSComparisonPredicate.Operator] = [.equalTo, .lessThan, .greaterThan, .notEqualTo]) {
        self.init(titles, type: .dateAttributeType, operators: operators, initialValue: initialValue)
    }
    
    convenience init(_ title: String, type: NSAttributeType, operators: [NSComparisonPredicate.Operator], modifier: NSComparisonPredicate.Modifier = .direct, options: NSComparisonPredicate.Options = [], initialValue: Any? = nil) {
        self.init([title], type: .dateAttributeType, operators: operators, initialValue: initialValue)
    }
    
    convenience init(_ titles: [String], type: NSAttributeType, operators: [NSComparisonPredicate.Operator], modifier: NSComparisonPredicate.Modifier = .direct, options: NSComparisonPredicate.Options = [], initialValue: Any? = nil) {
        let leftExpressions = titles.compactMap({NSExpression(forKeyPath: $0) })
        self.init(leftExpressions: leftExpressions,
                   rightExpressionAttributeType: type,
                   modifier: modifier,
                   operators: operators,
                  options: options)
        self.initialValue = initialValue
    }
    
    var allSubRowTemplates: [NSPredicateEditorRowTemplate] {
        if let rowTemplate = self as? CompoundPredicateEditorRowTemplate {
            return rowTemplate.subRowTemplates + rowTemplate.subRowTemplates.flatMap({$0.allSubRowTemplates})
        }
        return [self]
    }
}

/// A row template that displays a seperator.
open class SeparatorPredicateEditorRowTemplate: NSPredicateEditorRowTemplate {
    
    private let separatorPopUpButton = {
        let popUpButton = NSPopUpButton()
        popUpButton.menu?.addItem(.separator())
        return popUpButton
    }()

    open override var templateViews: [NSView] {
        return [separatorPopUpButton]
    }

    open override func match(for predicate: NSPredicate) -> Double {
        return 0.0
    }
}

#endif
