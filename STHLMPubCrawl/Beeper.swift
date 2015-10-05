//
//  Beeper.swift
//  PubCrawl
//
//  Created by Agust Rafnsson on 20/09/15.
//  Copyright © 2015 Agust Rafnsson. All rights reserved.
//

import Foundation
import AVFoundation

class Beeper {
    static let sharedBeeper = Beeper()
    
    let audioPlayer:AVAudioPlayer?
    
    init?(){
        let url = NSBundle.mainBundle().URLForResource("beep", withExtension: "wav")
        do{
            try audioPlayer = AVAudioPlayer(contentsOfURL: url!)
        }catch {
            // print("Player not available")
            audioPlayer = nil
            return nil
        }
    }
    
    
    func playBeep(){
        self.audioPlayer?.play()
       // print("beeping")
    }
}