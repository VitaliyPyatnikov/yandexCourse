//
//  RootViewController.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 01.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - RootViewController

final class RootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarItems()
    }

    // MARK: - Private

    private func setupTabBarItems() {
        guard let viewControllers = viewControllers else {
            return
        }
        viewControllers.forEach { navigationController in
            guard let navController = navigationController as? UINavigationController else {
                return
            }
            if let _ = navController.viewControllers.first as? NotesViewController {
                navController.tabBarItem = UITabBarItem(title: "Notes", image: #imageLiteral(resourceName: "Rectangle.pdf"), tag: 0)
            }
            if let _ = navController.viewControllers.first as? GalleryViewController {
                navController.tabBarItem = UITabBarItem(title: "Gallery", image: #imageLiteral(resourceName: "Rectangle.pdf"), tag: 1)
            }
        }
    }
}
