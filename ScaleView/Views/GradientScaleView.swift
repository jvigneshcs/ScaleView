//
//  ClimateScaleView.swift
//  Custom Views
//
//  Created by Vignesh J on 3/22/17.
//  Copyright © 2017 Vignesh J. All rights reserved.
//

import UIKit

@IBDesignable class GradientScaleView: ScaleView {
    
    @IBInspectable var initialTrackImage: UIImage?
    @IBInspectable var trackImage: UIImage?
    @IBInspectable var gradientStartColor: UIColor = .yellow
    @IBInspectable var gradientEndColor: UIColor = .orange
    @IBInspectable var gradientContainerBackgroundColor: UIColor = .white
    
    override var isHidden: Bool {
        didSet {
            gradientContainerView?.isHidden = isHidden
        }
    }
    
    private weak var sliderTrackImage: UIImage?
    private var gradientContainerView: UIView!
    private var slider: UISlider!
    private var gradientLayer: CAGradientLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeGradientContainerView()
        initializeSlider()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeGradientContainerView()
        initializeSlider()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedValue: Float = Float(self.selectedValue)
        let minimum = Float(markValueStart)
        let maximum = Float(maximumAllowedValue)
        if (selectedValue >= minimum && selectedValue <= maximum) {
            slider?.value = selectedValue
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        updateGradientContainerView()
        let numberOfMarks = calculateNumberOfMarks()
        let size = bounds.size
        let distanceBetweenMark = (size.width - (2 * markStartFrom)) / CGFloat(numberOfMarks - 1)
        let gradientWidth = calculateWidthForGradientLayer(with: distanceBetweenMark)
        
        if gradientWidth == 0 {
            if let layer = gradientLayer {
                if let _ = layer.superlayer {
                    layer.removeFromSuperlayer()
                }
                gradientLayer = nil
            }
        } else {
            initializeGradientLayer(with: CGSize(width: gradientWidth, height: size.height))
        }
        updateTrackImage()
        let rangeStart = CGPoint(x: 0, y: (frame.height - (slider?.frame.height ?? 0)) / 2)
        //var sliderWidth: CGFloat = 0
        //slider?.frame = CGRect(origin: rangeStart, size: CGSize(width: sliderWidth - rangeStart.x, height: slider?.frame.height ?? 0))
        slider?.frame = CGRect(origin: rangeStart, size: CGSize(width: frame.width, height: slider?.frame.height ?? 0))
    }
    
    private func initializeGradientContainerView() {
        if gradientContainerView == nil {
            gradientContainerView = UIView(frame: frame)
            if let superView = superview {
                superView.addSubview(gradientContainerView)
                superView.sendSubview(toBack: gradientContainerView)
            }
        }
        gradientContainerView?.backgroundColor = gradientContainerBackgroundColor
        gradientContainerView?.frame = frame
    }
    
    private func initializeSlider() {
        if slider == nil {
            slider = UISlider()
            addSubview(slider)
            let clearImage = UIImage()
            slider.setMinimumTrackImage(clearImage, for: .normal)
            slider.setMaximumTrackImage(clearImage, for: .normal)
            slider.center = center
            let minimum = Float(markValueStart)
            let maximum = Float(maximumAllowedValue)
            slider.minimumValue = minimum
            slider.maximumValue = maximum
            slider.value = (minimum + maximum) / 2
            slider.addTarget(self, action: #selector(onValueChanged(_:)), for: .valueChanged)
            slider.addTarget(self, action: #selector(onTouchUpInside(_:)), for: .touchUpInside)
            slider.addTarget(self, action: #selector(onTouchUpOutside(_:)), for: .touchUpOutside)
            sliderTrackImage = initialTrackImage
            updateTrackImage()
        }
    }
    
    private func initializeGradientLayer(with size: CGSize) {
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            gradientLayer?.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer?.endPoint = CGPoint(x: 1.0, y: 0.5)
            if let layer = gradientLayer {
                gradientContainerView?.layer.addSublayer(layer)
            }
        }
        gradientLayer?.frame = CGRect(origin: CGPoint.zero, size: size)
        gradientLayer?.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
    }
    
    private func updateGradientContainerView() {
        if gradientContainerView?.superview == nil {
            if let superView = superview, let containerView = gradientContainerView {
                superView.addSubview(containerView)
                superView.sendSubview(toBack: containerView)
            }
        }
        gradientContainerView?.frame = frame
    }
    
    private func updateTrackImage() {
        if let thumbImage = sliderTrackImage {
            slider?.setThumbImage(thumbImage, for: .normal)
            slider?.setThumbImage(thumbImage, for: .highlighted)
        } else if let thumbImage = initialTrackImage {
            sliderTrackImage = thumbImage
            updateTrackImage()
        }
    }
    
    private func calculateWidthForGradientLayer(with distanceBetweenMark: CGFloat) -> CGFloat {
        let width: CGFloat
        if selectedValue == 0 {
            width = 0
        } else if selectedValue <= markValueStart {
            let overallWidth = widthUptoFirstMark(with: distanceBetweenMark)
            width = overallWidth * CGFloat(selectedValue) / CGFloat(markValueStart)
        } else if selectedValue <= maximumAllowedValue {
            let widthUptoFirstMark = self.widthUptoFirstMark(with: distanceBetweenMark)
            let numberOfMarks = calculateNumberOfMarksExcludingBufferCount()
            let widthBetweenRange = CGFloat(numberOfMarks - 1) * distanceBetweenMark
            let widthSelectedBetweenRange = widthBetweenRange * CGFloat(selectedValue - markValueStart) / CGFloat(maximumAllowedValue - markValueStart)
            width = widthUptoFirstMark + widthSelectedBetweenRange
        } else {
            width = 0
        }
        return width
    }
    
    @objc private func onValueChanged(_ sender: UISlider) {
        sliderTrackImage = trackImage
        selectedValue = UInt8(round(sender.value))
    }
    
    @objc private func onTouchUpInside(_ sender: UISlider) {
        sender.value = Float(selectedValue)
        sendActions(for: .touchUpInside)
    }
    
    @objc private func onTouchUpOutside(_ sender: UISlider) {
        sendActions(for: .touchUpOutside)
    }
}
