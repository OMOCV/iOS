import SwiftUI

struct ContentView: View {
    @State private var files: [ABBFile] = []
    @State private var selectedFile: ABBFile?
    @State private var showDocumentPicker = false
    @State private var newlySelectedFiles: [ABBFile] = []

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()

                VStack(spacing: 18) {
                    headerCard

                    GlassContainer {
                        if files.isEmpty {
                            emptyState
                        } else {
                            FileListView(files: files, selectedFile: $selectedFile)
                                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
            }
            .navigationTitle(Text("app_title"))
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar { toolbarItems }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(selectedFiles: $newlySelectedFiles)
            }
            .onChange(of: newlySelectedFiles) { newFiles in
                withAnimation(.easeInOut) {
                    files.append(contentsOf: newFiles)
                    newlySelectedFiles = []
                }
            }
            .fullScreenCover(item: $selectedFile) { file in
                CodeEditorView(file: file)
            }
        }
        .navigationViewStyle(.stack)
    }

    private var headerCard: some View {
        GlassContainer {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.thinMaterial)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Circle()
                                .strokeBorder(.white.opacity(0.3), lineWidth: 1.5)
                        )
                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(NSLocalizedString("glass_headline", comment: ""))
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(NSLocalizedString("glass_subheadline", comment: ""))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Label(NSLocalizedString("ready_for_ios", comment: ""), systemImage: "leaf")
                        .labelStyle(.titleAndIcon)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 120, height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 12)

                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 52))
                    .foregroundColor(.white)
            }

            Text(NSLocalizedString("empty_state_title", comment: ""))
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(NSLocalizedString("empty_state_description", comment: ""))
                .font(.body)
                .foregroundStyle(.white.opacity(0.82))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                showDocumentPicker = true
            }) {
                Label(NSLocalizedString("import_files_action", comment: ""), systemImage: "folder.badge.plus")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [Color.white, Color(red: 0.85, green: 0.93, blue: 1.0)], startPoint: .top, endPoint: .bottom)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
            }
            .padding(.top, 8)
        }
    }

    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: {
                showDocumentPicker = true
            }) {
                Label(NSLocalizedString("import_toolbar", comment: ""), systemImage: "plus")
            }
        }

        ToolbarItemGroup(placement: .navigationBarLeading) {
            if !files.isEmpty {
                Button(role: .destructive) {
                    withAnimation(.easeInOut) {
                        files.removeAll()
                        selectedFile = nil
                    }
                } label: {
                    Label(NSLocalizedString("clear_all", comment: ""), systemImage: "trash")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
