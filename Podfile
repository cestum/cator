# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
ENV['COCOAPODS_DISABLE_STATS'] = "true"

target 'Cator' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  #use_frameworks!

  # Pods for Cator
  pod "FilesProvider"
  pod 'SETOCryptomatorCryptor', '~> 1.4.0'
  pod 'UICKeyChainStore'
end

target 'Provider' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  #use_frameworks!

  # Pods for Provider
  pod "FilesProvider"
  pod 'SETOCryptomatorCryptor', '~> 1.4.0'
  pod 'UICKeyChainStore'
end


post_install do |lib|
    lib.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        end
    end
end



