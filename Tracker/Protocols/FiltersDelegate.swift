import Foundation

protocol FiltersDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}