//
//  BehaviorManager.swift
//  6DegreesApp
//
//  Created by Сергей on 20.11.16.
//  Copyright © 2016 LindenValley. All rights reserved.
//

import UIKit


    //this class provaide add, update and remove items
class BehaviorManager {

    var animator : UIDynamicAnimator
    var attachmentBehaviors : [IndexPath : UIAttachmentBehavior] = [:]
    init(animator: UIDynamicAnimator) {
        self.animator = animator
    }

    func addItem(item: UICollectionViewLayoutAttributes, anchor: CGPoint) {
        let attachmentBehavior = createAttachmentBehaviorForItem(item: item, anchor:anchor)
        animator.addBehavior(attachmentBehavior)
        attachmentBehaviors[item.indexPath] = attachmentBehavior
    }
    
    private func createAttachmentBehaviorForItem(item : UIDynamicItem, anchor : CGPoint) -> UIAttachmentBehavior {
        
        var temp = (item as! UICollectionViewLayoutAttributes).frame
        temp = CGRect(x: roundcgf(temp.origin.x), y: roundcgf(temp.origin.y), width: roundcgf(temp.width), height: roundcgf(temp.height))
        (item as! UICollectionViewLayoutAttributes).frame = temp
        
        let roundedAnchor = CGPoint(x: roundcgf(anchor.x), y: roundcgf(anchor.y))
        let attachmentBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: roundedAnchor )
        //print ("temp \(temp) roundedAnchor\(roundedAnchor)")
        attachmentBehavior.damping = 0.8
        attachmentBehavior.frequency = 1
        attachmentBehavior.length = 1
        return attachmentBehavior
    }
    
    func removeItemAtIndexPath(indexPath: IndexPath) {
        if let toRemove = attachmentBehaviors[indexPath] {
            animator.removeBehavior(toRemove)
        }
        attachmentBehaviors.removeValue(forKey: indexPath)
    }
    
    func updateItemCollection(items : NSArray) {
        // Let's find the ones we need to remove. We work in indexPaths here
        
        var toRemove = Set<IndexPath>(minimumCapacity: 0)
        for item in attachmentBehaviors {
            toRemove.insert(item.key)
        }
            
        var setOfItemIndexes = Set<IndexPath>()
        for item in items {
            setOfItemIndexes.insert((item as! UICollectionViewLayoutAttributes).indexPath)
        }
        toRemove.subtract(setOfItemIndexes)

        for indexPath in toRemove {
            
            removeItemAtIndexPath(indexPath: indexPath)
        }
        
        let existingIndexPaths = currentlyManagedItemIndexPaths()
        for attr in items {

            var alreadyExists = false
            for indexPath in existingIndexPaths {
                if (indexPath as! IndexPath).row == (attr as! UICollectionViewLayoutAttributes).indexPath.row {
                    alreadyExists = true
                }
            }
            if !alreadyExists {
                addItem(item: attr as! UICollectionViewLayoutAttributes, anchor:(attr as AnyObject).center)
            }
        }
    }
    private func currentlyManagedItemIndexPaths() -> [Any] {
        return attachmentBehaviors.arrayOfKeys.sorted(by: { (index1, index2) -> Bool in
            return (index1 as! IndexPath).row < (index2 as! IndexPath).row
        })
    }
    private func currentlyManagedItems() -> [(key: IndexPath, value: UIAttachmentBehavior)] {
        return attachmentBehaviors.sorted(by: { (p1 :(key: IndexPath, value: UIAttachmentBehavior), p2: (key: IndexPath, value: UIAttachmentBehavior)) -> Bool in
            return p1.key.row < p2.key.row
        })
    }
}

extension Dictionary {
    var arrayOfValues : [Any] {
        var array : [Any] = []
        for item in self {
            array.append(item.value)
        }
        return array
    }
    var arrayOfKeys : [Any] {
        var array : [Any] = []
        for item in self {
            array.append(item.key)
        }
        return array
    }
}
