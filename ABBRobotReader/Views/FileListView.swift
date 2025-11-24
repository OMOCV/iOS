import SwiftUI

struct FileListView: View {
    let files: [ABBFile]
    @Binding var selectedFile: ABBFile?

    var body: some View {
        List(files) { file in
            Button(action: {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                    selectedFile = file
                }
            }) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(file.name)
                                .font(.headline)
                                .foregroundColor(.white)

                            Text(
                                String(
                                    localized: String.LocalizationValue(
                                        String(
                                            format: NSLocalizedString("modules_format", comment: ""),
                                            file.modules.count
                                        )
                                    )
                                )
                            )
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.78))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.subheadline.weight(.medium))
                    }

                    if !file.modules.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(file.modules) { module in
                                HStack(spacing: 10) {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(.white)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(module.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.white)
                                        Text(module.type.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.75))
                                    }
                                    Spacer()
                                    Text(
                                        String(
                                            localized: String.LocalizationValue(
                                                String(
                                                    format: NSLocalizedString("routines_format", comment: ""),
                                                    module.routines.count
                                                )
                                            )
                                        )
                                    )
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.white.opacity(0.08))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
