//
//  SoundEffectPlayer.swift
//  CalloverDesktop
//
//  Created by Leonid  on 10.06.26.
//

import AVFoundation

final class SoundEffectPlayer {
    static let shared = SoundEffectPlayer()
    
    private var player: AVAudioPlayer?
    private var currentSoundName: String?
    
    private init() {}
    
    func playLoop(name: String, extension fileExtension: String = "mp3") {
        if currentSoundName == name, player?.isPlaying == true {
            return
        }
        
        stop()
        
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: fileExtension
        ) else {
            print("Sound file not found: \(name).\(fileExtension)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
            
            self.player = player
            self.currentSoundName = name
        } catch {
            print("Failed to play sound:", error)
        }
    }
    
    func playOnce(name: String, extension fileExtension: String = "mp3") {
        stop()
        
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: fileExtension
        ) else {
            print("Sound file not found: \(name).\(fileExtension)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.play()
            
            self.player = player
            self.currentSoundName = name
        } catch {
            print("Failed to play sound:", error)
        }
    }
    
    func stop() {
        player?.stop()
        player?.currentTime = 0
        player = nil
        currentSoundName = nil
    }
}
