   PROGRAM



   INCLUDE('ABASCII.INC'),ONCE
   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABDOCK.INC'),ONCE
   INCLUDE('ABDROPS.INC'),ONCE
   INCLUDE('ABEIP.INC'),ONCE
   INCLUDE('ABERROR.INC'),ONCE
   INCLUDE('ABFILE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABPRHTML.INC'),ONCE
   INCLUDE('ABPRPDF.INC'),ONCE
   INCLUDE('ABQUERY.INC'),ONCE
   INCLUDE('ABREPORT.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABTBLSYN.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ABUSERCONTROL.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('ABWMFPAR.INC'),ONCE
   INCLUDE('CSIDLFOLDER.INC'),ONCE
   INCLUDE('CWSYNCWT.INC'),ONCE
   INCLUDE('CLAAWSS3.INC'),ONCE
   INCLUDE('CLAMAIL.INC'),ONCE
   INCLUDE('CLARUNEXT.INC'),ONCE
   INCLUDE('ERRORS.CLW'),ONCE
   INCLUDE('ITBROWSECLASS.INC'),ONCE
   INCLUDE('ITPREVIEWERCLASS.INC'),ONCE
   INCLUDE('ITSORTIMG.INC'),ONCE
   INCLUDE('JSON.INC'),ONCE
   INCLUDE('KEYCODES.CLW'),ONCE
   INCLUDE('QUICKWINTRANSLATOR.INC'),ONCE
   INCLUDE('SPECIALFOLDER.INC'),ONCE
   INCLUDE('SYSTEMSTRING.INC'),ONCE
   INCLUDE('ABBREAK.INC'),ONCE
   INCLUDE('ABCPTHD.INC'),ONCE
   INCLUDE('ABFUZZY.INC'),ONCE
   INCLUDE('ABGRID.INC'),ONCE
   INCLUDE('ABPRI2PDF.INC'),ONCE
   INCLUDE('ABPRNAME.INC'),ONCE
   INCLUDE('ABPRPNG.INC'),ONCE
   INCLUDE('ABPRTARG.INC'),ONCE
   INCLUDE('ABPRTARY.INC'),ONCE
   INCLUDE('ABPRTEXT.INC'),ONCE
   INCLUDE('ABPRXML.INC'),ONCE
   INCLUDE('ABQEIP.INC'),ONCE
   INCLUDE('ABRPATMG.INC'),ONCE
   INCLUDE('ABRPPSEL.INC'),ONCE
   INCLUDE('ABRULE.INC'),ONCE
   INCLUDE('ABSQL.INC'),ONCE
   INCLUDE('ABVCRFRM.INC'),ONCE
   INCLUDE('CCSBUTNS.INC'),ONCE
   INCLUDE('CCSLOCAT.INC'),ONCE
   INCLUDE('CCSSIZES.INC'),ONCE
   INCLUDE('CCSSQL1.INC'),ONCE
   INCLUDE('CCSTOOLB.INC'),ONCE
   INCLUDE('CFILTBASE.INC'),ONCE
   INCLUDE('CFILTERLIST.INC'),ONCE
   INCLUDE('CWSYNCHC.INC'),ONCE
   INCLUDE('MDISYNC.INC'),ONCE
   INCLUDE('QPROCESS.INC'),ONCE
   INCLUDE('RTFCTL.INC'),ONCE
   INCLUDE('TRIGGER.INC'),ONCE
   INCLUDE('WINEXT.INC'),ONCE

   MAP
     MODULE('GSVIEW_BC.CLW')
DctInit     PROCEDURE                                      ! Initializes the dictionary definition module
DctKill     PROCEDURE                                      ! Kills the dictionary definition module
     END
    MODULE('\SOURCE\OSG\ACCESS\ACCESS.DLL')
acc_getvar             FUNCTION( string, string, string ),string,DLL ! 
acc_setvar             PROCEDURE( string, string, string ),DLL ! 
    END
!--- Application Global and Exported Procedure Definitions --------------------------------------------
     MODULE('GSVIEW001.CLW')
ITPreViewer            FUNCTION(*Queue pImageQueue,Short pZoom,Byte pMaximize,String pWindowCaption,Byte pStartPageList,<*ReportTargetSelectorClass pTargetSelector>),byte   !
     END
     MODULE('WinAPI')
         API_DeleteFile(*cstring dfilename),bool,Raw,Pascal,Proc,Name('deletefileA')
     END !* MODULE *
     ! INCLUDE CWUtil : Module
     
         include( 'CWUTIL.inc' ),once
     
     ! END
    ! Declare functions defined in this DLL
gsview:Init            PROCEDURE(<ErrorClass curGlobalErrors>, <INIClass curINIMgr>)
gsview:Kill            PROCEDURE
    ! Declare init functions defined in a different dll
     MODULE('\SOURCE\OSG\ACCESS\ACCESS.DLL')
access:Init            PROCEDURE(<ErrorClass curGlobalErrors>, <INIClass curINIMgr>)
access:Kill            PROCEDURE
     END
   END

! INCLUDE : TPRE_TYPES.CLW 

    include( 'TPRN_TYPES.CLW', 'equates' ),once
    include( 'TPRE_TYPES.CLW' ),once

!* END *
! INCLUDE Zoom : Module

    include( 'ZoomModule.inc' ),once
    
!* END *
! INCLUDE Percent : Module

    include( 'PercentModule.inc' ),once
    
!* END *
! INCLUDE TPrinterClass : Module

    include( 'TPrinter.inc' ),once

! END
! INCLUDE ABC-REPORTs CLASSES

    INCLUDE('ABREPORT.INC'),ONCE

!* END *
! INCLUDE TWaitClass : Module

    include( 'TWaitClass.inc' ),once

! END
SilentRunning        BYTE(0)                               ! Set true when application is running in 'silent mode'

!region File Declaration
!endregion


GlobalRequest        BYTE(0),THREAD                        ! Set when a browse calls a form, to let it know action to perform
GlobalResponse       BYTE(0),THREAD                        ! Set to the response from the form
VCRRequest           LONG(0),THREAD                        ! Set to the request from the VCR buttons
LocalErrorStatus     ErrorStatusClass,THREAD
LocalErrors          ErrorClass
LocalINIMgr          INIClass
GlobalErrors         &ErrorClass
INIMgr               &INIClass
DLLInitializer       CLASS,TYPE                            ! An object of this type is used to initialize the dll, it is created in the generated bc module
Construct              PROCEDURE
Destruct               PROCEDURE
                     END

Dictionary           CLASS,THREAD
Construct              PROCEDURE
Destruct               PROCEDURE
                     END


  CODE
DLLInitializer.Construct PROCEDURE


  CODE
  LocalErrors.Init(LocalErrorStatus)
  LocalINIMgr.Init('cfg.ini', NVD_INI)                     ! Initialize the local INI manager to use windows INI file
  INIMgr &= LocalINIMgr
  IF GlobalErrors &= NULL
    GlobalErrors &= LocalErrors                            ! Assign local managers to global managers
  END
  DctInit()
  
!These procedures are used to initialize the DLL. It must be called by the main executable when it starts up
gsview:Init PROCEDURE(<ErrorClass curGlobalErrors>, <INIClass curINIMgr>)
gsview:Init_Called    BYTE,STATIC

  CODE
  IF gsview:Init_Called
     RETURN
  ELSE
     gsview:Init_Called = True
  END
  IF ~curGlobalErrors &= NULL
    GlobalErrors &= curGlobalErrors
  END
  IF ~curINIMgr &= NULL
    INIMgr &= curINIMgr
  END
  access:Init(curGlobalErrors, curINIMgr)                  ! Initialise dll - (ABC) -

!These procedures are used to shutdown the DLL. It must be called by the main executable before it closes down

gsview:Kill PROCEDURE
gsview:Kill_Called    BYTE,STATIC

  CODE
  IF gsview:Kill_Called
     RETURN
  ELSE
     gsview:Kill_Called = True
  END
  access:Kill()                                            ! Kill dll - (ABC) -
  

DLLInitializer.Destruct PROCEDURE

  CODE
  LocalINIMgr.Kill                                         ! Kill local managers and assign NULL to global refernces
  INIMgr &= NULL                                           ! It is an error to reference these object after this point
  GlobalErrors &= NULL



Dictionary.Construct PROCEDURE

  CODE
  IF THREAD()<>1
     DctInit()
  END


Dictionary.Destruct PROCEDURE

  CODE
  DctKill()

