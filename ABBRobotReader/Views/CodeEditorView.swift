import SwiftUI

struct CodeEditorView: View {
    let file: ABBFile
    @State private var selectedModule: ABBModule?
    @State private var selectedRoutine: ABBRoutine?

    var body: some View {
        NavigationView {
            List {
                ForEach(file.modules) { module in
                    Section(header:
                        HStack {
                            Text(module.name)
                                .font(.headline)
                            Spacer()
                            Text(module.type.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    ) {
                        // Declarations
                        if !module.declarations.isEmpty {
                            DisclosureGroup(String(format: NSLocalizedString("module.declarations", comment: ""), module.declarations.count)) {
                                ForEach(module.declarations, id: \.self) { declaration in
                                    Text(declaration)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Routines
                        if !module.routines.isEmpty {
                            DisclosureGroup(String(format: NSLocalizedString("module.routines", comment: ""), module.routines.count)) {
                                ForEach(module.routines) { routine in
                                    Button(action: {
                                        selectedRoutine = routine
                                        selectedModule = module
                                    }) {
                                        HStack {
                                            Image(systemName: "function")
                                                .foregroundColor(.orange)
                                            VStack(alignment: .leading) {
                                                Text(routine.name)
                                                    .font(.body)
                                                Text(routine.type.rawValue)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            if !routine.parameters.isEmpty {
                                                Text(String(format: NSLocalizedString("routine.parameters", comment: ""), routine.parameters.count))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // View full module
                        Button(action: {
                            selectedModule = module
                            selectedRoutine = nil
                        }) {
                            HStack {
                                Image(systemName: "doc.plaintext")
                                Text("module.view.full")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .glassListBackground()
            .background(
                LinearGradient(colors: [.clear, Color.black.opacity(0.1)], startPoint: .top, endPoint: .bottom)
            )
            .navigationTitle(file.name)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedModule) { module in
                RoutineDetailView(
                    content: selectedRoutine?.content ?? module.content,
                    title: selectedRoutine?.name ?? module.name
                )
            }
        }
    }
}

struct RoutineDetailView: View {
    let content: String
    let title: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(SyntaxHighlighter.highlight(content))
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("detail.done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
