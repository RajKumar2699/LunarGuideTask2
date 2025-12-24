//
//  TrailInfoViewController.swift
//  LunarGuideTask
//
//  Created by Askme Technologies on 24/12/25.
//

import UIKit

final class TrailInfoCardView: UIView {
    
    var onStartHiking: (() -> Void)?
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let distanceLabel = UILabel()
    private let ctaButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    
    init(name: String, distanceKM: Double) {
        super.init(frame: .zero)
        setupUI(name: name, distanceKM: distanceKM)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(name: String, distanceKM: Double) {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        titleLabel.text = name
        titleLabel.numberOfLines = 0
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        subtitleLabel.text = "Statistics computed from imported data"
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel
        
        distanceLabel.text = String(
            format: "Distance: %.2f km", distanceKM
        )
        distanceLabel.font = .systemFont(ofSize: 14)
        
        ctaButton.setTitle("Start Hiking", for: .normal)
        ctaButton.backgroundColor = .systemBlue
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.layer.cornerRadius = 6
        ctaButton.addTarget(self, action: #selector(startHikingBTn), for: .touchUpInside)
        
        closeButton.setTitle("✕", for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            distanceLabel,
            ctaButton
        ])
        stack.axis = .vertical
        stack.spacing = 8
        
        addSubview(stack)
        addSubview(closeButton)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
    }
    
    @objc private func closeTapped() {
        removeFromSuperview()
    }
    
    @objc private func startHikingBTn(){
        removeFromSuperview()
        onStartHiking?()
    }
}
