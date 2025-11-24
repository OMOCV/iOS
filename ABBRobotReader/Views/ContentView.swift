import SwiftUI

struct ContentView: View {
    @State private var files: [ABBFile] = []
    @State private var selectedFile: ABBFile?
    @State private var sheetFile: ABBFile?
    @State private var showDocumentPicker = false
    @State private var newlySelectedFiles: [ABBFile] = []
    @Namespace private var hero
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        metricRow
                        workspace
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showDocumentPicker = true }) {
                        Label("toolbar.import", systemImage: "plus")
                    }
                    .tint(.white)
                }

                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if !files.isEmpty {
                        Button(role: .destructive, action: {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                                files.removeAll()
                                selectedFile = nil
                                sheetFile = nil
                            }
                        }) {
                            Label("toolbar.clear", systemImage: "trash")
                        }
                        .tint(.white)
                    }
                }
            }
            .glassToolbarStyle()
            .navigationTitle(Text("app.title"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(selectedFiles: $newlySelectedFiles)
            }
            .onChange(of: newlySelectedFiles) { newFiles in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                    files.append(contentsOf: newFiles)
                    if selectedFile == nil { selectedFile = newFiles.first }
                }
                newlySelectedFiles = []
            }
            .sheet(item: $sheetFile) { file in
                CodeEditorView(file: file)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("app.title")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .shadow(radius: 6)

            Text("app.subtitle")
                .font(.callout)
                .foregroundStyle(Color.white.opacity(0.85))
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var metricRow: some View {
        let moduleCount = files.reduce(0) { $0 + $1.modules.count }
        let routineCount = files.reduce(0) { $0 + $1.modules.reduce(0) { $0 + $1.routines.count } }

        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

        return LazyVGrid(columns: columns, spacing: 12) {
            metricChip(title: "metrics.files", value: files.count, icon: "folder.fill")
            metricChip(title: "metrics.modules", value: moduleCount, icon: "shippingbox.fill")
            metricChip(title: "metrics.routines", value: routineCount, icon: "function")
        }
        .frame(maxWidth: .infinity)
    }

    private func metricChip(title: String, value: Int, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .padding(10)
                .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: NSLocalizedString(title, comment: ""), value))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text("\(value)")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var workspace: some View {
        GeometryReader { proxy in
            let isWide = proxy.size.width > 820 || horizontalSizeClass == .regular

            VStack(alignment: .leading, spacing: 16) {
                if files.isEmpty {
                    emptyState
                        .matchedGeometryEffect(id: "card", in: hero)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    if isWide {
                        HStack(alignment: .top, spacing: 18) {
                            FileListView(files: files) { file in
                                selectedFile = file
                            }
                            .frame(maxWidth: proxy.size.width * 0.45)

                            Group {
                                if let file = selectedFile ?? files.first {
                                    CodeEditorView(file: file, useAmbientBackground: false)
                                        .glassCard()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                } else {
                                    emptyDetail
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .transition(.opacity.combined(with: .scale))
                    } else {
                        FileListView(files: files) { file in
                            selectedFile = file
                            sheetFile = file
                        }
                        .transition(.opacity)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 520)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "rectangle.and.text.magnifyingglass")
                .font(.system(size: 76))
                .foregroundColor(.white.opacity(0.9))

            Text("empty.title")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("empty.description")
                .font(.callout)
                .foregroundStyle(Color.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)

            Button(action: {
                showDocumentPicker = true
            }) {
                Label("empty.import", systemImage: "folder.badge.plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.29, green: 0.6, blue: 0.98), Color(red: 0.28, green: 0.48, blue: 0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 8)
            }
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .glassCard()
    }

    private var emptyDetail: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundColor(.white.opacity(0.85))
            Text("detail.placeholder")
                .font(.headline)
                .foregroundStyle(.white)
            Text("detail.placeholder.description")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
