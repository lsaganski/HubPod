//
//  HubPlayerViewController.swift
//  HubPodExamples
//
//  Created by Leonardo Saganski on 26/09/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation
import UIKit
import HubPod

class HubPlayerViewController: UIViewController {
    var items = [
        ("http://www.designband.com/wp-content/uploads/2010/05/mustang_sally.mp3",false),
        ("https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.mp4",true),
        ("https://file-examples.com/wp-content/uploads/2017/04/file_example_MP4_640_3MG.mp4",true),
        ("http://designband.com/wp-content/uploads/2012/10/Happy-D.mp3",false)
    ]
    
    override func viewDidLoad() {
        navigationController?.title = "HubPlayer"
        navigationController?.navigationBar.backItem?.title = "BACK"
        
        let img = UIImageView()
        img.image = #imageLiteral(resourceName: "calendar_background")
        img.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(img)
        NSLayoutConstraint.activate([
            img.topAnchor.constraint(equalTo: view.topAnchor),
            img.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            img.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            img.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        let tbl = UITableView()
        tbl.delegate = self
        tbl.dataSource = self
        tbl.translatesAutoresizingMaskIntoConstraints = false
        tbl.backgroundColor = .clear
        tbl.allowsSelection = false
        view.addSubview(tbl)
        NSLayoutConstraint.activate([
            tbl.topAnchor.constraint(equalTo: view.topAnchor),
            tbl.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tbl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        tbl.register(HubPlayerCell.self, forCellReuseIdentifier: "playerCell")
        tbl.rowHeight = UITableView.automaticDimension
        tbl.estimatedRowHeight = 600
    }
}

extension HubPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as? HubPlayerCell else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.player.isVideoPlayer = item.1
        cell.player.urlVideo = item.0
//        cell.player.imagePlay = UIImage(named: "button_play")
//        cell.player.imagePause = UIImage(named: "button_pause")
//        cell.player.imageSoundOn = UIImage(named: "sound_on")
//        cell.player.imageSoundOff = UIImage(named: "sound_off")
        cell.player.colorButtons = .cyan
//        cell.player.colorBarFront = .yellow

        return cell
    }
}

class HubPlayerCell: UITableViewCell {
    let player: HubPlayer = {
        let player = HubPlayer()
        player.translatesAutoresizingMaskIntoConstraints = false
        return player
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        addSubview(player)
        NSLayoutConstraint.activate([
            player.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            player.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            player.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            player.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
}
