import Foundation
import UIKit

class ImageGenerationService {

    private let apiKey = Config.openAIAPIKey
    private let endpoint = "https://api.openai.com/v1/images/generations"


    func generateImage(from dreamText: String, style: ImageStyle = .watercolor) async throws -> UIImage {
        guard let url = URL(string: endpoint) else {
            throw ImageError.invalidURL
        }

        let prompt = buildPrompt(from: dreamText, style: style)

        let body: [String: Any] = [
            "model": "gpt-image-1",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 120

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImageError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                throw ImageError.apiError(errResponse.error.message)
            }
            throw ImageError.apiError("HTTP \(httpResponse.statusCode)")
        }

        let result = try JSONDecoder().decode(ImageGenerationResponse.self, from: data)

        guard let first = result.data.first else {
            throw ImageError.noImageData
        }

        if let b64 = first.b64_json,
           let imageData = Data(base64Encoded: b64),
           let image = UIImage(data: imageData) {
            return image
        }

        if let urlString = first.url,
           let imageURL = URL(string: urlString) {
            let (imageData, _) = try await URLSession.shared.data(from: imageURL)
            if let image = UIImage(data: imageData) {
                return image
            }
        }

        throw ImageError.decodingFailed
    }


    private func buildPrompt(from text: String, style: ImageStyle) -> String {
        """
        Create a dreamy illustration based on this Korean dream description: \(text).
        Art style: \(style.promptKeyword), dreamlike atmosphere, beautiful artistic composition.
        No text or words in the image.
        """
    }

    private func makePlaceholderImage(text: String) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cgCtx = ctx.cgContext

            let colors = [
                UIColor(red: 0.45, green: 0.25, blue: 0.85, alpha: 1).cgColor,
                UIColor(red: 0.15, green: 0.40, blue: 0.80, alpha: 1).cgColor,
                UIColor(red: 0.05, green: 0.15, blue: 0.50, alpha: 1).cgColor
            ]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: colors as CFArray,
                                      locations: [0.0, 0.5, 1.0])!
            cgCtx.drawLinearGradient(gradient,
                                     start: CGPoint(x: 256, y: 0),
                                     end: CGPoint(x: 256, y: 512),
                                     options: [])

            let starPositions = (0..<50).map { _ in
                CGPoint(x: CGFloat.random(in: 0...512), y: CGFloat.random(in: 0...350))
            }
            for pos in starPositions {
                let r = CGFloat.random(in: 0.5...2.5)
                UIColor.white.withAlphaComponent(CGFloat.random(in: 0.4...1.0)).setFill()
                UIBezierPath(ovalIn: CGRect(x: pos.x - r, y: pos.y - r, width: r * 2, height: r * 2)).fill()
            }

            UIColor.white.withAlphaComponent(0.95).setFill()
            UIBezierPath(ovalIn: CGRect(x: 380, y: 40, width: 80, height: 80)).fill()
            UIColor(red: 0.45, green: 0.25, blue: 0.85, alpha: 0.85).setFill()
            UIBezierPath(ovalIn: CGRect(x: 400, y: 30, width: 80, height: 80)).fill()

            let style = NSMutableParagraphStyle()
            style.alignment = .center
            style.lineBreakMode = .byWordWrapping

            let preview = text.count > 55 ? String(text.prefix(52)) + "..." : text
            (preview as NSString).draw(
                in: CGRect(x: 30, y: 220, width: 452, height: 100),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.9),
                    .paragraphStyle: style
                ]
            )
        }
    }
}


struct ImageGenerationResponse: Codable {
    let data: [ImageData]
}

struct ImageData: Codable {
    let url: String?
    let b64_json: String?
}

struct DALLEResponse: Codable {
    let data: [DALLEImageData]
}

struct DALLEImageData: Codable {
    let url: String
}

struct OpenAIErrorResponse: Codable {
    let error: OpenAIError
}

struct OpenAIError: Codable {
    let message: String
}


enum ImageError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case noImageURL
    case noImageData
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "잘못된 API URL입니다."
        case .invalidResponse: return "서버 응답이 올바르지 않습니다."
        case .apiError(let msg): return "API 오류: \(msg)"
        case .noImageURL: return "이미지 URL을 가져올 수 없습니다."
        case .noImageData: return "이미지 데이터가 없습니다."
        case .decodingFailed: return "이미지 변환에 실패했습니다."
        }
    }
}
