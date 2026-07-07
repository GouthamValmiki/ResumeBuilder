import UIKit

final class TemplateCell: UICollectionViewCell {
    static let reuseIdentifier = "TemplateCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var previewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var currentPreview: TemplatePreviewView?

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView)
        cardView.addSubview(previewContainer)
        cardView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            previewContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            previewContainer.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            previewContainer.widthAnchor.constraint(equalToConstant: 72),
            previewContainer.heightAnchor.constraint(equalToConstant: 92),

            nameLabel.topAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(template: ResumeTemplate, isSelected: Bool) {
        nameLabel.text = template.displayName
        
        // Remove old preview view
        currentPreview?.removeFromSuperview()
        
        // Create new preview view
        let preview = TemplatePreviewView(template: template)
        preview.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.addSubview(preview)
        
        NSLayoutConstraint.activate([
            preview.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            preview.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),
            preview.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            preview.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor)
        ])
        
        currentPreview = preview

        let accent = template.accentColor
        if isSelected {
            cardView.backgroundColor = accent.withAlphaComponent(0.08)
            cardView.layer.borderWidth = 2
            cardView.layer.borderColor = accent.cgColor
            nameLabel.textColor = accent
            preview.layer.borderColor = accent.withAlphaComponent(0.5).cgColor
        } else {
            cardView.backgroundColor = .secondarySystemGroupedBackground
            cardView.layer.borderWidth = 1
            cardView.layer.borderColor = UIColor.separator.withAlphaComponent(0.5).cgColor
            nameLabel.textColor = .label
            preview.layer.borderColor = UIColor.separator.cgColor
        }
    }
}

// MARK: - TemplatePreviewView
final class TemplatePreviewView: UIView {
    private let template: ResumeTemplate
    private let headerView = UIView()
    private let bodyStack = UIStackView()

    init(template: ResumeTemplate) {
        self.template = template
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 6
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.separator.cgColor
        clipsToBounds = true

        headerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerView)

        let hasHeaderBg = template.headerBackgroundColor != nil || template.headerGradientColors != nil

        if let gradient = template.headerGradientColors {
            let gradView = GradientView(colors: gradient)
            gradView.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(gradView)
            NSLayoutConstraint.activate([
                gradView.topAnchor.constraint(equalTo: headerView.topAnchor),
                gradView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
                gradView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
                gradView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
            ])
        } else {
            headerView.backgroundColor = template.headerBackgroundColor ?? .clear
        }

        let headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.spacing = 2
        headerStack.alignment = template == .executive ? .center : .leading
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerStack)

        let lineCol: UIColor = hasHeaderBg ? .white : .lightGray
        let tinyName = makeTinyLine(width: 24, height: 3, color: lineCol)
        let tinyContact = makeTinyLine(width: 36, height: 1.5, color: lineCol.withAlphaComponent(0.7))
        headerStack.addArrangedSubview(tinyName)
        headerStack.addArrangedSubview(tinyContact)

        bodyStack.axis = .vertical
        bodyStack.spacing = 3
        bodyStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bodyStack)

        // Mock two sections
        for _ in 0..<2 {
            bodyStack.addArrangedSubview(makeTinySectionHeader(template: template))
            bodyStack.addArrangedSubview(makeTinySectionContent(template: template))
        }

        let headerHeight: CGFloat = hasHeaderBg ? 22 : 14
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),

            headerStack.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 4),
            headerStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -4),

            bodyStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 4),
            bodyStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            bodyStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            bodyStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -4)
        ])
    }

    private func makeTinyLine(width: CGFloat, height: CGFloat, color: UIColor) -> UIView {
        let line = UIView()
        line.backgroundColor = color
        line.layer.cornerRadius = height / 2
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.widthAnchor.constraint(equalToConstant: width),
            line.heightAnchor.constraint(equalToConstant: height)
        ])
        return line
    }

    private func makeTinySectionHeader(template: ResumeTemplate) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 1

        let labelLine = makeTinyLine(width: 20, height: 2, color: template.accentColor)

        switch template {
        case .classic:
            container.addArrangedSubview(labelLine)
            container.addArrangedSubview(makeTinyLine(width: 44, height: 0.5, color: template.accentColor.withAlphaComponent(0.3)))
        case .modern:
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 2
            row.alignment = .center
            let bar = makeTinyLine(width: 1.5, height: 3.5, color: template.accentColor)
            row.addArrangedSubview(bar)
            row.addArrangedSubview(labelLine)
            container.addArrangedSubview(row)
        case .minimal:
            container.addArrangedSubview(labelLine)
            container.addArrangedSubview(makeTinyLine(width: 44, height: 0.5, color: .separator))
        case .executive:
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 2
            row.alignment = .center
            row.addArrangedSubview(makeTinyLine(width: 8, height: 0.5, color: template.accentColor.withAlphaComponent(0.3)))
            row.addArrangedSubview(labelLine)
            row.addArrangedSubview(makeTinyLine(width: 8, height: 0.5, color: template.accentColor.withAlphaComponent(0.3)))
            container.addArrangedSubview(row)
        case .creative:
            let badge = UIView()
            badge.backgroundColor = template.accentColor.withAlphaComponent(0.12)
            badge.layer.cornerRadius = 2
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.addSubview(labelLine)
            NSLayoutConstraint.activate([
                labelLine.topAnchor.constraint(equalTo: badge.topAnchor, constant: 1),
                labelLine.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -1),
                labelLine.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 2),
                labelLine.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -2)
            ])
            let row = UIStackView()
            row.axis = .horizontal
            row.addArrangedSubview(badge)
            row.addArrangedSubview(UIView())
            container.addArrangedSubview(row)
        }
        return container
    }

    private func makeTinySectionContent(template: ResumeTemplate) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 1.5

        let titleLine = makeTinyLine(width: 24, height: 1.5, color: .darkGray)
        stack.addArrangedSubview(titleLine)

        if template == .creative || template == .modern {
            for _ in 0..<2 {
                let bulletRow = UIStackView()
                bulletRow.axis = .horizontal
                bulletRow.spacing = 2
                bulletRow.alignment = .center

                let dot = makeTinyLine(width: 1, height: 1, color: template.accentColor)
                dot.layer.cornerRadius = 0.5

                let textLine = makeTinyLine(width: 32, height: 1, color: .lightGray)
                bulletRow.addArrangedSubview(dot)
                bulletRow.addArrangedSubview(textLine)
                stack.addArrangedSubview(bulletRow)
            }
        } else {
            stack.addArrangedSubview(makeTinyLine(width: 36, height: 1, color: .lightGray))
            stack.addArrangedSubview(makeTinyLine(width: 32, height: 1, color: .lightGray))
        }

        return stack
    }
}
