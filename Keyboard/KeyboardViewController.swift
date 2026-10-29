import UIKit

final class KeyboardViewController: UIInputViewController {

    private let gradient = CAGradientLayer()
    private let root = UIStackView()
    private let effects = PetalEffects()
    private var shift = false
    private var numbers = false

    private let letterRows = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l"],
        ["z","x","c","v","b","n","m"]
    ]
    private let numberRows = [
        ["1","2","3","4","5","6","7","8","9","0"],
        ["-","/",":",";","(",")","$","&","@","\""],
        [".",",","?","!","'","#","%"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        gradient.colors = [
            UIColor(red: 1.0, green: 0.85, blue: 0.91, alpha: 1).cgColor,
            UIColor(red: 0.96, green: 0.45, blue: 0.62, alpha: 1).cgColor
        ]
        view.layer.insertSublayer(gradient, at: 0)

        let h = view.heightAnchor.constraint(equalToConstant: 275)
        h.priority = UILayoutPriority(999)
        h.isActive = true

        root.axis = .vertical
        root.spacing = 9
        root.distribution = .fillEqually
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            root.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            root.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)
        ])
        build()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // MARK: Build
    private func build() {
        root.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let rows = numbers ? numberRows : letterRows

        root.addArrangedSubview(makeRow(rows[0].map { key($0) }))
        root.addArrangedSubview(makeRow(rows[1].map { key($0) }, inset: numbers ? 0 : 14))

        let shiftBtn = special(numbers ? "#+=" : (shift ? "⬆︎" : "⇧"), #selector(tapShift))
        let del = special("⌫", #selector(tapDelete))
        let letters = rows[2].map { key($0) }
        let row3 = makeRow([shiftBtn] + letters + [del])
        if let first = letters.first {
            shiftBtn.widthAnchor.constraint(equalTo: first.widthAnchor, multiplier: 1.5).isActive = true
            del.widthAnchor.constraint(equalTo: first.widthAnchor, multiplier: 1.5).isActive = true
        }
        root.addArrangedSubview(row3)

        let num = special(numbers ? "ABC" : "123", #selector(tapNumbers))
        let globe = special("🌐", #selector(tapGlobe(_:event:)))
        let space = special("♡  love  ♡", #selector(tapSpace))
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let ret = special("return", #selector(tapReturn))
        num.widthAnchor.constraint(equalToConstant: 48).isActive = true
        globe.widthAnchor.constraint(equalToConstant: 44).isActive = true
        ret.widthAnchor.constraint(equalToConstant: 78).isActive = true

        var bottom: [UIView] = [num, globe, space, ret]
        if !needsInputModeSwitchKey { bottom.removeAll { $0 === globe } }
        root.addArrangedSubview(makeRow(bottom))
    }

    private func makeRow(_ views: [UIView], inset: CGFloat = 0) -> UIStackView {
        let s = UIStackView(arrangedSubviews: views)
        s.axis = .horizontal
        s.spacing = 5
        s.distribution = .fill
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        let letterKeys = views.filter { $0.tag == 1 }
        if let first = letterKeys.first {
            letterKeys.dropFirst().forEach {
                $0.widthAnchor.constraint(equalTo: first.widthAnchor).isActive = true
            }
        }
        return s
    }

    // MARK: Key factory
    private func styled(_ title: String, special: Bool) -> UIButton {
        let b = UIButton(type: .custom)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: special ? 16 : 22, weight: .medium)
        b.setTitleColor(UIColor(red: 0.75, green: 0.1, blue: 0.35, alpha: 1), for: .normal)
        b.backgroundColor = special ? UIColor.white.withAlphaComponent(0.55)
                                    : UIColor.white.withAlphaComponent(0.88)
        b.layer.cornerRadius = 9
        b.layer.shadowColor = UIColor(red: 0.6, green: 0.1, blue: 0.3, alpha: 1).cgColor
        b.layer.shadowOpacity = 0.35
        b.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        b.layer.shadowRadius = 1.5
        b.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        b.addTarget(self, action: #selector(touchEnd(_:)),
                    for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return b
    }

    private func key(_ ch: String) -> UIButton {
        let shown = (shift && !numbers) ? ch.uppercased() : ch
        let b = styled(shown, special: false)
        b.tag = 1
        b.accessibilityLabel = shown
        b.addTarget(self, action: #selector(tapKey(_:)), for: .touchUpInside)
        return b
    }

    private func special(_ title: String, _ sel: Selector) -> UIButton {
        let b = styled(title, special: true)
        b.addTarget(self, action: sel, for: .touchUpInside)
        return b
    }

    // MARK: Animation
    @objc private func touchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.08) {
            sender.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
            sender.backgroundColor = UIColor(red: 1, green: 0.78, blue: 0.88, alpha: 1)
        }
        let p = sender.superview?.convert(sender.center, to: view) ?? sender.center
        effects.burst(in: view, at: p)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @objc private func touchEnd(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15) {
            sender.transform = .identity
            sender.backgroundColor = sender.tag == 1
                ? UIColor.white.withAlphaComponent(0.88)
                : UIColor.white.withAlphaComponent(0.55)
        }
    }

    // MARK: Actions
    @objc private func tapKey(_ s: UIButton) {
        textDocumentProxy.insertText(s.title(for: .normal) ?? "")
        if shift && !numbers { shift = false; build() }
    }

    @objc private func tapShift() {
        guard !numbers else { return }
        shift.toggle()
        build()
    }

    @objc private func tapDelete() { textDocumentProxy.deleteBackward() }
    @objc private func tapSpace() { textDocumentProxy.insertText(" ") }
    @objc private func tapReturn() { textDocumentProxy.insertText("\n") }
    @objc private func tapNumbers() { numbers.toggle(); build() }

    @objc private func tapGlobe(_ s: UIButton, event: UIEvent) {
        handleInputModeList(from: s, with: event)
    }
}
