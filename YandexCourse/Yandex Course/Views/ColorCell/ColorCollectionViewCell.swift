//
//  ColorCollectionViewCell.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 20.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - ColorCollectionViewCell

final class ColorCollectionViewCell: UICollectionViewCell {

    // MARK: - IBOutlets

    @IBOutlet weak var baseView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(withModel model: ColorCellModel) {
        shapeLayer.removeFromSuperlayer()
        baseView.backgroundColor = model.color
        baseView.layer.borderWidth = CGFloat(1)
        baseView.layer.borderColor = UIColor.black.cgColor
        if model.isSelected {
            configureRingCheckboxPath(toView: baseView)
            drawRingCheckboxPath()
        }
    }

    private let shapeLayer = CAShapeLayer()

    // MARK: - Ring path

    private func configureRingCheckboxPath(toView parentView: UIView) {
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        parentView.layer.addSublayer(shapeLayer)

        shapeLayer.path = ringCheckboxPath(with: parentView).cgPath
    }
    private func drawRingCheckboxPath() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.byValue = 1.0
        animation.duration = 1.0

        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false

        shapeLayer.add(animation, forKey: nil)
    }

    private func ringCheckboxPath(with parentView: UIView) -> UIBezierPath {
        // TODO: - Add more accurate calculations

        let bezierPath = UIBezierPath()
        let width = parentView.bounds.width
        let height = parentView.bounds.height
        let parentCenter = CGPoint(x: width / 2,
                                   y: height / 2)
        let arcCenter = CGPoint(x: parentCenter.x + width / 4,
                                y: parentCenter.y - height / 4)

        bezierPath.move(to: CGPoint(x: arcCenter.x - 3, y: arcCenter.y - 3))
        bezierPath.addLine(to: CGPoint(x: arcCenter.x, y: arcCenter.y + 3))
        bezierPath.addLine(to: CGPoint(x: arcCenter.x + 4, y: arcCenter.y - sqrt(33)))
        bezierPath.addArc(withCenter: arcCenter,
                          radius: 7.0,
                          startAngle: CGFloat(-11/36 * Double.pi),
                          endAngle: CGFloat(61/36 * Double.pi),
                          clockwise: true)
        return bezierPath

    }
}
