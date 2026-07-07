import UIKit

enum ListItemActions {
    static func swipeConfiguration(
        editHandler: @escaping () -> Void,
        deleteHandler: @escaping () -> Void
    ) -> UISwipeActionsConfiguration {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            deleteHandler()
            completion(true)
        }
        delete.image = UIImage(systemName: "trash")

        let edit = UIContextualAction(style: .normal, title: "Edit") { _, _, completion in
            editHandler()
            completion(true)
        }
        edit.backgroundColor = .systemBlue
        edit.image = UIImage(systemName: "pencil")

        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}
