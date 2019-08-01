//
//  GalleryViewController.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 28.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - GalleryWorker

protocol GalleryWorker: class {
    func add(image: UIImage)
}

// MARK: - GalleryViewController

final class GalleryViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GalleryPreviewSegue" {
            guard let destinationViewController = segue.destination as? GalleryPreviewViewController else {
                return
            }
            destinationViewController.images = images
            destinationViewController.selectedIndex = selectedIndex
        }
    }

    // MARK: - Private

    private var images: [UIImage] = [UIImage]()
    private var selectedIndex: Int?
    private let inset: CGFloat = 0.5
    private let spaceBetweenCels: CGFloat = 8
    private let cellsPerRow = 4

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "GalleryCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "GalleryCollectionViewCell")
    }
    private func setupNavigationBar() {
        title = "Gallery"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addNewImage))
    }
    @objc private func addNewImage() {
        let pickerViewController = GalleryImagePickerController()
        pickerViewController.pickerDelegate = self
        present(pickerViewController, animated: true, completion: nil)
    }
    private func selectImage(at indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "GalleryPreviewSegue", sender: self)
    }
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as? GalleryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setup(with: images[indexPath.row])

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCels
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCels
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let safeAreaInsetsSum = CGFloat(0)
        let marginsAndInsets = inset * 2 + safeAreaInsetsSum + spaceBetweenCels * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow))
        return CGSize(width: itemWidth, height: itemWidth)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectImage(at: indexPath)
    }
}

// MARK: - GalleryWorker

extension GalleryViewController: GalleryWorker {
    func add(image: UIImage) {
        images.append(image)
        collectionView.reloadData()
    }
}
