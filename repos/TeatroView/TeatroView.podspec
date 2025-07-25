Pod::Spec.new do |s|
  s.name         = 'TeatroView'
  s.version      = '0.1.0'
  s.summary      = 'Typesense GUI built with Teatro.'
  s.homepage     = 'https://github.com/fountain-coach/teatro'
  s.license      = { :type => 'MIT' }
  s.author       = { 'FountainCoach' => 'support@fountain.coach' }
  s.source       = { :git => 'https://github.com/fountain-coach/teatro.git', :tag => s.version.to_s }
  s.swift_version = '6.1'
  s.source_files  = 'Sources/**/*.{swift}'
end
