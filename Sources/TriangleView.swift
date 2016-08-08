//
//  TriangleView.swift
//  XLPagerTabStrip
//
//  Created by Matteo Innocenti  on 08/08/16.
//
//

import Foundation

public class TriangleView: UIView {

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, self.bounds.size.height))
        path.addLineToPoint(CGPointMake(self.bounds.size.width, self.bounds.size.height))
        path.addLineToPoint(CGPointMake(self.bounds.size.width/2, 0))
        path.addLineToPoint(CGPointMake(0, self.bounds.size.height))
        path.closePath()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        
        self.layer.mask = shapeLayer
    }
    
}