class Geiger
	# Used 10k resistor in line for vu meter
	
	# Initialize pin P8_12 in INPUT mode 
	p8_18 = GPIOPin.new(:P8_18, :IN) 
	
	# Initialize pin p9_16 in PWM mode
	p8_19 = PWMPin.new(:P8_19, 0, 2390000, :NORMAL)
	
	# array for pulses
	@pulseArray = []
	
	callback = lambda { |pin,edge,count| 
	    #puts "[#{count}] #{pin} #{edge}"
	    @pulseArray <<  Time.now.to_f
	}
	
	
	p8_18.run_on_edge(callback, :RISING)
	
	#puts "Waiting..."
	
	Thread.new do 
	    loop do
	        currentTime = Time.now.to_f
	        
	        @pulseArray.reject! { |oldTime| currentTime - oldTime > 0.5 }
	        
	        # Map the pulse per second value to valid gauge value
	        pulsesPerSec = @pulseArray.size
	        case pulsesPerSec
	            when 0 
	                dutyCycle = 0
	            when 1
	                dutyCycle = 20
	            when 2
	                dutyCycle = 40
	            when 3
	                dutyCycle = 70
	            else
	                dutyCycle = 100
	        end
	    
	        p8_19.set_duty_cycle(dutyCycle)
	        sleep 0.1
	    end
	end
	def self.getPulses
		return @pulseArray.size
	end
end
