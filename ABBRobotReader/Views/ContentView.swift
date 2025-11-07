import SwiftUI

struct ContentView: View {
    @State private var files: [ABBFile] = []
    @State private var selectedFile: ABBFile?
    @State private var showDocumentPicker = false
    @State private var newlySelectedFiles: [ABBFile] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if files.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("No ABB Robot Programs Loaded")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Import .mod, .prg, .sys, or .cfg files to get started")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showDocumentPicker = true
                        }) {
                            Label("Import Files", systemImage: "folder.badge.plus")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                } else {
                    FileListView(files: files, selectedFile: $selectedFile)
                }
            }
            .navigationTitle("ABB Robot Reader")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        Label("Import", systemImage: "plus")
                    }
                }
                
                if !files.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            files.removeAll()
                            selectedFile = nil
                        }) {
                            Label("Clear All", systemImage: "trash")
                        }
                    }
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(selectedFiles: $newlySelectedFiles)
            }
            .onChange(of: newlySelectedFiles) { newFiles in
                files.append(contentsOf: newFiles)
                newlySelectedFiles = []
            }
            .sheet(item: $selectedFile) { file in
                CodeEditorView(file: file)
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
