import UIKit

protocol TrackersCollectionViewDelegate: AnyObject {
    func trackersCollectionView(_ collectionView: TrackersCollectionView, didTapPlusFor tracker: Tracker, at indexPath: IndexPath)
    func trackersCollectionView(_ collectionView: TrackersCollectionView, completedCountFor tracker: Tracker) -> Int
    func trackersCollectionView(_ collectionView: TrackersCollectionView, isCompleted tracker: Tracker) -> Bool
}

final class TrackersCollectionView: NSObject {
    private let params: CollectionLayoutParams
    private let collectionView: UICollectionView
    private var categories: [TrackerCategory] = []
    
    weak var delegate: TrackersCollectionViewDelegate?
    
    init(using params: CollectionLayoutParams, collectionView: UICollectionView) {
        self.params = params
        self.collectionView = collectionView
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(TrackerSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerSectionHeaderView.identifier)
    }
    
    func update(with categories: [TrackerCategory]) {
        self.categories = categories
        collectionView.reloadData()
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        collectionView.reloadItems(at: indexPaths)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let isCompleted = delegate?.trackersCollectionView(self, isCompleted: tracker) ?? false
        let count = delegate?.trackersCollectionView(self, completedCountFor: tracker) ?? 0
        
        cell.delegate = self
        cell.configure(with: tracker, isCompleted: isCompleted, completedDays: count)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerSectionHeaderView.identifier, for: indexPath) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = categories[indexPath.section].title
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: params.leftInset, bottom: 16, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpaсing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 19)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersCollectionView: TrackerCellDelegate {
    func didTapCompleteButton(of cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        delegate?.trackersCollectionView(self, didTapPlusFor: tracker, at: indexPath)
    }
}
