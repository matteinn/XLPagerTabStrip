//  ButtonBarView.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2017 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public enum PagerScroll {
    case no
    case yes
    case scrollOnlyIfOutOfScreen
}

public enum SelectedBarAlignment {
    case left
    case center
    case right
    case progressive
}

public enum SelectedBarVerticalAlignment {
    case top
    case middle
    case bottom
}

open class ButtonBarView: UICollectionView {

    open lazy var selectedBarTrack: UIView = { [unowned self] in
        let bar  = UIView(frame: CGRect(x: 0, y: self.frame.size.height - CGFloat(self.selectedBarHeight), width: self.bounds.size.width, height: CGFloat(self.selectedBarHeight)))
        bar.backgroundColor = self.selectedBarTrackColor
        bar.layer.zPosition = 9998
        return bar
        }()
    
    open lazy var selectedBar: UIView = { [unowned self] in
        let bar  = UIView(frame: CGRect(x: 0, y: self.frame.size.height - CGFloat(self.selectedBarHeight), width: 0, height: CGFloat(self.selectedBarHeight)))
        bar.layer.zPosition = 9999
        return bar
    }()
    
    public lazy var selectedBarArrow: TriangleView = { [unowned self] in
        let arrow = TriangleView(frame: CGRect(x: 0, y: 0, width: 0, height: self.selectedBarArrowSize.height))
        arrow.backgroundColor = UIColor(red: 1, green: 162/255, blue: 0, alpha: 1)
        arrow.layer.zPosition = 10000
        return arrow
        }()
    
    internal var selectedBarHeight: CGFloat = 4 {
        didSet {
            updateSelectedBarYPosition()
        }
    }
    var selectedBarVerticalAlignment: SelectedBarVerticalAlignment = .bottom
    var selectedBarAlignment: SelectedBarAlignment = .center
    
    internal var selectedBarArrowSize: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.updateSelectedBarYPosition()
        }
    }
    
    internal var selectedBarFullWidth: Bool = false {
        didSet {
            self.updateSelectedBarYPosition()
        }
    }
    
    internal var selectedBarTrackColor: UIColor = .clear {
        didSet {
            self.updateSelectedBarYPosition()
        }
    }
    
    var selectedIndex = 0

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(selectedBarTrack)
        addSubview(selectedBar)
        addSubview(selectedBarArrow)
    }

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        addSubview(selectedBarTrack)
        addSubview(selectedBar)
        addSubview(selectedBarArrow)
    }

    open func moveTo(index: Int, animated: Bool, swipeDirection: SwipeDirection, pagerScroll: PagerScroll) {
        selectedIndex = index
        updateSelectedBarPosition(animated, swipeDirection: swipeDirection, pagerScroll: pagerScroll)
    }

    open func move(fromIndex: Int, toIndex: Int, progressPercentage: CGFloat, pagerScroll: PagerScroll) {
        selectedIndex = progressPercentage > 0.5 ? toIndex : fromIndex

        let fromFrame = layoutAttributesForItem(at: IndexPath(item: fromIndex, section: 0))!.frame
        let numberOfItems = dataSource!.collectionView(self, numberOfItemsInSection: 0)

        var toFrame: CGRect

        if toIndex < 0 || toIndex > numberOfItems - 1 {
            if toIndex < 0 {
                let cellAtts = layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
                toFrame = cellAtts!.frame.offsetBy(dx: -cellAtts!.frame.size.width, dy: 0)
            } else {
                let cellAtts = layoutAttributesForItem(at: IndexPath(item: (numberOfItems - 1), section: 0))
                toFrame = cellAtts!.frame.offsetBy(dx: cellAtts!.frame.size.width, dy: 0)
            }
        } else {
            toFrame = layoutAttributesForItem(at: IndexPath(item: toIndex, section: 0))!.frame
        }

        var targetFrame = fromFrame
        targetFrame.size.height = selectedBar.frame.size.height
        targetFrame.size.width += (toFrame.size.width - fromFrame.size.width) * progressPercentage
        targetFrame.origin.x += (toFrame.origin.x - fromFrame.origin.x) * progressPercentage

        selectedBar.frame = CGRect(x: targetFrame.origin.x, y: selectedBar.frame.origin.y, width: targetFrame.size.width, height: selectedBar.frame.size.height)
        selectedBarArrow.frame = CGRect(x: targetFrame.origin.x + (targetFrame.size.width - self.selectedBarArrowSize.width)/2, y: selectedBarArrow.frame.origin.y, width: self.selectedBarArrowSize.width, height: self.selectedBarArrowSize.height)
        
        selectedBar.frame = CGRect(
            x: selectedBarFullWidth ? 0 : targetFrame.origin.x,
            y: selectedBar.frame.origin.y,
            width: selectedBarFullWidth ? self.contentSize.width : targetFrame.size.width,
            height: selectedBar.frame.size.height)
        
        selectedBarArrow.frame = CGRect(
            x: targetFrame.origin.x + (targetFrame.size.width - self.selectedBarArrowSize.width)/2,
            y: selectedBarArrow.frame.origin.y,
            width: self.selectedBarArrowSize.width,
            height: self.selectedBarArrowSize.height)
        
        var targetContentOffset: CGFloat = 0.0
        if contentSize.width > frame.size.width {
            let toContentOffset = contentOffsetForCell(withFrame: toFrame, andIndex: toIndex)
            let fromContentOffset = contentOffsetForCell(withFrame: fromFrame, andIndex: fromIndex)

            targetContentOffset = fromContentOffset + ((toContentOffset - fromContentOffset) * progressPercentage)
        }

        DispatchQueue.main.async{
            self.setContentOffset(CGPoint(x: targetContentOffset, y: 0), animated: false)
        }
    }

    open func updateSelectedBarPosition(_ animated: Bool, swipeDirection: SwipeDirection, pagerScroll: PagerScroll) {
        var selectedBarFrame = selectedBar.frame
        var selectedBarArrowFrame = selectedBarArrow.frame
        
        let selectedCellIndexPath = IndexPath(item: selectedIndex, section: 0)
        let attributes = layoutAttributesForItem(at: selectedCellIndexPath)
        let selectedCellFrame = attributes!.frame
        
        updateContentOffset(animated: animated, pagerScroll: pagerScroll, toFrame: selectedCellFrame, toIndex: selectedCellIndexPath.row)
        
        selectedBarFrame.size.width = selectedBarFullWidth ? self.contentSize.width : selectedCellFrame.size.width
        selectedBarFrame.origin.x = selectedBarFullWidth ? 0 : selectedCellFrame.origin.x
        
        selectedBarArrowFrame.origin.x = selectedCellFrame.origin.x + (selectedCellFrame.size.width - self.selectedBarArrowSize.width)/2
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.selectedBar.frame = selectedBarFrame
                self?.selectedBarArrow.frame = selectedBarArrowFrame
                })
        }
        else {
            selectedBar.frame = selectedBarFrame
            selectedBarArrow.frame = selectedBarArrowFrame
        }
    }

    // MARK: - Helpers

    private func updateContentOffset(animated: Bool, pagerScroll: PagerScroll, toFrame: CGRect, toIndex: Int) {
        guard pagerScroll != .no || (pagerScroll != .scrollOnlyIfOutOfScreen && (toFrame.origin.x < contentOffset.x || toFrame.origin.x >= (contentOffset.x + frame.size.width - contentInset.left))) else { return }
        let targetContentOffset = contentSize.width > frame.size.width ? contentOffsetForCell(withFrame: toFrame, andIndex: toIndex) : 0
        DispatchQueue.main.async{
            self.setContentOffset(CGPoint(x: targetContentOffset, y: 0), animated: animated)
        }
    }

    private func contentOffsetForCell(withFrame cellFrame: CGRect, andIndex index: Int) -> CGFloat {
        let sectionInset = (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset // swiftlint:disable:this force_cast
        var alignmentOffset: CGFloat = 0.0

        switch selectedBarAlignment {
        case .left:
            alignmentOffset = sectionInset.left
        case .right:
            alignmentOffset = frame.size.width - sectionInset.right - cellFrame.size.width
        case .center:
            alignmentOffset = (frame.size.width - cellFrame.size.width) * 0.5
        case .progressive:
            let cellHalfWidth = cellFrame.size.width * 0.5
            let leftAlignmentOffset = sectionInset.left + cellHalfWidth
            let rightAlignmentOffset = frame.size.width - sectionInset.right - cellHalfWidth
            let numberOfItems = dataSource!.collectionView(self, numberOfItemsInSection: 0)
            let progress = index / (numberOfItems - 1)
            alignmentOffset = leftAlignmentOffset + (rightAlignmentOffset - leftAlignmentOffset) * CGFloat(progress) - cellHalfWidth
        }

        var contentOffset = cellFrame.origin.x - alignmentOffset
        contentOffset = max(0, contentOffset)
        contentOffset = min(contentSize.width - frame.size.width, contentOffset)
        return contentOffset
    }

    private func updateSelectedBarYPosition() {
        var selectedBarFrame = selectedBar.frame

        switch selectedBarVerticalAlignment {
        case .top:
            selectedBarFrame.origin.y = 0
        case .middle:
            selectedBarFrame.origin.y = (frame.size.height - selectedBarHeight) / 2
        case .bottom:
            selectedBarFrame.origin.y = frame.size.height - selectedBarHeight
        }

        selectedBarTrack.frame = CGRect(x: 0, y: frame.size.height - selectedBarHeight, width: self.contentSize.width, height: selectedBarHeight)
        
        selectedBarFrame.size.height = selectedBarHeight
        selectedBarFrame.size.width = selectedBarFullWidth ? self.contentSize.width : selectedBarFrame.size.width
        selectedBar.frame = selectedBarFrame
        
        var selectedBarArrowFrame = selectedBarArrow.frame
        selectedBarArrowFrame.origin.y = frame.size.height - selectedBarHeight - self.selectedBarArrowSize.height
        selectedBarArrowFrame.size.height = self.selectedBarArrowSize.height
        selectedBarArrow.frame = selectedBarArrowFrame
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        updateSelectedBarYPosition()
    }
}
