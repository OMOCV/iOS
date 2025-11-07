import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFiles: [ABBFile]
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [
            UTType(filenameExtension: "mod") ?? .plainText,
            UTType(filenameExtension: "prg") ?? .plainText,
            UTType(filenameExtension: "sys") ?? .plainText,
            UTType(filenameExtension: "cfg") ?? .plainText,
            .plainText
        ]
        
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
