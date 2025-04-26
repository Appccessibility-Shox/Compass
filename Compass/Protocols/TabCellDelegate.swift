/// The set of methods a class must implement to be the delegate for a `TabCell`.
protocol TabCellDelegate: AnyObject {
    
    /// Efficiently updates the collection view to remove the provided `TabCell` and
    /// deletes the corresponding `Tab` from the data model.
    func delete(cell: TabCell)
}

