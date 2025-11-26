import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFiles: [ABBFile]

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let extensions = [
            "mod", "prg", "sys", "cfg", // core RAPID sources
            "sio", "ls", "backup", "txt", // controller exports and diagnostics
            "rapid", "script", "cfgx", "log" // custom dumps often used in plants
        ]

        let supportedTypes: [UTType] = extensions.compactMap { ext in
            UTType(filenameExtension: ext)
        } + [.plainText]

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            DispatchQueue.global(qos: .userInitiated).async {
                var newFiles: [ABBFile] = []

                for url in urls {
                    if url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource() }

                        do {
                            let file = try ABBFileParser.parse(fileURL: url)
                            newFiles.append(file)
                        } catch {
                            print("Error parsing file \(url.lastPathComponent): \(error)")
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.parent.selectedFiles = newFiles
                }
            }
        }
    }
}
