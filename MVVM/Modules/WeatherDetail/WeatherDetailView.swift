import MVVMDomain
import SnapKit
import UIKit

final class WeatherDetailView: UIView {
    let scrollView = UIScrollView()
    let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        return stack
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func render(detail: WeatherDetailUIModel?) {
        contentStack.arrangedSubviews.forEach { view in
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        guard let detail else { return }
        titleLabel.attributedText = detail.title
        contentStack.addArrangedSubview(titleLabel)
        for row in detail.rows {
            let rowView = WeatherDetailRowView()
            rowView.configure(label: row.label, value: row.value)
            contentStack.addArrangedSubview(rowView)
        }
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

    private func setupLayout() {
        addSubview(scrollView)
        addSubview(loadingIndicator)
        addSubview(errorLabel)
        scrollView.addSubview(contentStack)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalTo(scrollView.snp.width).offset(-32)
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

final class WeatherDetailRowView: UIView {
    private let labelView: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private let valueView: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [labelView, valueView])
        stack.axis = .vertical
        stack.spacing = 4
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(label: String, value: NSAttributedString) {
        labelView.text = label
        valueView.attributedText = value
    }
}
