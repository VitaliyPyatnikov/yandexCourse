//
//  EditNoteViewController.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 20.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - EditNoteColorWorker

protocol EditNoteColorWorker: class {
    func setCustomColor(_ color: UIColor)
}

// MARK: - EditNoteViewController

final class EditNoteViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var destroyDateSwitch: UISwitch!
    @IBOutlet weak var destroyDatePicker: UIDatePicker!
    @IBOutlet weak var destroyDatePickerContainerView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    
    @IBOutlet weak var descriptionTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var destroyDatePickerContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorPickerVerticalConstraint: NSLayoutConstraint!

    // MARK: - IBActions

    @IBAction func destroyDateSwithcTapped(_ sender: UISwitch) {
        updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupCollectionView()
        setupLongGestureRecognizer()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ColorPickerSegue" {
            guard let colorPickerViewController = segue.destination as? ColorPickerViewController else {
                return
            }
            colorPickerViewController.editNoteWorker = self
        }
    }

    // MARK: - Private

    private let defaultPickerHeight = CGFloat(216)
    private let defaultVerticalSpace = CGFloat(16)
    private let spaceBetweenCels: CGFloat = 1
    private var colorsDataSource: [ColorCellModel] = [
        ColorCellModel(color: .white, isSelected: true),
        ColorCellModel(color: .red, isSelected: false),
        ColorCellModel(color: .green, isSelected: false),
        ColorCellModel(color: .custom(color: .clear), isSelected: false)
    ]
    private var lastSelectedColorIndex = 0
    private var gestureRecognizer: UILongPressGestureRecognizer?

    private func initialSetup() {
        descriptionTextView.delegate = self
        descriptionTextView.isScrollEnabled = false
    }
    private func setupLongGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                             action: #selector(handleLongPress))
        gestureRecognizer.minimumPressDuration = 0.5
        gestureRecognizer.delaysTouchesBegan = true
        colorsCollectionView.addGestureRecognizer(gestureRecognizer)
        self.gestureRecognizer = gestureRecognizer
    }
    private func updateUI() {
        let destroyPickerContainerHeight = destroyDateSwitch.isOn ? defaultPickerHeight : CGFloat(0)
        let colorPickerVerticalIndent = destroyPickerContainerHeight + defaultVerticalSpace

        UIView.animate(withDuration: 1.0) {
            self.destroyDatePickerContainerViewHeightConstraint.constant = destroyPickerContainerHeight
            self.colorPickerVerticalConstraint.constant = colorPickerVerticalIndent
            self.view.layoutIfNeeded()
        }
    }
    private func setupCollectionView() {
        colorsCollectionView.allowsMultipleSelection = false
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
        colorsCollectionView.contentInsetAdjustmentBehavior = .always
        
        let nib = UINib(nibName: "ColorCollectionViewCell", bundle: nil)
        // TODO: - Add typeName to ColorCollectionViewCell
        colorsCollectionView.register(nib, forCellWithReuseIdentifier: "ColorCell")
    }
    private func updateSelectedColor(at index: Int) {
        let currentSelectedColor = colorsDataSource[lastSelectedColorIndex]
        colorsDataSource[lastSelectedColorIndex] = ColorCellModel(color: currentSelectedColor.color,
                                                                  isSelected: false)
        lastSelectedColorIndex = index
        let newSelectedColor = colorsDataSource[index]
        colorsDataSource[index] = ColorCellModel(color: newSelectedColor.color,
                                                 isSelected: true)
        colorsCollectionView.reloadData()
    }
    @objc private func handleLongPress(gesture : UILongPressGestureRecognizer) {
        if gesture.state != .ended {
            return
        }

        let point = gesture.location(in: colorsCollectionView)

        if let indexPath = colorsCollectionView.indexPathForItem(at: point),
            indexPath.row == colorsDataSource.count - 1 {
            performSegue(withIdentifier: "ColorPickerSegue", sender: self)
        } else {
            Log.error("Incorrect point")
        }
    }
}

// MARK: - UITextViewDelegate

extension EditNoteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        descriptionTextViewHeightConstraint.constant = newSize.height
    }
}

// MARK: - UICollectionViewDelegate

extension EditNoteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        updateSelectedColor(at: indexPath.row)
    }
}

// MARK: - UICollectionViewDataSource

extension EditNoteViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return colorsDataSource.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // TODO: - Add typeName to ColorCollectionViewCell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell",
                                                            for: indexPath)
            as? ColorCollectionViewCell else {
                return UICollectionViewCell()
        }
        let model = colorsDataSource[indexPath.row]
        cell.setup(withModel: model)

        return cell
    }
}

// MARK: - EditNoteColorWorker

extension EditNoteViewController: EditNoteColorWorker {
    func setCustomColor(_ color: UIColor) {
        let lastIndex = colorsDataSource.count - 1
        colorsDataSource[lastIndex] = ColorCellModel(color: .custom(color: color),
                                                     isSelected: false)
        updateSelectedColor(at: lastIndex)
    }
}
