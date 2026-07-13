import MVVMDomain
import SnapKit
import UIKit

final class WeatherListView: UIView {
    let filterControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["7 Days", "30 Days", "Bookmarked"])
        control.selectedSegmentIndex = 0
        return control
    }()

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(WeatherListCell.self, forCellReuseIdentifier: WeatherListCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        return tableView
    }()

    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private var sections: [WeatherListSection] = []
    var onItemSelected: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func render(sections: [WeatherListSection]) {
        self.sections = sections
        tableView.reloadData()
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }

    func setErrorMessage(_ message: String?) {
        errorLabel.text = message
        errorLabel.isHidden = message == nil
    }

    func setSelectedFilter(_ filter: WeatherListFilter) {
        switch filter {
        case .sevenDays:
            filterControl.selectedSegmentIndex = 0
        case .thirtyDays:
            filterControl.selectedSegmentIndex = 1
        case .bookmarked:
            filterControl.selectedSegmentIndex = 2
        }
    }

    private func setupLayout() {
        addSubview(filterControl)
        addSubview(tableView)
        addSubview(loadingIndicator)
        addSubview(errorLabel)

        filterControl.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterControl.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        errorLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
    }
}

extension WeatherListView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: WeatherListCell.reuseIdentifier,
                for: indexPath
            ) as? WeatherListCell
        else {
            return UITableViewCell()
        }
        let item = sections[indexPath.section].items[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]
        onItemSelected?(item.id)
    }
}

final class WeatherListCell: UITableViewCell {
    static let reuseIdentifier = "WeatherListCell"

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(summaryLabel)
        summaryLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(with item: WeatherListItemUIModel) {
        summaryLabel.attributedText = item.summary
    }
}
