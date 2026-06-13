import SwiftUI

struct DreamListView: View {

    @ObservedObject var viewModel: DreamViewModel
    @State private var searchText = ""
    @State private var selectedFilter: String? = nil
    @State private var showFavoritesOnly = false
    @State private var entryToDelete: DreamEntry? = nil

    var filteredEntries: [DreamEntry] {
        var entries = viewModel.dreamEntries
        if !searchText.isEmpty {
            entries = entries.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
        }
        if let filter = selectedFilter {
            entries = entries.filter { $0.style == filter }
        }
        if showFavoritesOnly {
            entries = entries.filter { $0.isFavorite }
        }
        return entries
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.bgMid, Theme.bgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                if !viewModel.dreamEntries.isEmpty {
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                    StyleFilterBar(selected: $selectedFilter, showFavoritesOnly: $showFavoritesOnly)
                        .padding(.bottom, 8)
                }

                if viewModel.dreamEntries.isEmpty {
                    Spacer()
                    EmptyDreamView()
                    Spacer()
                } else if filteredEntries.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundStyle(Theme.decorCircle1)
                        Text("검색 결과가 없어요")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredEntries) { entry in
                                NavigationLink(destination: DreamDetailView(entry: entry, viewModel: viewModel)) {
                                    DreamEntryCard(
                                        entry: entry,
                                        onToggleFavorite: {
                                            viewModel.toggleFavorite(for: entry.id)
                                        },
                                        onDelete: {
                                            entryToDelete = entry
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationTitle("꿈 기록")
        .navigationBarTitleDisplayMode(.inline)
        .alert("꿈 기록 삭제", isPresented: Binding(
            get: { entryToDelete != nil },
            set: { if !$0 { entryToDelete = nil } }
        )) {
            Button("취소", role: .cancel) { entryToDelete = nil }
            Button("삭제", role: .destructive) {
                if let entry = entryToDelete {
                    viewModel.deleteDream(id: entry.id)
                }
                entryToDelete = nil
            }
        } message: {
            Text("이 꿈 기록을 삭제하시겠습니까?\n삭제한 기록은 복구할 수 없습니다.")
        }
    }
}


struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color(hex: "38BDF8"))
                .font(.system(size: 15))
            TextField("꿈 내용 검색...", text: $text)
                .font(.system(size: 15))
                .foregroundStyle(Theme.textPrimary)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textMuted)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color(hex: "0EA5E9").opacity(0.08), radius: 6, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
    }
}


struct StyleFilterBar: View {
    @Binding var selected: String?
    @Binding var showFavoritesOnly: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FavoriteFilterChip(isSelected: showFavoritesOnly) {
                    showFavoritesOnly.toggle()
                }
                FilterChip(label: "전체", isSelected: selected == nil) {
                    selected = nil
                }
                ForEach(ImageStyle.allCases) { style in
                    FilterChip(label: style.rawValue, isSelected: selected == style.rawValue) {
                        selected = selected == style.rawValue ? nil : style.rawValue
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct FavoriteFilterChip: View {
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: isSelected ? "heart.fill" : "heart")
                    .font(.system(size: 12))
                Text("즐겨찾기")
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? .white : Color(hex: "F87171"))
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                isSelected ? Color(hex: "F87171") : Theme.cardBackground
            )
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(
                    isSelected ? Color.clear : Color(hex: "FECACA"),
                    lineWidth: 1
                )
            )
        }
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : Theme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    isSelected ? Color(hex: "0284C7") : Theme.cardBackground
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(
                        isSelected ? Color.clear : Theme.decorCircle1,
                        lineWidth: 1
                    )
                )
        }
    }
}


struct DreamEntryCard: View {
    let entry: DreamEntry
    var onToggleFavorite: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    private var emotion: DreamEmotion? {
        DreamEmotion(rawValue: entry.emotion)
    }

    var body: some View {
        HStack(spacing: 14) {
            // 썸네일
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.chipBackground)
                    .frame(width: 76, height: 76)

                if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 76, height: 76)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    Image(systemName: "cloud.moon.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color(hex: "38BDF8"))
                }

                if let emotion = emotion {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: emotion.icon)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(5)
                                .background(Color(hex: emotion.colorHex))
                                .clipShape(Circle())
                                .offset(x: 6, y: -6)
                        }
                        Spacer()
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.shortText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 8) {
                    Text(entry.formattedDate)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary.opacity(0.5))

                    if !entry.style.isEmpty {
                        Text(entry.style)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "0284C7"))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Theme.chipBackground)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            if let onToggleFavorite = onToggleFavorite {
                Button(action: onToggleFavorite) {
                    Image(systemName: entry.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundStyle(entry.isFavorite ? Color(hex: "F87171") : Theme.textMuted)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 2)
            }

            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(hex: "F87171"))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 2)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.decorCircle1)
        }
        .padding(14)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color(hex: "0EA5E9").opacity(0.07), radius: 8, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
    }
}


struct EmptyDreamView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.chipBackground)
                    .frame(width: 110, height: 110)
                Image(systemName: "cloud.moon.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color(hex: "38BDF8"))
            }
            Text("아직 저장된 꿈이 없어요")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
            Text("꿈을 말하고 AI 이미지로 기록해보세요!")
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary.opacity(0.6))
        }
    }
}


struct DreamDetailView: View {
    let entry: DreamEntry
    @ObservedObject var viewModel: DreamViewModel
    @State private var showShareSheet = false
    @State private var isFavorite: Bool

    init(entry: DreamEntry, viewModel: DreamViewModel) {
        self.entry = entry
        self.viewModel = viewModel
        _isFavorite = State(initialValue: entry.isFavorite)
    }

    private var emotion: DreamEmotion? {
        DreamEmotion(rawValue: entry.emotion)
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
                VStack(spacing: 20) {
                    if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color(hex: "0EA5E9").opacity(0.15), radius: 16, x: 0, y: 6)
                            .padding(.horizontal, 20)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label(entry.formattedDate, systemImage: "calendar")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.textSecondary.opacity(0.6))
                            Spacer()
                            HStack(spacing: 6) {
                                if let emotion = emotion {
                                    Label(emotion.rawValue, systemImage: emotion.icon)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(Color(hex: emotion.colorHex))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: emotion.colorHex).opacity(0.15))
                                        .clipShape(Capsule())
                                }
                                if !entry.style.isEmpty {
                                    Label(entry.style, systemImage: "paintbrush.fill")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(Color(hex: "0284C7"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Theme.chipBackground)
                                        .clipShape(Capsule())
                                }
                            }
                        }

                        Divider()

                        Text(entry.text)
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.textPrimary)
                            .lineSpacing(6)
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
                    .padding(.bottom, 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle("꿈 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isFavorite.toggle()
                    }
                    viewModel.toggleFavorite(for: entry.id)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? Color(hex: "F87171") : Color(hex: "0284C7"))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color(hex: "0284C7"))
                }
                .disabled(entry.imageData == nil)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                ShareSheet(items: [uiImage, entry.text])
            }
        }
    }
}

#Preview {
    NavigationStack {
        DreamListView(viewModel: DreamViewModel())
    }
}
