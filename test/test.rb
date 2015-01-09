require 'clash'

count = Clash::Tests.new.tests.size
FileUtils.mkdir_p('_output')

puts "Running #{count} tests..."

system("clash --list > _output/0")

(1..count).each do |t|
  system("clash #{t} > _output/#{t}")
end

# On tests 1 & 2, substitute Jekyll output containing absolute paths
# This allows tests to pass on different systems
%w{1 2}.each do |f|
  content = File.open("_output/#{f}").read
  content = content.gsub(/Configuration file: .+\//, 'Configuration file: ')
    .gsub(/Source: .+\//, 'Source: ')
    .gsub(/Destination: .+\//, 'Destination: ')

  File.open("_output/#{f}", 'w') { |f| f.write(content) }
end

