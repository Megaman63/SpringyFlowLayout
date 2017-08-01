//
//  ViewController.swift
//  SpringyCollectionView
//
//  Created by Сергей on 25.01.17.
//  Copyright © 2017 LindenValley. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var data : [UIColor] = []
    
    @IBOutlet var collectionView : UICollectionView!
    @IBOutlet var stepper : UIStepper!
    @IBOutlet var springyRowSwitch: UISwitch!
    @IBOutlet var horizontalButton: UIButton!
    @IBOutlet var verticalButton: UIButton!
    @IBOutlet var itemsCount: UILabel!
    @IBOutlet var resistenceCount: UILabel!
    @IBOutlet var slider: UISlider!
    var spring : SpringyFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spring = collectionView.collectionViewLayout as! SpringyFlowLayout
        for _ in 0...90 {
            addNewColor()
        }
        stepper.value = Double(data.count)
        itemsCount.text = "items: \(Int(stepper.value))"
        springyRowSwitch.isOn = spring.springyRow
        switchDirectionButtons()
        resistenceCount.text = "Resistance: \(spring.kResistence)"
        slider.value = Float(spring.kResistence)
    }
    
    func switchDirectionButtons () {
        horizontalButton.isSelected = (spring.scrollDirection == .horizontal)
        verticalButton.isSelected = (spring.scrollDirection == .vertical)
    }
    
    func addNewColor () {
        let red : CGFloat = CGFloat(arc4random_uniform(100)) / 100
        let green : CGFloat = CGFloat(arc4random_uniform(100)) / 100
        let blue : CGFloat = CGFloat(arc4random_uniform(100)) / 100
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        data.append(color)
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = data[indexPath.row]
        
        return cell
    }
    
    @IBAction func springyRowSwitchTap() {
        spring.springyRow = springyRowSwitch.isOn
    }
    @IBAction func stepperTap() {
        if Int(stepper.value) < data.count {
            _ = data.popLast()
            collectionView.deleteItems(at: [IndexPath(row: data.count, section: 0)])
        } else if Int(stepper.value) > data.count {
            addNewColor()
            collectionView.insertItems(at: [IndexPath(row: data.count - 1, section: 0)])
        }
        itemsCount.text = "items: \(Int(stepper.value))"
    }
    @IBAction func horizontalButtonTap() {
        spring.scrollDirection = .horizontal
        collectionView.reloadData()
        switchDirectionButtons()
        
    }
    @IBAction func verticalButtonTap() {
        spring.scrollDirection = .vertical
        collectionView.reloadData()
        switchDirectionButtons()
    }
    @IBAction func sliderValueChanged () {
        spring.kResistence = CGFloat(slider.value)
        resistenceCount.text = "Resistance: \(spring.kResistence)"
    }
}

