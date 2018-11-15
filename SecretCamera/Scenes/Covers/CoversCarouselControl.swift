//
//  CoversCarouselControl.swift
//  SecretCamera
//
//  Created by Hung on 9/8/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation

final class CoversCarouselControl: NSObject {
    fileprivate let viewModel: CoversViewModel
    
    init(viewModel: CoversViewModel, carouselView: iCarousel?) {
        self.viewModel = viewModel
        super.init()
        carouselView?.delegate = self
        carouselView?.dataSource = self
    }
}

// MARK: - iCarouselDataSource
extension CoversCarouselControl: iCarouselDataSource {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return viewModel.numberOfItems()
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIView
        var imageView: UIImageView
        var titleLabel: UILabel
        
        //reuse view if available, otherwise create a new view
        if let view = view {
            itemView = view
            //get a reference to the label in the recycled view
            imageView = itemView.viewWithTag(1) as! UIImageView
            titleLabel = itemView.viewWithTag(2) as! UILabel
        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            let itemViewWidthSize = 170 * CGFloat(ScaleValue.SCREEN_WIDTH)
            let itemViewHeightSize = 200 * CGFloat(ScaleValue.SCREEN_WIDTH)
            
            itemView = UIView(frame: CGRect(x: 0, y: 0, width: itemViewWidthSize, height: itemViewHeightSize))
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: itemViewWidthSize, height: itemViewWidthSize))
            imageView.contentMode = .scaleAspectFit
            imageView.tag = 1
            itemView.addSubview(imageView)
            
            titleLabel = UILabel(frame: CGRect(x: 0, y: itemViewWidthSize + 12, width: itemViewWidthSize, height: 18))
            titleLabel.textAlignment = .center
            titleLabel.font = titleLabel.font.withSize(14 * CGFloat(ScaleValue.FONT))
            titleLabel.tag = 2
            itemView.addSubview(titleLabel)
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        imageView.image = UIImage(named: viewModel.getCoverImageNamed(at: index))
        titleLabel.text = viewModel.getCoverName(at: index)
        return itemView
    }
}

// MARK: - iCarouselDelegate
extension CoversCarouselControl: iCarouselDelegate {
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        viewModel.didSelectItemAt(at: index)
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        viewModel.didSelectItemAt(at: carousel.currentItemIndex)
    }
}
