//

import Foundation
import ApplicationServices

func test() -> AXUIElement? {
    let systemWideElement = AXUIElementCreateSystemWide()
    var focusedElement: AXUIElement?
    var focusedElementAny: AnyObject? {
        get { focusedElement }
        set { focusedElement = newValue.map { $0 as! AXUIElement } }
    }
    AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElementAny)
    return focusedElement
//    if let e = focusedElement {
//        printTree(node: e, children: \.children) { $0.description }
//    }

}

extension AXUIElement {
    func stringAttribute(_ attribute: String) -> String? {
        var value: CFTypeRef?
        AXUIElementCopyAttributeValue(self, attribute as CFString, &value)
        return value as? String
    }

    var title: String? { stringAttribute(kAXTitleAttribute) }
    var role: String? { stringAttribute(kAXRoleAttribute) }
    var value: String? { stringAttribute(kAXValueAttribute) }


    var attributeNames: [String] {
        var names: CFArray?
        AXUIElementCopyAttributeNames(self, &names)
        return (names as? [String]) ?? []

    }

    var children: [AXUIElement]? {
        var children: AnyObject?
        AXUIElementCopyAttributeValue(self, kAXChildrenAttribute as CFString, &children)
        let result = children as? [AXUIElement]
        return result?.count == 0 ? nil : result
    }

    func perform(action name: String) {
        AXUIElementPerformAction(self, name as CFString)
    }

    var actionNames: [String] {
        var names: CFArray?
        AXUIElementCopyActionNames(self, &names)
        return Array(Set((names as? [String]) ?? []))
    }

    func debugStringAttribute(_ attribute: String) -> Any {
        var value: CFTypeRef?
        AXUIElementCopyAttributeValue(self, attribute as CFString, &value)
        if value == nil { return "nil" }
        let typeID = CFGetTypeID(value)
        if typeID == CFStringGetTypeID() {
            return value as! String
        } else if typeID == CFArrayGetTypeID() {
            return value as! [Any]
        } else if typeID == CFBooleanGetTypeID() {
            return value as! Bool
        } else if typeID == CFNumberGetTypeID() {
            return (value as! CFNumber) as NSNumber
        } else if typeID == CFAttributedStringGetTypeID() {
            return ((value as! CFAttributedString) as NSAttributedString).string
        }
        let descr = CFCopyTypeIDDescription(typeID) as String
        if descr == "AXValue" {
            return (value as! AXValue)
        }
        return "Unknown: \(descr)"
    }

    var descriptionKeysAndValues: [(key: String, value: Any)] {
        let excluded: Set<String> = [kAXChildrenAttribute, kAXParentAttribute]
        return attributeNames.filter {
            !excluded.contains($0)
        }.map {
            (key: $0, value: debugStringAttribute($0))
        }
    }

    var description: String {
        var result: [String] = []
        let names = attributeNames
        for n in names {
            if n == kAXParentAttribute  || n == kAXChildrenAttribute { continue }
            if let str = stringAttribute(n) {
                result.append("\(n): \(str)")
            } else {
                result.append("\(n): \(debugStringAttribute(n))")
            }

        }
//        if let t = title { result.append("title: \(t)") }
//        if let r = role { result.append("role: \(r)") }
//        if let v = value { result.append("value: \(v)") }
//        result.append("names: \(attributeNames)")

        return result.joined(separator: "\n")
    }
}

extension AXUIElement: @retroactive Identifiable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

func printTree<T>(node: T, children childrenFn: (T) -> [T]?, indent: String = "", getValueString: (T) -> String) {
    // Get the string for the current node's value and split it into lines
    let valueString = getValueString(node)
    let valueLines = valueString.split(separator: "\n", omittingEmptySubsequences: false)

    // Print each line with the current level's indentation
    for (index, line) in valueLines.enumerated() {
        if index == 0 {
            // Print the first line with the current indentation
            print(indent + String(line))
        } else {
            // For subsequent lines of the value, indent further
            print(indent + "    " + String(line))
        }
    }

    // Recursively print the children, with an extra level of indentation
    if let children = childrenFn(node) {
        for child in children {
            printTree(node: child, children: childrenFn, indent: indent + "    ", getValueString: getValueString)
        }
    }
}
