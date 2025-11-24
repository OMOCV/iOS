import SwiftUI

struct FileListView: View {
    let files: [ABBFile]
    var onSelect: (ABBFile) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(files) { file in
                    Button(action: { onSelect(file) }) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.text.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(file.name)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)

                                    Text(String(format: NSLocalizedString("file.module.count", comment: ""), file.modules.count))
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.75))
                            }

                            if !file.modules.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(file.modules) { module in
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "shippingbox")
                                                        .font(.caption)
                                                    Text(module.name)
                                                        .font(.subheadline.weight(.semibold))
                                                }
                                                .foregroundStyle(.white.opacity(0.95))

                                                HStack(spacing: 6) {
                                                    Text(module.type.rawValue)
                                                    Text(String(format: NSLocalizedString("file.routine.count", comment: ""), module.routines.count))
                                                }
                                                .font(.caption2)
                                                .foregroundStyle(.white.opacity(0.78))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 6)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .scrollClipDisabled()
                            }
                        }
                        .padding(14)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: files)
    }
}
