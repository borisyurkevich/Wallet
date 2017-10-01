//
//  CarouselViewController.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import UIKit

enum State: Int {
    case first
    case second
    case third
}

protocol CarouselViewControllerDelegate: class {
    func updateState(newState: State)
}

class CarouselViewController: UIViewController {
    
    weak var delegate: CarouselViewControllerDelegate?
    
    private var animator: UIViewPropertyAnimator!
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
            let velocity = sender.velocity(in: self.view)
            if velocity.x > 0 {
                // Moving forward.
                animator = UIViewPropertyAnimator(duration: 1.0, controlPoint1:
                mainLabel.center, controlPoint2: leftLabel.center) {
                    switch self.state {
                    case .first:
                        self.mainLabel.center = self.rightView.center
                        self.leftLabel.center = self.mainView.center
                        self.rightLabel.center = self.leftView.center
                        
                        self.mainLabel.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                        self.leftLabel.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                        
                    case .second:
                        self.mainLabel.center = self.leftView.center
                        self.leftLabel.center = self.rightView.center
                        self.rightLabel.center = self.mainView.center
                        
                        self.rightLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.leftLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                        
                    case .third:
                        self.mainLabel.center = self.mainView.center
                        self.leftLabel.center = self.leftView.center
                        self.rightLabel.center = self.rightView.center
                        
                        self.mainLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.rightLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    }
                }
            } else {
                // Moving backward
                animator = UIViewPropertyAnimator(duration: 1.0, controlPoint1:
                mainLabel.center, controlPoint2: leftLabel.center) {
                    switch self.state {
                    case .first:
                        self.mainLabel.center = self.leftView.center
                        self.leftLabel.center = self.rightView.center
                        self.rightLabel.center = self.mainView.center
                        
                        self.rightLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.mainLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                        
                    case .second:
                        self.mainLabel.center = self.mainView.center
                        self.leftLabel.center = self.leftView.center
                        self.rightLabel.center = self.rightView.center
                        
                        self.leftLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                        self.mainLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        
                    case .third:
                        self.mainLabel.center = self.rightView.center
                        self.leftLabel.center = self.mainView.center
                        self.rightLabel.center = self.leftView.center
                        
                        self.rightLabel.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                        self.leftLabel.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                    }
                }
            }
            
        case .changed:
            // begam
            let translation = sender.translation(in: self.view)
            animator.fractionComplete = abs(translation.x) / 100
        case .ended:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            
            let velocity = sender.velocity(in: self.view)
            if velocity.x > 0 {
                // Going forward
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
            } else {
                // Going backward.
                switch self.state {
                case .first:
                    self.state = .third
                    self.pageControl.currentPage = 2
                case .second:
                    self.state = .first
                    self.pageControl.currentPage = 0
                case .third:
                    self.state = .second
                    self.pageControl.currentPage = 1
                }
            }
            
            self.delegate?.updateState(newState: self.state)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        rightLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        leftLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
    

}
