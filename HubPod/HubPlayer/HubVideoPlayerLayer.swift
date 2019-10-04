//
//  HubVideoPlayerLayer.swift
//  HubPod
//
//  Created by Leonardo Saganski on 2/10/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation
import AVFoundation

class HubVideoPlayerLayer: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
}
