require 'clash'

tests = Clash::Tests.new.tests
titles = tests.dup.map {|t| t['title'].gsub(/ /,'-').gsub(/[^\w-]/,'').downcase }

output = "test-output/output"
FileUtils.rm_r(output, :force => true)
FileUtils.mkdir(output)

puts "Running #{tests.size} tests..."

system("clash --list > #{output}/list")

titles.each_with_index do |t, index|
  result = `clash #{index + 1} -t`

  # Swap out paths output by Jekyll tests
  result = result.gsub(File.join(Dir.pwd,''), '')

  File.open(File.join(output, t), 'w') { |f| f.write(result) }
end
