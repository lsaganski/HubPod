//
//  HubPlayer.swift
//  HubPod
//
//  Created by Leonardo Saganski on 26/09/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation
import AVFoundation

@IBDesignable
public final class HubPlayer: UIView {
    @IBInspectable public var isVideoPlayer: Bool = true {
        didSet {
            initHubVideoPlayer()
        }
    }
    @IBInspectable public var imagePlay: UIImage? = nil {
        didSet {
            configUIPlay()
        }
    }
    @IBInspectable public var imagePause: UIImage? = nil {
        didSet {
            configUIPlay()
        }
    }
    @IBInspectable public var imageSoundOn: UIImage? = nil {
        didSet {
            configUISound()
        }
    }
    @IBInspectable public var imageSoundOff: UIImage? = nil {
        didSet {
            configUISound()
        }
    }
    @IBInspectable public var imageProgress: UIImage? = nil {
        didSet {
            configProgress()
        }
    }
    @IBInspectable public var colorButtons: UIColor? {
        didSet {
            configUIColor()
        }
    }
    @IBInspectable public var colorBarFront: UIColor? {
        didSet {
            configUIColor()
        }
    }
    // UI components
    var viewContainer = UIView(frame: .zero)
    var viewVideo = HubVideoPlayerLayer(frame: .zero)
    var viewControls = UIView(frame: .zero)
    var buttonPlay = UIButton(type: .custom)
    var progressBar = UISlider(frame: .zero)
    var labelTime = UILabel(frame: .zero)
    var buttonMute = UIButton(type: .custom)
    var loading = UIActivityIndicatorView(frame: .zero)
    // player variables
    private var player = AVPlayer()
    private var playerItem: AVPlayerItem?
    var timeObserverToken: Any?
    var observerPlayerItemStatus: NSKeyValueObservation?
    public var urlVideo: String = "" {
        didSet {
            updateURL()
        }
    }
    var playing = false
    var resourceBundle: Bundle?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initHubVideoPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initHubVideoPlayer()
    }
    
    override public func prepareForInterfaceBuilder() {
        initHubVideoPlayer()
    }
    
    func initHubVideoPlayer() {
        //        let audioSession = AVAudioSession.sharedInstance()
        //        do {
        //            try audioSession.setCategory(.playback, mode: .moviePlayback)
        //        }
        //        catch {
        //            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        //        }
        
        resourceBundle = Bundle(identifier: "br.com.itaubba.HubPod") 

        createComponents()
        configUI()
        if isVideoPlayer {
            viewVideo.player = player
        }
    }
    
    func createComponents() {
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        viewVideo.translatesAutoresizingMaskIntoConstraints = false
        viewControls.translatesAutoresizingMaskIntoConstraints = false
        buttonPlay.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        labelTime.translatesAutoresizingMaskIntoConstraints = false
        buttonMute.translatesAutoresizingMaskIntoConstraints = false
        loading.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(viewContainer)
        if isVideoPlayer {
            viewContainer.addSubview(viewVideo)
        }
        viewContainer.addSubview(viewControls)
        viewControls.addSubview(buttonPlay)
        viewControls.addSubview(progressBar)
        viewControls.addSubview(labelTime)
        viewControls.addSubview(buttonMute)
        viewControls.addSubview(loading)
        
        let controlsHeight = CGFloat(40)
        
        if isVideoPlayer {
            let ratioWidth = CGFloat(16)
            let ratioHeight = CGFloat(9)
            NSLayoutConstraint.activate([
                viewVideo.topAnchor.constraint(equalTo: viewContainer.topAnchor, constant: 0),
                viewVideo.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 0),
                viewVideo.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: 0),
                viewVideo.heightAnchor.constraint(equalTo: viewVideo.widthAnchor, multiplier: ratioHeight/ratioWidth)
                ])
        }
        
        NSLayoutConstraint.activate([
            viewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            viewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            viewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            viewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            
            viewControls.topAnchor.constraint(equalTo: isVideoPlayer ?
                viewVideo.bottomAnchor : viewContainer.topAnchor, constant: 10),
            viewControls.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor, constant: 0),
            viewControls.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 0),
            viewControls.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: 0),
            viewControls.heightAnchor.constraint(equalToConstant: controlsHeight),
            
            buttonPlay.topAnchor.constraint(equalTo: viewControls.topAnchor),
            buttonPlay.bottomAnchor.constraint(equalTo: viewControls.bottomAnchor),
            buttonPlay.leadingAnchor.constraint(equalTo: viewControls.leadingAnchor, constant: 10),
            buttonPlay.trailingAnchor.constraint(equalTo: progressBar.leadingAnchor, constant: -10),
            buttonPlay.heightAnchor.constraint(equalToConstant: controlsHeight),
            buttonPlay.widthAnchor.constraint(equalToConstant: controlsHeight),

            loading.topAnchor.constraint(equalTo: viewControls.topAnchor),
            loading.bottomAnchor.constraint(equalTo: viewControls.bottomAnchor),
            loading.leadingAnchor.constraint(equalTo: viewControls.leadingAnchor, constant: 10),
            loading.trailingAnchor.constraint(equalTo: progressBar.leadingAnchor, constant: -10),
            loading.heightAnchor.constraint(equalToConstant: controlsHeight),
            loading.widthAnchor.constraint(equalToConstant: controlsHeight),
            
            progressBar.centerYAnchor.constraint(equalTo: viewControls.centerYAnchor),
            progressBar.trailingAnchor.constraint(equalTo: labelTime.leadingAnchor, constant: -10),
            
            labelTime.trailingAnchor.constraint(equalTo: buttonMute.leadingAnchor, constant: -10),
            labelTime.centerYAnchor.constraint(equalTo: viewControls.centerYAnchor),
            labelTime.widthAnchor.constraint(equalToConstant: controlsHeight),
            
            buttonMute.topAnchor.constraint(equalTo: viewControls.topAnchor),
            buttonMute.bottomAnchor.constraint(equalTo: viewControls.bottomAnchor),
            buttonMute.trailingAnchor.constraint(equalTo: viewControls.trailingAnchor, constant: -10),
            buttonMute.heightAnchor.constraint(equalToConstant: controlsHeight),
            buttonMute.widthAnchor.constraint(equalToConstant: controlsHeight)
            ])
        
        buttonPlay.setContentHuggingPriority(.defaultLow, for: .horizontal)
        progressBar.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        labelTime.setContentHuggingPriority(.defaultLow, for: .horizontal)
        buttonMute.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        buttonPlay.addTarget(self, action: #selector(onPressPlay), for: .touchUpInside)
        buttonMute.addTarget(self, action: #selector(onPressMute), for: .touchUpInside)

        loading.hidesWhenStopped = true
        loading.style = .whiteLarge
        loading.stopAnimating()

        progressBar.isContinuous = true
        progressBar.backgroundColor = .clear
        progressBar.addTarget(self, action: #selector(onChangedProgressValue(_:)), for: .valueChanged)
        
        player.volume = 1.0
    }
    
    func configProgressView() {
        let duration : CMTime = player.currentItem?.asset.duration ?? CMTime()   // asset.
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        progressBar.maximumValue = Float(seconds)
        progressBar.minimumValue = 0
    }
    
    func configUI() {
        configUIPlay()
        configUISound()
        configProgress()
        viewVideo.borderWidth = 1
        labelTime.font = .systemFont(ofSize: 12)
        labelTime.textAlignment = .center
        labelTime.text = "00:00"
        configUIColor()
    }
    
    func configProgress() {
        if let imgBar = imageProgress {
            progressBar.setThumbImage(imgBar.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    func configUIColor() {
        viewVideo.borderColor = colorButtons ?? .black
        loading.color = colorButtons ?? .black
        progressBar.tintColor = colorBarFront ?? .black
        progressBar.thumbTintColor = colorButtons ?? .black
        labelTime.textColor = colorButtons ?? .black
        buttonPlay.tintColor = colorButtons ?? .black
        buttonMute.tintColor = colorButtons ?? .black
        layoutIfNeeded()
    }

    func configUISound() {
        if player.volume == 0.0 {
            if let imgOff = imageSoundOff {
                buttonMute.setImage(imgOff.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                let img = UIImage(name: "sound_off", bundleOf: self)
                buttonMute.setImage(img?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        } else {
            if let imgOn = imageSoundOn {
                buttonMute.setImage(imgOn.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                var img = UIImage(name: "sound_on", bundleOf: self)
                if img != nil {
                    print("imgok para Jonas")
                } else {
                    img = UIImage(named: "sound_on")
                    if img != nil {
                        print("imgok para named normal")
                    } else {
                        img = #imageLiteral(resourceName: "sound_on.png")
                        if img != nil {
                            print("imgok para literal")
                        } else {
                            resourceBundle = Bundle(identifier: "br.com.itaubba.HubPod")
                            img = UIImage(named: "sound_on", in: resourceBundle, compatibleWith: nil)
                            if img != nil {
                                print("imgok para bundle identifier")
                            } else {
                                resourceBundle = Bundle(for: HubPlayer.self)
                                img = UIImage(named: "sound_on", in: resourceBundle, compatibleWith: nil)
                                if img != nil {
                                    print("imgok para bundle for class")
                                } else {
                                    print("imgok NOT OK")
                                }
                            }
                        }
                    }
                }
                buttonMute.setImage(img?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
        
        configUIColor()
    }
    
    func configUIPlay() {
//        print("Bundle Path: \(resourceBundle?.bundlePath ?? "")")
//        print("Bundle URL: \(resourceBundle?.bundleURL.absoluteString ?? "")")
//        print("Bundle Identifier: \(resourceBundle?.bundleIdentifier ?? "")")
        if playing {
            if let imgPause = imagePause {
                buttonPlay.setImage(imgPause.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                let img = UIImage(name: "button_pause", bundleOf: self)
                //let img = UIImage(named:"button_pause")?.withRenderingMode(.alwaysTemplate)  // , in: resourceBundle, compatibleWith: nil
                buttonPlay.setImage(img, for: .normal)
//                print("imgPause : \(img?.description ?? "imgPause not found")")
            }
        } else {
            if let imgPlay = imagePlay {
                buttonPlay.setImage(imgPlay.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                let img = UIImage(name: "button_play", bundleOf: self)
//                let img = UIImage(named:"button_play")?.withRenderingMode(.alwaysTemplate)
                buttonPlay.setImage(img, for: .normal)
//                print("imgPlay : \(img?.description ?? "imgPlay not found")")
            }
        }
        
        configUIColor()
    }
    
    func updateURL() {
        buttonPlay.isHidden = true
        loading.startAnimating()
        if let url = URL(string: self.urlVideo) {
            let asset = AVURLAsset(url: url)
            self.playerItem = AVPlayerItem(asset: asset)
            if let item = self.playerItem {
                
                self.observerPlayerItemStatus = playerItem?.observe(\.status, options:  [.new, .old], changeHandler: {
                    [weak self]
                    (item, change) in
                    if item.status == .readyToPlay {
                        guard let self = self else { return }
                        self.loading.stopAnimating()
                        self.buttonPlay.isHidden = false
                        self.observerPlayerItemStatus?.invalidate()
                    }
                })

                DispatchQueue.main.async {
                    self.player.replaceCurrentItem(with: item)
                    self.configProgressView()
                }
            }
        }
    }
    
    @objc
    func onPressPlay() {
        if player.currentItem != nil {
            if playing {
                pause()
            } else {
                play()
            }
        }
    }
    
    @objc
    func onPressMute() {
        player.volume = player.volume == 0.0 ? 1.0 : 0.0
        configUISound()
    }
    
    deinit {
        removeObservers()
    }
    
    @objc
    func onChangedProgressValue(_ slider:UISlider)
    {
        let seconds : Int64 = Int64(slider.value)
        let cmTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player.seek(to: cmTime)
        
        if player.rate == 0
        {
            play()
        }
    }
    
    func play() {
        player.play()
        addObservers()
        playing = true
        configUIPlay()
    }
    
    func pause() {
        player.pause()
        removeObservers()
        playing = false
        configUIPlay()
    }
    
    func addObservers() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1.0, preferredTimescale: timeScale)
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                           queue: .main) {
                                                            [weak self] time in
                                                            guard let self = self else { return }
                                                            self.labelTime.text = time.toString
                                                            self.progressBar.setValue(Float(time.seconds), animated: true)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func removeObservers() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc
    func finishedPlaying(myNotification:NSNotification) {
        playing = false
        configUIPlay()
        player.seek(to: CMTime.zero)
    }
}

extension CMTime {
    var toString:String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
