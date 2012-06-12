Pod::Spec.new do |s|
  s.name     = 'AZSlidingViewController'
  s.version  = '0.0.1'
  s.license  = 'Apache 2.0'
  s.summary  = 'A container around a UIScrollView to easily slide around overlapping views.'
  s.homepage = 'https://github.com/pashields/AZSlidingViewController'
  s.author   = { 'Pat Shields' => 'yeoldefortran@gmail.com' }
  s.source   = { :git => 'git://github.com/pashields/AZSlidingViewController.git' }
  s.platform = :ios
  s.source_files = 'AZSlidingViewController/lib/*.{h,m}'
  s.framework = 'UIKit'
  s.requires_arc = true
end
