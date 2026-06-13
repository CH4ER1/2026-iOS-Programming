import Foundation
import Speech
import AVFoundation

class SpeechRecognitionService: NSObject {

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    var onTextUpdate: ((String) -> Void)?
    var onError: ((String) -> Void)?


    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            AVAudioSession.sharedInstance().requestRecordPermission { _ in }
            DispatchQueue.main.async {
                completion(authStatus == .authorized)
            }
        }
    }


    func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.requestCreationFailed
        }
        recognitionRequest.shouldReportPartialResults = true

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self?.onTextUpdate?(text)
                }
            }
            if let error = error {
                DispatchQueue.main.async {
                    self?.onError?(error.localizedDescription)
                }
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.finish()
        recognitionRequest = nil
        recognitionTask = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}


enum SpeechError: LocalizedError {
    case requestCreationFailed
    case recognizerUnavailable
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .requestCreationFailed: return "음성 인식 요청을 생성할 수 없습니다."
        case .recognizerUnavailable: return "음성 인식기를 사용할 수 없습니다. 네트워크 연결을 확인해 주세요."
        case .notAuthorized: return "음성 인식 권한이 필요합니다. 설정에서 권한을 허용해 주세요."
        }
    }
}
