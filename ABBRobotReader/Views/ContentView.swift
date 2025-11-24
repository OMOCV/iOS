import SwiftUI

struct ContentView: View {
    @State private var files: [ABBFile] = []
    @State private var selectedFile: ABBFile?
    @State private var showDocumentPicker = false
    @State private var newlySelectedFiles: [ABBFile] = []
    @Namespace private var hero

    var body: some View {
        NavigationView {
            ZStack {
                LiquidGlassBackground()
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    header

                    if files.isEmpty {
                        emptyState
                            .matchedGeometryEffect(id: "card", in: hero)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        FileListView(files: files, selectedFile: $selectedFile)
                            .matchedGeometryEffect(id: "card", in: hero)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        Label("toolbar.import", systemImage: "plus")
                    }
                    .tint(.white)
                }

                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if !files.isEmpty {
                        Button(action: {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                                files.removeAll()
                                selectedFile = nil
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
                }
                newlySelectedFiles = []
            }
            .sheet(item: $selectedFile) { file in
                CodeEditorView(file: file)
            }
        }
        .navigationViewStyle(.stack)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
