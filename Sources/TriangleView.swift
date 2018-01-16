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
        path.move(to: CGPoint(x: 0, y: self.bounds.size.height))
        path.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
        path.addLine(to: CGPoint(x: self.bounds.size.width/2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        
        self.layer.mask = shapeLayer
    }
    
}
