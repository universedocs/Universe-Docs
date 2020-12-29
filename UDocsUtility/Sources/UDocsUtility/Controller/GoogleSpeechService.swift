import UIKit
import AVFoundation
import SwiftyJSON

public enum VoiceType: String {
    case undefined
    case waveNetFemale = "en-US-Wavenet-F"
    case waveNetMale = "en-US-Wavenet-D"
    case standardFemale = "en-US-Standard-E"
    case standardMale = "en-US-Standard-D"
    case tamilMale = "ta-IN-Standard-B"
    case tamilFemale = "ta-IN-Standard-A"
    case hindiWaveNetFemale = "hi-IN-Wavenet-A"
    case hindiWaveNetMale = "hi-IN-Wavenet-B"
    case hindiWaveNetFemale2 = "hi-IN-Wavenet-D"
    case hindiWaveNetMale2 = "hi-IN-Wavenet-C"
    case hindiStandardFemale2 = "hi-IN-Standard-D"
    case hindiStandardMale2 = "hi-IN-Standard-C"
    case japaneseWaveNetFemale = "ja-JP-Wavenet-A"
    case japaneseWaveNetFemale1 = "ja-JP-Wavenet-B"
    case japaneseWaveNetMale = "ja-JP-Wavenet-C"
    case japaneseWaveNetMale1 = "ja-JP-Wavenet-D"
    case japaneseStandardFemale = "ja-JP-Standard-A"
    case japaneseStandardFemale1 = "ja-JP-Standard-B"
    case japaneseStandardMale = "ja-JP-Standard-C"
    case japaneseStandardMale1 = "ja-JP-Standard-D"
    
}

public enum languageCode: String {
    case undefined
    case tamilIndia = "ta-IN"
    case englishUS = "en-US"
    case hindiIndia = "hi-IN"
    case japaneseJapan = "ja-JP"
}

let ttsAPIUrl = "https://texttospeech.googleapis.com/v1beta1/text:synthesize"

let APIKey = "AIzaSyDJ8nljsfXfyMzkQPx4dmim_mgDKeZCAwY"

public class TextToSpeechUtility: NSObject, AVAudioPlayerDelegate {
    
    static let shared = TextToSpeechUtility()
    private(set) var busy: Bool = false
    
    private var completionHandler: (() -> Void)?
    
    
    private func buildPostData(text: String, voiceType: VoiceType, languageCode: languageCode, pitch: Double, speakingRate: Double) -> Data {
        var voiceParams: [String: Any] = [
            // All available voices here: https://cloud.google.com/text-to-speech/docs/voices
            "languageCode": languageCode.rawValue
        ]
        
        if voiceType != .undefined {
            voiceParams["name"] = voiceType.rawValue
        }
        
        let params: [String: Any] = [
            "input": [
                "text": text
            ],
            "voice": voiceParams,
            "audioConfig": [
                // All available formats here: https://cloud.google.com/text-to-speech/docs/reference/rest/v1beta1/text/synthesize#audioencoding
                "audioEncoding": "LINEAR16",
                "pitch": pitch,
                "speakingRate": speakingRate
            ]
        ]
        
        // Convert the Dictionary to Data
        let data = try! JSONSerialization.data(withJSONObject: params)
        return data
    }
    
    
    /*
     
     DispatchQueue.global(qos: .background).async { [self] in
     do {
     
     try GoogleSpeechService().speak(player: &detailViewController!.player, text: "வணக்கம்", voiceType: .tamilFemale, languageCode: .tamilIndia, pitch: 0, speakingRate: 0.8)
     // Finished speaking
     } catch {
     print(error)
     }
     }
     */
    
    // See example above
    public func speak(player: inout AVAudioPlayer?, text: String, voiceType: VoiceType = .waveNetMale, languageCode: languageCode = .englishUS, pitch: Double = 0, speakingRate: Double = 0.8) throws {
        
        let url = URL(string: ttsAPIUrl)!
        var request = URLRequest(url: url)
        let postData = self.buildPostData(text: text, voiceType: voiceType, languageCode: languageCode, pitch: pitch, speakingRate: speakingRate)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(APIKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let (data, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request)
        if let error = error {
            print("Error in Text to Speech: \(error.localizedDescription)")
        }
        else {
            let json = try JSON(data: data!)
            let audioData = Data(base64Encoded: json["audioContent"].string!)
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            player = try AVAudioPlayer(data: audioData!, fileTypeHint: AVFileType.wav.rawValue)
            player!.play()
        }
        
    }
    
}
