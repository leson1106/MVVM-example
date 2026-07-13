platform :ios, '15.0'

target 'MVVMDomain' do
  use_frameworks!
  pod 'RxSwift'
end

target 'MVVMNetwork' do
  use_frameworks!
  pod 'RxSwift'
end

target 'MVVM' do
  use_frameworks!

  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SnapKit'

  target 'MVVMTests' do
    inherit! :search_paths
    pod 'RxSwift'
    pod 'RxCocoa'
  end

  target 'MVVMUITests' do
  end
end
