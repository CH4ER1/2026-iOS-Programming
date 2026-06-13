import SwiftUI

struct MainView: View {

    @StateObject private var viewModel = DreamViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Theme.bgTop, Theme.bgMid, Theme.bgBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Theme.decorCircle1.opacity(0.5))
                            .frame(width: 200, height: 200)
                            .offset(x: 60, y: -60)
                    }
                    Spacer()
                    HStack {
                        Circle()
                            .fill(Theme.decorCircle2.opacity(0.3))
                            .frame(width: 150, height: 150)
                            .offset(x: -40, y: 40)
                        Spacer()
                    }
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Theme.chipBackground)
                            .frame(width: 120, height: 120)

                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "38BDF8"), Color(hex: "0EA5E9")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 88, height: 88)
                            .shadow(color: Color(hex: "0EA5E9").opacity(0.4), radius: 20, x: 0, y: 10)

                        Image(systemName: "cloud.moon.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                    }
                    .padding(.bottom, 32)

                    VStack(spacing: 10) {
                        Text("Dream Canvas")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)

                        Text("당신의 꿈을 말하면\nAI가 아름다운 그림으로 그려드립니다")
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.textSecondary.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                    }

                    Spacer()

                    if !viewModel.dreamEntries.isEmpty {
                        HStack(spacing: 12) {
                            StatCard(value: "\(viewModel.dreamEntries.count)", label: "기록된 꿈")
                            StatCard(value: recentDate(viewModel.dreamEntries), label: "최근 기록")
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    VStack(spacing: 12) {
                        NavigationLink(destination: RecordingView(viewModel: viewModel)) {
                            HStack(spacing: 10) {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 16))
                                Text("꿈 말하기 시작")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "38BDF8"), Color(hex: "0284C7")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(hex: "0284C7").opacity(0.3), radius: 12, x: 0, y: 6)
                        }

                        NavigationLink(destination: DreamListView(viewModel: viewModel)) {
                            HStack(spacing: 10) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color(hex: "0EA5E9"))
                                Text("꿈 기록 보기")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                if !viewModel.dreamEntries.isEmpty {
                                    Text("\(viewModel.dreamEntries.count)")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 3)
                                        .background(Color(hex: "0EA5E9"))
                                        .clipShape(Capsule())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 17)
                            .background(Theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(hex: "0EA5E9").opacity(0.1), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Theme.decorCircle1, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 52)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func recentDate(_ entries: [DreamEntry]) -> String {
        guard let latest = entries.first else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: latest.createdAt)
    }
}


struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "0284C7"))
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color(hex: "0EA5E9").opacity(0.08), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
    }
}

#Preview {
    MainView()
}
