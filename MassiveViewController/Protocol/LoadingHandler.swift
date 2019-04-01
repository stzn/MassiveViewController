//
//  LoadingHandler.swift
//  VISITSKit
//
//  Created by shiz on 2019/03/28.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

protocol LoadingHandler where Self: UIViewController {
    func showLoading(_ view: UIView)
    func hideLoading()
}

extension LoadingHandler {
    public func showLoading(_ view: UIView) {
        let indicator = makeIndicatorView()
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.topAnchor.constraint(equalTo: view.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            indicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }

    func hideLoading() {
        guard let indicator = view.viewWithTag(indicatorViewTag) else {
            return
        }
        indicator.removeFromSuperview()
    }

    private func makeIndicatorView() -> UIView {
        if let view = self.view.viewWithTag(indicatorViewTag) {
            return view
        }

        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = indicatorViewTag
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        indicator.startAnimating()
        return view
    }
}

private let indicatorViewTag = 123456
