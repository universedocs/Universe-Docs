//
//  SwiftGoogleTranslate.swift
//  SwiftGoogleTranslate
//
//  Created by Maxim on 10/29/18.
//  Copyright © 2018 Maksym Bilan. All rights reserved.
//
//Copyright 2020 Kumar Muthaiah
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
import UIKit
import AVFoundation
import SwiftyJSON

// for other codes check: https://cloud.google.com/text-to-speech/docs/voices
public enum VoiceType: String {
    case undefined
    case englishWaveNetFemale = "en-US-Wavenet-F"
    case englishWaveNetMale = "en-US-Wavenet-D"
    case englishStandardFemale = "en-US-Standard-E"
    case englishStandardMale = "en-US-Standard-D"
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

public var speakingRateDefaultMap: [String: Double] = [
    "ta-IN": 0.7,
    "en-US": 0.8,
    "hi-IN": 0.8,
    "ja-JP": 0.7
]

// for other codes check: https://cloud.google.com/text-to-speech/docs/voices
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
        var speakingRateLocal: Double  = 0
        
        if speakingRate > 0 {
            speakingRateLocal = speakingRate
        } else {
            speakingRateLocal = speakingRateDefaultMap[languageCode.rawValue]!
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
                "speakingRate": speakingRateLocal
            ]
        ]
        
        // Convert the Dictionary to Data
        let data = try! JSONSerialization.data(withJSONObject: params)
        return data
    }
    
    
    /*
     DispatchQueue.global(qos: .background).async { [self] in
     do {
     
     try TextToSpeechUtility().speak(player: &detailViewController!.player, text: "வணக்கம்", voiceType: .tamilFemale, languageCode: .tamilIndia, pitch: 0, speakingRate: 0.8)
     try TextToSpeechUtility().speak(player: &detailViewController!.aviAudioPlayer, text: "एक किसान था, वह अपने खेतों में काम कर घर लौट रहा था। रास्ते में ही एक हलवाई की दुकान थी। उस दिन किसान ने कुछ ज्‍यादा काम कर लिया था और उसे भूख भी बहुत लग रही थी। ऐसे में जब वह हलवाई की दुकान के पास से गुजरा तो उसे मिठाइयों की खुशबू आने लगी। वह वहां खुद को रोके बिना नहीं रह पाया। लेकिन उस दिन उसके पास ज्यादा पैसे नहीं थे, ऐसे में वह मिठाई खरीद नहीं सकता था, तब वह कुछ देर वहीं खड़े होकर मिठाइयों की सुगंध का आनंद लेने लगा।", voiceType: .hindiWaveNetFemale, languageCode: .hindiIndia, pitch: 0, speakingRate: 0)
     
     try TextToSpeechUtility().speak(player: &detailViewController!.aviAudioPlayer, text: "彼の畑で働いて家に帰る農夫がいました。途中でお菓子がありました。その日、農夫はもっと仕事をしていて、彼もお腹がすいた。そんな中、菓子屋さんを通りかかったとき、お菓子の匂いがし始めました。彼は立ち止まらずにそこに住むことはできなかった。でもその日はお金がなかったのでお菓子が買えなかったので、しばらくそこに立ってお菓子の香りを楽しみ始めました", voiceType: .japaneseWaveNetFemale, languageCode: .japaneseJapan, pitch: 0, speakingRate: 0)
     // Finished speaking
     } catch {
     print(error)
     }
     }
     */
    
    // See example above
    public func speak(player: inout AVAudioPlayer?, text: String, voiceType: VoiceType = .englishWaveNetMale, languageCode: languageCode = .englishUS, pitch: Double = 0, speakingRate: Double = 0.0) throws {
        
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
