//
//  NSPredicateEditor+.swift
//
//
//  Created by Florian Zand on 25.01.24.
//

#if os(macOS)
import AppKit

extension NSPredicateEditor {
    /**
     Creates a predicate editor with the specified row templates.
     
     - Parameter rowTemplates: The row templates.
     */
    public convenience init (rowTemplates: [NSPredicateEditorRowTemplate]) {
        self.init()
        self.rowTemplates = rowTemplates
    }
    
    /**
     Creates a predicate editor with the specified row templates and displays the specified displaying row templates.
     
     By default the row temples are displayed using `||`. You can combine multiple row templates via the operators `&&` and `||`.
     
     Example usage:
     
     ```swift
     let countryRowTemplate = NSPredicateEditorRowTemplate(constant: "Country", values: ["United States","Mexico"])
     let ageRowTemplate = NSPredicateEditorRowTemplate(integer: ["Age"])
     let nameRowTemplate = NSPredicateEditorRowTemplate(string: ["Name", "lastName"])

     let predicateEditor = NSPredicateEditor(rowTemplates: [ageRowTemplate, countryRowTemplate, nameRowTemplate], displayingRowTemplates: {
        (countryRowTemplate && nameRowTemplate) || nameRowTemplate
     })
     ```
     
     - Parameters
        - rowTemplates: The row templates.
        - displayingRowTemplates: The row templates to display.
     */
    public convenience init (rowTemplates: [NSPredicateEditorRowTemplate], @RowTemplateBuilder displayingRowTemplates: () -> [NSPredicateEditorRowTemplate]) {
        self.init()
        self.rowTemplates = rowTemplates
        self.displayRowTemplates(displayingRowTemplates)
    }
    
    /**
     Displays the specified row templates.
     
     By default the row temples are displayed using `||`. You can combine multiple row templates via the operators `&&` and `||`.
     
     Example usage:
     
     ```swift
     let countryRowTemplate = NSPredicateEditorRowTemplate(constant: "Country", values: ["United States","Mexico"])
     let ageRowTemplate = NSPredicateEditorRowTemplate(integer: ["Age"])
     let nameRowTemplate = NSPredicateEditorRowTemplate(string: ["Name", "lastName"])

     predicateEditor.displayRowTemplates() {
         (countryRowTemplate && nameRowTemplate) || nameRowTemplate
     }
     ```
     
     - Parameter rowTemplates: The rowTemplates to display.
     */
    public func displayRowTemplates(@RowTemplateBuilder _ rowTemplates: () -> [NSPredicateEditorRowTemplate]) {
        let rowTemplates = rowTemplates()
        
        let allRowTemplates = rowTemplates.flatMap({$0.allSubRowTemplates}).filter({self.rowTemplates.contains($0) == false})
        self.rowTemplates.append(contentsOf: allRowTemplates)
        
        let predicates = rowTemplates.compactMap({$0.predicate})
        if predicates.count == 1 {
            objectValue = predicates.first
        } else if predicates.count > 1 {
            objectValue = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        } else {
            objectValue = nil
        }
    }
    
    /// A function builder type for building the displayed row templates.
    @resultBuilder
    public enum RowTemplateBuilder {
        public static func buildBlock(_ block: [NSPredicateEditorRowTemplate]...) -> [NSPredicateEditorRowTemplate] {
            block.flatMap { $0 }
        }

        public static func buildArray(_ components: [[NSPredicateEditorRowTemplate]]) -> [NSPredicateEditorRowTemplate] {
            components.flatMap { $0 }
        }
        
        public static func buildExpression(_ expr: [NSPredicateEditorRowTemplate]?) -> [NSPredicateEditorRowTemplate] {
           return expr ?? []
        }

        public static func buildExpression(_ expr: NSPredicateEditorRowTemplate?) -> [NSPredicateEditorRowTemplate] {
            expr.map { [$0] } ?? []
        }
    }
}

extension NSPredicateEditorRowTemplate {
    public static func && (lhs: NSPredicateEditorRowTemplate, rhs: NSPredicateEditorRowTemplate) -> NSPredicateEditorRowTemplate {
        CompoundPredicateEditorRowTemplate(and: [lhs, rhs])
    }
    
    public static func || (lhs: NSPredicateEditorRowTemplate, rhs: NSPredicateEditorRowTemplate) -> NSPredicateEditorRowTemplate {
        CompoundPredicateEditorRowTemplate(or: [lhs, rhs])
    }
}

class CompoundPredicateEditorRowTemplate: NSPredicateEditorRowTemplate {
    let type: NSCompoundPredicate.LogicalType
    let subRowTemplates: [NSPredicateEditorRowTemplate]
    
    init(and subRowTemplates: [NSPredicateEditorRowTemplate]) {
        self.type = .and
        self.subRowTemplates = subRowTemplates
        super.init()
    }
    
    init(or subRowTemplates: [NSPredicateEditorRowTemplate]) {
        self.type = .or
        self.subRowTemplates = subRowTemplates
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var predicate: NSPredicate {
        NSCompoundPredicate(type: type, subpredicates: subRowTemplates.compactMap({$0.predicate}))
    }
}

#endif
