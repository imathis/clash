require 'clash'

count = Clash::Tests.new().tests.size

(1..count).each do |t|
  system("clash #{t} > _output/#{t}")
end

test = Clash::Tests.new(file: ".test.yml")
test.run

