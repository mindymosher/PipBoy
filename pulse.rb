require 'beaglebone'
include Beaglebone

p9_33 = AINPin.new(:P9_33)
@now = Time.now

changecallback = lambda { |pin, mv_last, mv, count| puts "[#{count}] #{mv_last} -> #{mv}" if mv > mv_last}
p9_33.run_on_change(changecallback, 20, 0.01)


sleep 100000
threshcallback = lambda { |pin, mv_last, mv, state_last, state, count|
    @last = @now
    @now = Time.now

    puts "#{state} #{(@now - @last).to_f}"    

}

p9_33.run_on_threshold(threshcallback, 599, 600, 100, 0.02)


loop do 
   sleep 10000
    
end