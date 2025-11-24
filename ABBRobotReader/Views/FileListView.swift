import SwiftUI

struct FileListView: View {
    let files: [ABBFile]
    @Binding var selectedFile: ABBFile?

    var body: some View {
        List(files) { file in
            Button(action: {
                selectedFile = file
            }) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "doc.richtext")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(file.name)
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text(String(format: NSLocalizedString("file.module.count", comment: ""), file.modules.count))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        Spacer()
                    }

                    if !file.modules.isEmpty {
                        ForEach(file.modules) { module in
                            HStack(spacing: 12) {
                                Image(systemName: "shippingbox")
                                    .foregroundStyle(Color.white.opacity(0.9))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(module.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text(module.type.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.75))
                                }
                                Spacer()
                                Text(String(format: NSLocalizedString("file.routine.count", comment: ""), module.routines.count))
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .glassListBackground()
        .listStyle(.plain)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: files)
    }
}
