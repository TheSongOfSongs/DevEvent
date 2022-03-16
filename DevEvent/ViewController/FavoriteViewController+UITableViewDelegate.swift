//
//  FavoriteViewController+UITableViewDelegate.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/17.
//

import UIKit

extension FavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
