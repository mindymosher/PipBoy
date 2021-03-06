lightButton = GPIOPin.new(:P8_9, :IN) #from pin to button then button to ground
p9_41 =  GPIOPin.new(:P9_41, :OUT) #pin to 10k resistor, to transistor base(left), 
				   #transistor collector(middle) goes to neg on LED
				   #transistor emitter(right) to ground (on board when wall wart, otherwise ground on battery board)

Thread.new do
	count = 1
	loop do
		lightButton.wait_for_edge(:FALLING)
		#puts "hit"
		if count%2 == 0
			p9_41.digital_write(:LOW)
		else
			p9_41.digital_write(:HIGH)
		end
		count += 1
		sleep 0.25
	end
end


