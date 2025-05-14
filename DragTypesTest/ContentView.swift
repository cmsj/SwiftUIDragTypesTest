//
//  ContentView.swift
//  DragTypesTest
//
//  Created by Chris Jones on 14/05/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var listEntries: [String] = []
    @State private var allowFileURL: Bool = true
    @State private var allowImage: Bool = true
    @State private var allowData: Bool = true
    @State private var allowPNG: Bool = true

    private var droppableTypes: [UTType] {
        get {
            var types: [UTType] = []
            if allowFileURL { types.append(.fileURL) }
            if allowImage { types.append(.image) }
            if allowData { types.append(.data) }
            if allowPNG { types.append(.png) }
            return types
        }
    }

    var body: some View {
        VStack {
            Text("Drag a file on me!")
            List(listEntries, id: \.self) { type in
                Text(type)
            }
            Toggle(isOn: $allowFileURL, label: { Text("Allow File URLs") })
            Toggle(isOn: $allowImage, label: { Text("Allow Images") })
            Toggle(isOn: $allowData, label: { Text("Allow Data") })
            Toggle(isOn: $allowPNG, label: { Text("Allow PNGs") })
        }
        .padding()
        .onDrop(of: droppableTypes, isTargeted: nil, perform: { providers, _ in
            listEntries = [
                "Drop with \(providers.count) items"
            ]
            for provider in providers {
                let canLoadURL = provider.canLoadObject(ofClass: URL.self)
                let hasURLProvider = provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
                listEntries.append("Is able to be URL: \(canLoadURL)")
                listEntries.append("Has Item Conforming to URL: \(hasURLProvider)")

                listEntries.append("Registered Type Identifiers:")
                listEntries += provider.registeredTypeIdentifiers.map { $0 }

                listEntries.append("Registered Content Types:")
                listEntries += provider.registeredContentTypes.map { $0.identifier }
            }
            return true
        })
    }
}

#Preview {
    ContentView()
}
