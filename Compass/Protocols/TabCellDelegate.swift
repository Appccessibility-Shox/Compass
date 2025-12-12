/// The set of methods a class must implement to be the delegate for a `TabCell`.
protocol TabCellDelegate: AnyObject {
    
    /// Efficiently updates the collection view to remove the provided `TabCell` and
    /// deletes the corresponding `Tab` from the data model.
    func delete(cell: TabCell)
    
    /// Copies the URL for the `Tab` that cell represents to the user's clipboard.
    func copyURL(cell: TabCell)

    /// Used to determine whether the copy URL button should be shown in the context menu.
    func canCopyURL(cell: TabCell) -> Bool

    func someTabCellIsBeingSwiped(isSwiping: Bool)
}

