//
//  ViewController.swift
//  dijkstra
//
//  Created by Shoichi Kanzaki on 2017/07/04.
//  Copyright © 2017年 mycompany. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var dots: [DotView] = []
        (0...5).forEach { _ in
            let dot = DotView(frame: CGRect(
                x: CGFloat(arc4random_uniform(UInt32(Int32(view.frame.width)))),
                y: CGFloat(arc4random_uniform(UInt32(Int32(view.frame.height)))),
                width: 20 , height: 20 ))
            dot.backgroundColor = .darkGray
            dot.layer.cornerRadius = dot.frame.width / 2
            dots.append(dot)
            view.addSubview(dot)
        }
        
        let startLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        startLabel.text = "S"
        startLabel.textColor = .white
        startLabel.textAlignment = .center
        dots.first?.addSubview(startLabel)
        dots.first?.type = .start
        
        let goalLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        goalLabel.text = "G"
        goalLabel.textColor = .white
        goalLabel.textAlignment = .center
        dots.last?.addSubview(goalLabel)
        dots.last?.type = .goal
        
        dots.forEach { dot in
            var otherDots = dots.filter { $0 != dot }
            dot.otherDots.append(otherDots.remove(at: Int(arc4random_uniform(UInt32(otherDots.count)))))
            dot.otherDots.append(otherDots.remove(at: Int(arc4random_uniform(UInt32(otherDots.count)))))
        }
        
        dots.forEach { dot in
            dot.otherDots.forEach { otherDot in
                let lineView = LineView(start: dot.frame.origin, end: otherDot.frame.origin)
                view.addSubview(lineView)
                view.sendSubview(toBack: lineView)
            }
        }
        
        if let start = dots.first {
            var targetDots = [start]
            while targetDots.count != 0 {
                let targetDot = targetDots.remove(at: 0)
                targetDot.otherDots.forEach {
                    let dx = targetDot.frame.origin.x - $0.frame.origin.x
                    let dy = targetDot.frame.origin.y - $0.frame.origin.y
                    if $0.score == 0 || targetDot.score + sqrt(dx*dx + dy*dy) < $0.score {
                        $0.score = targetDot.score + sqrt(dx*dx + dy*dy)
                        targetDots.append($0)
                        $0.routeDots = targetDot.routeDots + [targetDot]
                    }
                }
            }
        }
        
        if let last = dots.last, last.routeDots.count != 0 {
            last.routeDots.append(last)
            (0...(last.routeDots.count - 2)).forEach {
                let lineView = LineView(
                    start: last.routeDots[$0].frame.origin,
                    end: last.routeDots[$0 + 1].frame.origin,
                    color: .red,
                    lineWidth: 2)
                view.addSubview(lineView)
            }
        }
        
    }
}

class DotView: UIView {
    enum DotType {
        case start
        case goal
        case normal
    }
    
    var otherDots: [DotView] = []
    var score: CGFloat = 0
    var type: DotType = .normal
    var routeDots: [DotView] = []
}

class LineView: UIView {
    let start: CGPoint
    let end: CGPoint
    let color: UIColor
    let lineWidth: CGFloat
    
    init(start: CGPoint, end: CGPoint, color: UIColor = .darkGray, lineWidth: CGFloat = 4) {
        self.start = start
        self.end = end
        self.color = color
        self.lineWidth = lineWidth
        
        super.init(frame: CGRect(
            x: ([start.x, end.x].min() ?? 0) + 10,
            y: ([start.y, end.y].min() ?? 0) + 10,
            width: abs(start.x - end.x),
            height: abs(start.y - end.y))
        )
        
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw( _ rect: CGRect) {
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        color.set()
        path.move(to: CGPoint(x: start.x - frame.origin.x + 10, y: start.y - frame.origin.y + 10))
        path.addLine(to: CGPoint(x: end.x - frame.origin.x + 10, y: end.y - frame.origin.y + 10))
        path.stroke()
    }
}
