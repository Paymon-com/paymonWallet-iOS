# Uncomment the next line to define a global platform for your project
# platform :ios, '10.0'

target 'paymon' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks

    pod 'OpenSSL-Universal'

  use_frameworks!

  pod 'Alamofire', '~> 4.0'
    pod 'MBProgressHUD', '~> 1.0.0'
    #pod 'AlamofireObjectMapper'
    pod 'CoreStore', '~> 5.0'
    pod 'ScrollableGraphView'
    pod 'SDWebImage', '~> 4.0'
    pod 'FLAnimatedImage', '~> 1.0'
    #pod 'ReverseExtension'
    pod 'web3swift', :git => 'https://github.com/bankex/web3swift.git'
    pod 'KeychainAccess'
    pod 'BlockiesSwift'
    pod 'DeckTransition', '~> 2.0'

    # Pods for paymon

  target 'paymonTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'paymonUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            # This works around a unit test issue introduced in Xcode 10.
            # We only apply it to the Debug configuration to avoid bloating the app size
            if config.name == "Debug" && defined?(target.product_type) && target.product_type == "com.apple.product-type.framework"
                config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = "YES"
            end
        end
    end
end
end

