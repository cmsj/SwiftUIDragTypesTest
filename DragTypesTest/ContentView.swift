//
//  ContentView.swift
//  DragTypesTest
//
//  Created by Chris Jones on 14/05/2025.
//

import SwiftUI
import UniformTypeIdentifiers

enum DropItem: Transferable {
    case url(URL)
    case data(Data)

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { return DropItem.url($0) }

        DataRepresentation(contentType: UTType.image) { image in
            image.data!
        } importing: { data in
            return DropItem.data(data)
        }
    }

    var url: URL? {
        switch self {
        case .url(let url): return url
        default: return nil
        }
    }

    var data: Data? {
        switch self {
        case .data(let data): return data
        default: return nil
        }
    }
}


struct ContentView: View {
    @State private var onDropListEntries: [String] = []
    @State private var dropDestinationListEntries: [String] = []

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

    func handleOnDrop(_ providers: [NSItemProvider]) -> Bool {
        onDropListEntries = [
            ".onDrop() with \(providers.count) NSItemProviders"
        ]
        for provider in providers {
            let canLoadURL = provider.canLoadObject(ofClass: URL.self)
            let hasURLProvider = provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
            onDropListEntries.append("Is able to be URL: \(canLoadURL)")
            onDropListEntries.append("Has Item Conforming to URL: \(hasURLProvider)")

            onDropListEntries.append("Registered Type Identifiers:")
            onDropListEntries += provider.registeredTypeIdentifiers.map { $0 }

            onDropListEntries.append("Registered Content Types:")
            onDropListEntries += provider.registeredContentTypes.map { $0.identifier }
        }
        return true
    }

    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Rectangle()
                        .fill(.green)
                    Text("Drag a file on me! (.onDrop)")
                }
                .onDrop(of: droppableTypes, isTargeted: nil, perform: { providers, _ in
                    handleOnDrop(providers)
                })
                ZStack {
                    Rectangle()
                        .fill(.blue)
                    Text("Drag a file on me! (.dropDestination)")
                }
                .dropDestination(for: DropItem.self, action: { items, _ in
                    dropDestinationListEntries = [
                        ".dropDestination() with \(items.count) DropItems"
                    ]
                    for item in items {
                        switch item {
                        case .data(let data):
                            dropDestinationListEntries.append("Data length: \(data.count)")
                        case .url(let url):
                            dropDestinationListEntries.append("URL: \(url.absoluteString)")
                        }
                    }
                    return true
                })
            }
            HStack {
                VStack {
                    List(onDropListEntries, id: \.self) { entry in
                        Text(entry)
                    }
                    Grid() {
                        GridRow {
                            Toggle(isOn: $allowFileURL, label: { Text("Allow File URLs") })
                            Toggle(isOn: $allowImage, label: { Text("Allow Images") })
                        }
                        GridRow {
                            Toggle(isOn: $allowData, label: { Text("Allow Data") })
                            Toggle(isOn: $allowPNG, label: { Text("Allow PNGs") })
                        }
                    }
                }
                VStack {
                    List(dropDestinationListEntries, id: \.self) { entry in
                        Text(entry)
                    }
                    Text("(drop types can't be configured dynamically)")
                }
            }

        }
        .padding()

    }
}

#Preview {
    ContentView()
}
