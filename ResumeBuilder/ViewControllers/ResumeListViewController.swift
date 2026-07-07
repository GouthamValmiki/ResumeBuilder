import UIKit

final class ResumeListViewController: UIViewController {
    private var resumes: [Resume] = []
    private var filteredResumes: [Resume] = []
    private var selectedTemplate: ResumeTemplate = .classic
    private let storage = ResumeStorage.shared

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let heroView = HomeHeroView()
    private let logoMarkView = AppLogoMarkView()
    private let brandLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let heroCreateButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Create Resume"
        config.image = UIImage(systemName: "plus")
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(red: 0.05, green: 0.42, blue: 0.46, alpha: 1)
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 18)

        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let metricsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let resumeMetricView = HomeMetricView(
        iconName: "doc.text.fill",
        tintColor: UIColor(red: 0.05, green: 0.59, blue: 0.55, alpha: 1)
    )
    private let templateMetricView = HomeMetricView(
        iconName: "square.grid.2x2.fill",
        tintColor: UIColor(red: 0.18, green: 0.31, blue: 0.55, alpha: 1)
    )
    private let latestMetricView = HomeMetricView(
        iconName: "clock.fill",
        tintColor: UIColor(red: 0.42, green: 0.49, blue: 0.58, alpha: 1)
    )
    private let careerToolkitButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Career Toolkit"
        config.subtitle = "Job match, resume bullets, tracker, and interview prep"
        config.image = UIImage(systemName: "briefcase.fill")
        config.imagePlacement = .leading
        config.imagePadding = 12
        config.titleAlignment = .leading
        config.cornerStyle = .large
        config.baseBackgroundColor = .secondarySystemGroupedBackground
        config.baseForegroundColor = UIColor(red: 0.10, green: 0.15, blue: 0.23, alpha: 1)
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)

        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .fill
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.withAlphaComponent(0.28).cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.04
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let templateTitleLabel = UILabel()
    private let templateCollectionView: UICollectionView
    private let resumeListTitleLabel = UILabel()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Find a resume"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private var tableViewHeightConstraint: NSLayoutConstraint?

    private let floatingCreateButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(red: 0.05, green: 0.59, blue: 0.55, alpha: 1)

        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.tintColor = .white

        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 7)
        button.layer.shadowRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        templateCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)

        setupScrollContainer()
        setupHero()
        setupMetrics()
        setupCareerToolkit()
        setupTemplatePicker()
        setupResumeListHeader()
        setupSearchBar()
        setupTableView()
        setupEmptyState()
        setupFloatingButton()
        reloadData()

        searchBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    private func setupScrollContainer() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.keyboardDismissMode = .interactive

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupHero() {
        heroView.translatesAutoresizingMaskIntoConstraints = false
        logoMarkView.translatesAutoresizingMaskIntoConstraints = false

        brandLabel.text = "ATS resume maker"
        brandLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        brandLabel.textColor = UIColor(red: 0.36, green: 0.43, blue: 0.52, alpha: 1)
        brandLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "Resume Builder"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.10, green: 0.15, blue: 0.23, alpha: 1)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text = "Create clean resumes, check ATS readiness, and manage job applications in one place."
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor(red: 0.38, green: 0.45, blue: 0.55, alpha: 1)
        subtitleLabel.numberOfLines = 3
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        heroCreateButton.addTarget(self, action: #selector(createResume), for: .touchUpInside)

        contentView.addSubview(heroView)
        heroView.addSubview(logoMarkView)
        heroView.addSubview(brandLabel)
        heroView.addSubview(titleLabel)
        heroView.addSubview(subtitleLabel)
        heroView.addSubview(heroCreateButton)

        NSLayoutConstraint.activate([
            heroView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroView.bottomAnchor.constraint(equalTo: heroCreateButton.bottomAnchor, constant: 24),

            logoMarkView.topAnchor.constraint(equalTo: heroView.topAnchor, constant: 62),
            logoMarkView.leadingAnchor.constraint(equalTo: heroView.leadingAnchor, constant: 20),
            logoMarkView.widthAnchor.constraint(equalToConstant: 48),
            logoMarkView.heightAnchor.constraint(equalTo: logoMarkView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: logoMarkView.topAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: logoMarkView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: heroView.trailingAnchor, constant: -20),

            brandLabel.leadingAnchor.constraint(equalTo: logoMarkView.trailingAnchor, constant: 12),
            brandLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            brandLabel.trailingAnchor.constraint(lessThanOrEqualTo: heroView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: logoMarkView.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: heroView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: heroView.trailingAnchor, constant: -20),

            heroCreateButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 18),
            heroCreateButton.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            heroCreateButton.trailingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor),
            heroCreateButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupMetrics() {
        contentView.addSubview(metricsStackView)
        metricsStackView.addArrangedSubview(resumeMetricView)
        metricsStackView.addArrangedSubview(templateMetricView)
        metricsStackView.addArrangedSubview(latestMetricView)

        NSLayoutConstraint.activate([
            metricsStackView.topAnchor.constraint(equalTo: heroView.bottomAnchor, constant: 16),
            metricsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            metricsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            metricsStackView.heightAnchor.constraint(equalToConstant: 76)
        ])
    }

    private func setupTemplatePicker() {
        templateTitleLabel.text = "Templates"
        templateTitleLabel.font = .systemFont(ofSize: 16, weight: .black)
        templateTitleLabel.textColor = .label
        templateTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        templateCollectionView.backgroundColor = .clear
        templateCollectionView.showsHorizontalScrollIndicator = false
        templateCollectionView.translatesAutoresizingMaskIntoConstraints = false
        templateCollectionView.register(TemplateCell.self, forCellWithReuseIdentifier: TemplateCell.reuseIdentifier)
        templateCollectionView.dataSource = self
        templateCollectionView.delegate = self

        contentView.addSubview(templateTitleLabel)
        contentView.addSubview(templateCollectionView)

        NSLayoutConstraint.activate([
            templateTitleLabel.topAnchor.constraint(equalTo: careerToolkitButton.bottomAnchor, constant: 20),
            templateTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            templateTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            templateCollectionView.topAnchor.constraint(equalTo: templateTitleLabel.bottomAnchor, constant: 10),
            templateCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            templateCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            templateCollectionView.heightAnchor.constraint(equalToConstant: 144)
        ])
    }

    private func setupCareerToolkit() {
        careerToolkitButton.addTarget(self, action: #selector(openCareerToolkit), for: .touchUpInside)
        contentView.addSubview(careerToolkitButton)

        NSLayoutConstraint.activate([
            careerToolkitButton.topAnchor.constraint(equalTo: metricsStackView.bottomAnchor, constant: 18),
            careerToolkitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            careerToolkitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            careerToolkitButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 72)
        ])
    }

    private func setupResumeListHeader() {
        resumeListTitleLabel.text = "Recent Resumes"
        resumeListTitleLabel.font = .systemFont(ofSize: 16, weight: .black)
        resumeListTitleLabel.textColor = .label
        resumeListTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resumeListTitleLabel)

        NSLayoutConstraint.activate([
            resumeListTitleLabel.topAnchor.constraint(equalTo: templateCollectionView.bottomAnchor, constant: 12),
            resumeListTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resumeListTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func setupSearchBar() {
        searchBar.searchTextField.backgroundColor = .secondarySystemGroupedBackground
        searchBar.searchTextField.layer.cornerRadius = 12
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.searchTextField.font = .systemFont(ofSize: 14, weight: .medium)
        contentView.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: resumeListTitleLabel.bottomAnchor, constant: 6),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 124
        tableView.contentInset = .zero
        tableView.register(ResumeCardCell.self, forCellReuseIdentifier: ResumeCardCell.reuseIdentifier)

        contentView.addSubview(tableView)
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: 170)
        tableViewHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 2),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -96),
            heightConstraint
        ])
    }

    private func setupEmptyState() {
        emptyLabel.text = "No resumes yet.\nPick a template and create your first resume."
        emptyLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 54),
            emptyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
        ])
    }

    private func setupFloatingButton() {
        view.addSubview(floatingCreateButton)
        floatingCreateButton.addTarget(self, action: #selector(createResume), for: .touchUpInside)

        NSLayoutConstraint.activate([
            floatingCreateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            floatingCreateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            floatingCreateButton.widthAnchor.constraint(equalToConstant: 56),
            floatingCreateButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func reloadData() {
        resumes = storage.loadAll()
        filterResumes()
        updateMetrics()
    }

    private func updateMetrics() {
        let count = resumes.count
        resumeMetricView.configure(value: "\(count)", caption: count == 1 ? "resume" : "resumes")
        templateMetricView.configure(value: "\(ResumeTemplate.allCases.count)", caption: "styles")
        latestMetricView.configure(value: latestUpdateSummary(), caption: "updated")
    }

    private func latestUpdateSummary() -> String {
        guard let latestUpdate = resumes.first?.updatedAt else { return "None" }

        if Calendar.current.isDateInToday(latestUpdate) {
            return "Today"
        }

        let days = Calendar.current.dateComponents([.day], from: latestUpdate, to: Date()).day ?? 0
        if days <= 1 {
            return "1 day"
        }
        if days < 7 {
            return "\(days)d"
        }
        return "7d+"
    }

    private func filterResumes() {
        let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if query.isEmpty {
            filteredResumes = resumes
        } else {
            filteredResumes = resumes.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                $0.personalInfo.fullName.localizedCaseInsensitiveContains(query)
            }
        }
        tableView.reloadData()
        updateTableHeight()
        emptyLabel.isHidden = !filteredResumes.isEmpty

        if filteredResumes.isEmpty && query.isEmpty {
            emptyLabel.text = "No resumes yet.\nPick a template and create your first resume."
        } else if filteredResumes.isEmpty {
            emptyLabel.text = "No resumes found matching \"\(query)\""
        }
    }

    private func updateTableHeight() {
        tableView.layoutIfNeeded()

        let minimumHeight: CGFloat = filteredResumes.isEmpty ? 170 : CGFloat(filteredResumes.count) * 124
        let targetHeight = max(minimumHeight, tableView.contentSize.height)
        guard abs((tableViewHeightConstraint?.constant ?? 0) - targetHeight) > 0.5 else { return }

        tableViewHeightConstraint?.constant = targetHeight
    }

    @objc private func createResume() {
        let alert = UIAlertController(
            title: "Create Resume",
            message: "Template: \(selectedTemplate.displayName)",
            preferredStyle: .alert
        )
        alert.addTextField { field in
            field.placeholder = "e.g. Senior iOS Engineer CV"
            field.text = "My Resume"
            field.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self else { return }
            let title = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "My Resume"
            let resume = self.storage.save(Resume(title: title.isEmpty ? "My Resume" : title, template: self.selectedTemplate))
            self.openEditor(for: resume)
            self.reloadData()
        })
        present(alert, animated: true)
    }

    @objc private func openCareerToolkit() {
        navigationController?.pushViewController(CareerToolkitViewController(), animated: true)
    }

    private func openEditor(for resume: Resume) {
        let editor = ResumeEditorViewController(resume: resume)
        navigationController?.pushViewController(editor, animated: true)
    }

    private func editResumeTitle(_ resume: Resume) {
        let alert = UIAlertController(title: "Edit Name", message: "Update resume title", preferredStyle: .alert)
        alert.addTextField { field in
            field.text = resume.title
            field.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self else { return }
            var updated = resume
            let title = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? resume.title
            updated.title = title.isEmpty ? resume.title : title
            self.storage.save(updated)
            self.reloadData()
        })
        present(alert, animated: true)
    }

    private func deleteResume(_ resume: Resume) {
        let alert = UIAlertController(
            title: "Delete Resume",
            message: "Are you sure you want to delete \"\(resume.title)\"?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.storage.delete(id: resume.id)
            self?.reloadData()
        })
        present(alert, animated: true)
    }
}

// MARK: - Collection View Data Source & Delegate
extension ResumeListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ResumeTemplate.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateCell.reuseIdentifier, for: indexPath) as! TemplateCell
        let template = ResumeTemplate.allCases[indexPath.item]
        cell.configure(template: template, isSelected: template == selectedTemplate)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTemplate = ResumeTemplate.allCases[indexPath.item]
        collectionView.reloadData()

        UIView.animate(withDuration: 0.1, animations: {
            collectionView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                collectionView.transform = .identity
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 104, height: 138)
    }
}

// MARK: - Table View Data Source & Delegate
extension ResumeListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredResumes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ResumeCardCell.reuseIdentifier, for: indexPath) as! ResumeCardCell
        let resume = filteredResumes[indexPath.row]
        cell.configure(with: resume)
        cell.onEdit = { [weak self] in self?.editResumeTitle(resume) }
        cell.onDelete = { [weak self] in self?.deleteResume(resume) }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openEditor(for: filteredResumes[indexPath.row])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let resume = filteredResumes[indexPath.row]
        return ListItemActions.swipeConfiguration(
            editHandler: { [weak self] in self?.editResumeTitle(resume) },
            deleteHandler: { [weak self] in self?.deleteResume(resume) }
        )
    }
}

// MARK: - Search Bar Delegate
extension ResumeListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterResumes()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

private final class HomeHeroView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let clippedPath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 24, height: 24)
        )

        context.saveGState()
        clippedPath.addClip()

        UIColor.secondarySystemGroupedBackground.setFill()
        context.fill(rect)

        UIColor(red: 0.12, green: 0.19, blue: 0.30, alpha: 0.06).setStroke()
        let divider = UIBezierPath()
        divider.lineWidth = 1
        divider.move(to: CGPoint(x: rect.minX + 20, y: rect.maxY - 1))
        divider.addLine(to: CGPoint(x: rect.maxX - 20, y: rect.maxY - 1))
        divider.stroke()

        context.restoreGState()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setNeedsDisplay()
    }
}

private final class AppLogoMarkView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let markRect = rect.insetBy(dx: 1, dy: 1)
        let markPath = UIBezierPath(roundedRect: markRect, cornerRadius: rect.width * 0.22)
        context.saveGState()
        markPath.addClip()

        let colors = [
            UIColor(red: 0.12, green: 0.19, blue: 0.30, alpha: 1).cgColor,
            UIColor(red: 0.08, green: 0.31, blue: 0.38, alpha: 1).cgColor
        ] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: nil)
        if let gradient = gradient {
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: rect.minX, y: rect.minY),
                end: CGPoint(x: rect.maxX, y: rect.maxY),
                options: []
            )
        }

        context.restoreGState()

        UIColor.white.setFill()
        let sheetRect = CGRect(x: rect.width * 0.29, y: rect.height * 0.19, width: rect.width * 0.42, height: rect.height * 0.58)
        UIBezierPath(roundedRect: sheetRect, cornerRadius: rect.width * 0.05).fill()

        UIColor(red: 0.05, green: 0.42, blue: 0.46, alpha: 1).setFill()
        UIBezierPath(
            roundedRect: CGRect(x: sheetRect.minX + 7, y: sheetRect.minY + 8, width: sheetRect.width * 0.56, height: 4),
            cornerRadius: 2
        )
        .fill()

        UIColor(red: 0.12, green: 0.19, blue: 0.30, alpha: 0.24).setFill()
        for index in 0..<3 {
            UIBezierPath(
                roundedRect: CGRect(
                    x: sheetRect.minX + 7,
                    y: sheetRect.minY + CGFloat(18 + index * 7),
                    width: sheetRect.width * (index == 2 ? 0.42 : 0.68),
                    height: 2.4
                ),
                cornerRadius: 1.2
            ).fill()
        }

        let checkPath = UIBezierPath()
        checkPath.lineWidth = max(rect.width * 0.055, 2)
        checkPath.lineCapStyle = .round
        checkPath.lineJoinStyle = .round
        checkPath.move(to: CGPoint(x: rect.width * 0.35, y: rect.height * 0.72))
        checkPath.addLine(to: CGPoint(x: rect.width * 0.47, y: rect.height * 0.84))
        checkPath.addLine(to: CGPoint(x: rect.width * 0.72, y: rect.height * 0.56))
        UIColor(red: 0.36, green: 0.73, blue: 0.61, alpha: 1).setStroke()
        checkPath.stroke()
    }
}

private final class HomeResumeSnapshotView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let sheetRect = rect.insetBy(dx: 8, dy: 8)
        let shadowPath = UIBezierPath(roundedRect: sheetRect.offsetBy(dx: 0, dy: 5), cornerRadius: 16)
        UIColor.black.withAlphaComponent(0.08).setFill()
        shadowPath.fill()

        let sheetPath = UIBezierPath(roundedRect: sheetRect, cornerRadius: 16)
        UIColor.white.setFill()
        sheetPath.fill()

        UIColor(red: 0.12, green: 0.19, blue: 0.30, alpha: 0.12).setStroke()
        sheetPath.lineWidth = 1
        sheetPath.stroke()

        drawLine(in: sheetRect, x: 14, y: 16, width: 56, height: 7, color: UIColor(red: 0.05, green: 0.42, blue: 0.46, alpha: 1))
        drawLine(in: sheetRect, x: 14, y: 34, width: 42, height: 4, color: UIColor(red: 0.12, green: 0.19, blue: 0.30, alpha: 0.55))
        drawLine(in: sheetRect, x: 14, y: 47, width: 62, height: 3, color: UIColor(red: 0.12, green: 0.19, blue: 0.30, alpha: 0.20))
        drawLine(in: sheetRect, x: 14, y: 58, width: 58, height: 3, color: UIColor(red: 0.12, green: 0.19, blue: 0.30, alpha: 0.20))
        drawLine(in: sheetRect, x: 14, y: 69, width: 38, height: 3, color: UIColor(red: 0.12, green: 0.19, blue: 0.30, alpha: 0.20))

        let checkPath = UIBezierPath()
        checkPath.lineWidth = 4
        checkPath.lineCapStyle = .round
        checkPath.lineJoinStyle = .round
        checkPath.move(to: CGPoint(x: sheetRect.minX + 20, y: sheetRect.minY + 92))
        checkPath.addLine(to: CGPoint(x: sheetRect.minX + 31, y: sheetRect.minY + 103))
        checkPath.addLine(to: CGPoint(x: sheetRect.minX + 57, y: sheetRect.minY + 78))
        UIColor(red: 0.36, green: 0.73, blue: 0.61, alpha: 1).setStroke()
        checkPath.stroke()
    }

    private func drawLine(in rect: CGRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        color.setFill()
        UIBezierPath(
            roundedRect: CGRect(x: rect.minX + x, y: rect.minY + y, width: width, height: height),
            cornerRadius: height / 2
        )
        .fill()
    }
}

private final class HomeMetricView: UIView {
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let valueLabel = UILabel()
    private let captionLabel = UILabel()
    private let tintColorValue: UIColor

    init(iconName: String, tintColor: UIColor) {
        tintColorValue = tintColor
        super.init(frame: .zero)

        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 12
        translatesAutoresizingMaskIntoConstraints = false

        iconContainerView.backgroundColor = tintColor.withAlphaComponent(0.13)
        iconContainerView.layer.cornerRadius = 13
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = tintColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.font = .systemFont(ofSize: 19, weight: .black)
        valueLabel.textColor = .label
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.72
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        captionLabel.font = .systemFont(ofSize: 9, weight: .black)
        captionLabel.textColor = .secondaryLabel
        captionLabel.adjustsFontSizeToFitWidth = true
        captionLabel.minimumScaleFactor = 0.72
        captionLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        addSubview(valueLabel)
        addSubview(captionLabel)

        NSLayoutConstraint.activate([
            iconContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            iconContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            iconContainerView.widthAnchor.constraint(equalToConstant: 26),
            iconContainerView.heightAnchor.constraint(equalTo: iconContainerView.widthAnchor),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 14),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),

            valueLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 8),
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            captionLabel.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            captionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            captionLabel.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            captionLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(value: String, caption: String) {
        valueLabel.text = value
        captionLabel.text = caption.uppercased()
        iconContainerView.backgroundColor = tintColorValue.withAlphaComponent(0.13)
        iconImageView.tintColor = tintColorValue
    }
}
