! -----------------------------------------------------------------------------
! Gustavo Saracca (c) 2024
!
! PREVIEWER ULTIMATE
! TYPES
! -----------------------------------------------------------------------------

TQ_Pages                QUEUE,TYPE,PRE()    ! 
PrintPage                   BYTE            ! Flag set to True if page is to be printed, false if not
PrintIcon                   SHORT           ! 
PageNumber                  LONG            ! 
PageSize                    LONG            ! Size of the image file
Tagged                      BYTE            ! Tagged (not used in release)
WmfFile                     cstring(1000)   ! Path and name of the image file
Found                       byte            ! IF SearchText Found Text
                        END !* QUEUE *

!* END *