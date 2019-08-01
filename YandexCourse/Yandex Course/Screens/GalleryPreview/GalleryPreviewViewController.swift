//
//  GalleryPreviewViewController.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 01.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - GalleryPreviewViewController

final class GalleryPreviewViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var images: [UIImage]?
    var selectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollViewData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for (index, imageView) in imageViews.enumerated() {
            imageView.frame.size = scrollView.frame.size
            imageView.frame.origin.x = scrollView.frame.width * CGFloat(index)
            imageView.frame.origin.y = 0
        }

        let contentWidth = scrollView.frame.width * CGFloat(imageViews.count)
        scrollView.contentSize = CGSize(width: contentWidth,
                                        height: scrollView.frame.height)
        scrollToCurrentView()
    }

    // MARK: - Private

    private var imageViews = [UIImageView]()

    private func setupScrollViewData() {
        scrollView.isPagingEnabled = true
        guard let images = images else {
            return
        }
        for image in images {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            scrollView.addSubview(imageView)
            imageViews.append(imageView)
        }
    }
    private func scrollToCurrentView() {
        guard let index = selectedIndex else {
            return
        }
        let point = CGPoint(x: scrollView.frame.width * CGFloat(index),
                            y: 0)
        scrollView.setContentOffset(point, animated: false)
    }
}
