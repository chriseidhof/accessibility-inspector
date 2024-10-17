//

import SwiftUI
import CoreServices

struct ContentView: View {
    @State var myValue = 0
    @State var element: AXUIElement? = nil
    var body: some View {
        VSplitView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                HStack {
                    Button("Test") {
                        print("Test button")
                    }
                }
                Stepper(value: $myValue, label: { Text("My Stepper: \(myValue)")})
            }
            .overlay {
                Text("Overlay text")
            }
            .padding()
            .frame(maxWidth: .infinity)
            List(element == nil ? [] : [element!], children: \.children) { element in
                VStack(alignment: .leading) {
                    HStack {
                        ForEach(element.actionNames, id: \.self) { name in
                            Button(name) {
                                element.perform(action: name)
                            }
                        }
                    }
                    ForEach(element.descriptionKeysAndValues, id: \.key) { (key, value) in
                        LabeledContent(key) {
                            if let v = value as? String {
                                Text(verbatim: v)
                                    .monospaced()
                                    .foregroundStyle(Color.accentColor)
                            } else {
                                Text(verbatim: "\(value)")
                                    .monospaced()
                            }
                        }
                    }
                }
                .fixedSize()
            }
//            .listStyle(.sidebar)
            .accessibilityHidden(true)
        }
        .onAppear() {
            element = test()
        }
//        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ContentView()
}
