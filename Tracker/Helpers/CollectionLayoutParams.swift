import UIKit
struct CollectionLayoutParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpaсing: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpaсing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpaсing = cellSpaсing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpaсing
    }
}
