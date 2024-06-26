#!/usr/bin/env ruby


require "./niz.rb"
require 'progress_bar'

override_mapping = lambda do |mapping|
	# mapping[level][key_id] = hwcode
	# level:
	#   0: normal
	#   1: Right Fn
	#   2: Left Fn
	# key_id: 1-66
	# hwcode: See ./niz.rb HWCODE constant

	mapping[0][61] = 68 # Set key_id 61 (right side of space) = 68 (super)
	mapping[0][62] = 71
	mapping[0][63] = 74

	mapping[0][30] = 67 # L-CTRL
	mapping[0][56] = 42 # Caps Lock
	mapping[0][58] = 69 # Left-Alt
	mapping[0][59] = 68 # Left-Super
	mapping[0][61] = 72 # Right-Super
	mapping[0][63] = 156 # R-Fn
	mapping[1][63] = 156 # R-Fn
	mapping[2][63] = 156 # R-Fn
end

#################################################################

niz = NiZ.new
Timeout.timeout(1) do
	begin
		niz.open
	rescue => e
		$stderr.puts "#{e.inspect} retrying open device..."
		retry
	end
end

puts "Version: #{niz.version}"
puts "#{niz.keycount} keys"

puts "Reading key mapping..."
progress = ProgressBar.new(niz.keycount * 3)
read_all = niz.read_all do |count, keymap|
	progress.increment!
end

mapping = NiZ.mapping_from_array(read_all)

override_mapping[mapping]

puts "Writing key mapping..."
progress = ProgressBar.new(niz.keycount * 3)
niz.write_all(mapping) do |count|
	progress.increment!
end

