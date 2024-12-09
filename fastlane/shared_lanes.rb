# fastlane/shared_lanes.rb
module SharedLanes
    def self.define_lanes
      desc "Build the app for release"
      lane :build_app do |options|
        platform = options[:platform] || 'ios'
        if platform == 'ios'
          gym(scheme: "YouriOSAppScheme", export_method: "ad-hoc")
        elsif platform == 'android'
          gradle(task: "assembleRelease")
        else
          UI.user_error!("Unsupported platform #{platform}")
        end
      end
  
      desc "Deploy the app to Firebase App Distribution"
      lane :deploy_to_firebase do |options|
        platform = options[:platform] || 'ios'
        if platform == 'ios'
          firebase_app_distribution(
            app: "1:YOUR_IOS_FIREBASE_APP_ID:ios:YOUR_APP_KEY",
            ipa_path: "./build/ios/ipa/YourApp.ipa"
          )
        elsif platform == 'android'
          firebase_app_distribution(
            app: "1:YOUR_ANDROID_FIREBASE_APP_ID:android:YOUR_APP_KEY",
            apk_path: "./build/android/app/release/app-release.apk"
          )
        else
          UI.user_error!("Unsupported platform #{platform}")
        end
      end
    end
  end
  