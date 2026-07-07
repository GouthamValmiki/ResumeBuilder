import UIKit

final class FormTextViewCell: UITableViewCell, UITextViewDelegate {
    static let reuseIdentifier = "FormTextViewCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let textView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16)
        view.layer.borderColor = UIColor.separator.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var onTextChanged: ((String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        textView.delegate = self
        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            textView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, text: String) {
        titleLabel.text = title
        textView.text = text
    }

    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?(textView.text)
    }
}
