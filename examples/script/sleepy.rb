puts File.expand_path('.')
puts `rvm current`
trap("TERM") { puts "got term"; exit 0 }
sleep 100000
puts "done sleeping"
