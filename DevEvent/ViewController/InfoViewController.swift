//
//  InfoViewController.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/17.
//

import UIKit

final class InfoViewController: UIViewController, StoryboardInstantiable {
    
    struct CellTexts {
        let title: String
        let description: String
    }
    
    static var defaultFileName: String = "Main"
    
    @IBOutlet weak var tableView: UITableView!
    
    var coordinator: InfoCoordinator!
    var cellTexts: [CellTexts] = []
    
    var appVersion: String? {
        guard let info = Bundle.main.infoDictionary,
              let currentVersion = info["CFBundleShortVersionString"] as? String else {
            return nil
        }
        
        return currentVersion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView cell의 label에 들어갈 문구
        cellTexts = [
            CellTexts(title: "앱 버전", description: appVersion ?? ""),
            CellTexts(title: "문의 사항", description: "jinhyang.programmer@gmail.com로 메일 부탁드립니다"),
            CellTexts(title: "GitHub", description: "용감하게 도전하는 친구들 _ Why not change the world? 🌐")
        ]
        
        setupTableView()
    }
    
    func setupTableView() {
        let cell = UINib(nibName: InfoTableViewCell.identifier, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: InfoTableViewCell.identifier)
    }
}

extension InfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.identifier, for: indexPath) as? InfoTableViewCell else {
            return UITableViewCell()
        }
        
        let cellText = self.cellTexts[indexPath.row]
        cell.titleLabel.text = cellText.title
        cell.descriptionLabel.text = cellText.description
        
        return cell
    }
}

extension InfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
