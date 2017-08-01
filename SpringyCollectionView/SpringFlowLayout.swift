//
//  SpringFlowLayout.swift
//  6DegreesApp
//
//  Created by Сергей on 17.11.16.
//  Copyright © 2016 LindenValley. All rights reserved.
//
import UIKit
import Foundation


/// warning! if width, height, origin.x or origin.y of your collectionView's frame is not integer there may be issue (your item will go around anchor point)

class SpringyFlowLayout: UICollectionViewFlowLayout {
    
    @IBInspectable var springyRow: Bool = true
    
    private var dynamicAnimator: UIDynamicAnimator!
    private var behaviorManager: BehaviorManager!
    private var visibleIndexPathsSet: NSMutableSet!
    private var latestDelta = CGFloat()
    
    var kLength = CGFloat(1)
    var kDamping = CGFloat(0.8)
    var kFrequence = CGFloat(1)
    var kResistence = CGFloat(1400)
    
    override init() {
        super.init()
        dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
        behaviorManager = BehaviorManager(animator: dynamicAnimator)
        visibleIndexPathsSet = NSMutableSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
        behaviorManager = BehaviorManager(animator: dynamicAnimator)
        visibleIndexPathsSet = NSMutableSet()
    }
    
    
    // MARK - Layout
    
    override func prepare() {
        super.prepare()
        let visibleRect = collectionView!.bounds.insetBy(dx: -100, dy: -100)
        let itemsInVisibleRectArray = super.layoutAttributesForElements(in: visibleRect)! as NSArray
 
        behaviorManager.updateItemCollection(items: itemsInVisibleRectArray)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var array : [UICollectionViewLayoutAttributes] = []
        for item in dynamicAnimator.items(in: rect) {
            array.append(item as! UICollectionViewLayoutAttributes)
        }
        return array
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let visibleRect = collectionView!.bounds.insetBy(dx: -100, dy: -100)
        let itemsInVisibleRectArray = (dynamicAnimator.items(in: visibleRect) as! [UICollectionViewLayoutAttributes])
        var exist = false
        for item in itemsInVisibleRectArray {
            if item.indexPath.row == indexPath.row {
                exist = true
                break
            }
        }
        if !exist {
            return super.layoutAttributesForItem(at: indexPath)
        }
        return dynamicAnimator.layoutAttributesForCell(at: indexPath)
    }
    

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        
        invalidateLayout()

        let visibleRect = collectionView!.bounds.insetBy(dx: -100, dy: -100)
        let itemsInVisibleRectArray = super.layoutAttributesForElements(in: visibleRect)! as NSArray
        
        for item in itemsInVisibleRectArray {
            
            let attr = (item as! UICollectionViewLayoutAttributes)
            //print ("attr \(attr)")
            behaviorManager.removeItemAtIndexPath(indexPath: attr.indexPath)
            behaviorManager.addItem(item: attr, anchor: attr.center)
            dynamicAnimator.updateItem(usingCurrentState: attr)
        }
        super.prepare(forCollectionViewUpdates: updateItems)

    }
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if scrollDirection == .vertical {
            latestDelta = newBounds.origin.y - collectionView!.bounds.origin.y
        } else {
            latestDelta = newBounds.origin.x - collectionView!.bounds.origin.x
        }
        
        let touchLocation: CGPoint = collectionView!.panGestureRecognizer.location(in: collectionView)
        for springBehaviour in behaviorManager.attachmentBehaviors {

            var scrollResistance = CGFloat()
            
            if scrollDirection == .vertical {
                let yDistanceFromTouch, xDistanceFromTouch: CGFloat
                if springyRow {
                    yDistanceFromTouch = abs(touchLocation.y - springBehaviour.value.anchorPoint.y)
                    xDistanceFromTouch = abs(touchLocation.x - springBehaviour.value.anchorPoint.x)
                } else {
                    yDistanceFromTouch = abs(touchLocation.y - springBehaviour.value.anchorPoint.y)
                    xDistanceFromTouch = 0
                }
                scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / kResistence
                
            } else {
                let yDistanceFromTouch, xDistanceFromTouch: CGFloat
                if springyRow {
                    yDistanceFromTouch = abs(touchLocation.y - springBehaviour.value.anchorPoint.y)
                    xDistanceFromTouch = abs(touchLocation.x - springBehaviour.value.anchorPoint.x)
                } else {
                    yDistanceFromTouch = 0
                    xDistanceFromTouch = abs(touchLocation.x - springBehaviour.value.anchorPoint.x)
                }
                scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / kResistence
            }
 
            let item = springBehaviour.value.items.first as! UICollectionViewLayoutAttributes
            var center = item.center
            
            if scrollDirection == .vertical {
                if latestDelta < 0 {
                    center.y = center.y + max(latestDelta, latestDelta * scrollResistance)
                } else {
                    center.y = center.y + min(latestDelta, latestDelta * scrollResistance)
                }
            } else {
                if latestDelta < 0 {
                    center.x = center.x + max(latestDelta, latestDelta * scrollResistance)
                } else {
                    center.x = center.x + min(latestDelta, latestDelta * scrollResistance)
                }
            }

            item.center = center
            dynamicAnimator.updateItem(usingCurrentState: item)
        }
        return false
    }
}

func roundcgf(_ value: CGFloat) -> CGFloat {
    
    let newValue = Int(roundf(Float(value)))
    if newValue % 2 != 0 {
        //newValue = newValue - 1
    }
    return CGFloat(newValue)
}

func roundcgfEven(_ value: CGFloat) -> CGFloat {
    
    var newValue = Int(roundf(Float(value)))
    if newValue % 2 != 0 {
        newValue = newValue - 1
    }
    return CGFloat(newValue)
}
