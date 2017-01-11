//
//  XBCusBtn.swift
//  XCP
//
//  Created by xxb on 2016/12/26.
//  Copyright © 2016年 xxb. All rights reserved.
//

import UIKit

class XBCusBtn: UIControl {
    
    typealias ActionBlock = ((_ btn:XBCusBtn) ->Void)
    
    enum XBCusBtnContentType:Int {
        case imageTop,imageBottom,imageLeft,imageRight
    }
    
    enum XBCusBtnContentSide {
        case top,bottom,left,right,center
    }
    
    /** 图片和文字排布样式 ，默认图片在左*/
    var contentType:XBCusBtnContentType{didSet{setNeedsDisplay()}}
    
    /** 内容（图片和文字）是靠那个方向对齐，上下左右，默认横向居中 */
    var contentSide:XBCusBtnContentSide{didSet{setNeedsDisplay()}}
    
    /** 图片和文字的间距,默认是0 */
    var spaceOfImageAndTitle:CGFloat{didSet{setNeedsDisplay()}}
    
    /** 内容（图片和文字）到对齐方向边缘的距离，内容在中间时不起作用，默认是0 */
    var spaceToContentSide:CGFloat{didSet{setNeedsDisplay()}}
    
    /** 图片所占的比例（默认0.5），如果是横向，则是高度占自身高度的比例；如果是纵向，则是宽度占自身宽度的比例
     *  如果同时设置了imageSize，以imageSize优先
     */
    var imageRectScale:CGFloat{didSet{setNeedsDisplay()}}
    
    /** 图片显示的size，如果同时设置了imageRectScale，以这里设置的size优先 */
    var imageSize:CGSize{didSet{setNeedsDisplay()}}
    
    /** 正常状态下的图片 */
    var imageNormal:UIImage?{didSet{image=imageNormal}}
    
    /** 选中状态的图片 */
    var imageSelected:UIImage?{didSet{image=imageSelected}}
    
    /** 正常状态下的文字 */
    var titleNormal:String?{didSet{title=titleNormal!}}
    
    /** 选中状态的文字 */
    var titleSelected:String?{didSet{title=titleSelected!}}
    
    /** 正常状态下的文字颜色，默认黑色 */
    var titleColorNormal:UIColor?{didSet{titleColor=titleColorNormal!}}
    
    /** 选中状态的文字颜色，默认黑色 */
    var titleColorSelected:UIColor?{didSet{titleColor=titleColorSelected!}}
    
    /** 标题字体，默认15号系统字体 */
    var titleFont:UIFont{didSet{setNeedsDisplay()}}
    
    /** 正常状态下的背景图片 */
    var backgroundImageNormal:UIImage?{didSet{backgroundImage=backgroundImageNormal}}
    
    /** 选中状态的背景图片 */
    var backgroundImageSelected:UIImage?{didSet{backgroundImage=backgroundImageSelected}}
    
    /** 正常状态的背景颜色 */
    var backgroundColorNormal:UIColor?{didSet{backgroundColor=backgroundColorNormal}}
    
    /** 高亮状态的背景颜色 */
    var backgroundColorHighlight:UIColor?
    
    /** 点击回调,如果用到拥有者的self指针，需要weak，否则循环引用 */
    var block:ActionBlock?
    
    
    private var targetSave:Any?
    private var actionSave:Selector?
    private var controlEventsSave:UIControlEvents?
    private var imageRectSize:CGSize=CGSize.zero
    private var titleRectSize:CGSize=CGSize.zero
    private var imageOrigin:CGPoint=CGPoint.zero
    private var titleOrigin:CGPoint=CGPoint.zero
    /** 图片 */
    private var image:UIImage?{didSet{setNeedsDisplay()}}
    /** 文字 */
    private var title:String{didSet{setNeedsDisplay()}}
    /** 文字颜色，默认黑色 */
    private var titleColor:UIColor?{didSet{setNeedsDisplay()}}
    /** 背景图片 */
    private var backgroundImage:UIImage?{didSet{setNeedsDisplay()}}
    
    
    override init(frame: CGRect) {
        titleFont=UIFont.systemFont(ofSize: 15)
        titleColor=UIColor.black
        imageRectScale=0.5;
        contentType = .imageLeft
        spaceOfImageAndTitle=0;
        title=""
        imageSize=CGSize.zero
        spaceToContentSide=0;
        contentSide = .center;
        backgroundColorNormal=UIColor.clear
        super.init(frame: frame)
        backgroundColor=UIColor.clear
        layer.masksToBounds=true;
        addTarget(self, action: #selector(selfClick), for: UIControlEvents.touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selfClick() -> Void {
        
    }
    
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        if block != nil
        {
            weak var weakSelf=self
            block!(weakSelf!)
        }
        else
        {
            super.sendAction(action, to: target, for: event)
        }
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        if target is XBCusBtn
        {
            if (target as! XBCusBtn) == self
            {
                if actions(forTarget: self, forControlEvent: controlEvents) != nil
                {
                    return;
                }
                else
                {
                    super.addTarget(target, action: action, for: controlEvents)
                }
            }
        }
        else
        {
            if actions(forTarget: self, forControlEvent: controlEvents) != nil
            {
                removeTarget(self, action: action, for: controlEvents)
            }
            super.addTarget(target, action: action, for: controlEvents)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        getTitleSizeWith(rect: rect, font: titleFont)
        getImageSizeWith(rect: rect)
        getTitleOriginWith(rect: rect)
        getImageOriginWith(rect: rect)
        
        if backgroundImage != nil{backgroundImage?.draw(in: rect)}
        if image != nil{image?.draw(in: CGRect(x: imageOrigin.x, y: imageOrigin.y, width: imageRectSize.width, height: imageRectSize.height))}
        if title.isEmpty == false
        {
            
            var dict = [String:Any]()
            dict[NSForegroundColorAttributeName]=titleColor
            dict[NSFontAttributeName]=titleFont
            let nsTitle = title as NSString
            nsTitle.draw(in: CGRect(x: titleOrigin.x, y: titleOrigin.y, width: titleRectSize.width, height: titleRectSize.height), withAttributes: dict)
        }
    }
    
    private func getImageOriginWith(rect:CGRect) -> Void
    {
        var imageX:CGFloat=0
        var imageY:CGFloat=0
        
        switch contentSide{
        case .top:
            switch (contentType){
            case .imageTop://图片在上
                imageY=titleOrigin.y-imageRectSize.height-spaceOfImageAndTitle;
                break;
            case .imageBottom://文字在上
                imageY=titleOrigin.y+titleRectSize.height+spaceOfImageAndTitle;
            default:
                break;
            }
            imageX=(rect.size.width-imageRectSize.width)*0.5;
            
            break
        case .bottom:
            switch (contentType){
            case .imageTop://图片在上
                imageY=titleOrigin.y-imageRectSize.height-spaceOfImageAndTitle;
                break;
            case .imageBottom://文字在上
                imageY=titleOrigin.y+titleRectSize.height+spaceOfImageAndTitle;
            default:
                break;
            }
            imageX=(rect.size.width-imageRectSize.width)*0.5;
            break
        case .left:
            switch (contentType){
            case .imageLeft:
                break;
            case .imageRight:
                imageX=titleOrigin.x+spaceOfImageAndTitle+titleRectSize.width;
                break;
                
            default:
                break;
            }
            imageY=(rect.size.height-imageRectSize.height)*0.5;
            break
        case .right:
            switch (contentType){
            case .imageLeft:
                imageX=titleOrigin.x-spaceOfImageAndTitle-imageRectSize.width;
                break;
            case .imageRight:
                imageX=titleOrigin.x+spaceOfImageAndTitle+titleRectSize.width;
                break;
                
            default:
                break;
            }
            imageY=(rect.size.height-imageRectSize.height)*0.5;
            break
        case .center:
            switch (contentType){
            case .imageLeft:
                imageX=titleOrigin.x-spaceOfImageAndTitle-imageRectSize.width;
                imageY=(rect.size.height-imageRectSize.height)*0.5;
                break;
            case .imageRight:
                imageX=titleOrigin.x+spaceOfImageAndTitle+titleRectSize.width;
                imageY=(rect.size.height-imageRectSize.height)*0.5;
                break;
            case .imageTop://图片在上
                imageY=titleOrigin.y-imageRectSize.height-spaceOfImageAndTitle;
                imageX=(rect.size.width-imageRectSize.width)*0.5;
                break;
            case .imageBottom://文字在上
                imageY=titleOrigin.y+titleRectSize.height+spaceOfImageAndTitle;
                imageX=(rect.size.width-imageRectSize.width)*0.5;
                break;
            }
            break;
        }
        imageOrigin=CGPoint(x:imageX, y:imageY);
    }
    
    private func getTitleOriginWith(rect:CGRect){
        var titleY:CGFloat=0
        var titleX:CGFloat=0
        switch (contentSide){
        case .top:
            switch (contentType){
            case .imageTop://竖直，图片在上
                titleY=spaceToContentSide+spaceOfImageAndTitle+imageRectSize.height;
                break;
            case .imageBottom://竖直，文字在上
                titleY=spaceToContentSide;
            default:
                break;
            }
            titleX=(rect.size.width-titleRectSize.width)*0.5;
            break;
            
        case .bottom:
            switch (contentType){
            case .imageTop://竖直，图片在上
                titleY=rect.size.height-spaceToContentSide-titleRectSize.height;
                break;
            case .imageBottom://竖直，文字在上
                titleY=rect.size.height-spaceToContentSide-imageRectSize.height-spaceOfImageAndTitle-titleRectSize.height;
            default:
                break;
            }
            titleX=(rect.size.width-titleRectSize.width)*0.5;
            break;
            
        case .left:
            switch (contentType){
            case .imageLeft://水平，图片在左边
                titleX=spaceToContentSide+imageRectSize.width+spaceOfImageAndTitle;
                break;
            case .imageRight://水平，文字在左边
                titleX=spaceToContentSide;
                break;
                
            default:
                break;
            }
            titleY=(rect.size.height-titleRectSize.height)*0.5;
            break;
            
        case .right:
            switch (contentType){
            case .imageLeft://水平，图片在左边
                titleX=rect.size.width-titleRectSize.width-spaceToContentSide;
                break;
            case .imageRight://水平，文字在左边
                titleX=rect.size.width-titleRectSize.width-spaceToContentSide-spaceOfImageAndTitle-imageRectSize.width;
                break;
                
            default:
                break;
            }
            titleY=(rect.size.height-titleRectSize.height)*0.5;
            break;
            
        case .center:
            switch (contentType){
            case .imageLeft://水平，图片在左边
                titleX=(rect.size.width-titleRectSize.width-spaceOfImageAndTitle-imageRectSize.width)*0.5+imageRectSize.width+spaceOfImageAndTitle;
                titleY=(rect.size.height-titleRectSize.height)*0.5;
                break;
                
            case .imageRight://水平，文字在左边
                titleX=(rect.size.width-titleRectSize.width-spaceOfImageAndTitle-imageRectSize.width)*0.5;
                titleY=(rect.size.height-titleRectSize.height)*0.5;
                break;
                
            case .imageTop:
                titleY=(rect.size.height-titleRectSize.height-imageRectSize.height-spaceOfImageAndTitle)*0.5+imageRectSize.height+spaceOfImageAndTitle;
                titleX=(rect.size.width-titleRectSize.width)*0.5;
                break;
                
            case .imageBottom:
                titleY=(rect.size.height-titleRectSize.height-imageRectSize.height-spaceOfImageAndTitle)*0.5;
                titleX=(rect.size.width-titleRectSize.width)*0.5;
                break;
            }
            break;
        }
        titleOrigin=CGPoint(x:titleX, y:titleY);
    }
    
    //计算文字的size
    private func getTitleSizeWith(rect:CGRect, font:UIFont){
        if (title.isEmpty == false)
        {
            let textWith = XBPublicFunctions.getWidthWith(text: title, font: font)
            if (contentType == XBCusBtnContentType.imageTop || contentType==XBCusBtnContentType.imageBottom)
            {
                let rectW=rect.size.width;
                titleRectSize=XBPublicFunctions.getAdjustSizeWith(text: title, maxWidth:XBPublicFunctions.selectItemBy(bool: (textWith > rectW), item1: rectW, item2: textWith) as! CGFloat, font: font)
            }
            else
            {
                let rectW=(rect.size.width-spaceToContentSide-imageRectSize.width-spaceOfImageAndTitle);
                titleRectSize=XBPublicFunctions.getAdjustSizeWith(text: title, maxWidth: XBPublicFunctions.selectItemBy(bool: (textWith>rectW), item1: rectW, item2: textWith) as! CGFloat, font: font)
            }
        }
    }
    
    //计算图片的size
    private func getImageSizeWith(rect:CGRect){
        if image != nil
        {
            let imageHWScale=(image?.size.height)!/(image?.size.width)!;
            var imageW:CGFloat=0
            var imageH:CGFloat=0
            switch (contentType)
            {
            case .imageTop:
                imageW=rect.size.width*imageRectScale;
                imageH=imageW*imageHWScale;
                break;
            case .imageBottom:
                imageW=rect.size.width*imageRectScale;
                imageH=imageW*imageHWScale;
                break;
            case .imageLeft:
                imageH=rect.size.height*imageRectScale;
                imageW=imageH/imageHWScale;
                break;
            case .imageRight:
                imageH=rect.size.height*imageRectScale;
                imageW=imageH/imageHWScale;
                break;
            }
            if (imageSize.width==CGSize.zero.width && imageSize.height==CGSize.zero.height)
            {
                imageRectSize=CGSize(width:imageW, height:imageH);
            }
            else
            {
                imageRectSize=imageSize;
            }
        }
    }
    
    override var isHighlighted: Bool{
        didSet{
            if isHighlighted
            {
                if backgroundColorHighlight != nil
                {
                    backgroundColor=backgroundColorHighlight;
                }
                else
                {
                    backgroundColor=backgroundColorNormal;
                }
            }
            else
            {
                backgroundColor=backgroundColorNormal;
            }
        }
    }
    
    override var isSelected: Bool{
        didSet{
            if (isSelected)
            {
                if titleColorSelected != nil{titleColor=titleColorSelected}
                else if titleColorNormal != nil{titleColor=titleColorNormal}
                
                if titleSelected != nil{title=titleSelected!}
                else if titleNormal != nil{title=titleNormal!}
                
                if imageSelected != nil{image=imageSelected}
                else if imageNormal != nil{image=imageNormal}
                
                if backgroundImageSelected != nil{backgroundImage=backgroundImageSelected}
                else if backgroundImageNormal != nil{backgroundImage=backgroundImageNormal}
            }
            else
            {
                if titleColorNormal != nil{titleColor=titleColorNormal}
                else if titleColorSelected != nil{titleColor=titleColorSelected}
                
                if titleNormal != nil{title=titleNormal!}
                else if titleSelected != nil{title=titleSelected!}
                
                if imageNormal != nil{image=imageNormal}
                else if imageSelected != nil{image=imageSelected}
                
                if backgroundImageNormal != nil{backgroundImage=backgroundImageNormal}
                else if backgroundImageSelected != nil{backgroundImage=backgroundImageSelected}
            }
            setNeedsDisplay()
        }
    }
}
