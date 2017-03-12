Pod::Spec.new do |s|

	s.name = "Speedy"
	s.version = "0.1"
	s.summary = "Reactive Swift property observation framework."
	s.description = <<-DESC
	Speedy provides quick and easy property observation tools for Swift.
	You can make any value observable and watch changes to that value over time.
	Speedy provides a powerful filtering and mapping system.
	DESC

	s.homepage = "https://github.com/RedHandTech/Speedy"
	s.license = { :type => "MIT", :file => "LISCENCE.txt" }
	s.author = { "Rob Sanders" => "rob.sanders@redhandtechnologies.co.uk" }
	s.ios.deployment_target = "10.2"
	s.osx.deployment_target = "10.12"
	s.watchos.deployment_target = "3.1"
	s.tvos.deployment_target = "10.1"

	s.source = { :git => "https://github.com/RedHandTech/Speedy.git", :tag => "#{s.version}" }
	s.source_files = "Sources/*.swift"

end