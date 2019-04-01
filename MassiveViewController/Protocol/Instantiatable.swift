//
//  Instantiatable.swift
//  MessageSample
//
//  Created by shiz on 2019/01/13.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

protocol Instantiatable {
    associatedtype Input
    init(with input: Input)
}

extension Instantiatable {
    static func instantiate(with input: Input) -> Self {
        return Self.init(with: input)
    }
}

extension Instantiatable where Input == Void {
    static func instantiate() -> Self {
        return Self.init(with: ())
    }
}

protocol StoryboardInstantiatable {
    associatedtype Input = Void
}

extension StoryboardInstantiatable where Input == Void, Self: UIViewController {
    static func instantiate() -> Self {
        return UIStoryboard(name: String(describing: self),
                            bundle: Bundle(for: self)).instantiateInitialViewController() as! Self
    }
    
    static func instantiate(storyboardName: String) -> Self {
        return UIStoryboard(name: storyboardName,
                            bundle: Bundle(for: self)).instantiateViewController(withIdentifier: String(describing: self)) as! Self
    }
}
