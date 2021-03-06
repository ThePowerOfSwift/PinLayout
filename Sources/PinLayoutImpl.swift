// Copyright (c) 2017, Mirego
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// - Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// - Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// - Neither the name of the Mirego nor the names of its contributors may
//   be used to endorse or promote products derived from this software without
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

import Foundation

#if os(iOS)
    
public var unitTestLastWarning: String?

#if DEBUG
    public var PinLayoutLogConflicts = true
#else
    public var PinLayoutLogConflicts = false
#endif

class PinLayoutImpl: PinLayout {
    fileprivate let view: UIView

    fileprivate var _top: CGFloat?       // offset from superview's top edge
    fileprivate var _left: CGFloat?      // offset from superview's left edge
    fileprivate var _bottom: CGFloat?    // offset from superview's top edge
    fileprivate var _right: CGFloat?     // offset from superview's left edge
    
    fileprivate var _hCenter: CGFloat?
    fileprivate var _vCenter: CGFloat?
    
    fileprivate var width: CGFloat?
    fileprivate var height: CGFloat?

    fileprivate var marginTop: CGFloat?
    fileprivate var marginLeft: CGFloat?
    fileprivate var marginBottom: CGFloat?
    fileprivate var marginRight: CGFloat?
    fileprivate var shouldPinEdges = false
    
    fileprivate var shouldSizeToFit = false

    fileprivate var _marginTop: CGFloat { return marginTop ?? 0  }
    fileprivate var _marginLeft: CGFloat { return marginLeft ?? 0 }
    fileprivate var _marginBottom: CGFloat { return marginBottom ?? 0 }
    fileprivate var _marginRight: CGFloat { return marginRight ?? 0 }

    init(view: UIView) {
        self.view = view
    }
    
    deinit {
        apply()
    }
    
    //
    // top, left, bottom, right
    //
    @discardableResult func top() -> PinLayout {
        setTop(0, { return "top()" })
        return self
    }

    @discardableResult
    func top(_ value: CGFloat) -> PinLayout {
        setTop(value, { return "top(\(value))" })
        return self
    }
    
    @discardableResult
    func top(_ percent: Percent) -> PinLayout {
        func context() -> String { return "top(\(percent))" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setTop(percent.of(layoutSuperview.frame.height), context)
        return self
    }
    
    @discardableResult func left() -> PinLayout {
        setLeft(0, { return "left()" })
        return self
    }

    @discardableResult
    func left(_ value: CGFloat) -> PinLayout {
        setLeft(value, { return "left(\(value))" })
        return self
    }
    
    @discardableResult
    func left(_ percent: Percent) -> PinLayout {
        func context() -> String { return "left(\(percent))" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setLeft(percent.of(layoutSuperview.frame.width), context)
        return self
    }
    
    @discardableResult func bottom() -> PinLayout {
        func context() -> String { return "bottom()" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setBottom(layoutSuperview.frame.height, context)
        return self
    }

    @discardableResult
    func bottom(_ value: CGFloat) -> PinLayout {
        func context() -> String { return "bottom(\(value))" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setBottom(layoutSuperview.frame.height - value, context)
        return self
    }
    
    @discardableResult
    func bottom(_ percent: Percent) -> PinLayout {
        func context() -> String { return "bottom(\(percent))" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setBottom(layoutSuperview.frame.height - percent.of(layoutSuperview.frame.height), context)
        return self
    }

    @discardableResult func right() -> PinLayout {
        func context() -> String { return "right()" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setRight(layoutSuperview.frame.width, context)
        return self
    }

    @discardableResult
    func right(_ value: CGFloat) -> PinLayout {
        func context() -> String { return "right(\(value))" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setRight(layoutSuperview.frame.width - value, context)
        return self
    }
    
    @discardableResult
    func right(_ percent: Percent) -> PinLayout {
        func context() -> String { return "right(\(percent))" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setRight(layoutSuperview.frame.width - percent.of(layoutSuperview.frame.width), context)
        return self
    }

    @discardableResult
    func hCenter() -> PinLayout {
        func context() -> String { return "hCenter()" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setHorizontalCenter(layoutSuperview.frame.width / 2, context)
        return self
    }

    @discardableResult
    func hCenter(_ value: CGFloat) -> PinLayout {
        func context() -> String { return "hCenter(\(value))" }
        setHorizontalCenter(value, context)
        return self
    }
    
    @discardableResult
    func hCenter(_ percent: Percent) -> PinLayout {
        func context() -> String { return "hCenter(\(percent))" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setHorizontalCenter(percent.of(layoutSuperview.frame.width), context)
        return self
    }

    @discardableResult
    func vCenter() -> PinLayout {
        func context() -> String { return "vCenter()" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setVerticalCenter(layoutSuperview.frame.height / 2, context)
        return self
    }
    
    @discardableResult
    func vCenter(_ value: CGFloat) -> PinLayout {
        func context() -> String { return "vCenter(\(value))" }
        setVerticalCenter(value, context)
        return self
    }
    
    @discardableResult
    func vCenter(_ percent: Percent) -> PinLayout {
        func context() -> String { return "vCenter(\(percent))" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setVerticalCenter(percent.of(layoutSuperview.frame.height), context)
        return self
    }

    //
    // top, left, bottom, right
    //
    @discardableResult
    func top(to edge: VerticalEdge) -> PinLayout {
        func context() -> String { return relativeEdgeContext(method: "top", edge: edge) }
        if let coordinate = computeCoordinate(forEdge: edge, context) {
            setTop(coordinate, context)
        }
        return self
    }
    
    @discardableResult
    func left(to edge: HorizontalEdge) -> PinLayout {
        func context() -> String { return relativeEdgeContext(method: "left", edge: edge) }
        if let coordinate = computeCoordinate(forEdge: edge, context) {
            setLeft(coordinate, context)
        }
        return self
    }
    
    @discardableResult
    func bottom(to edge: VerticalEdge) -> PinLayout {
        func context() -> String { return relativeEdgeContext(method: "bottom", edge: edge) }
        if let coordinate = computeCoordinate(forEdge: edge, context) {
            setBottom(coordinate, context)
        }
        return self
    }
    
    @discardableResult
    func right(to edge: HorizontalEdge) -> PinLayout {
        func context() -> String { return relativeEdgeContext(method: "right", edge: edge) }
        if let coordinate = computeCoordinate(forEdge: edge, context) {
            setRight(coordinate, context)
        }
        return self
    }
    
    //
    // topLeft, topCenter, topRight,
    // leftCenter, center, rightCenter,
    // bottomLeft, bottomCenter, bottomRight,
    //
    /// Position the topLeft on the specified view's Anchor.
    @discardableResult
    func topLeft(to anchor: Anchor) -> PinLayout {
        func context() -> String { return relativeAnchorContext(method: "topLeft", anchor: anchor) }
        if let coordinatesList = computeCoordinates(forAnchors: [anchor], context) {
            setTopLeft(coordinatesList[0], context)
        }
        return self
    }

    /// Position on the topLeft corner of its superview.
    @discardableResult
    func topLeft() -> PinLayout {
        func context() -> String { return "topLeft()" }
        setTop(0, context)
        setLeft(0, context)
        return self
    }
    
    /// Position the topCenter on the specified view's pin.
    @discardableResult
    func topCenter(to anchor: Anchor) -> PinLayout {
        func context() -> String { return relativeAnchorContext(method: "topCenter", anchor: anchor) }
        if let coordinatesList = computeCoordinates(forAnchors: [anchor], context) {
            setTopCenter(coordinatesList[0], context)
        }
        return self
    }

    /// Position on the topCenter corner of its superview.
    @discardableResult
    func topCenter() -> PinLayout {
        func context() -> String { return "topCenter()" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setTop(0, context)
        setHorizontalCenter(layoutSuperview.frame.width / 2, context)
        return self
    }

    /// Position the topRight on the specified view's pin.
    @discardableResult
    func topRight(to anchor: Anchor) -> PinLayout {
        func context() -> String { return relativeAnchorContext(method: "topRight", anchor: anchor) }
        if let coordinatesList = computeCoordinates(forAnchors: [anchor], context) {
            setTopRight(coordinatesList[0], context)
        }
        return self
    }

    /// Position on the topRight corner of its superview.
    @discardableResult
    func topRight() -> PinLayout {
        func context() -> String { return "topRight()" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setTop(0, context)
        setRight(layoutSuperview.frame.width, context)
        return self
    }
    
    /// Position the leftCenter on the specified view's pin.
    @discardableResult
    func leftCenter(to anchor: Anchor) -> PinLayout {
        func context() -> String { return relativeAnchorContext(method: "leftCenter", anchor: anchor) }
        if let coordinatesList = computeCoordinates(forAnchors: [anchor], context) {
            setLeftCenter(coordinatesList[0], context)
        }
        return self
    }
    
    /// Position on the leftCenter corner of its superview.
    @discardableResult
    func leftCenter() -> PinLayout {
        func context() -> String { return "leftCenter()" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setLeft(0, context)
        setVerticalCenter(layoutSuperview.frame.height / 2, context)
        return self
    }

    /// Position the centers on the specified view's pin.
    @discardableResult
    func center(to anchor: Anchor) -> PinLayout {
        func context() -> String { return relativeAnchorContext(method: "center", anchor: anchor) }
        if let coordinatesList = computeCoordinates(forAnchors: [anchor], context) {
            setCenter(coordinatesList[0], context)
        }
        return self
    }
    
    @discardableResult
    func center() -> PinLayout {
        func context() -> String { return "center()" }

        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setHorizontalCenter(layoutSuperview.frame.width / 2, context)
        setVerticalCenter(layoutSuperview.frame.height / 2, context)
        return self
    }
    
    /// Position the rightCenter on the specified view's pin.
    @discardableResult
    func rightCenter(to anchor: Anchor) -> PinLayout {
        func context() -> String { return relativeAnchorContext(method: "rightCenter", anchor: anchor) }
        if let coordinatesList = computeCoordinates(forAnchors: [anchor], context) {
            setRightCenter(coordinatesList[0], context)
        }
        return self
    }
    
    /// Position on the rightCenter corner of its superview.
    @discardableResult
    func rightCenter() -> PinLayout {
        func context() -> String { return "rightCenter()" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setRight(layoutSuperview.frame.width, context)
        setVerticalCenter(layoutSuperview.frame.height / 2, context)
        return self
    }
    
    /// Position the bottomLeft on the specified view's pin.
    @discardableResult
    func bottomLeft(to anchor: Anchor) -> PinLayout {
        func context() -> String { return relativeAnchorContext(method: "bottomLeft", anchor: anchor) }
        if let coordinatesList = computeCoordinates(forAnchors: [anchor], context) {
            setBottomLeft(coordinatesList[0], context)
        }
        return self
    }

    /// Position on the bottomLeft corner of its superview.
    @discardableResult
    func bottomLeft() -> PinLayout {
        func context() -> String { return "bottomLeft()" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setLeft(0, context)
        setBottom(layoutSuperview.frame.height, context)
        return self
    }

    /// Position the bottomCenter on the specified view's pin.
    @discardableResult
    func bottomCenter(to anchor: Anchor) -> PinLayout {
        func context() -> String { return relativeAnchorContext(method: "bottomCenter", anchor: anchor) }
        if let coordinatesList = computeCoordinates(forAnchors: [anchor], context) {
            setBottomCenter(coordinatesList[0], context)
        }
        return self
    }

    /// Position on the bottomCenter corner of its superview.
    @discardableResult
    func bottomCenter() -> PinLayout {
        func context() -> String { return "bottomCenter()" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setHorizontalCenter(layoutSuperview.frame.width / 2, context)
        setBottom(layoutSuperview.frame.height, context)
        return self
    }

    /// Position the bottomRight on the specified view's pin.
    @discardableResult
    func bottomRight(to anchor: Anchor) -> PinLayout {
        func context() -> String { return relativeAnchorContext(method: "bottomRight", anchor: anchor) }
        if let coordinatesList = computeCoordinates(forAnchors: [anchor], context) {
            setBottomRight(coordinatesList[0], context)
        }
        return self
    }

    /// Position on the bottomRight corner of its superview.
    @discardableResult
    func bottomRight() -> PinLayout {
        func context() -> String { return "bottomRight()" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        setBottom(layoutSuperview.frame.height, context)
        setRight(layoutSuperview.frame.width, context)
        return self
    }

    /// Set the view's bottom coordinate above all specified views.
    @discardableResult
    func above(of relativeViews: UIView...) -> PinLayout {
        func context() -> String { return "above(of: UIView...)" }
        guard validateRelativeViewsCount(relativeViews, context: context) else { return self }
        
        let anchors = relativeViews.map({ $0.anchor.topLeft })
        if let coordinatesList = computeCoordinates(forAnchors: anchors, context) {
            setBottom(getTopMostCoordinate(list: coordinatesList), context)
        }
        return self
    }

    /// Set the view's bottom coordinate above all specified view.
    @discardableResult
    func above(of relativeViews: UIView..., aligned: HorizontalAlignment) -> PinLayout {
        func context() -> String { return "above(of: UIView..., aligned: \(aligned))" }
        guard validateRelativeViewsCount(relativeViews, context: context) else { return self }
        
        let anchors: [Anchor]
        switch aligned {
        case .left:   anchors = relativeViews.map({ $0.anchor.topLeft })
        case .center: anchors = relativeViews.map({ $0.anchor.topCenter })
        case .right:  anchors = relativeViews.map({ $0.anchor.topRight })
        }
        
        if let coordinatesList = computeCoordinates(forAnchors: anchors, context) {
            setBottom(getTopMostCoordinate(list: coordinatesList), context)
            
            switch aligned {
            case .left:   setLeft(getLeftMostCoordinate(list: coordinatesList), context)
            case .center: setHorizontalCenter(getAverageHCenterCoordinate(list: coordinatesList), context)
            case .right:  setRight(getRightMostCoordinate(list: coordinatesList), context)
            }
        }
        return self
    }
    
    /// Set the view's top coordinate below all specified view.
    @discardableResult
    func below(of relativeViews: UIView...) -> PinLayout {
        func context() -> String { return "below(of: UIView...)" }
        guard validateRelativeViewsCount(relativeViews, context: context) else { return self }
        
        let anchors = relativeViews.map({ $0.anchor.bottomLeft })
        if let coordinatesList = computeCoordinates(forAnchors: anchors, context) {
            setTop(getBottomMostCoordinate(list: coordinatesList), context)
        }
        return self
    }
    
    @discardableResult
    func below(of relativeViews: UIView..., aligned: HorizontalAlignment) -> PinLayout {
        func context() -> String { return "below(of: UIView..., aligned: \(aligned))" }
        guard validateRelativeViewsCount(relativeViews, context: context) else { return self }
        
        let anchors: [Anchor]
        switch aligned {
        case .left:   anchors = relativeViews.map({ $0.anchor.bottomLeft })
        case .center: anchors = relativeViews.map({ $0.anchor.bottomCenter })
        case .right:  anchors = relativeViews.map({ $0.anchor.bottomRight })
        }
        
        if let coordinatesList = computeCoordinates(forAnchors: anchors, context) {
            setTop(getBottomMostCoordinate(list: coordinatesList), context)
            
            switch aligned {
            case .left:   setLeft(getLeftMostCoordinate(list: coordinatesList), context)
            case .center: setHorizontalCenter(getAverageHCenterCoordinate(list: coordinatesList), context)
            case .right:  setRight(getRightMostCoordinate(list: coordinatesList), context)
            }
        }
        return self
    }
    
    /// Set the view's right coordinate left of the specified view.
    @discardableResult
    func left(of relativeViews: UIView...) -> PinLayout {
        func context() -> String { return "left(of: UIView...)" }
        guard validateRelativeViewsCount(relativeViews, context: context) else { return self }
        
        let anchors = relativeViews.map({ $0.anchor.topLeft })
        if let coordinatesList = computeCoordinates(forAnchors: anchors, context) {
            setRight(getLeftMostCoordinate(list: coordinatesList), context)
        }
        return self
    }
    
    @discardableResult
    func left(of relativeViews: UIView..., aligned: VerticalAlignment) -> PinLayout {
        func context() -> String { return "left(of: UIView..., aligned: \(aligned))" }
        guard validateRelativeViewsCount(relativeViews, context: context) else { return self }
        
        let anchors: [Anchor]
        switch aligned {
        case .top:    anchors = relativeViews.map({ $0.anchor.topLeft })
        case .center: anchors = relativeViews.map({ $0.anchor.leftCenter })
        case .bottom: anchors = relativeViews.map({ $0.anchor.bottomLeft })
        }
        
        if let coordinatesList = computeCoordinates(forAnchors: anchors, context) {
            setRight(getLeftMostCoordinate(list: coordinatesList), context)
            
            switch aligned {
            case .top:    setTop(getTopMostCoordinate(list: coordinatesList), context)
            case .center: setVerticalCenter(getAverageVCenterCoordinate(list: coordinatesList), context)
            case .bottom: setBottom(getBottomMostCoordinate(list: coordinatesList), context)
            }
        }
        return self
    }
    
    /// Set the view's left coordinate right of the specified view.
    @discardableResult
    func right(of relativeViews: UIView...) -> PinLayout {
        func context() -> String { return "right(of: UIView...)" }
        guard validateRelativeViewsCount(relativeViews, context: context) else { return self }
        
        let anchors = relativeViews.map({ $0.anchor.topRight })
        if let coordinatesList = computeCoordinates(forAnchors: anchors, context) {
            setLeft(getRightMostCoordinate(list: coordinatesList), context)
        }
        return self
    }
    
    @discardableResult
    func right(of relativeViews: UIView..., aligned: VerticalAlignment) -> PinLayout {
        func context() -> String { return "right(of: UIView..., aligned: \(aligned))" }
        guard validateRelativeViewsCount(relativeViews, context: context) else { return self }
        
        let anchors: [Anchor]
        switch aligned {
        case .top:    anchors = relativeViews.map({ $0.anchor.topRight })
        case .center: anchors = relativeViews.map({ $0.anchor.rightCenter })
        case .bottom: anchors = relativeViews.map({ $0.anchor.bottomRight })
        }
        
        if let coordinatesList = computeCoordinates(forAnchors: anchors, context) {
            setLeft(getRightMostCoordinate(list: coordinatesList), context)
            
            switch aligned {
            case .top:    setTop(getTopMostCoordinate(list: coordinatesList), context)
            case .center: setVerticalCenter(getAverageVCenterCoordinate(list: coordinatesList), context)
            case .bottom: setBottom(getBottomMostCoordinate(list: coordinatesList), context)
            }
        }
        return self
    }
    
    //
    // width, height
    //
    @discardableResult
    func width(_ width: CGFloat) -> PinLayout {
        return setWidth(width, { return "width(\(width))" })
    }
    
    @discardableResult
    func width(_ percent: Percent) -> PinLayout {
        func context() -> String { return "width(\(percent))" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        return setWidth(percent.of(layoutSuperview.frame.width), context)
    }

    @discardableResult
    func width(of view: UIView) -> PinLayout {
        return setWidth(view.frame.width, { return "width(of: \(view))" })
    }

    @discardableResult
    func height(_ height: CGFloat) -> PinLayout {
        return setHeight(height, { return "height(\(height))" })
    }
    
    @discardableResult
    func height(_ percent: Percent) -> PinLayout {
        func context() -> String { return "height(\(percent))" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        return setHeight(percent.of(layoutSuperview.frame.height), context)
    }

    @discardableResult
    func height(of view: UIView) -> PinLayout {
        return setHeight(view.frame.height, { return "height(of: \(view))" })
    }
    
    //
    // size, sizeToFit
    //
    @discardableResult
    func size(_ size: CGSize) -> PinLayout {
        return setSize(size, { return "size(CGSize(width: \(size.width), height: \(size.height)))" })
    }
    
    @discardableResult
    func size(_ sideLength: CGFloat) -> PinLayout {
        return setSize(CGSize(width: sideLength, height: sideLength), { return "size(sideLength: \(sideLength))" })
    }
    
    @discardableResult
    func size(_ percent: Percent) -> PinLayout {
        func context() -> String { return "size(\(percent))" }
        guard let layoutSuperview = layoutSuperview(context) else { return self }
        let size = CGSize(width: percent.of(layoutSuperview.frame.width), height: percent.of(layoutSuperview.frame.height))
        return setSize(size, context)
    }
    
    @discardableResult
    func size(of view: UIView) -> PinLayout {
        func context() -> String { return "size(of \(view))" }
        return setSize(view.frame.size, context)
    }
    
    @discardableResult
    func sizeToFit() -> PinLayout {
        shouldSizeToFit = true
        return self
    }
    
    //
    // Margins
    //
    @discardableResult
    func marginTop(_ value: CGFloat) -> PinLayout {
        marginTop = value
        return self
    }

    @discardableResult
    func marginLeft(_ value: CGFloat) -> PinLayout {
        marginLeft = value
        return self
    }

    @discardableResult
    func marginBottom(_ value: CGFloat) -> PinLayout {
        marginBottom = value
        return self
    }

    @discardableResult
    func marginRight(_ value: CGFloat) -> PinLayout {
        marginRight = value
        return self
    }

    func marginHorizontal(_ value: CGFloat) -> PinLayout {
        marginLeft = value
        marginRight = value
        return self
    }

    @discardableResult
    func marginVertical(_ value: CGFloat) -> PinLayout {
        marginTop = value
        marginBottom = value
        return self
    }

    @discardableResult
    func margin(_ value: CGFloat) -> PinLayout {
        marginTop = value
        marginLeft = value
        marginBottom = value
        marginRight = value
        return self
    }

    @discardableResult
    func margin(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> PinLayout {
        marginTop = top
        marginLeft = left
        marginBottom = bottom
        marginRight = right
        return self
    }

    @discardableResult func margin(_ vertical: CGFloat, _ horizontal: CGFloat) -> PinLayout {
        marginTop = vertical
        marginLeft = horizontal
        marginBottom = vertical
        marginRight = horizontal
        return self
    }

    @discardableResult func margin(_ top: CGFloat, _ horizontal: CGFloat, _ bottom: CGFloat) -> PinLayout {
        marginTop = top
        marginLeft = horizontal
        marginBottom = bottom
        marginRight = horizontal
        return self
    }

    @discardableResult
    func pinEdges() -> PinLayout {
        shouldPinEdges = true
        return self
    }
}

//
// MARK: Private methods - Set coordinates
//
extension PinLayoutImpl {
    fileprivate func setTop(_ value: CGFloat, _ context: Context) {
        if let _bottom = _bottom, let height = height {
            warnConflict(context, ["bottom": _bottom, "height": height])
        } else if let _vCenter = _vCenter {
            warnConflict(context, ["Vertical Center": _vCenter])
        } else if let _top = _top, _top != value {
            warnPropertyAlreadySet("top", propertyValue: _top, context)
        } else {
            _top = value
        }
    }
    
    fileprivate func setLeft(_ value: CGFloat, _ context: Context) {
        if let _right = _right, let width = width  {
            warnConflict(context, ["right": _right, "width": width])
        } else if let _hCenter = _hCenter {
            warnConflict(context, ["Horizontal Center": _hCenter])
        } else if let _left = _left, _left != value {
            warnPropertyAlreadySet("left", propertyValue: _left, context)
        } else {
            _left = value
        }
    }
    
    fileprivate func setRight(_ value: CGFloat, _ context: Context) {
        if let _left = _left, let width = width  {
            warnConflict(context, ["left": _left, "width": width])
        } else if let _hCenter = _hCenter {
            warnConflict(context, ["Horizontal Center": _hCenter])
        } else if let _right = _right, _right != value {
            warnPropertyAlreadySet("right", propertyValue: _right, context)
        } else {
            _right = value
        }
    }
    
    fileprivate func setBottom(_ value: CGFloat, _ context: Context) {
        if let _top = _top, let height = height {
            warnConflict(context, ["top": _top, "height": height])
        } else if let _vCenter = _vCenter {
            warnConflict(context, ["Vertical Center": _vCenter])
        } else if let _bottom = _bottom, _bottom != value {
            warnPropertyAlreadySet("bottom", propertyValue: _bottom, context)
        } else {
            _bottom = value
        }
    }

    fileprivate func setHorizontalCenter(_ value: CGFloat, _ context: Context) {
        if let _left = _left {
            warnConflict(context, ["left": _left])
        } else if let _right = _right {
            warnConflict(context, ["right": _right])
        } else if let _hCenter = _hCenter, _hCenter != value {
            warnPropertyAlreadySet("Horizontal Center", propertyValue: _hCenter, context)
        } else {
            _hCenter = value
        }
    }
    
    fileprivate func setVerticalCenter(_ value: CGFloat, _ context: Context) {
        if let _top = _top {
            warnConflict(context, ["top": _top])
        } else if let _bottom = _bottom {
            warnConflict(context, ["bottom": _bottom])
        } else if let _vCenter = _vCenter, _vCenter != value {
            warnPropertyAlreadySet("Vertical Center", propertyValue: _vCenter, context)
        } else {
            _vCenter = value
        }
    }
    
    @discardableResult
    fileprivate func setTopLeft(_ point: CGPoint, _ context: Context) -> PinLayout {
        setLeft(point.x, context)
        setTop(point.y, context)
        return self
    }
    
    @discardableResult
    fileprivate func setTopCenter(_ point: CGPoint, _ context: Context) -> PinLayout {
        setHorizontalCenter(point.x, context)
        setTop(point.y, context)
        return self
    }
    
    @discardableResult
    fileprivate func setTopRight(_ point: CGPoint, _ context: Context) -> PinLayout {
        setRight(point.x, context)
        setTop(point.y, context)
        return self
    }
    
    @discardableResult
    fileprivate func setLeftCenter(_ point: CGPoint, _ context: Context) -> PinLayout {
        setLeft(point.x, context)
        setVerticalCenter(point.y, context)
        return self
    }
    
    @discardableResult
    fileprivate func setCenter(_ point: CGPoint, _ context: Context) -> PinLayout {
        setHorizontalCenter(point.x, context)
        setVerticalCenter(point.y, context)
        return self
    }
    
    @discardableResult
    fileprivate func setRightCenter(_ point: CGPoint, _ context: Context) -> PinLayout {
        setRight(point.x, context)
        setVerticalCenter(point.y, context)
        return self
    }
    
    @discardableResult
    fileprivate func setBottomLeft(_ point: CGPoint, _ context: Context) -> PinLayout {
        setLeft(point.x, context)
        setBottom(point.y, context)
        return self
    }
    
    @discardableResult
    fileprivate func setBottomCenter(_ point: CGPoint, _ context: Context) -> PinLayout {
        setHorizontalCenter(point.x, context)
        setBottom(point.y, context)
        return self
    }
    
    @discardableResult
    fileprivate func setBottomRight(_ point: CGPoint, _ context: Context) -> PinLayout {
        setRight(point.x, context)
        setBottom(point.y, context)
        return self
    }

    @discardableResult
    fileprivate func setWidth(_ value: CGFloat, _ context: Context) -> PinLayout {
        guard value >= 0 else {
            warn("the width (\(value)) ust be greater than or equal to zero.", context); return self
        }
        
        if let _left = _left, let _right = _right {
            warnConflict(context, ["left": _left, "right": _right])
        } else if let width = width, width != value {
            warnPropertyAlreadySet("width", propertyValue: width, context)
        } else {
            width = value
        }
        return self
    }
    
    @discardableResult
    fileprivate func setHeight(_ value: CGFloat, _ context: Context) -> PinLayout {
        guard value >= 0 else {
            warn("the height (\(value)) must be greater than or equal to zero.", context); return self
        }
        
        if let _top = _top, let _bottom = _bottom {
            warnConflict(context, ["top": _top, "bottom": _bottom])
        } else if let height = height, height != value {
            warnPropertyAlreadySet("height", propertyValue: height, context)
        } else {
            height = value
        }
        return self
    }
    
    fileprivate func setSize(_ size: CGSize, _ context: Context) -> PinLayout {
        setWidth(size.width, { return "\(context())'s width" })
        setHeight(size.height, { return "\(context())'s height" })
        return self
    }
    
    fileprivate func computeCoordinates(_ point: CGPoint, _ layoutSuperview: UIView, _ referenceView: UIView, _ referenceSuperview: UIView) -> CGPoint {
        if layoutSuperview == referenceSuperview {
            return point   // same superview => no coordinates conversion required.
        } else {
            return referenceSuperview.convert(point, to: layoutSuperview)
        }
    }
    
    fileprivate func computeCoordinates(forAnchors anchors: [Anchor], _ context: Context) -> [CGPoint]? {
        guard let layoutSuperview = layoutSuperview(context) else { return nil }
        var results: [CGPoint] = []
        anchors.forEach({ (anchor) in
            let anchor = anchor as! AnchorImpl
            if let referenceSuperview = referenceSuperview(anchor.view, context) {
                results.append(computeCoordinates(anchor.point, layoutSuperview, anchor.view, referenceSuperview))
            }
        })
        
        guard results.count > 0 else {
            warn("no valid references", context)
            return nil
        }
        
        return results
    }
    
    fileprivate func computeCoordinate(forEdge edge: HorizontalEdge, _ context: Context) -> CGFloat? {
        let edge = edge as! HorizontalEdgeImpl
        guard let layoutSuperview = layoutSuperview(context) else { return nil }
        guard let referenceSuperview = referenceSuperview(edge.view, context) else { return nil }
        
        return computeCoordinates(CGPoint(x: edge.x, y: 0), layoutSuperview, edge.view, referenceSuperview).x
    }

    fileprivate func computeCoordinate(forEdge edge: VerticalEdge, _ context: Context) -> CGFloat? {
        let edge = edge as! VerticalEdgeImpl
        guard let layoutSuperview = layoutSuperview(context) else { return nil }
        guard let referenceSuperview = referenceSuperview(edge.view, context) else { return nil }

        return computeCoordinates(CGPoint(x: 0, y: edge.y), layoutSuperview, edge.view, referenceSuperview).y
    }

    fileprivate func layoutSuperview(_ context: Context) -> UIView? {
        if let superview = view.superview {
            return superview
        } else {
            warn("the view must be added as a sub-view before being layouted using this method.", context)
            return nil
        }
    }

    fileprivate func referenceSuperview(_ referenceView: UIView, _ context: Context) -> UIView? {
        if let superview = referenceView.superview {
            return superview
        } else {
            warn("the reference view \(viewDescription(referenceView)) is invalid. UIViews must be added as a sub-view before being used as a reference.", context)
            return nil
        }
    }
}
    
// MARK - Relative methods helpers
extension PinLayoutImpl {
    fileprivate func getTopMostCoordinate(list: [CGPoint]) -> CGFloat {
        assert(list.count > 0)
        let firstCoordinate = list[0].y
        return list.dropFirst().reduce(firstCoordinate, { (bestCoordinate, otherCoordinates) -> CGFloat in
            return (otherCoordinates.y < bestCoordinate) ? otherCoordinates.y : bestCoordinate
        })
    }
    
    fileprivate func getBottomMostCoordinate(list: [CGPoint]) -> CGFloat {
        assert(list.count > 0)
        let firstCoordinate = list[0].y
        return list.dropFirst().reduce(firstCoordinate, { (bestCoordinate, otherCoordinates) -> CGFloat in
            return (otherCoordinates.y > bestCoordinate) ? otherCoordinates.y : bestCoordinate
        })
    }
    
    fileprivate func getLeftMostCoordinate(list: [CGPoint]) -> CGFloat {
        assert(list.count > 0)
        let firstCoordinate = list[0].x
        return list.dropFirst().reduce(firstCoordinate, { (bestCoordinate, otherCoordinates) -> CGFloat in
            return (otherCoordinates.x < bestCoordinate) ? otherCoordinates.x : bestCoordinate
        })
    }
    
    fileprivate func getRightMostCoordinate(list: [CGPoint]) -> CGFloat {
        assert(list.count > 0)
        let firstCoordinate = list[0].x
        return list.dropFirst().reduce(firstCoordinate, { (bestCoordinate, otherCoordinates) -> CGFloat in
            return (otherCoordinates.x > bestCoordinate) ? otherCoordinates.x : bestCoordinate
        })
    }
    
    fileprivate func getAverageHCenterCoordinate(list: [CGPoint]) -> CGFloat {
        assert(list.count > 0)
        let sum = list.reduce(0, { (result, point) -> CGFloat in
            return result + point.x
        })
        return sum / CGFloat(list.count)
    }
    
    fileprivate func getAverageVCenterCoordinate(list: [CGPoint]) -> CGFloat {
        assert(list.count > 0)
        let sum = list.reduce(0, { (result, point) -> CGFloat in
            return result + point.y
        })
        return sum / CGFloat(list.count)
    }
    
    fileprivate func validateRelativeViewsCount(_ views: [UIView], context: Context) -> Bool {
        guard let _ = layoutSuperview(context) else { return false }
        guard views.count > 0 else {
            warn("At least one view must be specified", context)
            return false
        }
        
        return true
    }
}

// MARK - UIView's frame compuation methods
extension PinLayoutImpl {
    fileprivate func apply() {
        apply(onView: view)
    }
    
    fileprivate func apply(onView view: UIView) {
        var newRect = view.frame

        handlePinEdges()

        let newSize = computeSize()
        
        // Compute horizontal position
        if let left = _left, let width = newSize.width {
            // left & width is set
            newRect.origin.x = left + _marginLeft
            newRect.size.width = width
        } else if let left = _left, let right = _right {
            // left & right is set
            newRect.origin.x = left + _marginLeft
            newRect.size.width = right - _marginRight - newRect.origin.x
        } else if let right = _right, let width = newSize.width {
            // right & width is set
            newRect.size.width = width
            newRect.origin.x = right - _marginRight - width
        } else if let _hCenter = _hCenter, let width = newSize.width {
            // hCenter & width is set
            newRect.size.width = width
            newRect.origin.x = _hCenter - (width / 2) + _marginLeft
        } else if let left = _left {
            // Only left is set
            newRect.origin.x = left + _marginLeft
        } else if let right = _right {
            // Only right is set
            newRect.origin.x = right - view.frame.width - _marginRight
        } else if let _hCenter = _hCenter {
            // Only hCenter is set
            newRect.origin.x = _hCenter - (view.frame.width / 2)
        } else if let width = newSize.width {
            // Only width is set
            newRect.size.width = width
        }
        
        // Compute vertical position
        if let top = _top, let height = newSize.height {
            // top & height is set
            newRect.origin.y = top + _marginTop
            newRect.size.height = height
        } else if let top = _top, let bottom = _bottom {
            // top & bottom is set
            newRect.origin.y = top + _marginTop
            newRect.size.height = bottom - _marginBottom - newRect.origin.y
        } else if let bottom = _bottom, let height = newSize.height {
            // bottom & height is set
            newRect.size.height = height
            newRect.origin.y = bottom - _marginBottom - height
        } else if let _vCenter = _vCenter, let height = newSize.height {
            // vCenter & height is set
            newRect.size.height = height
            newRect.origin.y = _vCenter - (newRect.size.height / 2) + _marginTop
        } else if let top = _top {
            // Only top is set
            newRect.origin.y = top + _marginTop
        } else if let bottom = _bottom {
            // Only bottom is set
            newRect.origin.y = bottom - view.frame.height - _marginBottom
        } else if let _vCenter = _vCenter {
            // Only vCenter is set
            newRect.origin.y = _vCenter - (view.frame.height / 2)
        } else if let height = newSize.height {
            // Only height is set
            newRect.size.height = height
        }

        view.frame = Coordinates.adjustRectToDisplayScale(newRect)
    }

    fileprivate func handlePinEdges() {
        guard shouldPinEdges else { return }

        if let width = width {
            if let left = _left {
                // convert the width into a right
                assert(self._right == nil)
                self._right = left + width
                self.width = nil
            } else if let right = _right {
                // convert the width into a left
                assert(self._left == nil)
                self._left = right - width
                self.width = nil
            } else if let _hCenter = _hCenter {
                // convert the width & hCenter into a left & right
                assert(self._left == nil && self._right == nil)
                let halfWidth = width / 2
                self._left = _hCenter - halfWidth
                self._right = _hCenter + halfWidth
                self._hCenter = nil
                self.width = nil
            }
        }

        if let height = height {
            if let top = _top {
                // convert the height into a bottom
                assert(self._right == nil)
                self._bottom = top + height
                self.height = nil
            } else if let bottom = _bottom {
                // convert the height into a top
                assert(self._top == nil)
                self._top = bottom - height
                self.height = nil
            } else if let _vCenter = _vCenter {
                // convert the height & vCenter into a top & bottom
                assert(self._top == nil && self._bottom == nil)
                let halfHeight = height / 2
                self._top = _vCenter - halfHeight
                self._bottom = _vCenter + halfHeight
                self._vCenter = nil
                self.height = nil
            }
        }
    }

    fileprivate func computeSize() -> Size {
        var newWidth = computeWidth()
        var newHeight = computeHeight()
        
        if shouldSizeToFit && (newWidth != nil || newHeight != nil) {
            let fitSize = CGSize(width: newWidth ?? .greatestFiniteMagnitude,
                                 height: newHeight ?? .greatestFiniteMagnitude)

            let sizeThatFits = view.sizeThatFits(fitSize)

            if newWidth != nil && newWidth! != sizeThatFits.width {
                let marginToDistribute = newWidth! - sizeThatFits.width
                
                // Distribute the width change to Margins
                if let _ = _left {
                    marginRight = (marginRight ?? 0) + marginToDistribute
                } else if let _ = _right {
                    marginLeft = (marginLeft ?? 0) + marginToDistribute
                }
            }
            
            if newHeight != nil && newHeight! != sizeThatFits.height {
                let marginToDistribute = newHeight! - sizeThatFits.height
                
                // Distribute the height change to Margins
                if let _ = _top {
                    marginBottom = (marginBottom ?? 0) + marginToDistribute
                } else if let _ = _bottom {
                    marginTop = (marginTop ?? 0) + marginToDistribute
                }
            }
            
            if fitSize.width != .greatestFiniteMagnitude && sizeThatFits.width > fitSize.width {
                newWidth = fitSize.width
            } else {
                newWidth = sizeThatFits.width
            }

            if fitSize.height != .greatestFiniteMagnitude && sizeThatFits.height > fitSize.height {
                newHeight = fitSize.height
            } else {
                newHeight = sizeThatFits.height
            }
        }

        return (newWidth, newHeight)
    }
    
    fileprivate func computeWidth() -> CGFloat? {
        if let left = _left, let right = _right {
            return right - left - _marginLeft - _marginRight
        } else if let width = width {
            return width
        } else {
            return nil
        }
    }
    
    fileprivate func computeHeight() -> CGFloat? {
        if let top = _top, let bottom = _bottom {
            return bottom - top - _marginTop - _marginBottom
        } else if let height = height {
            return height
        } else {
            return nil
        }
    }

    fileprivate func pointContext(method: String, point: CGPoint) -> String {
        return "\(method)(to: CGPoint(x: \(point.x), y: \(point.y)))"
    }

    fileprivate func relativeEdgeContext(method: String, edge: VerticalEdge) -> String {
        let edge = edge as! VerticalEdgeImpl
        return "\(method)(to: \(edge.type.rawValue), of: \(edge.view))"
    }

    fileprivate func relativeEdgeContext(method: String, edge: HorizontalEdge) -> String {
        let edge = edge as! HorizontalEdgeImpl
        return "\(method)(to: \(edge.type.rawValue), of: \(edge.view))"
    }

    fileprivate func relativeAnchorContext(method: String, anchor: Anchor) -> String {
        let anchor = anchor as! AnchorImpl
        return "\(method)(to: \(anchor.type.rawValue), of: \(anchor.view))"
    }

    fileprivate func warn(_ text: String, _ context: Context) {
        guard PinLayoutLogConflicts else { return }
        displayWarning("\n👉 PinLayout Warning: \(context()) won't be applied, \(text)\n")
    }
    
    fileprivate func warnPropertyAlreadySet(_ propertyName: String, propertyValue: CGFloat, _ context: Context) {
        guard PinLayoutLogConflicts else { return }
        displayWarning("\n👉 PinLayout Conflict: \(context()) won't be applied since it value has already been set to \(propertyValue).\n")
    }
    
    fileprivate func warnPropertyAlreadySet(_ propertyName: String, propertyValue: CGSize, _ context: Context) {
        guard PinLayoutLogConflicts else { return }
        displayWarning("\n👉 PinLayout Conflict: \(context()) won't be applied since it value has already been set to CGSize(width: \(propertyValue.width), height: \(propertyValue.height)).\n")
    }
    
    fileprivate func warnConflict(_ context: Context, _ properties: [String: CGFloat]) {
        guard PinLayoutLogConflicts else { return }
        var warning = "\n👉 PinLayout Conflict: \(context()) won't be applied since it conflicts with the following already set properties:\n"
        properties.forEach { (key, value) in
            warning += " \(key): \(value)\n"
        }
        
        displayWarning(warning)
    }
    
    fileprivate func displayWarning(_ text: String) {
        print(text)
        unitTestLastWarning = text
    }
    
    fileprivate func viewDescription(_ view: UIView) -> String {
        return "\"\(view.description)\""
    }
}
    
#endif
