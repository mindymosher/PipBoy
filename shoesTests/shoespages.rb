
class Screens
    
    def stats(something)
        s = self
        something.app do
            @stats = flow do
                para "Stats"
                button "Items" do
                    @stats.hide()
                    @items = s.items(something)
                    @items.show()
                end
                button "Data" do
                    @stats.hide()
                    @data = s.data(something)
                    @data.show()
                end
            end
        end
    end
    
    def items(something)
        s = self
        something.app do
            @items = flow do
                para "Items"
                button "Stats" do
                    @items.hide()
                    @stats = s.stats(something)
                    @stats.show()
                end
                button "Data" do
                    @items.hide()
                    @data = s.data(something)
                    @data.show()
                end
            end
        end
    end
    
    def data(something)
        s = self
        something.app do
            @data = flow do
                para "Data"
                button "Stats" do
                @data.hide()
                @stats = s.stats(something)
                @stats.show()
            end
            button "Items" do
                @data.hide()
                @items = s.items(something)
                @items.show()
            end
        end
    end    end

    def initialize(something)
        stats(something)
        data(something)
        items(something)
    end
end

Shoes.app(title: "Pipboy 3000", width: 470, height: 280, resizable: false) {
    background "background1.png", width: 470, height: 280
    background "screenpixel.png", width: 470, height: 280
    
    
    @screens = Screens.new(self)
    
    
    
    # stroke green
    #nofill
    
    #shape do
    #    move_to(90, 55)
    #    line_to(10, 20)
    #    line_to(100, 20)
    #end
    #caption("TEST")
}