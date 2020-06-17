Pod::Spec.new do |spec|
    spec.name             = 'RSRealmHelper'
    spec.version          = '1.1.2'
    spec.summary          = 'A helper class to use with Realm database'

    spec.description      = <<-DESC
    A class to use with Realm database to manager the connection, abstract the file creation and crypto.
    Get helper functions to save, update and delete objetcs.
    DESC

    spec.homepage         = 'https://github.com/redspark-io/RSRealmHelper'
    spec.license          = { :type => 'MIT', :file => 'LICENSE' }
    spec.author           = { 'Marcus Costa' => 'marcus.costa@redspark.io' }
    spec.source           = { :git => 'https://github.com/redspark-io/RSRealmHelper.git', :tag => spec.version.to_s }

    spec.ios.deployment_target = '9.0'
    spec.swift_version = '4.2'
    spec.module_name = 'RSRealmHelper'

    spec.source_files = 'RSRealmHelper/Classes/**/*'

    spec.dependency 'RealmSwift'
    spec.dependency 'KeychainAccess'

end
