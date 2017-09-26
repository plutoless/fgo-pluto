//
//  FgoLayout.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 26/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

class FgoLayout : UICollectionViewLayout
{
    open var itemSize:CGSize = CGSize(width: 44, height: 44)
    open var headerHeight:CGFloat = 0
    open var itemSpace:CGFloat = 0
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        super.prepare()
        // 1
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        // 2
        let numberOfColumns:Int = Int((self.contentWidth + self.itemSpace) / (self.itemSize.width + self.itemSpace))
        var xOffset = [CGFloat]()
        let xStart = (self.contentWidth - (CGFloat(numberOfColumns) * (self.itemSize.width + self.itemSpace) - self.itemSpace))/2.0
        for column in 0..<numberOfColumns {
            if(column == 0){
                xOffset.append(xStart)
            } else {
                xOffset.append(xStart + CGFloat(column) * (self.itemSize.width + self.itemSpace))
            }
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        // 3
        for section in 0 ..< collectionView.numberOfSections {
            let header_attrs = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
            header_attrs.frame = CGRect(x: 0, y: yOffset[0], width: self.contentWidth, height: self.headerHeight)
            //padding header
            for i in column..<numberOfColumns{
                yOffset[i] = yOffset[i] + self.headerHeight
            }
            self.contentHeight = max(self.contentHeight, header_attrs.frame.maxY)
            self.cache.append(header_attrs)
            
            for item in 0 ..< collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                
                // 4
                let height = self.itemSize.height
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: self.itemSize.width, height: height)
                
                // 5
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                self.cache.append(attributes)
                
                // 6
                self.contentHeight = max(self.contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                column = column < (numberOfColumns - 1) ? (column + 1) : 0
            }
            
            for i in column..<numberOfColumns{
                yOffset[i] = yOffset[0]
            }
            column = 0
        }
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in self.cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cache[indexPath.item]
    }
}
