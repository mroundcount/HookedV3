//
//  AudioRadarViewController + ExtensionTest.swift
//  Hooked
//
//  Created by Michael Roundcount on 1/11/21.
//  Copyright © 2021 Michael Roundcount. All rights reserved.
//

import Foundation
import UIKit
import LNPopupController
import AVFoundation
import AVKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

extension AudioRadarViewController {


    func testDownloadFile(audio: Audio) {
        loadingInidcator.startAnimating()
                        
        print("The title is \(audio.title)")
        
        let url = NSURL(string: audio.audioUrl)
        
        print("getting url for \(String(describing: url))")
        
        playerItem = AVPlayerItem(url: url! as URL)
        player = AVPlayer(playerItem: playerItem!)
        let playerLayer = AVPlayerLayer(player: player!)
        playerLayer.frame=CGRect(x: 0, y: 0, width: 300, height: 50)
        self.view.layer.addSublayer(playerLayer)

        startTime = Int(audio.startTime)
        stopTime = Int(audio.stopTime)

        testPlayAudioFromBeginning()
    }
    
    
    @objc func playImgDidTap() {
        if recordStatus == "Playing" {
            testPauseAudio()
        } else if recordStatus == "Paused" {
            testPlayAudio()
        } else if recordStatus == "Finished" {
            testReplayAudio()
        } else {
        }
    }
    
    @objc func stopImgDidTap() {
        testTotalReplayAudio()
    }
    
    
    func testPlayAudioFromBeginning() {
        //print("In testPlayAudioFromBeginning")
        audioSettings()
        //loadingInidcator.stopAnimating()
        player?.play()
        player?.seek(to:CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: 1))
        testStartTimer()
        recordStatus = "Playing"
        playImg.isHidden = false
        playImg.image = UIImage(systemName: "pause.circle")
        stopImg.image = UIImage(named: "refresh_circle")
    }
    
    func testPlayAudio() {
        //print("In testPlayAudio")
        player?.play()
        recordStatus = "Playing"
        playImg.image = UIImage(systemName: "pause.circle")
        stopImg.image = UIImage(named: "refresh_circle")
    }
    
    func testPauseAudio() {
        //print("In testPauseAudio")
        player?.pause()
        recordStatus = "Paused"
        playImg.image = UIImage(systemName: "play.circle")
    }

    func testStopAudio() {
        //print("In testStopAudio")
        player?.pause()
        player?.seek(to: .zero)
        recordStatus = "Stopped"
        testStopTimer()
        playImg.isHidden = true
        stopImg.image = UIImage(named: "refresh_circle")
    }
    
    func testReplayAudio() {
        //print("In testReplayAudio")
        testDownloadFile(audio: (cards.first?.audio)!)
        recordStatus = "Playing"
        playImg.isHidden = false
        playImg.image = UIImage(systemName: "pause.circle")
        stopImg.image = UIImage(named: "refresh_circle")
    }
    
    func testTotalReplayAudio() {
        //print("testTotalReplayAudio tapped")
        player?.pause()
        player?.seek(to: .zero)
        
        testDownloadFile(audio: (cards.first?.audio)!)
        recordStatus = "Playing"
        //playImg.isHidden = false
        playImg.isHidden = false
        playImg.image = UIImage(systemName: "pause.circle")
    }
  
    
    func testAudioPlayerDidFinishPlaying(note: NSNotification) {
        //print("testAudioPlayerDidFinishPlaying")
        player?.pause()
        player?.seek(to: .zero)
        recordStatus = "Finished"
        playImg.isHidden = true
        playImg.image = UIImage(named: "play")
        //stopImg.image = UIImage(systemName: "arrow.uturn.left.circle")
        stopImg.image = UIImage(named: "refresh_circle")
    }

    
    func testStartTimer() {
        print("in timer")
        DispatchQueue.main.async { [self] in
            if(timer == nil) {
                timer = Timer.scheduledTimer(
                timeInterval: 0.1,
                target: self,
                selector: #selector(testUpdateSlider),
                userInfo: nil,
                repeats: true)
            }
        }
    }
    
    func testStopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func testGetCurrentTime() -> TimeInterval {
        if player != nil {
            return (player?.currentItem?.currentTime().seconds) as! TimeInterval
        }
    return 0.0
    }
    
    @objc func testUpdateSlider() {
        let prog = Float(testGetCurrentTime())
        
        if prog > Float(startTime) {
            loadingInidcator.stopAnimating()
            loadingInidcator.hidesWhenStopped = true
        }
        
        if prog > Float(stopTime) {
            testStopAudio()
        }
    }
    
    
    func audioSettings() {
        //Playing the audio without the silencer being turned off
        //https://stackoverflow.com/questions/35289918/play-audio-when-device-in-silent-mode-ios-swift
        do {
           try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
        
        //Enabling audio to play in the background
        //https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/configuring_ios_and_tvos_audio_playback_behavior
        //https://stackoverflow.com/questions/30280519/how-to-play-audio-in-background-with-swift
        /*
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        } */
    }
    
    
    //I don' think these were every actually used anywhere. Haning on to for reference right now.
    /*
    func testGetLengthOfAudio() -> TimeInterval {
          if audioPlayer != nil {
              if audioPlayer.isPlaying {
                  return audioPlayer.duration
              }
          }
      return 0.0
      }
    
    func testGotAudioLength() {
        self.length = Float(getLengthOfAudio())
        //print("length from gotAudio\(String(describing: length))")
        DispatchQueue.main.async {
            //self.slider.maximumValue = self.length!
            self.startTimer()
        }
    } */
    
    
}


