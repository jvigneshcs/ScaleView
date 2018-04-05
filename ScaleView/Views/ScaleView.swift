//
//  ScaleView.swift
//  Custom Views
//
//  Created by Vignesh J on 3/22/17.
//  Copyright © 2017 Vignesh J. All rights reserved.
//

import UIKit


@IBDesignable class ScaleView: UIControl {
    
    @IBInspectable var markColor: UIColor = .darkGray
    @IBInspectable var selectedMarkColor: UIColor = .white
    
    @IBInspectable var markWidth: CGFloat = 1
    @IBInspectable var markHeight: CGFloat = 6
    @IBInspectable var subMarkWidth: CGFloat = 1
    @IBInspectable var subMarkHeight: CGFloat = 3
    @IBInspectable var markValueStart: UInt8 = 0
    @IBInspectable var markValueInterval: UInt8 = 10
    @IBInspectable var markCount: UInt8 = 11
    @IBInspectable var subMarkCount: UInt8 = 9
    @IBInspectable var subMarkBufferCount: UInt8 = 0
    @IBInspectable var needSelectedColorChange: Bool = false
    @IBInspectable var drawMarksOnTop: Bool = true
    @IBInspectable var drawMarksOnBottom: Bool = true
    
    @IBInspectable var selectedValue: UInt8 = 0 {
        didSet {
            selectedValue = max(markValueStart, min(selectedValue, maximumAllowedValue))
            setNeedsDisplay()
            
            sendActions(for: .valueChanged)
        }
    }
    
    let markStartFrom: CGFloat = 0
    
    var maximumAllowedValue: UInt8 {
        return markValueStart + ((markCount - 1) * markValueInterval)
    }
    
    private var defaultMarkCount: UInt8 = 10
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        guard drawMarksOnTop || drawMarksOnBottom else {
            return
        }
        let numberOfMarks = calculateNumberOfMarks()
        let size = bounds.size
        let distanceBetweenMark = (size.width - (2 * markStartFrom)) / CGFloat(numberOfMarks - 1)
        let selectedMarkCount: UInt8 = needSelectedColorChange ? calculateSelectedMarkCount() : 0
        
        if selectedMarkCount > 0 {
            selectedMarkColor.setFill()
        } else {
            markColor.setFill()
        }
        
        var markValue = markValueStart
        var fillColorSwitched = false
        var isFirstMark = true
        
        for index in 0 ..< numberOfMarks {
            if !fillColorSwitched && index >= selectedMarkCount {
                markColor.setFill()
                fillColorSwitched = true
            }
            let isMark = checkIfMark(index: index)
            let width = isMark ? markWidth : subMarkWidth
            let height = isMark ? markHeight : subMarkHeight
            let x = (CGFloat(index) * distanceBetweenMark) + markStartFrom - (width / 2)
            var y: CGFloat = 0
            
            if drawMarksOnTop {
                UIRectFill(CGRect(x: x, y: y, width: width, height: height))
            }
            y = size.height - height
            if drawMarksOnBottom {
                UIRectFill(CGRect(x: x, y: y, width: width, height: height))
            }
            
            if isMark {
                markValue += markValueInterval
                
                if isFirstMark {
                    isFirstMark = false
                }
            }
        }
    }
    
    func resetControl() {
        
    }
    
    func calculateNumberOfMarksExcludingBufferCount() -> UInt8 {
        var numberOfMarks = markCount > 0 ? markCount : defaultMarkCount
        if subMarkCount > 0 {
            numberOfMarks = numberOfMarks + ((numberOfMarks - 1) * subMarkCount)
        }
        return numberOfMarks
    }
    
    func calculateNumberOfMarks() -> UInt8 {
        var numberOfMarks = calculateNumberOfMarksExcludingBufferCount()
        if subMarkCount > 0 {
            numberOfMarks = numberOfMarks + (2 * subMarkBufferCount)
        }
        return numberOfMarks
    }
    
    func widthUptoFirstMark(with distanceBetweenMark: CGFloat) -> CGFloat {
        return subMarkBufferCount > 0 ? CGFloat(subMarkBufferCount + 1) * distanceBetweenMark : markStartFrom
    }
    
    private func calculateSelectedMarkCount() -> UInt8 {
        var selectedMarkCount: UInt8 = 0
        if selectedValue == 0 {
            markColor.setFill()
        } else if selectedValue <= markValueStart {
            if subMarkBufferCount > 0 {
                selectedMarkCount = UInt8(Float(subMarkBufferCount + 1) * (Float(selectedValue) / Float(markValueStart)))
            }
        } else if selectedValue <= maximumAllowedValue {
            let numberOfMarks = calculateNumberOfMarksExcludingBufferCount()
            selectedMarkCount = UInt8(Float(numberOfMarks - 1) * (Float(selectedValue - 10) / (Float(markCount * markValueStart) - 10)))
            selectedMarkCount += subMarkBufferCount + 1
        }
        return selectedMarkCount
    }
    
    private func checkIfMark(index: UInt8) -> Bool {
        if index < subMarkBufferCount {
            return false
        } else {
            return ((index - subMarkBufferCount) % (subMarkCount + 1) == 0)
        }
    }
}
