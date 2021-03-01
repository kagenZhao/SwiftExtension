//
//  UITableViewCell+Rx.swift
//  wmIOS
//
//  Created by 赵国庆 on 2019/7/4.
//  Copyright © 2019 kagen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxTableViewCell: UITableViewCell {
    public var reuseDisposeBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}

class RxTableViewHeaderFooterView: UITableViewHeaderFooterView {
    public var reuseDisposeBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}

class RxCollectionViewCell: UICollectionViewCell {
    public var reuseDisposeBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}

class RxCollectionReusableView: UICollectionReusableView {
    public var reuseDisposeBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}



