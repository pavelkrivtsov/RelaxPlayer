//
//  MixCell.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.02.2023.
//

import UIKit

final class MixCell: UITableViewCell {
    
    static let reuseId = "MixCell"
    
    private var title = UILabel()    
    private var vStack = UIStackView()
    private var hStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: "foregroundColor")
        setupVStack()
        setupHStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupVStack() {
        contentView.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: self.topAnchor),
            vStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        vStack.spacing = 16
        vStack.alignment = .center
        vStack.axis = .vertical
        
        vStack.addArrangedSubview(title)
        vStack.addArrangedSubview(hStack)
    }
    
    private func setupHStack() {
        hStack.spacing = 8
        hStack.alignment = .center
    }
}

extension MixCell {
    func configure(mix: Mix) {
        self.title.text = mix.name
        let noises = mix.noises?.allObjects as! [Noise]
        for noise in noises {
            let label = UILabel()
            label.text = noise.name
            hStack.addArrangedSubview(label)
        }
    }
}
