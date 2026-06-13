import SwiftUI

struct ContentConfirmView: View {

    @ObservedObject var viewModel: DreamViewModel
    @Binding var path: [DreamRoute]
    @State private var editedText: String
    @State private var isLoading = false
    @FocusState private var isTextFieldFocused: Bool

    init(viewModel: DreamViewModel, path: Binding<[DreamRoute]>) {
        self.viewModel = viewModel
        self._path = path
        _editedText = State(initialValue: viewModel.recognizedText)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.bgMid, Theme.bgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    SectionHeader(icon: "doc.text.fill", title: "꿈 내용", color: Color(hex: "0EA5E9"))

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.cardBackground)
                            .shadow(color: Color(hex: "0EA5E9").opacity(0.07), radius: 10, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        isTextFieldFocused ? Color(hex: "38BDF8") : Theme.cardBorder,
                                        lineWidth: isTextFieldFocused ? 1.5 : 1
                                    )
                            )

                        if editedText.isEmpty {
                            Text("인식된 꿈 내용이 없습니다.\n직접 입력해 보세요.")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.textMuted)
                                .padding(16)
                        }

                        TextEditor(text: $editedText)
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.textPrimary)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .focused($isTextFieldFocused)
                    }
                    .frame(minHeight: 160, maxHeight: 240)

                    HStack {
                        Image(systemName: "pencil")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.textMuted)
                        Text("내용을 자유롭게 수정할 수 있어요")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textMuted)
                        Spacer()
                        Text("\(editedText.count)자")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "0EA5E9").opacity(0.7))
                    }

                    SectionHeader(icon: "paintbrush.fill", title: "이미지 스타일", color: Color(hex: "0EA5E9"))

                    StylePickerView(selectedStyle: $viewModel.selectedStyle)

                    SectionHeader(icon: "heart.fill", title: "꿈의 감정", color: Color(hex: "0EA5E9"))

                    EmotionPickerView(selectedEmotion: $viewModel.selectedEmotion)

                    Spacer(minLength: 20)

                    Button {
                        confirmAndGenerate()
                    } label: {
                        HStack(spacing: 10) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.9)
                                Text("이미지 생성 중...")
                                    .font(.system(size: 17, weight: .semibold))
                            } else {
                                Image(systemName: "wand.and.stars")
                                    .font(.system(size: 16))
                                Text("이미지 생성하기")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background {
                            if editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading {
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
                            color: Color(hex: "0284C7").opacity(isLoading ? 0 : 0.25),
                            radius: 10, x: 0, y: 5
                        )
                    }
                    .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    .padding(.bottom, 8)
                }
                .padding(24)
            }
        }
        .navigationTitle("내용 확인")
        .navigationBarTitleDisplayMode(.inline)
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인") { viewModel.showError = false }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onTapGesture { isTextFieldFocused = false }
    }

    private func confirmAndGenerate() {
        isTextFieldFocused = false
        viewModel.recognizedText = editedText
        isLoading = true
        Task {
            await viewModel.generateImage()
            await MainActor.run {
                isLoading = false
                path.append(.result)
            }
        }
    }
}


struct StylePickerView: View {
    @Binding var selectedStyle: ImageStyle

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(ImageStyle.allCases) { style in
                StyleChip(style: style, isSelected: selectedStyle == style) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedStyle = style
                    }
                }
            }
        }
    }
}

struct StyleChip: View {
    let style: ImageStyle
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: style.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? .white : Color(hex: "0284C7"))
                Text(style.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                if isSelected {
                    LinearGradient(
                        colors: [Color(hex: "38BDF8"), Color(hex: "0284C7")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Theme.cardBackground
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : Theme.decorCircle1,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: "0284C7").opacity(0.25) : Color.clear,
                radius: 8, x: 0, y: 4
            )
        }
    }
}


struct EmotionPickerView: View {
    @Binding var selectedEmotion: DreamEmotion

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(DreamEmotion.allCases) { emotion in
                EmotionChip(emotion: emotion, isSelected: selectedEmotion == emotion) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedEmotion = emotion
                    }
                }
            }
        }
    }
}

struct EmotionChip: View {
    let emotion: DreamEmotion
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: emotion.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? .white : Color(hex: emotion.colorHex))
                Text(emotion.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                if isSelected {
                    Color(hex: emotion.colorHex)
                } else {
                    Theme.cardBackground
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : Theme.decorCircle1,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: emotion.colorHex).opacity(0.3) : Color.clear,
                radius: 8, x: 0, y: 4
            )
        }
    }
}


struct SectionHeader: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        ContentConfirmView(viewModel: {
            let vm = DreamViewModel()
            vm.recognizedText = "비가 많이 오는 날에 빗소리를 들으며 수업을 듣는 꿈을 꾸었다"
            return vm
        }(), path: .constant([]))
    }
}
