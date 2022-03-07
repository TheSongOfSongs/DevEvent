//
//  HomeViewController+UITableViewDelegate.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/07.
//

import UIKit

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
