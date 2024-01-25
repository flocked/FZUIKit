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
     
     - Parameters
        - rowTemplates: The row templates.
        - displayingRowTemplates: The row templates to display.
     */
    public convenience init (rowTemplates: [NSPredicateEditorRowTemplate], @PredicateBuilder displayingRowTemplates: () -> [NSPredicate]) {
        self.init()
        self.rowTemplates = rowTemplates
        self.displayRowTemplates(displayingRowTemplates)
    }
    
    
    /**
     Displays the specified row templates.
     
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
    public func displayRowTemplates(@PredicateBuilder _ rowTemplates: () -> [NSPredicate]) {
        let predicates = rowTemplates()
        if predicates.count == 1 {
            objectValue = predicates.first
        } else if predicates.count > 1 {
            objectValue = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        } else {
            objectValue = nil
        }
    }
    
    /// A function builder type for building the displayed row templates.
    @resultBuilder
    public enum PredicateBuilder {
        public static func buildBlock(_ block: [NSPredicate]...) -> [NSPredicate] {
            block.flatMap { $0 }
        }

        public static func buildArray(_ components: [[NSPredicate]]) -> [NSPredicate] {
            components.flatMap { $0 }
        }

        
        public static func buildExpression(_ expr: [NSPredicate]?) -> [NSPredicate] {
           return expr ?? []
        }

        public static func buildExpression(_ expr: NSPredicate?) -> [NSPredicate] {
            expr.map { [$0] } ?? []
        }
        
        public static func buildExpression(_ expr: [NSPredicateEditorRowTemplate]?) -> [NSPredicate] {
            expr?.compactMap({$0.predicate}) ?? []
        }

        public static func buildExpression(_ expr: NSPredicateEditorRowTemplate?) -> [NSPredicate] {
            expr.map { [$0.predicate] } ?? []
        }
    }
}


extension NSPredicateEditorRowTemplate {
    public static func && (lhs: NSPredicateEditorRowTemplate, rhs: NSPredicateEditorRowTemplate) -> NSPredicate {
        NSCompoundPredicate(type: .and, subpredicates: [lhs.predicate, rhs.predicate])
    }
    
    public static func || (lhs: NSPredicateEditorRowTemplate, rhs: NSPredicateEditorRowTemplate) -> NSPredicate {
        NSCompoundPredicate(type: .or, subpredicates: [lhs.predicate, rhs.predicate])
    }
}

extension NSPredicate {
    public static func && (lhs: NSPredicate, rhs: NSPredicateEditorRowTemplate) -> NSPredicate {
        NSCompoundPredicate(type: .and, subpredicates: [lhs, rhs.predicate])
    }
    
    public static func || (lhs: NSPredicate, rhs: NSPredicateEditorRowTemplate) -> NSPredicate {
        NSCompoundPredicate(type: .or, subpredicates: [lhs, rhs.predicate])
    }
    
    public static func && (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
        NSCompoundPredicate(type: .and, subpredicates: [lhs, rhs])
    }
    
    public static func || (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
        NSCompoundPredicate(type: .or, subpredicates: [lhs, rhs])
    }
}

#endif

/*
public static func buildOptional(_ item: [NSPredicate]?) -> [NSPredicate] {
    item ?? []
}

public static func buildEither(first: [NSPredicate]?) -> [NSPredicate] {
    first ?? []
}

public static func buildEither(second: [NSPredicate]?) -> [NSPredicate] {
    second ?? []
}
*/
