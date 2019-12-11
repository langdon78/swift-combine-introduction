//
//  SoundPlayer.swift
//  PubSubExample
//
//  Created by James Langdon on 12/8/19.
//  Copyright © 2019 corporatelangdon. All rights reserved.
//

import Foundation
import AVFoundation

class SoundPlayer {
    public static let shared: SoundPlayer = {
        return SoundPlayer()
    }()
    
    var player: AVAudioPlayer?
    
    private init() {}
    
    func playSound(for name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}
