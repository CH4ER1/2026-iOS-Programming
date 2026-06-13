import SwiftUI

struct DreamResultView: View {

    @ObservedObject var viewModel: DreamViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var imageToShare: UIImage? = nil

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.bgMid, Theme.bgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Theme.chipBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 340)
                            .shadow(color: Color(hex: "0EA5E9").opacity(0.12), radius: 16, x: 0, y: 6)

                        if viewModel.isGeneratingImage {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.cardBackground.opacity(0.8))
                                        .frame(width: 80, height: 80)
                                    ProgressView()
                                        .tint(Color(hex: "0284C7"))
                                        .scaleEffect(1.5)
                                }
                                Text("꿈을 그리는 중...")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color(hex: "0284C7"))
                                Text("잠시만 기다려 주세요")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.textSecondary.opacity(0.6))
                            }
                        } else if let image = viewModel.generatedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 340)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "cloud.moon.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Color(hex: "38BDF8"))
                                Text("이미지를 불러오는 중...")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Theme.textSecondary.opacity(0.6))
                            }
                        }

                        if !viewModel.isGeneratingImage {
                            VStack {
                                HStack(alignment: .top) {
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            viewModel.markAsFavorite.toggle()
                                        }
                                    } label: {
                                        Image(systemName: viewModel.markAsFavorite ? "heart.fill" : "heart")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(viewModel.markAsFavorite ? Color(hex: "F87171") : .white)
                                            .padding(10)
                                            .background(Color.black.opacity(0.25))
                                            .clipShape(Circle())
                                    }
                                    .padding(12)

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 6) {
                                        Label(viewModel.selectedStyle.rawValue,
                                              systemImage: viewModel.selectedStyle.icon)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color(hex: "0284C7").opacity(0.75))
                                            .clipShape(Capsule())

                                        Label(viewModel.selectedEmotion.rawValue,
                                              systemImage: viewModel.selectedEmotion.icon)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color(hex: viewModel.selectedEmotion.colorHex).opacity(0.85))
                                            .clipShape(Capsule())
                                    }
                                    .padding(12)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "moon.zzz.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(Color(hex: "38BDF8"))
                            Text("당신의 꿈")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.textSecondary)
                            Spacer()
                        }
                        Text(viewModel.recognizedText)
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.textPrimary)
                            .lineSpacing(5)
                    }
                    .padding(18)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: "0EA5E9").opacity(0.07), radius: 8, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    VStack(spacing: 12) {
                        Button {
                            viewModel.saveDream()
                            viewModel.saveImageToPhotos()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("꿈 저장하기")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background {
                                if viewModel.isGeneratingImage {
                                    Color(hex: "94A3B8")
                                } else {
                                    LinearGradient(
                                        colors: [Color(hex: "38BDF8"), Color(hex: "0284C7")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                            }
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(
                                color: Color(hex: "0284C7").opacity(viewModel.isGeneratingImage ? 0 : 0.25),
                                radius: 10, x: 0, y: 5
                            )
                        }
                        .disabled(viewModel.isGeneratingImage)

                        HStack(spacing: 12) {
                            Button {
                                if let image = viewModel.generatedImage {
                                    imageToShare = image
                                    showShareSheet = true
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 15))
                                    Text("공유")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Theme.cardBackground)
                                .foregroundStyle(Color(hex: "0284C7"))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Theme.decorCircle1, lineWidth: 1.5)
                                )
                            }
                            .disabled(viewModel.generatedImage == nil || viewModel.isGeneratingImage)

                            Button {
                                viewModel.reset()
                                dismiss()
                                dismiss()
                                dismiss()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 15))
                                    Text("새 꿈")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Theme.cardBackground)
                                .foregroundStyle(Theme.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Theme.cardBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle("당신의 꿈")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let image = imageToShare {
                ShareSheet(items: [image, viewModel.recognizedText])
            }
        }
        .alert("저장 완료", isPresented: $viewModel.showSaveConfirmation) {
            Button("확인") { viewModel.showSaveConfirmation = false }
        } message: {
            Text(viewModel.saveMessage)
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인") { viewModel.showError = false }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        DreamResultView(viewModel: {
            let vm = DreamViewModel()
            vm.recognizedText = "비가 많이 오는 날에 빗소리를 들으며 수업을 듣는 꿈을 꾸었다"
            return vm
        }())
    }
}
