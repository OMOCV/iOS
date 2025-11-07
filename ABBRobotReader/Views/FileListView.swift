import SwiftUI

struct FileListView: View {
    let files: [ABBFile]
    @Binding var selectedFile: ABBFile?
    
    var body: some View {
        List(files) { file in
            Button(action: {
                selectedFile = file
            }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(file.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(file.modules.count) module(s)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !file.modules.isEmpty {
                        ForEach(file.modules) { module in
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.blue)
                                Text(module.name)
                                    .font(.caption)
                                Spacer()
                                Text("\(module.routines.count) routine(s)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 16)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
    }
}
