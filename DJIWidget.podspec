Pod::Spec.new do |s|
    s.name = 'DJIWidget'
    s.version = '1.0'
    s.author = { 'Lacklock' => 'lacklock@gmail.com',
                 'Owen'     => 'wen.pandara@gmail.com' }
    s.license = { :type => 'CUSTOM', :text => <<-LICENSE
****************************************************************************************************************************

DJI Mobile SDK for iOS is offered under DJI's END USER LICENSE AGREEMENT. You can obtain the license from the below link:
http://developer.dji.com/policies/eula/

****************************************************************************************************************************
    LICENSE
    }

    s.homepage = 'https://github.com/gzkiwiinc/Mobile-SDK-iOS'
    s.source = { :git => 'git@github.com:gzkiwiinc/Mobile-SDK-iOS.git', :tag => "w#{s.version}"}
    s.summary = 'DJIWidget'
    s.platform = :ios, '10.0'

    s.vendored_frameworks = 'FFmpeg/FFmpeg.framework'
    s.frameworks = 'Foundation', 'CoreGraphics', 'CoreMedia', 'FFmpeg'

    s.module_name = 'DJIWidget'

    s.source_files = 'DJIWidget/*.{h,m,c}', 'DJIWidget/**/*.{h,m,c}'


    s.pod_target_xcconfig = {
        'ENABLE_BITCODE' => 'NO',
        'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/DJIWidget/FFmpeg/FFmpeg.framework/Headers" "${PODS_ROOT}/DJIWidget/FFmpeg/FFmpeg.framework/Headers/libavcodec" "${PODS_ROOT}/DJIWidget/FFmpeg/FFmpeg.framework/Headers/libavdevice" "${PODS_ROOT}/DJIWidget/FFmpeg/FFmpeg.framework/Headers/libavfilter" "${PODS_ROOT}/DJIWidget/FFmpeg/FFmpeg.framework/Headers/libavformat" "${PODS_ROOT}/DJIWidget/FFmpeg/FFmpeg.framework/Headers/libavresample" "${PODS_ROOT}/DJIWidget/FFmpeg/FFmpeg.framework/Headers/libavutil" "${PODS_ROOT}/DJIWidget/FFmpeg/FFmpeg.framework/Headers/libswresample" "${PODS_ROOT}/DJIWidget/FFmpeg/FFmpeg.framework/Headers/libswscale"',
    }
    
    s.dependency 'DJI-SDK-iOS', '~> 4.7.1'

    s.subspec 'DJIVideoPreviewerExtension' do |ss|
        ss.source_files = 'DJIVideoPreviewerExtension/*.{h,m}'
        ss.public_header_files = 'DJIVideoPreviewerExtension/*.h'
    end

end
