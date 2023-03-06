//
//  MixCell.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.02.2023.
//

import UIKit

final class MixCell: UITableViewCell {
    
    static let reuseId = "MixCell"
    
    private var view = UIView()
    private var stack = UIStackView()
    private var titleLabel = UILabel()
    private var noisesLabel = UILabel()
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        var viewAnchors = [NSLayoutConstraint]()
        viewAnchors.append(view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8))
        viewAnchors.append(view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8))
        viewAnchors.append(view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8))
        viewAnchors.append(view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8))
        NSLayoutConstraint.activate(viewAnchors)
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        var stackAnchors = [NSLayoutConstraint]()
        stackAnchors.append(stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8))
        stackAnchors.append(stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8))
        stackAnchors.append(stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8))
        stackAnchors.append(stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8))
        NSLayoutConstraint.activate(stackAnchors)
        
        view.backgroundColor = UIColor(named: "foregroundColor")
        view.layer.cornerRadius = 16

        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(noisesLabel)
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MixCell {
    func configure(mix: Mix) {
        guard let noises = mix.noises.allObjects as? [Noise] else {
            return print("error configure cell")
        }
        
        var noiseNames = [String]()
        
        let sortedNoises = noises.sorted { noise1, noise2 in
            return noise1.createdAt < noise2.createdAt
        }
     
        for noise in sortedNoises {
            noiseNames.append(noise.name)
        }
        
        noisesLabel.text = noiseNames.joined(separator: ", ")
        noisesLabel.font = .systemFont(ofSize: 16)
        titleLabel.text = mix.name
        titleLabel.font = .boldSystemFont(ofSize: 20)
    }
}
