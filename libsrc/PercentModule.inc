! -----------------------------------------------------------------------------
! Gustavo Saracca (c) 2024
!
! Procolo: Init { Run } Done
! -----------------------------------------------------------------------------
! MODULE PercentModule;

  OMIT('_EndOfInclude_', _TPERCENT_PRESENT_ )
_TPERCENT_PRESENT_  EQUATE(1)

TPercentClass       class(),type,module( 'PercentModule.clw' ),link( 'PercentModule.clw' )
Percent                 long,private
Counter                 long,private
RecCounter              long,private
control                 long,private

Init                    procedure( long _ctrl, long _counter )
Next                    procedure( *long _idx ),long
Update                  procedure()
Done                    procedure()
                    end !* class *
    
    _EndOfInclude_