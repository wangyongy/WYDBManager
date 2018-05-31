@version = "0.0.3"

Pod::Spec.new do |s| 
s.name = "WYDBManager" 
s.version = @version 
s.summary = "数据库" 
s.description = "基于FMDB，一行代码实现数据库增删改查" 
s.homepage = "https://github.com/wangyongy/WYDBManager.git" 
s.license = "Copyright (c) 2018年 wangyong. All rights reserved."
s.author = { "wangyong" => "15889450281@163.com" } 
s.ios.deployment_target = '8.0' 
s.source = { :git => "https://github.com/wangyongy/WYDBManager.git", :tag => "v#{s.version}" } 
s.source_files = 'WYDBManager/WYDBManager/**/*.{h,m,bundle}' 
s.requires_arc = true 
s.framework = 'Foundation','UIKit'
s.dependency 'FMDB'
end