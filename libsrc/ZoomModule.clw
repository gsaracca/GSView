    member

    map
    end 

include( 'ZoomModule.inc' ),once

! -----------------------------------------------------------------------------
! CONST
! -----------------------------------------------------------------------------
GS_MinimumZoom      EQUATE(25)
GS_MaximumZoom      EQUATE(500)

GS_ZoomPageHeight   EQUATE(-2)      ! Zoom  -2 = PageHeight
GS_ZoomPageWidth    EQUATE(-1)      ! Zoom  -1 = PageWidth
GS_Zoom100          EQUATE( 0)      ! Zoom   0 = Full (100%)
! -----------------------------------------------------------------------------

TzoomClass.InitStep     procedure()
    code
    IF self.QSteps &= NULL
        self.QSteps &= NEW TQ_ZoomSteps
        free( self.QSteps )
    END !* if *
    
TzoomClass.AddZoomStep  procedure( long _value )
    code
    clear( self.QSteps )
    case _value 
        of GS_ZoomPageHeight
            self.QSteps.Desc = 'Page Height'
        of GS_ZoomPageWidth
            self.QSteps.Desc = 'Page Width'
        else 
            self.QSteps.Desc = format( _value, @n_3 ) & '%'
    end !* case *
    self.QSteps.Value = _value
    add( self.QSteps )

TzoomClass.KillStep     procedure()
    code
    IF NOT self.QSteps &= NULL
        free( self.QSteps )
        dispose( self.QSteps )
    END !* if *

TzoomClass.IsZoom       procedure()!,long
    code
    return self.Zoom

TzoomClass.SetZoomOn    procedure()
    code
    self.Zoom = TRUE
    
TzoomClass.SetZoomOff   procedure()
    code
    self.Zoom = FALSE
   
TzoomClass.SetValue     procedure( long _value )
    code
    self.ZoomValue = _value

TzoomClass.GetValue     procedure()!,long
iValue      long
    code
    get( self.QSteps, self.ZoomState )
    case self.QSteps.Value
        of GS_ZoomPageHeight
            iValue = (self.ClientHeight/self.PageHeight) * 100
        of GS_ZoomPageWidth
            iValue = (self.ClientWidth/self.PageWidth) * 100        
        else 
            iValue = self.ZoomValue
    end !* case *
    return iValue
    
TzoomClass.ZoomPageHeight   procedure()
state       long
    code
    if self.FindState( GS_ZoomPageHeight, state )
        self.SetState( state )
    end !* if *
    
TzoomClass.ZoomPageWidth    procedure()
state       long
    code
    if self.FindState( GS_ZoomPageWidth, state )
        self.SetState( state )
    end !* if *
    
TzoomClass.Zoom100          procedure()    
state       long
    code
    if self.FindState( 100, state )
        self.SetState( state )
    end !* if *
    
TzoomClass.ZoomIn           procedure()
    code
    if self.ZoomState < records( self.QSteps )
        self.SetState( self.ZoomState + 1 )
    end !* if *
    
TzoomClass.ZoomOut      procedure()
    code
    if self.ZoomState > 1
        self.SetState( self.ZoomState - 1 )        
    end !* if *
    
TzoomClass.SetList          procedure( long _list )    
    code
    self.ListCtrl = _list
    self.ListCtrl{ Prop:LineHeight } = 12
    
TzoomClass.SetPageHeight    procedure( long _height )
    code
    self.PageHeight = _height 
    
TzoomClass.SetPageWidth     procedure( long _width )
    code
    self.PageWidth = _width

TzoomClass.SetClientHeight  procedure( long _height )
    code
    self.ClientHeight = _height
       
TzoomClass.SetClientWidth   procedure( long _width )
    code
    self.ClientWidth = _width    
   
TzoomClass.GetState     procedure()!,long
    code
    return self.ZoomState
    
TzoomClass.SetState     procedure( long _state )
    code
    self.ZoomState = _state    
    get( self.QSteps, self.ZoomState )
    if not errorcode()        
        self.SetValue( self.QSteps.Value )
        select( self.ListCtrl, self.ZoomState )
    end !* if *   
    
TzoomClass.FindState    procedure( long _value, *long _state )!,long
is_found    long
    code
    is_found = false
    
    clear( self.QSteps )
    self.QSteps.value = _value
    get( self.QSteps, self.QSteps.value )
    if not errorcode()
        _state = pointer( self.QSteps )
        is_found = true
    end !* if *    
    
    return is_found

TzoomClass.SetZoomByValue   procedure( long _value ) 
state       long
    code
    if _value = GS_Zoom100
        _value = 100
    end !* if *        
    if self.FindState( _value, state )
        self.SetState( state )
    end !* if *    
    
TzoomClass.LoadQueue        procedure( *TQ_ZoomSteps _queue )    
i           long
    code
    free( _queue )
    
    loop i = 1 to records( self.QSteps )
        get( self.QSteps, i )
        
        clear( _queue )
        _queue.Desc = self.QSteps.Desc
        _queue.Value = self.QSteps.Value
        add( _queue )
        
    end !* loop *        

TzoomClass.Init         procedure()
state                   long
    code
    self.SetZoomOff()
   
    self.InitStep()
    self.AddZoomStep( GS_ZoomPageHeight )
    self.AddZoomStep( GS_ZoomPageWidth )
    self.AddZoomStep(  25 )
    self.AddZoomStep(  33 )
    self.AddZoomStep(  50 )
    self.AddZoomStep(  67 )
    self.AddZoomStep(  75 )
    self.AddZoomStep(  80 )
    self.AddZoomStep(  90 )
    self.AddZoomStep( 100 )
    self.AddZoomStep( 110 )
    self.AddZoomStep( 125 )
    self.AddZoomStep( 150 )
    self.AddZoomStep( 175 )
    self.AddZoomStep( 200 )
    self.AddZoomStep( 250 )
    self.AddZoomStep( 300 )
    self.AddZoomStep( 400 )
    self.AddZoomStep( 500 )
   
TzoomClass.Run          procedure()
is_run          long
    code
    is_run = TRUE
    
    return is_run
    
TzoomClass.Done         procedure()
    code
    self.KillStep()

!* END *