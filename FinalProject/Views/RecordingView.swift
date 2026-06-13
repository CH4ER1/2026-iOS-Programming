import SwiftUI

struct RecordingView: View {

    @ObservedObject var viewModel: DreamViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToConfirm = false
    @State private var ripple = false
    @State private var waveScale: [CGFloat] = [1, 1, 1]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.chipBackground, Theme.bgMid, Theme.bgBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Spacer()
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Ellipse()
                            .fill(Theme.decorCircle1.opacity(0.15 - Double(i) * 0.04))
                            .frame(width: 320 + CGFloat(i) * 80, height: 120 + CGFloat(i) * 30)
                            .scaleEffect(waveScale[i])
                            .animation(
                                .easeInOut(duration: 1.8 + Double(i) * 0.3)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.2),
                                value: waveScale[i]
                            )
                    }
                }
                .offset(y: 30)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color(hex: "38BDF8").opacity(0.08))
                        .frame(width: 220, height: 220)
                        .scaleEffect(ripple ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: ripple)

                    Circle()
                        .fill(Color(hex: "38BDF8").opacity(0.12))
                        .frame(width: 175, height: 175)
                        .scaleEffect(ripple ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.1), value: ripple)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "38BDF8"), Color(hex: "0284C7")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 128, height: 128)
                        .shadow(color: Color(hex: "0284C7").opacity(0.35), radius: 24, x: 0, y: 10)

                    Image(systemName: "mic.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                }
                .onAppear {
                    ripple = true
                    waveScale = [1.05, 1.08, 1.1]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        viewModel.startRecording()
                    }
                }
                .padding(.bottom, 36)

                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: "0EA5E9"))
                            .frame(width: 7, height: 7)
                            .opacity(ripple ? 1 : 0.3)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: ripple)
                        Text("듣고 있어요...")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    Text("편하게 꿈 이야기를 해주세요")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.textSecondary.opacity(0.6))
                }
                .padding(.bottom, 28)

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.cardBackground)
                        .shadow(color: Color(hex: "0EA5E9").opacity(0.08), radius: 10, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Theme.decorCircle1, lineWidth: 1)
                        )

                    if viewModel.recognizedText.isEmpty {
                        Text("음성이 인식되면 여기에 표시됩니다")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textMuted)
                            .padding(16)
                    } else {
                        Text(viewModel.recognizedText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(16)
                            .animation(.easeOut(duration: 0.2), value: viewModel.recognizedText)
                    }
                }
                .frame(minHeight: 80, maxHeight: 140)
                .padding(.horizontal, 28)

                Spacer()

                Button {
                    viewModel.stopRecording()
                    navigateToConfirm = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 18))
                        Text("녹음 완료")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        viewModel.isRecording
                        ? Color(hex: "0284C7")
                        : Theme.textMuted
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(
                        color: Color(hex: "0284C7").opacity(viewModel.isRecording ? 0.3 : 0),
                        radius: 12, x: 0, y: 6
                    )
                }
                .disabled(!viewModel.isRecording)
                .padding(.horizontal, 28)
                .padding(.bottom, 52)
            }
        }
        .navigationTitle("꿈 녹음")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToConfirm) {
            ContentConfirmView(viewModel: viewModel)
        }
        .onDisappear {
            if viewModel.isRecording { viewModel.stopRecording() }
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인") { viewModel.showError = false }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    NavigationStack {
        RecordingView(viewModel: DreamViewModel())
    }
}
