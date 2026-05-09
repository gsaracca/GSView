! -------------------------------------------------------------------------------------------------
!
! Gustavo Saracca (C) - 2026
!
! -------------------------------------------------------------------------------------------------
    program  
      
    include('ABREPORT.INC'),once
    include('ABERROR.INC'),once

!--- Application Global and Exported Procedure Definitions --------------------------------------------
    map
        module('GS_PV.CLW')
            GSPreViewer(*Queue pImageQueue,Short pZoom,Byte pMaximize,String pWindowCaption,Byte pStartPageList, <*ReportTargetSelectorClass pTargetSelector>),byte,dll
        end !* module 
        module('WinAPI')
            API_DeleteFile(*cstring dfilename),bool,Raw,Pascal,Proc,Name('deletefileA')
        end !* module *
        include( 'CWUTIL.inc' ),once
        
        gsview:Init( <ErrorClass curGlobalErrors>, <INIClass curINIMgr> ),dll
        gsview:Kill(),dll
    end !* map *
! -------------------------------------------------------------------------------------------------
    include( 'TPRN_TYPES.CLW', 'equates' ),once ! INCLUDE : TPRE_TYPES.CLW 
    include( 'TPRE_TYPES.CLW' ),once
    include( 'PercentModule.inc' ),once     ! INCLUDE Percent : Module
    include( 'TPrinter.inc' ),once          ! INCLUDE TPrinterClass : Module
	include( 'TWaitClass.inc' ),once        ! INCLUDE TWaitClass : Module
	include( 'ZoomModule.inc' ),once        ! INCLUDE Zoom : Module
! -------------------------------------------------------------------------------------------------
GSView:Version          equate('26.05.09A')
! -------------------------------------------------------------------------------------------------
SilentRunning           byte(0)             ! Set true when application is running in 'silent mode'
GlobalRequest           byte(0),THREAD      ! Set when a browse calls a form, to let it know action to perform
GlobalResponse          byte(0),THREAD      ! Set to the response from the form
VCRRequest              long(0),THREAD      ! Set to the request from the VCR buttons
! -------------------------------------------------------------------------------------------------
LocalErrors             ErrorClass
GlobalErrors            &ErrorClass
! -------------------------------------------------------------------------------------------------
DLLInitializer          class,type          ! An object of this type is used to initialize the dll, it is created in the generated bc module
Construct                   procedure()
Destruct                    procedure()
                        end
    code
    ! main()

! -------------------------------------------------------------------------------------------------
gsview:Init             procedure(<ErrorClass curGlobalErrors>, <INIClass curINIMgr>)
gsview:Init_Called      byte,static
    code
    if gsview:Init_Called
        return
    else
        gsview:Init_Called = True
    end !* if *
    if ~curGlobalErrors &= NULL
        GlobalErrors &= curGlobalErrors
    end !* if *
  
gsview:Kill             procedure()
gsview:Kill_Called      byte,static
    code
    if gsview:Kill_Called
        return
    else
        gsview:Kill_Called = True
    end !* if *
    
DLLInitializer.Construct    procedure()
    code
    if GlobalErrors &= NULL
        GlobalErrors &= LocalErrors
    end !* if *    
   
DLLInitializer.Destruct     procedure()
    code
    GlobalErrors &= NULL

! -------------------------------------------------------------------------------------------------
!* end *
! -------------------------------------------------------------------------------------------------
