//
//  CarouselViewController.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import UIKit

enum State {
    case first
    case second
    case third
}

class CarouselViewController: UIViewController {
    
    var animator: UIViewPropertyAnimator!
    private var state = State.first
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {        
        switch sender.state {
        case .began:
            // Do any additional setup after loading the view.
            animator = UIViewPropertyAnimator(duration: 1.0, controlPoint1:
            mainLabel.center, controlPoint2: leftLabel.center) {
                
                switch self.state {
                case .first:
                    self.mainLabel.center = self.leftView.center
                    self.leftLabel.center = self.rightView.center
                    self.rightLabel.center = self.mainView.center
                case .second:
                    self.mainLabel.center = self.rightView.center
                    self.leftLabel.center = self.mainView.center
                    self.rightLabel.center = self.leftView.center
                case .third:
                    self.mainLabel.center = self.mainView.center
                    self.leftLabel.center = self.leftView.center
                    self.rightLabel.center = self.rightView.center
                }
                
            }
        case .changed:
            // begam
            let translation = sender.translation(in: mainLabel)
            animator.fractionComplete = translation.x / 100
        case .ended:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            
            switch self.state {
                case .first:
                    self.state = .second
                    self.pageControl.currentPage = 1
                case .second:
                    self.state = .third
                    self.pageControl.currentPage = 2
                case .third:
                    self.state = .first
                    self.pageControl.currentPage = 0
            }
        default:
            break
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}
