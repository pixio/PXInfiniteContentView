Pod::Spec.new do |s|
  s.name             = "PXInfiniteContentView"
  s.version          = "0.2.0"
  s.summary          = 'A view that can scroll forever in either direction to lazy-load "infinite" content.'

  s.description      = <<-DESC
                       A view that can scroll forever in either direction, with delegate methods that let you load
                       the content for a view at a particular index lazily (only when it is shown).
                       DESC

  s.homepage         = "https://github.com/pixio/PXInfiniteContentView"
  s.license          = 'MIT'
  s.author           = { "Spencer Phippen" => "spencer.phippen@gmail.com" }
  s.source           = { :git => "https://github.com/pixio/PXInfiniteContentView.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.public_header_files = 'Pod/Classes/{PXInfiniteContentView,PXInfiniteContentBounds}.h'
  s.resource_bundles = {
    'PXInfiniteContentView' => ['Pod/Assets/*.png']
  }
end
