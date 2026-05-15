! -----------------------------------------------------------------------------
! Gustavo Saracca (c) 2024
!
! Procolo: Init { Run } Done
! -----------------------------------------------------------------------------

TQ_ZoomSteps            QUEUE,TYPE
Desc                        cstring(64)
Value                       long
                        END !* QUEUE *

  OMIT('_EndOfInclude_', _TZOOM_PRESENT_ )
_TZOOM_PRESENT_     EQUATE(1)

TZoomClass          class,type,module( 'ZoomModule.clw' ),link( 'ZoomModule.clw' )
Zoom                    byte,private            ! Zoom on MouseRight or MouseLeft
ZoomValue               long,private            ! Current Zoom Value
ZoomState               long,private            ! Pointer to Current Zoom Queue 
PageWidth               long,private
PageHeight              long,private
ClientWidth             long,private
ClientHeight            long,private
QSteps                  &TQ_ZoomSteps,private
ListCtrl                long,private

InitStep                procedure(),private
AddZoomStep             procedure( long _value ),private
KillStep                procedure(),private

IsZoom                  procedure(),long
SetZoomOn               procedure()
SetZoomOff              procedure()

SetValue                procedure( long _value )
GetValue                procedure(),long

ZoomPageHeight          procedure()
ZoomPageWidth           procedure()
Zoom100                 procedure()
ZoomIn                  procedure()
ZoomOut                 procedure()

SetList                 procedure( long _list )
SetPageHeight           procedure( long _height )
SetPageWidth            procedure( long _width )
SetClientHeight         procedure( long _height )
SetClientWidth          procedure( long _width )

GetState                procedure(),long
SetState                procedure( long _state )
FindState               procedure( long _value, *long _state ),long

SetZoomByValue          procedure( long _value )

LoadQueue               procedure( *TQ_ZoomSteps _queue )

Init                    procedure()
Run                     procedure(),long
Done                    procedure()
                    end !* class *
                                        
    _EndOfInclude_