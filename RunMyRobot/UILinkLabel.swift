//
//  UILinkLabel.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 09/07/2017.
//  Copyright © 2017 Let's Robot. All rights reserved.
//

import UIKit

protocol UILinkLabelDelegate: class {
    func attributedLabel(_ label: UILinkLabel!, didSelectLinkWith url: URL!)
}

class UILinkLabel: UILabel {
    
    typealias LinkAttributes = [String: Any]
    
    private var links = [TappableLink]()
    private var currentLink: TappableLink?
    
    weak var delegate: UILinkLabelDelegate?
    var linkAttributes: LinkAttributes?
    
    func setLinkText(_ text: NSMutableAttributedString) {
        links.removeAll()
        attributedText = text
        isUserInteractionEnabled = true
    }
    
    func addLink(to url: URL, at range: NSRange, attributes: LinkAttributes? = nil) {
        let link = TappableLink(url: url, range: range, attributes: attributes ?? linkAttributes)
        links.append(link)
        
        guard let text = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        
        for link in links {
            if let attributes = link.attributes {
                text.addAttributes(attributes, range: link.range)
            }
        }
        
        attributedText = text
        setNeedsDisplay()
    }
    
    // Link Recogniser
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self), let currentLink = link(at: point) {
            self.currentLink = currentLink
            return
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentLink = currentLink else {
            super.touchesMoved(touches, with: event)
            return
        }
        
        if let point = touches.first?.location(in: self), let newLink = link(at: point) {
            // Some of our links (e.g. new snapshot) have multiple links to the same address but with different ranges & attributes
            // By only checking the url here we enable the ability for the user's finger to move anywhere on the label and for it
            // to still match!
            if newLink.url != currentLink.url {
                self.currentLink = nil
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentLink = currentLink else {
            super.touchesEnded(touches, with: event)
            return
        }
        
        delegate?.attributedLabel(self, didSelectLinkWith: currentLink.url)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentLink = nil
        super.touchesCancelled(touches, with: event)
    }
    
    private func link(at point: CGPoint) -> TappableLink? {
        // Check that we have at least one link
        guard links.count > 0 else { return nil }
        
        // Check that we actually have text
        guard let attributedText = attributedText else { return nil }
        
        // Fail Fast: Ensure the tap is within the bounds of the label (+15pt expansion)
        guard bounds.insetBy(dx: -15, dy: -15).contains(point) else { return nil }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        
        let labelSize = bounds.size
        textContainer.size = labelSize
        
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: point.x - textContainerOffset.x,
                                                     y: point.y - textContainerOffset.y)
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)

        return links.first(where: { NSLocationInRange(indexOfCharacter, $0.range) })
    }
}

struct TappableLink {
    var url: URL
    var range: NSRange
    var attributes: UILinkLabel.LinkAttributes?
}
