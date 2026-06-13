import Foundation
import UIKit
import Photos
import Combine
import SwiftUI


enum ImageStyle: String, CaseIterable, Identifiable {
    case watercolor = "수채화"
    case oilPainting = "유화"
    case photo = "사진풍"
    case anime = "애니메이션"
    case pastel = "파스텔"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .watercolor:  return "paintbrush.fill"
        case .oilPainting: return "paintpalette.fill"
        case .photo:       return "camera.fill"
        case .anime:       return "sparkles"
        case .pastel:      return "wand.and.stars"
        }
    }

    var promptKeyword: String {
        switch self {
        case .watercolor:  return "soft watercolor painting, flowing colors, paper texture"
        case .oilPainting: return "rich oil painting, thick brushstrokes, classical art style"
        case .photo:       return "photorealistic, cinematic lighting, highly detailed"
        case .anime:       return "anime illustration style, vibrant colors, cel-shaded"
        case .pastel:      return "pastel art, soft muted tones, gentle dreamy colors"
        }
    }
}


enum DreamEmotion: String, CaseIterable, Identifiable {
    case happy = "행복"
    case scary = "무서움"
    case mysterious = "신비로움"
    case sad = "슬픔"
    case peaceful = "평온함"
    case exciting = "흥미진진"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .happy:      return "face.smiling.fill"
        case .scary:      return "exclamationmark.triangle.fill"
        case .mysterious: return "sparkles"
        case .sad:        return "cloud.rain.fill"
        case .peaceful:   return "leaf.fill"
        case .exciting:   return "bolt.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .happy:      return "FBBF24"
        case .scary:      return "F87171"
        case .mysterious: return "A78BFA"
        case .sad:        return "60A5FA"
        case .peaceful:   return "34D399"
        case .exciting:   return "FB923C"
        }
    }
}


class DreamViewModel: ObservableObject {

    @Published var recognizedText: String = ""
    @Published var isRecording: Bool = false
    @Published var generatedImage: UIImage? = nil
    @Published var isGeneratingImage: Bool = false
    @Published var dreamEntries: [DreamEntry] = []
    @Published var isSpeechAuthorized: Bool = false
    @Published var selectedStyle: ImageStyle = .watercolor
    @Published var selectedEmotion: DreamEmotion = .mysterious
    @Published var markAsFavorite: Bool = false

    @Published var errorMessage: String = ""
    @Published var showError: Bool = false

    @Published var showSaveConfirmation: Bool = false
    @Published var saveMessage: String = ""

    private let speechService = SpeechRecognitionService()
    private let imageService = ImageGenerationService()
    private let storageService = DreamStorageService()

    init() {
        loadDreams()
        speechService.onTextUpdate = { [weak self] text in
            self?.recognizedText = text
        }
        speechService.onError = { [weak self] message in
            self?.errorMessage = message
            self?.showError = true
        }
        requestSpeechAuthorization()
    }


    func requestSpeechAuthorization() {
        speechService.requestAuthorization { [weak self] authorized in
            self?.isSpeechAuthorized = authorized
        }
    }

    func startRecording() {
        guard isSpeechAuthorized else {
            errorMessage = "음성 인식 권한이 필요합니다. 설정 > 앱 이름에서 마이크 및 음성 인식 권한을 허용해 주세요."
            showError = true
            return
        }
        recognizedText = ""
        isRecording = true
        do {
            try speechService.startRecording()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isRecording = false
        }
    }

    func stopRecording() {
        isRecording = false
        speechService.stopRecording()
    }


    @MainActor
    func generateImage() async {
        guard !recognizedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "꿈 내용을 먼저 입력해 주세요."
            showError = true
            return
        }
        isGeneratingImage = true
        generatedImage = nil
        do {
            let image = try await imageService.generateImage(from: recognizedText, style: selectedStyle)
            generatedImage = image
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isGeneratingImage = false
    }


    func saveDream() {
        let imageData = generatedImage?.jpegData(compressionQuality: 0.8)
        let entry = DreamEntry(text: recognizedText, imageData: imageData,
                                style: selectedStyle.rawValue, emotion: selectedEmotion.rawValue,
                                isFavorite: markAsFavorite)
        dreamEntries.insert(entry, at: 0)
        storageService.save(entries: dreamEntries)
    }

    func deleteDream(at offsets: IndexSet) {
        dreamEntries.remove(atOffsets: offsets)
        storageService.save(entries: dreamEntries)
    }

    func deleteDream(id: UUID) {
        dreamEntries.removeAll { $0.id == id }
        storageService.save(entries: dreamEntries)
    }

    func toggleFavorite(for id: UUID) {
        guard let index = dreamEntries.firstIndex(where: { $0.id == id }) else { return }
        dreamEntries[index].isFavorite.toggle()
        storageService.save(entries: dreamEntries)
    }

    private func loadDreams() {
        dreamEntries = storageService.load()
    }


    func saveImageToPhotos() {
        guard let image = generatedImage else {
            errorMessage = "저장할 이미지가 없습니다."
            showError = true
            return
        }
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    self?.saveMessage = "꿈이 사진 앱과 앱 내 기록에 저장되었습니다."
                } else {
                    self?.saveMessage = "꿈이 앱 내 기록에 저장되었습니다.\n(사진 앱 저장: 설정에서 권한을 허용하세요)"
                }
                self?.showSaveConfirmation = true
            }
        }
    }


    func reset() {
        recognizedText = ""
        generatedImage = nil
        isRecording = false
        isGeneratingImage = false
        selectedStyle = .watercolor
        selectedEmotion = .mysterious
        markAsFavorite = false
    }
}
