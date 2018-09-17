platform :ios, '9.0'
inhibit_all_warnings!
target 'SwiftExtensions' do
  use_frameworks!
  pod 'Alamofire'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SwiftTryCatch'
  pod 'RxDataSources'
  pod 'SwiftyJSON'
  pod 'SwifterSwift'
  pod 'Kingfisher'
  pod 'Aspects'
  pod 'fishhook'
  pod 'ReactiveCocoa', '~> 2.5'
  pod 'SnapKit'
  pod 'HandyJSON', :git => 'https://github.com/alibaba/HandyJSON.git',  :branch => 'dev_for_swift4.2'
  pod 'DeviceKit'
  pod 'SwiftDate'
end

target 'SwiftExtensionsExample' do
  use_frameworks!
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name != "HandyJSON"
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.1'
            end
        end
    end
end
