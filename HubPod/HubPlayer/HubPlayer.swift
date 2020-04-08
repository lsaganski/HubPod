//
//  HubPlayer.swift
//  HubPod
//
//  Created by Leonardo Saganski on 26/09/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

public protocol HubPlayerDelegate: class {
    func didStartPlaying()
}

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
    @IBInspectable public var colorBarBack: UIColor? {
        didSet {
            configUIColor()
        }
    }
    @IBInspectable public var horizontalPaddingControls: CGFloat = 0.0 {
        didSet {
//            initHubVideoPlayer()
            configUIPlay()
        }
    }
    // UI components
    var viewContainer = UIView(frame: .zero)
    var viewVideo = HubVideoPlayerLayer(frame: .zero)
    var viewControls = UIView(frame: .zero)
    var buttonPlay = UIButton(type: .custom)
    var progressBar = CustomSlider(frame: .zero)
    var labelTime = UILabel(frame: .zero)
    var buttonMute = UIButton(type: .custom)
    var buttonFull = UIButton(type: .custom)
    var loading = UIActivityIndicatorView(frame: .zero)
    var space = UIView(frame: .zero)
    // player variables
    private var player = AVPlayer()
    private var playerItem: AVPlayerItem?
    var timeObserverToken: Any?
    var observerPlayerItemStatus: NSKeyValueObservation?
    var constraintLeadingControls: NSLayoutConstraint?
    var constraintTraillingControls: NSLayoutConstraint?
    var constraintWidthSpace: NSLayoutConstraint?
    var constraintTraillingMute: NSLayoutConstraint?
    var delegate: HubPlayerDelegate?
    
    public var hostVC = UIViewController() {
        didSet {
            updateHost()
        }
    }
    
    public var urlVideo: String = "" {
        didSet {
            updateURL()
        }
    }
    var playing = false
    
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
        
        createComponents()
        configUI()
        if isVideoPlayer {
            viewVideo.player = player
        }
    }
    
    func updateHost() {
//        hostVC.addChild(playerVC)
    }
    
    func createComponents() {
//        viewContainer = UIView(frame: .zero)
//        viewControls = UIView(frame: .zero)
        
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        viewVideo.translatesAutoresizingMaskIntoConstraints = false
        viewControls.translatesAutoresizingMaskIntoConstraints = false
        buttonPlay.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        labelTime.translatesAutoresizingMaskIntoConstraints = false
        buttonMute.translatesAutoresizingMaskIntoConstraints = false
        buttonFull.translatesAutoresizingMaskIntoConstraints = false
        loading.translatesAutoresizingMaskIntoConstraints = false
        space.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(viewContainer)
        if isVideoPlayer {
            viewContainer.addSubview(viewVideo)
            viewContainer.addSubview(buttonFull)
            let imgFull = #imageLiteral(resourceName: "fullscreen") //UIImage(name: "fullscreen", bundleOf: self)
            buttonFull.setImage(imgFull.withRenderingMode(.alwaysTemplate), for: .normal)
            buttonFull.tintColor = .white
            buttonFull.alpha = 0.3
        }
        buttonFull.isHidden = !isVideoPlayer

        viewContainer.addSubview(viewControls)
        viewControls.addSubview(buttonPlay)
        viewControls.addSubview(progressBar)
        viewControls.addSubview(labelTime)
        viewControls.addSubview(buttonMute)
        viewControls.addSubview(loading)
        viewControls.addSubview(space)

        let controlsHeight = CGFloat(28)

        if isVideoPlayer {
            let videoRatioWidth = CGFloat(16)
            let videoRatioHeight = CGFloat(9)
            NSLayoutConstraint.activate([
                viewVideo.topAnchor.constraint(equalTo: viewContainer.topAnchor, constant: 0),
                viewVideo.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 0),
                viewVideo.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: 0),
                viewVideo.heightAnchor.constraint(equalTo: viewVideo.widthAnchor, multiplier: videoRatioHeight/videoRatioWidth),
                
                buttonFull.topAnchor.constraint(equalTo: viewVideo.topAnchor, constant: 10),
                buttonFull.trailingAnchor.constraint(equalTo: viewVideo.trailingAnchor, constant: -10),
                buttonFull.heightAnchor.constraint(equalToConstant: controlsHeight),
                buttonFull.widthAnchor.constraint(equalToConstant: controlsHeight)
                ])
        }
        
//        let ratioWidth = CGFloat(35)
//        let ratioHeight = CGFloat(4)
        NSLayoutConstraint.activate([
            viewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            viewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            viewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            viewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            
            viewControls.topAnchor.constraint(equalTo: isVideoPlayer ?
                viewVideo.bottomAnchor : viewContainer.topAnchor, constant: 10),
            viewControls.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 0),
            viewControls.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: 0),
            viewControls.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor, constant: 0),
            viewControls.heightAnchor.constraint(equalToConstant: controlsHeight), // equalTo: viewContainer.widthAnchor, multiplier: ratioHeight/ratioWidth),
//            viewControls.heightAnchor.constraint(equalToConstant: controlsHeight),
            
            space.centerYAnchor.constraint(equalTo: viewControls.centerYAnchor),
            space.leadingAnchor.constraint(equalTo: viewControls.leadingAnchor),
            space.heightAnchor.constraint(equalToConstant: 10),
            
            buttonPlay.topAnchor.constraint(equalTo: viewControls.topAnchor),
            buttonPlay.bottomAnchor.constraint(equalTo: viewControls.bottomAnchor),
            buttonPlay.trailingAnchor.constraint(equalTo: progressBar.leadingAnchor, constant: -15),
            buttonPlay.leadingAnchor.constraint(equalTo: space.trailingAnchor, constant: 0),
            buttonPlay.heightAnchor.constraint(equalToConstant: controlsHeight),
            buttonPlay.widthAnchor.constraint(equalToConstant: controlsHeight),

            loading.topAnchor.constraint(equalTo: viewControls.topAnchor),
            loading.bottomAnchor.constraint(equalTo: viewControls.bottomAnchor),
            loading.leadingAnchor.constraint(equalTo: space.trailingAnchor, constant: 0),
            loading.trailingAnchor.constraint(equalTo: progressBar.leadingAnchor, constant: -15),
            loading.heightAnchor.constraint(equalToConstant: controlsHeight),
            loading.widthAnchor.constraint(equalToConstant: controlsHeight),
            
            progressBar.centerYAnchor.constraint(equalTo: viewControls.centerYAnchor),
            progressBar.trailingAnchor.constraint(equalTo: labelTime.leadingAnchor, constant: -11),
            
            labelTime.trailingAnchor.constraint(equalTo: buttonMute.leadingAnchor, constant: -23),
            labelTime.centerYAnchor.constraint(equalTo: viewControls.centerYAnchor),
            labelTime.widthAnchor.constraint(equalToConstant: 40),
            
//            buttonMute.topAnchor.constraint(equalTo: viewControls.topAnchor),
//            buttonMute.bottomAnchor.constraint(equalTo: viewControls.bottomAnchor),
            buttonMute.centerYAnchor.constraint(equalTo: viewControls.centerYAnchor),
            buttonMute.heightAnchor.constraint(equalToConstant: 20),
            buttonMute.widthAnchor.constraint(equalToConstant: 20)
            ])
        
        constraintWidthSpace = space.widthAnchor.constraint(equalToConstant: 0)
        constraintTraillingMute = buttonMute.trailingAnchor.constraint(equalTo: viewControls.trailingAnchor, constant: 0)

        constraintWidthSpace?.isActive = true
        constraintTraillingMute?.isActive = true
        
        buttonPlay.setContentHuggingPriority(.defaultLow, for: .horizontal)
        progressBar.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        labelTime.setContentHuggingPriority(.defaultLow, for: .horizontal)
        buttonMute.setContentHuggingPriority(.defaultLow, for: .horizontal)
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)

        buttonPlay.addTarget(self, action: #selector(onPressPlay), for: .touchUpInside)
        buttonMute.addTarget(self, action: #selector(onPressMute), for: .touchUpInside)
        buttonFull.addTarget(self, action: #selector(expandVideo), for: .touchUpInside)

        loading.hidesWhenStopped = true
        loading.style = .white
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
        labelTime.font = .systemFont(ofSize: 13)
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
        viewVideo.borderColor = .clear //colorButtons ?? .black
        loading.color = colorButtons ?? .itauDarkGray
//        progressBar.tintColor = colorBarFront ?? .black
        progressBar.minimumTrackTintColor = colorBarFront ?? .itauOrange
        progressBar.maximumTrackTintColor = colorBarBack ?? .itauLightGray
        progressBar.thumbTintColor = .clear
        labelTime.textColor = colorButtons ?? .itauDarkGray
        buttonPlay.tintColor = colorButtons ?? .itauDarkGray
        buttonMute.tintColor = colorButtons ?? .itauDarkGray
        if isVideoPlayer {
        }

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
                let img = UIImage(name: "sound_on", bundleOf: self)
                buttonMute.setImage(img?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
        
        configUIColor()
    }
    
    func configUIPlay() {
        if playing {
            if let imgPause = imagePause {
                buttonPlay.setImage(imgPause.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                let img = UIImage(name: "button_pause", bundleOf: self)
                buttonPlay.setImage(img?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        } else {
            if let imgPlay = imagePlay {
                buttonPlay.setImage(imgPlay.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                let img = UIImage(name: "button_play", bundleOf: self)
                buttonPlay.setImage(img?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
        
        if isVideoPlayer {
        }
        
        constraintTraillingMute?.isActive = false
        constraintTraillingMute?.constant = -horizontalPaddingControls
        constraintTraillingMute?.isActive = true
        constraintWidthSpace?.isActive = false
        constraintWidthSpace?.constant = horizontalPaddingControls
        constraintWidthSpace?.isActive = true
        layoutIfNeeded()

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
                        self.configProgressView()
                    }
                })

                DispatchQueue.main.async {
                    self.player.replaceCurrentItem(with: item)
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
        delegate?.didStartPlaying()
        player.play()
        addObservers()
        playing = true
        configUIPlay()
    }
    
    public func pause() {
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
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("avPlayerDidDismiss"), object: nil)
//        player.removeObserver(self, forKeyPath: “timeControlStatus”)
    }
    
    @objc
    func finishedPlaying(myNotification:NSNotification) {
        playing = false
        configUIPlay()
        player.seek(to: CMTime.zero)
    }
    
    @objc func expandVideo()  {
        player.pause()
        let controller = AVPlayerViewController()
        controller.player = player
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerClosed), name: Notification.Name("avPlayerDidDismiss"), object: nil)
        hostVC.present(controller, animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.player.play()
            }
        }
    }

    @objc func avPlayerClosed(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.player.play()
        }
    }
}

extension AVPlayerViewController {
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player?.pause()
        NotificationCenter.default.post(name: Notification.Name("avPlayerDidDismiss"), object: nil, userInfo: nil)
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

class CustomSlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let height = CGFloat(6)
        let customBounds = CGRect(origin: CGPoint(x: bounds.origin.x, y: (bounds.size.height/2)+1-(height/2)), size: CGSize(width: bounds.size.width, height: height))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
}
