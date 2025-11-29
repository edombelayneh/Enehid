//
//  RefreshableViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/29/25.
//

import UIKit

class RefreshableViewController: UIViewController {

    private let refreshScrollView = UIScrollView()
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
    }

    private func setupRefreshControl() {
        refreshScrollView.frame = view.bounds
        refreshScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        refreshScrollView.alwaysBounceVertical = true
        refreshScrollView.backgroundColor = .clear
        refreshScrollView.showsVerticalScrollIndicator = false

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshScrollView.refreshControl = refreshControl

        view.addSubview(refreshScrollView)

        // 🔽 Ensure the refreshScrollView stays behind all your actual content
        view.sendSubviewToBack(refreshScrollView)
    }

    @objc func handleRefresh() {
        // To be overridden by subclass
        print("🔄 Refresh triggered – override in subclass.")
        endRefreshing()
    }

    func endRefreshing() {
        refreshControl.endRefreshing()
    }
}

