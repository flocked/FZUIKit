//
//  UITableView+Handlers.swift
//
//
//  Created by Florian Zand on 08.02.24.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UITableView {
    struct SelectionHandlers {
        var willSelect: ((IndexPath) -> ())?
        var didSelect: ((IndexPath) -> ())?
        var willDeselect: ((IndexPath) -> ())?
        var didDeselect: ((IndexPath) -> ())?
    }
    
    struct HightlightHandlers {
        var shouldHightlight: ((IndexPath) -> (Bool))?
        var didHightlight: ((IndexPath) -> ())?
        var didUnhightlight: ((IndexPath) -> ())?
    }
    
    struct EditingHandlers {
        var willBeginEditing: ((IndexPath) -> ())?
        var didEndEditing: ((IndexPath) -> ())?
    }
    
    struct DisplayingHandler {
        var willDisplay: ((UITableViewCell, IndexPath) -> ())?
        var didEndDisplaying: ((UITableViewCell, IndexPath) -> ())?
        var willDisplayHeader: ((UIView, IndexPath) -> ())?
        var didEndDisplayingHeader: ((UIView, IndexPath) -> ())?
        var willDisplayFooter: ((UIView, IndexPath) -> ())?
        var didEndDisplayingFooter: ((UIView, IndexPath) -> ())?
    }
    
    #if os(iOS)
    struct SwipeActionHandlers {
        var leading: ((IndexPath) -> (UISwipeActionsConfiguration?))?
        var trailing: ((IndexPath) -> (UISwipeActionsConfiguration?))?
    }
    #endif
}
#endif
