    member

    map
    end  

include( 'PercentModule.inc' ),once

TPercentClass.Init      procedure( long _ctrl, long _counter )
    code
    self.Percent    = 0
    self.Counter    = 0
    self.RecCounter = _counter
    self.control = _ctrl
    self.control{Prop:Hide} = False
    self.control{prop:RangeLow} = 1
    self.control{prop:RangeHigh} = self.RecCounter

TPercentClass.Next      procedure( *long _idx )!,long
is_next         long
    code   
    is_next = false
    
    self.Counter = self.Counter + 1
    if self.Counter <= self.RecCounter
        _idx = self.counter
        is_next = true
        self.control{ PROP:progress } = self.Counter
    end !* end *
    
    return is_next

TPercentClass.Update    procedure()
    code
    self.Percent = (self.Counter / self.RecCounter) * 100.0
    display( self.control )

TPercentClass.Done      procedure()
    code
    self.Percent = 0
    self.control{Prop:Hide} = true
    display( self.control )

!* END *