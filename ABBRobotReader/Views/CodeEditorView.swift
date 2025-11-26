import SwiftUI

struct CodeEditorView: View {
    let file: ABBFile
    var useAmbientBackground: Bool = true
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedModuleID: ABBModule.ID?
    @State private var selectedRoutineID: ABBRoutine.ID?
    @State private var compactModule: ABBModule?
    @State private var compactRoutine: ABBRoutine?

    private var selectedModule: ABBModule? {
        guard let selectedModuleID else { return nil }
        return file.modules.first { $0.id == selectedModuleID }
    }

    private var selectedRoutine: ABBRoutine? {
        guard let selectedRoutineID, let selectedModule else { return nil }
        return selectedModule.routines.first { $0.id == selectedRoutineID }
    }

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                NavigationSplitView {
                    moduleList(usesInlineDetail: true)
                } detail: {
                    detailPane
                }
                .navigationSplitViewStyle(.balanced)
            } else {
                NavigationStack {
                    moduleList(usesInlineDetail: false)
                        .navigationTitle(file.name)
                        .navigationBarTitleDisplayMode(.inline)
                        .glassToolbarStyle()
                }
                .sheet(item: $compactModule) { module in
                    RoutineDetailView(
                        content: (compactRoutine ?? module.routines.first)?.content ?? module.content,
                        title: compactRoutine?.name ?? module.name
                    )
                }
            }
        }
        .background(
            Group {
                if useAmbientBackground {
                    ZStack {
                        LiquidGlassBackground()
                            .ignoresSafeArea()
                        LinearGradient(colors: [.clear, Color.black.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea()
                    }
                }
            }
        )
    }

    @ViewBuilder
    private func moduleList(usesInlineDetail: Bool) -> some View {
        List(selection: usesInlineDetail ? $selectedModuleID : .constant(nil)) {
            ForEach(file.modules) { module in
                Section(header: moduleHeader(module)) {
                    if !module.declarations.isEmpty {
                        DisclosureGroup(String(format: NSLocalizedString("module.declarations", comment: ""), module.declarations.count)) {
                            ForEach(module.declarations, id: \.self) { declaration in
                                Text(declaration)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                            }
                        }
                    }

                    if !module.routines.isEmpty {
                        DisclosureGroup(String(format: NSLocalizedString("module.routines", comment: ""), module.routines.count)) {
                            ForEach(module.routines) { routine in
                                Button(action: {
                                    if usesInlineDetail {
                                        selectedModuleID = module.id
                                        selectedRoutineID = routine.id
                                    } else {
                                        compactModule = module
                                        compactRoutine = routine
                                    }
                                }) {
                                    routineRow(routine)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button(action: {
                        if usesInlineDetail {
                            selectedModuleID = module.id
                            selectedRoutineID = nil
                        } else {
                            compactModule = module
                            compactRoutine = nil
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.plaintext")
                            Text("module.view.full")
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
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
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: selectedModuleID)
        .listStyle(.insetGrouped)
    }

    private func moduleHeader(_ module: ABBModule) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(module.name)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(module.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if !module.routines.isEmpty {
                Text("\(module.routines.count) ▸")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func routineRow(_ routine: ABBRoutine) -> some View {
        HStack {
            Image(systemName: "function")
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(routine.name)
                    .font(.body)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
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

    @ViewBuilder
    private var detailPane: some View {
        if let module = selectedModule {
            let title = selectedRoutine?.name ?? module.name
            let content = selectedRoutine?.content ?? module.content
            RoutineDetailView(content: content, title: title)
                .navigationTitle(file.name)
                .glassToolbarStyle()
        } else {
            VStack(spacing: 12) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text(NSLocalizedString("module.view.full", comment: ""))
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("Tap a module or routine to preview its RAPID code.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
        }
    }
}

struct RoutineDetailView: View {
    let content: String
    let title: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
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
            .background(.ultraThinMaterial)
        }
    }
}
