import UIKit
final class ATSCheckerViewController: UITableViewController {
    private enum Section {
        case fixes
        case passed
        case keywords

        var title: String {
            switch self {
            case .fixes: return "Fix First"
            case .passed: return "Passed Checks"
            case .keywords: return "Keyword Tips"
            }
        }
    }

    private let report: ATSCheckReport
    private let headerView: ATSScoreHeaderView
    private var sections: [Section] {
        var result: [Section] = []
        if !report.improvementChecks.isEmpty {
            result.append(.fixes)
        }
        if !report.passedChecks.isEmpty {
            result.append(.passed)
        }
        if !report.keywordSuggestions.isEmpty {
            result.append(.keywords)
        }
        return result
    }

    init(report: ATSCheckReport) {
        self.report = report
        self.headerView = ATSScoreHeaderView(report: report)
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ATS Check"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ATSCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "KeywordCell")
        tableView.backgroundColor = .systemGroupedBackground
        setupHeader()
        setupFooter()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .fixes:
            return report.improvementChecks.count
        case .passed:
            return report.passedChecks.count
        case .keywords:
            return report.keywordSuggestions.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .fixes:
            return checkCell(for: report.improvementChecks[indexPath.row], at: indexPath)
        case .passed:
            return checkCell(for: report.passedChecks[indexPath.row], at: indexPath)
        case .keywords:
            return keywordCell(for: report.keywordSuggestions[indexPath.row], at: indexPath)
        }
    }

    private func checkCell(for item: ATSCheckItem, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ATSCell", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()
        config.text = item.title
        config.textProperties.font = .systemFont(ofSize: 15, weight: .bold)
        config.secondaryText = "\(item.detail)\nScore: \(item.points)/\(item.maxPoints)"
        config.secondaryTextProperties.font = .systemFont(ofSize: 13, weight: .regular)
        config.secondaryTextProperties.color = .secondaryLabel
        config.secondaryTextProperties.numberOfLines = 0
        config.image = UIImage(systemName: iconName(for: item.status))
        config.imageProperties.tintColor = tintColor(for: item.status)
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        cell.accessoryType = .none
        return cell
    }

    private func keywordCell(for suggestion: String, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeywordCell", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()
        config.text = suggestion
        config.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
        config.textProperties.numberOfLines = 0
        config.secondaryText = nil
        config.image = UIImage(systemName: "text.magnifyingglass")
        config.imageProperties.tintColor = .systemIndigo
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        cell.accessoryType = .none
        return cell
    }

    private func setupFooter() {
        let footer = UILabel()
        footer.text = "ATS score is guidance, not a guarantee. Recruiter calls still depend on role fit, timing, market demand, and how closely the resume matches each job post."
        footer.font = .systemFont(ofSize: 12, weight: .medium)
        footer.textColor = .secondaryLabel
        footer.textAlignment = .center
        footer.numberOfLines = 0
        footer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 78)
        tableView.tableFooterView = footer
    }

    private func setupHeader() {
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 230)
        tableView.tableHeaderView = headerView
    }

    private func iconName(for status: ATSCheckStatus) -> String {
        switch status {
        case .passed: return "checkmark.seal.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .failed: return "xmark.octagon.fill"
        }
    }

    private func tintColor(for status: ATSCheckStatus) -> UIColor {
        switch status {
        case .passed: return .systemGreen
        case .warning: return .systemOrange
        case .failed: return .systemRed
        }
    }
}

private final class ATSScoreHeaderView: UIView {
    private let report: ATSCheckReport
    private let cardView = UIView()
    private let scoreLabel = UILabel()
    private let ratingLabel = UILabel()
    private let titleLabel = UILabel()
    private let summaryLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)

    init(report: ATSCheckReport) {
        self.report = report
        super.init(frame: .zero)
        setupView()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .clear

        cardView.backgroundColor = .secondarySystemGroupedBackground
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 5)
        cardView.layer.shadowRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "ATS Readiness"
        titleLabel.font = .systemFont(ofSize: 13, weight: .black)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        scoreLabel.font = .systemFont(ofSize: 52, weight: .black)
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.minimumScaleFactor = 0.75
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        ratingLabel.font = .systemFont(ofSize: 18, weight: .black)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        summaryLabel.font = .systemFont(ofSize: 14, weight: .medium)
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 0
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false

        progressView.trackTintColor = .tertiarySystemFill
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(scoreLabel)
        cardView.addSubview(ratingLabel)
        cardView.addSubview(summaryLabel)
        cardView.addSubview(progressView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            scoreLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            scoreLabel.widthAnchor.constraint(equalToConstant: 118),

            ratingLabel.leadingAnchor.constraint(equalTo: scoreLabel.trailingAnchor, constant: 12),
            ratingLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            ratingLabel.bottomAnchor.constraint(equalTo: scoreLabel.centerYAnchor, constant: -2),

            progressView.leadingAnchor.constraint(equalTo: ratingLabel.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 10),
            progressView.heightAnchor.constraint(equalToConstant: 8),

            summaryLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 12),
            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            summaryLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -18)
        ])
    }

    private func configure() {
        scoreLabel.text = "\(report.score)"
        ratingLabel.text = report.rating
        summaryLabel.text = report.summary
        progressView.progress = Float(report.score) / 100

        let color = scoreColor(report.score)
        scoreLabel.textColor = color
        ratingLabel.textColor = color
        progressView.progressTintColor = color
    }

    private func scoreColor(_ score: Int) -> UIColor {
        switch score {
        case 85...100: return .systemGreen
        case 70..<85: return .systemTeal
        case 50..<70: return .systemOrange
        default: return .systemRed
        }
    }
}
