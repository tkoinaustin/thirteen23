//
//  ViewController.swift
//  thirteen23
//
//  Created by Tom Nelson on 8/5/15.
//  Copyright © 2015 TKO Solutions. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, RadialMenuDelegate {
    
    //MARK: - Properties
    
    var radialMenu:RadialMenuView? = nil
    let pressRecognizer = UILongPressGestureRecognizer()
    let panRecognizer = UIPanGestureRecognizer()
    let formHome:UIView = UIView()
    let formOne:UIView = UIView()
    let formTwo:UIView = UIView()
    let formThree:UIView = UIView()
    var lastButtonPressed:RadialButton = .home
    let radialMenuSize:CGFloat = 400
    
    
    // MARK: - view load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        pressRecognizer.addTarget(self, action: #selector(ViewController.handleLongPress(_:)))
        self.view.addGestureRecognizer(pressRecognizer)
        panRecognizer.addTarget(self, action: #selector(ViewController.handleSwipe(_:)))
        panRecognizer.delegate = self
        self.view.addGestureRecognizer(panRecognizer)
        
        initAndAddForm(formOne, labelText: "one")
        initAndAddForm(formTwo, labelText: "two")
        initAndAddForm(formThree, labelText: "three")
        initAndAddForm(formHome, labelText: "home")
        formHome.alpha = 1.0
    }
    
    // If the device is rotated, place the label back in the center
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        UIView.animate(withDuration: 0.3, animations: {
            self.formHome.center = self.view!.center
            self.formOne.center = self.view!.center
            self.formTwo.center = self.view!.center
            self.formThree.center = self.view!.center
        })
    }
    
    //MARK: - Helper Functions
    
    // This animates the view transitions in and out
    func animateForm(_ incomingView:UIView, outgoingView:UIView, direction:Direction) {
        var outgoingViewCenter = outgoingView.center
        switch (direction) {
        case .down:
            incomingView.center.y -= self.view.frame.size.height
            outgoingViewCenter.y += self.view.frame.size.height
        case .left:
            incomingView.center.x -= self.view.frame.size.width
            outgoingViewCenter.x += self.view.frame.size.width
        case .right:
            incomingView.center.x += self.view.frame.size.width
            outgoingViewCenter.x -= self.view.frame.size.width
        case .up:
            incomingView.center.y += self.view.frame.size.height
            outgoingViewCenter.y -= self.view.frame.size.height
        default: break
        }
        incomingView.alpha = 1.0
        self.view.bringSubviewToFront(incomingView)
        UIView.animate(withDuration: 0.5, delay:0.0, options:[], animations: {
            incomingView.center = self.view!.center
            outgoingView.center = outgoingViewCenter
            }, completion:{ _ in
                outgoingView.alpha = 0.0
                outgoingView.center = self.view!.center
        })

    }
    
    func initAndAddForm(_ form:UIView, labelText:String) {
        form.frame = view.frame
        form.backgroundColor = UIColor.white
        form.alpha = 0.0
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.center = form.center
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name:label.font.fontName, size:48)
        label.text = labelText
        form.addSubview(label)
        self.view.addSubview(form)

    }
    
    // This defines which buttons get displayed on the Radial Menu View for the different screens
    func getRadialButtons() -> [RadialButton] {
        switch (lastButtonPressed) {
        case .home:
            return [RadialButton.one,RadialButton.two,RadialButton.three]
        case .one:
            return [RadialButton.home,RadialButton.two]
        case .two:
            return [RadialButton.home,RadialButton.one,RadialButton.three]
        case .three:
            return [RadialButton.home,RadialButton.two]
        case .touch:
            return [RadialButton.home]
        }
    }
    
    func determineQuadrant(_ location:CGPoint, size:CGSize) -> Quadrant {
        return location.y > size.height * 0.75 ? (location.x > size.width / 2.0  ? .bottomRight : .bottomLeft) :
            location.y < size.height * 0.25 ? (location.x > size.width / 2.0 ? .topRight : .topLeft) :
            location.x > size.width / 2.0 ? .right : .left
    }
    
    //MARK: - Gesture Recognizer

    @objc func handleLongPress(_ recognizer:UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            // load up the radialMenu centered at this spot
            let pressLocation = recognizer.location(in: self.view)
            let windowSize = view.frame.size
            let quadrant = determineQuadrant(pressLocation, size: windowSize)
            radialMenu = RadialMenuView(frame: CGRect(x: 0, y: 0, width: radialMenuSize, height: radialMenuSize))
            if let radialMenu = radialMenu {
                radialMenu.setupDelegate(self)
                radialMenu.center = pressLocation
                self.view.insertSubview(radialMenu, aboveSubview: self.view)
                radialMenu.setButtons(getRadialButtons(), quadrant:quadrant)
            }
        }
        if recognizer.state == .ended {
            radialMenu!.animateOut(nil)
        }
    }

    @objc func handleSwipe(_ recognizer: UIPanGestureRecognizer) {
        if let radialMenu = radialMenu {
            radialMenu.handleMenuSwipe(recognizer)
        }
    }

    func gestureRecognizer(_ gestureRecognizer:UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    
    //MARK: - RadialMenuDelegate
    
    func onSelected(_ menuItem: RadialButton) {
        var outgoingView:UIView?
        switch lastButtonPressed {
        case .home:
            outgoingView = formHome
        case .one:
            outgoingView = formOne
        case .two:
            outgoingView = formTwo
        case .three:
            outgoingView = formThree
        default:
            outgoingView = formHome
        }
        switch (menuItem) {
        case .home:
            animateForm(formHome, outgoingView:outgoingView!, direction:Direction.down)
        case .one:
            animateForm(formOne, outgoingView:outgoingView!, direction:lastButtonPressed == .home ? Direction.up : Direction.left)
        case .two:
            animateForm(formTwo, outgoingView:outgoingView!, direction:lastButtonPressed == .home ? Direction.up : lastButtonPressed == .three ? Direction.left : Direction.right)
        case .three:
            animateForm(formThree, outgoingView:outgoingView!, direction:lastButtonPressed == .home ? Direction.up : Direction.right)
        case .touch:
            break
        }
        lastButtonPressed = menuItem
   }
}

