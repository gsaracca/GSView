! -----------------------------------------------------------------------------
! CLASS : WaitWindowClass
!
! (C) Gustavo Saracca - 2024
!
! Usage: Init( mensaje ) { Update( mensaje ) } Done()
! -----------------------------------------------------------------------------

        member

        map
        end !* map *

include( 'TWaitClass.inc' ),once

! WINDOW - WAIT
! -----------------------------------------------------------------------------

WaitWindow WINDOW,AT(,,200,60),CENTER,GRAY,FONT('Microsoft Sans Serif',8),NOFRAME
        BOX,AT(10,10,180,40),USE(?BoxExternal),COLOR(0D7FFH),ROUND,LINEWIDTH(1)
        BOX,AT(16,16,168,28),USE(?Box),FILL(0F3E0D0H),ROUND,LINEWIDTH(0)
        STRING('Gestión'),AT(16,24,168),USE(?Title),CENTER,FONT('Segoe UI',12, |
                0BE6E10H,FONT:bold,CHARSET:DEFAULT),COLOR(0F3E0D0H)
    END

!* end *

TWaitClass.Init     procedure( string _msg )
    code
    open( WaitWindow )
    display()
    SetCursor( CURSOR:WAIT )    
    
    self.Update( _msg )

TWaitClass.Update       procedure( string _msg )
    code
    ?Title{ prop:text } = clip(_msg)
    display( ?Title )

! TWaitClass.Done()

TWaitClass.Done         procedure()
    code
    SetCursor()
    display()
    close( WaitWindow )
    
!* END *