import SwiftUI

struct CodeEditorView: View {
    let file: ABBFile
    @State private var selectedModule: ABBModule?
    @State private var selectedRoutine: ABBRoutine?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()

                List {
                    ForEach(file.modules) { module in
                        Section(header: moduleHeader(for: module)) {
                            // Declarations
                            if !module.declarations.isEmpty {
                                DisclosureGroup(
                                    String(
                                        format: NSLocalizedString("declarations_format", comment: ""),
                                        module.declarations.count
                                    )
                                ) {
                                    ForEach(module.declarations, id: \.self) { declaration in
                                        Text(declaration)
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }

                            // Routines
                            if !module.routines.isEmpty {
                                DisclosureGroup(
                                    String(
                                        format: NSLocalizedString("routines_format", comment: ""),
                                        module.routines.count
                                    )
                                ) {
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
                                                    Text(
                                                        String(
                                                            format: NSLocalizedString("parameters_format", comment: ""),
                                                            routine.parameters.count
                                                        )
                                                    )
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
                                    Text(NSLocalizedString("view_full_module", comment: ""))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .listRowBackground(.thinMaterial)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(file.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Label(NSLocalizedString("close_action", comment: ""), systemImage: "xmark")
                    }
                }
            }
            .sheet(item: $selectedModule) { module in
                RoutineDetailView(
                    content: selectedRoutine?.content ?? module.content,
                    title: selectedRoutine?.name ?? module.name
                )
            }
        }
    }

    private func moduleHeader(for module: ABBModule) -> some View {
        HStack {
            Text(module.name)
                .font(.headline)
            Spacer()
            Text(module.type.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct RoutineDetailView: View {
    let content: String
    let title: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()

                ScrollView {
                    Text(SyntaxHighlighter.highlight(content))
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                                )
                        )
                        .padding()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("close_action", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
