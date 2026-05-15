! -----------------------------------------------------------------------------
! CLASS : WaitWindowClass
!
! (C) Gustavo Saracca - 2024
!
! Usage: Init( mensaje ) { Update( mensaje ) } Done()
! -----------------------------------------------------------------------------

  OMIT('_EndOfInclude_', _TWAITWINDOW_PRESENT_ )
_TWAITWINDOW_PRESENT_  EQUATE(1)

TWaitClass              class(),type,module( 'TWaitClass.clw' ),link( 'TWaitClass.clw' )
Init                            procedure( string _msg )
Update                          procedure( string _msg )
Done                            procedure()
                        end !* class *

  _EndOfInclude_                        