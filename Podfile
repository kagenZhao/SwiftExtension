PROJECT_DEPLOYMENT_TARGET = '10.0'
platform :ios, PROJECT_DEPLOYMENT_TARGET
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
  pod 'HandyJSON'
  pod 'DeviceKit'
  pod 'SwiftDate'
  pod 'CocoaMQTT'
end

target 'SwiftExtensionsExample' do
  use_frameworks!
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = PROJECT_DEPLOYMENT_TARGET
    end
    # XX 编译类型为静态库
#    if static_lib_targets.include?(xx.name)
#      target.build_configurations.each do |config|
#        config.build_settings['MACH_O_TYPE'] = 'staticlib'
#      end
#    end
  end
  
  # 解决警告 product cannot link framework Foundation.framework
#  podsTargets = installer.pods_project.targets.find_all { |target| target.name.start_with?('Pods') }
#  podsTargets.each do |target|
#    target.frameworks_build_phase.clear
#  end
end
