! -------------------------------------------------------------------------------------------------
!
! Gustavo Saracca (C) - 2026
!
! -------------------------------------------------------------------------------------------------

    member('gsview.clw')

    map
        include('GSView001.inc'),once
    end !* map *
   include('KeyCodes.clw'),once
   include('ABWINDOW.INC'),once

ITPreViewer procedure( *Queue pImageQueue, short pZoom, byte pMaximize, string pWindowCaption, byte pStartPageList, <*ReportTargetSelectorClass pTargetSelector> )
! -------------------------------------------------------------------------------------------------
! MAP
! -------------------------------------------------------------------------------------------------
    map
        GetFileSize( *cstring _file ),long
        GetReportImageSize( *cstring _fname, *long _width, *long _height )
        GetClientArea()
        DeleteFile( *cstring _fname )
    end !* map *
! -------------------------------------------------------------------------------------------------
! CONST
! -------------------------------------------------------------------------------------------------
GS_EVENT:Sized      EQUATE(501h)

! -------------------------------------------------------------------------------------------------
! PROJECT - LINK - RESOURCE FILES 
! -------------------------------------------------------------------------------------------------
ICON_CHECK_ON           equate('~check_on.ico')
ICON_CHECK_OFF          equate('~check_off.ico')
    
    PRAGMA('link(check_on.ico)')
    PRAGMA('link(check_off.ico)')

! -------------------------------------------------------------------------------------------------   
! DATA for Window
! -------------------------------------------------------------------------------------------------
WD                  GROUP,PRE(WD)
CurrentPage             long
Percent                 long
SearchString            cstring(255)
ShowPageList            byte
                    END !* group *

! -------------------------------------------------------------------------------------------------
! LOCAL QUEUEs
! -------------------------------------------------------------------------------------------------
PageQueue               TQ_Pages
QZoom                   TQ_ZoomSteps
QPrinters               TQ_PRINTERS

! -------------------------------------------------------------------------------------------------
! DATA
! -------------------------------------------------------------------------------------------------
GSV:Response            BYTE

GSV:ClientAreaWidth     LONG
GSV:ClientAreaHeight    LONG

GSV:BorderFEQ           LONG
GSV:ImageFEQ            LONG
GSV:RegionFEQ           LONG
             
! -------------------------------------------------------------------------------------------------
! WINDOW - PREVIEWER
! -------------------------------------------------------------------------------------------------
PreviewWindow WINDOW('GSoft - Previewer'),AT(,,751,235),CENTER,GRAY,IMM,MAX, |
            ICON(ICON:Print1),STATUS(-1,90,90),FONT('Arial',10),ALRT(PgDnKey), |
             ALRT(PgUpKey),COLOR(COLOR:BTNFACE),Tiled,HVSCROLL,RESIZE
        TOOLBAR,AT(0,0,751,62),USE(?ITPreviwerToolbar),COLOR(COLOR:BTNFACE),Tiled
            GROUP,AT(3,2,268,27),USE(?ZoomGroup)
                BUTTON,AT(6,4,30,21),USE(?ZoomInButton),ICON('zoom_in.ico'), |
                        TIP('Zoom In')
                BUTTON,AT(39,4,30,21),USE(?ZoomOutButton),ICON('Zoom_out.ico'), |
                        TIP('Zoom Out')
                BUTTON,AT(72,4,30,21),USE(?ZoomToPageWidth),ICON('layer_resize_r' & |
                        'eplicate_h.ico'),TIP('Zoom to Page Width')
                BUTTON,AT(105,4,30,21),USE(?ZoomToPageHeight),ICON('layer_resize' & |
                        '_replicate_v.ico'),TIP('Zoom to Page Height')
                BUTTON,AT(138,4,30,21),USE(?Zoom100Percent),ICON('layer_resize.ico'), |
                        TIP('Zoom 100%')
                LIST,AT(179,12,79,12),USE(?ListZoom),VSCROLL,RIGHT(2), |
                        FONT(,,,FONT:regular),COLOR(COLOR:WINDOW),TIP('Zoom Actual'), |
                        DROP(10,70),FROM(QZoom),FORMAT('71R(2)|M')
            END
            GROUP,AT(274,2,258,27),USE(?ActionGroup)
                BUTTON,AT(277,4,30,21),USE(?PrintAllButton),ICON('printer.ico'), |
                        TIP('Imprimir Páginas Seleccionadas')
                BUTTON,AT(310,4,30,21),USE(?PrintOneButton),ICON('catalog_pages.ico'), |
                        TIP('Imprimir Página Actual')
                BUTTON,AT(343,4,30,21),USE(?CancelButton),ICON('printer_delete.ico'), |
                        TIP('Cerrar sin Imprimir')
                LIST,AT(377,12,146,12),USE(?ListPrinters),VSCROLL,LEFT(2), |
                        FONT(,,,FONT:regular),COLOR(COLOR:WINDOW),TIP('Impresora' & |
                        ' de Destino'),DROP(10,170),FROM(Qprinters), |
                        FORMAT('169L(2)|M')
            END
            GROUP,AT(3,30,268,28),USE(?NavigationGroup)
                CHECK,AT(6,33,30,21),USE(WD:ShowPageList),VALUE('1','0'), |
                        ICON('layout_sidebar.ico'),TIP('Show/Hide PageList'), |
                        KEY(CtrlL)
                BUTTON,AT(39,33,30,21),USE(?JumpFirstButton),ICON('resultset_fir' & |
                        'st.ico'),TIP('Jump to First page')
                BUTTON,AT(72,33,30,21),USE(?JumpPrevButton),ICON('resultset_prev' & |
                        'ious.ico'),TIP('Jump to Previous page')
                BUTTON,AT(105,33,30,21),USE(?JumpNextButton),ICON('resultset_next.ico'), |
                        TIP('Jump to Next page')
                BUTTON,AT(138,33,30,21),USE(?JumpLastButton),ICON('resultset_last.ico'), |
                        TIP('Jump to Last page'),LEFT
                GROUP,AT(172,33,95,21),USE(?GrpPages),FONT(,8,,,CHARSET:DEFAULT), |
                        BEVEL(0,0,8888H)
                    BOX,AT(172,33,95,21),USE(?BOX1),COLOR(080FFFFH),FILL(0C0FFFFH), |
                            ROUND,LINEWIDTH(1)
                    STRING('Páginas'),AT(178,39,30,9),USE(?PagesStr),TRN, |
                            FONT(,9,COLOR:Black)
                    STRING(@n_6),AT(207,39,27,9),USE(WD:CurrentPage),TRN,CENTER, |
                            FONT(,9,COLOR:Black),COLOR(COLOR:WINDOW)
                    STRING(''),AT(237,39,30,10),USE(?OfString),TRN,FONT(,9,COLOR:Black)
                END
            END
            GROUP,AT(274,30,258,28),USE(?SearchGroup)
                ENTRY(@s50),AT(277,37,71,14),CURSOR(CURSOR:IBeam),USE(WD:SearchString), |
                        FONT(,10,COLOR:Black,,CHARSET:DEFAULT),COLOR(COLOR:WINDOW), |
                        TIP('Ingrese el Texto a Buscar, si desea agregar el nuev' & |
                        'o texto a la búsqueda anterior debe anteponer el signo ' & |
                        '"+". En tanto si desea buscar el texto "+algo" y agrega' & |
                        'rlo a la búsqueda actual debe escribirlo de la siguient' & |
                        'e manera: "++algo".-')
                PROGRESS,AT(277,48,72,6),USE(WD:Percent),HIDE,RANGE(0,100)
                BUTTON('Buscar'),AT(352,37,54,14),USE(?SearchButton), |
                        FONT(,,,FONT:regular),ICON('search.ico'),TIP('Buscar el ' & |
                        'texto ingresado marcando las páginas encontradas como p' & |
                        'ara imprimir. Debe ingresar más de 2 caracteres para qu' & |
                        'e se realice la búsqueda.'),LEFT
                BUTTON,AT(409,37,20,14),USE(?SearchPrev),FONT(,,,FONT:regular), |
                        ICON(ICON:PrevPage),TIP('Página Previa con Búsqueda Exitosa.')
                BUTTON,AT(433,37,20,14),USE(?SearchNext),FONT(,,,FONT:regular), |
                        ICON(ICON:NextPage),TIP('Siguiente Página con Búsqueda E' & |
                        'xitosa.')
                BUTTON,AT(457,37,20,14),USE(?TagAllPages),FONT(,,,FONT:regular), |
                        ICON('cla_mark.ico'),TIP('Marcar para impresión todas la' & |
                        's páginas ignorando si fueron encontradas o no en la úl' & |
                        'tima búsqueda.')
                BUTTON,AT(481,37,20,14),USE(?TagPagesFound),FONT(,,,FONT:regular), |
                        ICON('cla_down_clone.ico'),TIP('Marcar solo las páginas ' & |
                        'en las cuales se encontró el texto buscado.')
                BUTTON,AT(504,37,20,14),USE(?SearchReset),FONT(,,,FONT:regular), |
                        ICON('cla_down_plus.ico'),TIP('Marcar todas las páginas ' & |
                        'eliminando los datos de la/s búsquedas anteriores.')
            END
            GROUP,AT(535,2,209,56),USE(?SaveAsGroup)
                BUTTON,AT(536,12,32,36),USE(?SaveAsPDF),ICON('Hechiceroo-Mnemo-P' & |
                        'df.ico'),TIP('Guardar como PDF')
                BUTTON,AT(571,12,32,36),USE(?SaveAsText),ICON('Hechiceroo-Mnemo-' & |
                        'Txt.ico'),TIP('Guardar como TXT')
                BUTTON,AT(607,12,32,36),USE(?SaveAsHTML),ICON('Hechiceroo-Mnemo-' & |
                        'Html.ico'),TIP('Guardar como HTML')
                BUTTON,AT(642,12,32,36),USE(?SaveAsXML),ICON('Hechiceroo-Mnemo-X' & |
                        'ml.ico'),TIP('Guardar como XML')
                BUTTON,AT(677,12,32,36),USE(?SaveAsPNG),ICON('Hechiceroo-Mnemo-P' & |
                        'ng.ico'),TIP('Guardar como PNG')
                BUTTON,AT(712,12,32,36),USE(?SaveAsXLS),ICON('Hechiceroo-Mnemo-X' & |
                        'ls.ico'),TIP('Guardar como Excel')
            END
        END
        BUTTON,AT(465,3,12,10),CURSOR(CURSOR:Arrow),USE(?TogglePrintButton),SKIP, |
                TIP('Toggle Print/Not print this page'),LEFT
        BOX,AT(3,16,55,64),USE(?BorderBox),COLOR(COLOR:Gray),HIDE,LINEWIDTH(1)
        LIST,AT(3,92,81,77),USE(?ListPages),FLAT,HIDE,VSCROLL,FONT('Arial',8,, |
                FONT:regular),COLOR(COLOR:White,COLOR:HIGHLIGHTTEXT,COLOR:HIGHLIGHT), |
                TIP('Listado de Páginas del Informe. Con marca de seleccionadas ' & |
                'para imprimir y el tamaño de cada una.'),CURSOR(CURSOR:Arrow), |
                FROM(PageQueue),FORMAT('11LI@p p@26R(2)|~Página~C(0)@n_4@34R(2)|' & |
                '~Tamaño~C(0)@n9@'),ALRT(MouseLeft2), ALRT(CtrlEnd), ALRT(CtrlHome)
        IMAGE,AT(60,16),USE(?PageImage),HIDE
        REGION,AT(109,16,55,64),CURSOR(CURSOR:Zoom),USE(?BorderRegion),IMM,BEVEL(1,-1)
        PANEL,AT(93,92,71,78),USE(?ListboxPanel),FILL(COLOR:BTNFACE),HIDE,BEVEL(-1)
    END

!* END *

! -------------------------------------------------------------------------------------------------
! ThisWindow : CLASS()
! -------------------------------------------------------------------------------------------------
ThisWindow           CLASS(WindowManager)
Init                    PROCEDURE(),BYTE,PROC,DERIVED
Kill                    PROCEDURE(),BYTE,PROC,DERIVED
Ask                     PROCEDURE(),DERIVED
ChangeAction            PROCEDURE(),BYTE,DERIVED
OnCloseEventCancelled   PROCEDURE(),DERIVED
Reset                   PROCEDURE(BYTE Force=0),DERIVED
Run                     PROCEDURE(),BYTE,PROC,DERIVED
SetAlerts               PROCEDURE(),DERIVED
Update                  PROCEDURE(),DERIVED
TakeAccepted            PROCEDURE(),BYTE,PROC,DERIVED
TakeFieldEvent          PROCEDURE(),BYTE,PROC,DERIVED
TakeDisableButton       PROCEDURE(SIGNED Control,BYTE MakeDisable),DERIVED
TakeCloseEvent          PROCEDURE(),BYTE,PROC,DERIVED
TakeWindowEvent         PROCEDURE(),BYTE,PROC,DERIVED
TakeNewSelection        PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent               PROCEDURE(),BYTE,PROC,DERIVED
                     END

! -------------------------------------------------------------------------------------------------
! TPreViewerClass : class()
! -------------------------------------------------------------------------------------------------
TPreViewerClass         class(),type
CurrentPage                 long,private
WindowCtrl                  &window,private
Found                       long,private
FindIndex                   long,private

TotalPages                  long,private
TotalFileSize               long,private

IncPage                     procedure()
DecPage                     procedure()

JumpFirstPage               procedure()
JumpLastPage                procedure()
JumpPreviousPage            procedure()
JumpNextPage                procedure()
ScrollUpPage                procedure()
ScrollDownPage              procedure()
ScrollUpabit                procedure()
ScrollDownabit              procedure()

DrawPage                    procedure()

GetCurrentPageFromQueue     procedure()
GetCurrentImage             procedure(),*cstring

GetCurrentPage              procedure(),long
SetCurrentPage              procedure( long _page )
GetTotalPages               procedure(),long

FindFirst                   procedure()
FindNext                    procedure()
FindPrev                    procedure()

TagAllPages                 procedure()
TagPagesFound               procedure()
SearchReset                 procedure()
SearchText                  procedure( *cstring _search_text ),long
GetFound                    procedure(),long

Init                        procedure( *window _window )
Run                         procedure(),long
Done                        procedure()
                        end !* class *

! -------------------------------------------------------------------------------------------------
! TToPrintClass : class()
! -------------------------------------------------------------------------------------------------
TToPrintClass           class(),type
ReportJobName               cstring(255),private
Landscape                   byte,private
Paper                       long,private
CopiesToPrint               long,private
ReportWidth                 long,private
ReportHeight 			    long,private

ToPrinter                   procedure( long _all )

Init                        procedure()
Run                         procedure(),long
Done                        procedure()
                        end !* class *
    
! -------------------------------------------------------------------------------------------------
! TImageClass   :   class()
! -------------------------------------------------------------------------------------------------
TImageClass         class(),type
ImageWidth              long,private
ImageHeight             long,private
AspectRatio             real,private

GetWidth                procedure(),long
GetHeight               procedure(),long 
GetAspect               procedure(),real

Init                    procedure( *cstring _fname )
Run                     procedure(),long
Done                    procedure()
                    end !* class *
                    
! -------------------------------------------------------------------------------------------------
! TPButtonClass :   class()
! -------------------------------------------------------------------------------------------------
TPButtonClass       class(),type
btnCtrl                 long,private
Xrange                  long,dim(2),private
Yrange                  long,dim(2),private

GetArea                 procedure()
MouseOnArea             procedure(),long
SetHide                 procedure( long _on )

Init                    procedure( long _ctrl )
Draw                    procedure()
Done                    procedure()
                    end !* class *
! -------------------------------------------------------------------------------------------------
! TPageListClass : class()
! -------------------------------------------------------------------------------------------------
TPageListClass          class(),type
listCtrl                    long,private
panelCtrl                   long,private

Xrange                      long,dim(2),private
Yrange                      long,dim(2),private

GetPage                     procedure()
GetArea                     procedure()
MouseOnArea                 procedure(),long

Init                        procedure( long _ctrl, long _panel )
Draw                        procedure()
Done                        procedure()
                        end !* class *

! -------------------------------------------------------------------------------------------------
! TSaveAsClass : class
! -------------------------------------------------------------------------------------------------                     
TSaveAsClass            class,type
CFG_GROUP                   cstring('ALL'),private
CFG_VALUE                   cstring('PreViewer.ExportPath'),private
is_enable                   long,private
export_path                 cstring(1000),private

ReportTarget                &IReportGenerator,private
WMFParser                   &WMFDocumentParser,private
OutputFileQueue             &OutputFileQueue,private
PrevQueue                   &PreviewQueue,private

if_xml                      long,private
if_pdf                      long,private
if_text                     long,private
if_html                     long,private
if_png                      long,private
if_xls                      long,private

SelectOutputFile            procedure(),long,private

Init                        procedure()
SetButtons                  procedure()
LoadPath                    procedure()
SavePath                    procedure()
Run                         procedure( string _type ),long,proc
Done                        procedure()
                        end !* class *
                        
! -------------------------------------------------------------------------------------------------
! TPVQueueClass : class
! -------------------------------------------------------------------------------------------------
TQ_NewName      queue,type
OldName             cstring(1000)
NewName             cstring(1000)
                end !* QUEUE *

TPVQueueClass   class(),type
NewName             &TQ_NewName,private

LoadPagesQueue      procedure(),private
UnloadPagesQueue    procedure(),private

RestoreMetaFiles    procedure()
RenameMetaFiles     procedure()
RemoveMetaFiles     procedure()

Init                procedure()
Done                procedure()
                end !* class *
                        
! -------------------------------------------------------------------------------------------------
! Classes Instances
! -------------------------------------------------------------------------------------------------
Toolbar             ToolbarClass
TZoom               TZoomClass
Tpre                TPreViewerClass
TPrinter            TPrinterClass
ToPrint             TToPrintClass
TImage              TImageClass
TPButton            TPButtonClass
TPageList           TPageListClass
TSaveAs             TSaveAsClass
TPVQueue            TPVQueueClass
TWait               TWaitClass

    code
    clear( WD )         ! Clear Windows Data

    ToPrint.Init()      ! Need to be first because need takes the current "Report"
    
    TPVQueue.Init()     ! Read the current Previewer Queue
    
    TSaveAs.Init()      ! Init the Save As, PDF, TEXT, HTML, PNG, XML
       
    TPrinter.Init()     ! Init Printer List & Default Printer
    
    GlobalResponse = ThisWindow.Run()
            
    TPrinter.Done()    
    Tzoom.Done()
    TSaveAs.Done()    
    TPVQueue.Done()    
    ToPrint.Done()
    
    RETURN(GSV:Response)
! -------------------------------------------------------------------------------------------------

! -------------------------------------------------------------------------------------------------
! ThisWindow.Ask()
! -------------------------------------------------------------------------------------------------
ThisWindow.Ask      procedure()
    CODE
    PARENT.Ask

! -------------------------------------------------------------------------------------------------
! ThisWindow.ChangeAction()
! -------------------------------------------------------------------------------------------------
ThisWindow.ChangeAction     procedure()
ReturnValue     byte,auto
    CODE
    ReturnValue = parent.ChangeAction()
    return ReturnValue

! -------------------------------------------------------------------------------------------------
! ThisWindow.OnCloseEventCancelled()
! -------------------------------------------------------------------------------------------------
ThisWindow.OnCloseEventCancelled    procedure()
    CODE
    parent.OnCloseEventCancelled
    
! -------------------------------------------------------------------------------------------------
! ThisWindow.Reset( BYTE Force=0 )
! -------------------------------------------------------------------------------------------------
ThisWindow.Reset    procedure(BYTE Force=0)
    code
    self.ForcedReset += Force
    if PreviewWindow{Prop:AcceptAll}
        return
    end !* if *
    parent.Reset(Force)

! -------------------------------------------------------------------------------------------------
! ThisWindow.Update()
! -------------------------------------------------------------------------------------------------
ThisWindow.Update       procedure()
    code
    WD.CurrentPage = Tpre.GetCurrentPage()
    parent.Update()

! -------------------------------------------------------------------------------------------------
! ThisWindow.SetAlerts()
! -------------------------------------------------------------------------------------------------
ThisWindow.SetAlerts    procedure()
    code
    parent.SetAlerts

! -------------------------------------------------------------------------------------------------
! ThisWindow.TakeAccepted()
! -------------------------------------------------------------------------------------------------
ThisWindow.TakeAccepted procedure()
ReturnValue     BYTE,AUTO
Looped          BYTE
    code
    loop
        if Looped
            return Level:Notify
        else
            Looped = 1
        end !* if *
        case Accepted()
        OF ?PrintAllButton
        OF ?PrintOneButton
        OF ?CancelButton
        OF ?JumpFirstButton
        OF ?JumpPrevButton
        OF ?JumpNextButton
        OF ?JumpLastButton
        OF ?WD:CurrentPage
        OF ?WD:ShowPageList
        OF ?ZoomInButton
        OF ?ZoomOutButton
        OF ?ZoomToPageWidth
        OF ?ZoomToPageHeight
        OF ?Zoom100Percent
        OF ?WD:SearchString
        OF ?SearchButton
        OF ?TogglePrintButton
        OF ?ListPages
        OF ?BorderRegion
        END
        ReturnValue = parent.TakeAccepted()
        
        case Accepted()
        OF ?PrintAllButton
            ThisWindow.Update()
            ToPrint.ToPrinter( true )
        OF ?PrintOneButton
            ThisWindow.Update()
            ToPrint.ToPrinter( false )
        OF ?CancelButton
            ThisWindow.Update()
            GSV:Response = False
            Post(EVENT:CloseWindow)
        OF ?JumpFirstButton
            ThisWindow.Update()
            Tpre.JumpFirstPage()
        OF ?JumpPrevButton
            ThisWindow.Update()
            Tpre.JumpPreviousPage()
        OF ?JumpNextButton
            ThisWindow.Update()
            Tpre.JumpNextPage()
        OF ?JumpLastButton
            ThisWindow.Update()
            Tpre.JumpLastPage()
        OF ?WD:CurrentPage
            Tpre.DrawPage()
        OF ?WD:ShowPageList
            TPageList.Draw()
            Tpre.DrawPage()
        OF ?ZoomInButton
            ThisWindow.Update()
            Tzoom.ZoomIn()
            Tpre.DrawPage()
        OF ?ZoomOutButton
            ThisWindow.Update()
            Tzoom.ZoomOut()
            Tpre.DrawPage()
        OF ?ZoomToPageWidth
            ThisWindow.Update()
            Tzoom.ZoomPageWidth()
            Tpre.DrawPage()
        OF ?ZoomToPageHeight
            ThisWindow.Update()
            Tzoom.ZoomPageHeight()
            Tpre.DrawPage()
        OF ?Zoom100Percent
            ThisWindow.Update()
            Tzoom.Zoom100()
            Tpre.DrawPage()
        OF ?WD:SearchString
            Post(EVENT:Accepted,?SearchButton)
        OF ?SearchButton
            ThisWindow.Update()            
            IF Tpre.SearchText( WD:SearchString )
                Tpre.FindFirst()
                Tpre.DrawPage()
            END !* IF *             
        OF ?SearchPrev
            Tpre.FindPrev()
            Tpre.DrawPage()
        OF ?SearchNext
            Tpre.FindNext()
            Tpre.DrawPage()             
        OF ?TagAllPages
            ThisWindow.Update()
            Tpre.TagAllPages()
            Tpre.DrawPage()    
        OF ?TagPagesFound
            ThisWindow.Update()
            Tpre.TagPagesFound()
            Tpre.DrawPage()
        OF ?SearchReset
            ThisWindow.Update()
            Tpre.SearchReset()
            Tpre.DrawPage()
        OF ?TogglePrintButton
            ThisWindow.Update()
            Tpre.GetCurrentPageFromQueue()
            PageQueue.PrintPage = Choose(PageQueue.PrintPage=False,True,False)
            PageQueue.PrintIcon = PageQueue.PrintPage + 1
            Put(PageQueue)
            TPButton.Draw()
        OF ?ListZoom
            ThisWindow.Update()
            if choice( ?ListZoom )
                TZoom.SetState( choice( ?ListZoom ) )
                Tpre.DrawPage()
            end !* if *
        OF ?ListPrinters
            ThisWindow.Update()
            if choice( ?ListPrinters )
                get( QPrinters, choice( ?ListPrinters ) )
                if TPrinter.SearchAndSet( QPrinters.PrinterName  )
                    ! Se supone que debería funcionar
                end !* end *
            end !* if *
        OF ?ListPages
            TPageList.GetPage()
            Tpre.SetCurrentPage( PageQueue.PageNumber )
            Tpre.DrawPage()
        OF ?SaveAsPDF
            TSaveAs.Run( 'PDF' )
        OF ?SaveAsText
            TSaveAs.Run( 'TEXT' )
        OF ?SaveAsHTML
            TSaveAs.Run( 'HTML' )
        OF ?SaveAsXML
            TSaveAs.Run( 'XML' )
        OF ?SaveAsPNG
            TSaveAs.Run( 'PNG' )
        OF ?SaveAsXLS
            TSaveAs.Run( 'XLS' )
        END !* CASE *
        
        RETURN ReturnValue
    END !* LOOP *
    
    ReturnValue = Level:Fatal
    
    RETURN ReturnValue
    
! -------------------------------------------------------------------------------------------------
! ThisWindow.TakeCloseEvent()
! -------------------------------------------------------------------------------------------------
ThisWindow.TakeCloseEvent PROCEDURE
ReturnValue          BYTE,AUTO
    CODE
    ReturnValue = PARENT.TakeCloseEvent()
    RETURN ReturnValue

! -------------------------------------------------------------------------------------------------
! ThisWindow.TakeDisableButton( SIGNED Control, BYTE MakeDisable )
! -------------------------------------------------------------------------------------------------
ThisWindow.TakeDisableButton    procedure( SIGNED Control,BYTE MakeDisable )
    CODE
    PARENT.TakeDisableButton(Control,MakeDisable)

! -------------------------------------------------------------------------------------------------
! ThisWindow.TakeEvent()
! -------------------------------------------------------------------------------------------------
ThisWindow.TakeEvent    procedure()
ReturnValue             BYTE,AUTO
Looped                  BYTE
    CODE
    LOOP                                                     ! This method receives all events
        IF Looped
            RETURN Level:Notify
        ELSE
            Looped = 1
        END
        ReturnValue = PARENT.TakeEvent()
        RETURN ReturnValue
    END
    
    ReturnValue = Level:Fatal
    RETURN ReturnValue
    
! -------------------------------------------------------------------------------------------------
! ThisWindow.TakeFieldEvent()
! -------------------------------------------------------------------------------------------------
ThisWindow.TakeFieldEvent       procedure()
ReturnValue         BYTE,AUTO
Looped              BYTE
    CODE
    LOOP                                                     ! This method receives all field specific events
        IF Looped
            RETURN Level:Notify
        ELSE
            Looped = 1
        END
        CASE FIELD()
            OF ?ActionGroup
            OF ?PrintAllButton
                CASE EVENT()
                OF EVENT:Selecting
                END
            OF ?PrintOneButton
                CASE EVENT()
                OF EVENT:Selecting
                END
          OF ?CancelButton
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?NavigationGroup
          OF ?JumpFirstButton
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?JumpPrevButton
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?JumpNextButton
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?JumpLastButton
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?WD:CurrentPage
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?OfString
          OF ?WD:ShowPageList
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?ZoomGroup
          OF ?ZoomInButton
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?ZoomOutButton
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?ZoomToPageWidth
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?ZoomToPageHeight
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?Zoom100Percent
            CASE EVENT()
            OF EVENT:Selecting
            END
          !OF ?PagesToPrintGroup
          OF ?SearchGroup
          OF ?WD:SearchString
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?SearchButton
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?WD:Percent
          OF ?TogglePrintButton
            CASE EVENT()
            OF EVENT:Selecting
            END
          OF ?BorderBox
          OF ?PageImage
          OF ?ListPages
            CASE EVENT()
            OF EVENT:Selecting
            OF EVENT:AlertKey
            OF EVENT:PreAlertKey
            END
          OF ?BorderRegion
            CASE EVENT()
            OF EVENT:MouseUp
            OF EVENT:MouseIn
            OF EVENT:MouseOut
            OF EVENT:MouseMove
            END
          OF ?ListboxPanel
        END
          
        ReturnValue = PARENT.TakeFieldEvent()

        CASE FIELD()
        OF ?ListPages
            CASE EVENT()
                OF EVENT:AlertKey
                    If KeyCode() = MouseLeft2
                        TPageList.GetPage()
                        PageQueue.PrintPage = Choose( PageQueue.PrintPage=True,False,True )
                        PageQueue.PrintIcon = PageQueue.PrintPage+1
                        Put(PageQueue)                        
                        TPButton.Draw()
                    End
                    If KeyCode() = CtrlHome
                        Post( Event:Accepted, ?JumpFirstButton )
                    End
                    If KeyCode() = CtrlEnd
                        Post( Event:Accepted, ?JumpLastButton )
                    End
            END
        OF ?BorderRegion
            IF Event() = EVENT:AlertKey
                IF KeyCode() = MouseLeft or KeyCode() = MouseRight
                    IF Inrange(MouseX(),0,GSV:ClientAreaWidth) And Inrange(MouseY(),0,GSV:ClientAreaHeight)
                        IF TPButton.MouseOnArea()
                            Tzoom.SetZoomOff()
                        ELSIF WD.ShowPageList and TPageList.MouseOnArea()
                            Tzoom.SetZoomOff()
                        ELSE
                            Tzoom.SetZoomOn()
                        END !* if *
                    ELSE
                        TZoom.SetZoomOff()
                    END !* IF *
                    IF Tzoom.IsZoom()
                        Case KeyCode()
                            OF MouseRight
                                Tzoom.ZoomIn()
                                Tpre.DrawPage()
                            OF MouseLeft
                                Tzoom.ZoomOut() 
                                Tpre.DrawPage()
                        END !* CASE *
                    END !* IF *
                END !* IF *
            END !* IF *
        END !* CASE *
        RETURN ReturnValue
    END !* IF *  
    ReturnValue = Level:Fatal
    
    RETURN ReturnValue

! -------------------------------------------------------------------------------------------------
! ThisWindow.TakeWindowEvent()
! -------------------------------------------------------------------------------------------------
ThisWindow.TakeWindowEvent      procedure()
ReturnValue         BYTE,AUTO
Looped              BYTE
    CODE
    LOOP                                                     ! This method receives all window specific events
        IF Looped
            RETURN Level:Notify
        ELSE
            Looped = 1
        END

        CASE EVENT()
        OF EVENT:AlertKey
        OF EVENT:CloseDown
        OF EVENT:CloseWindow
        OF EVENT:Completed
        OF EVENT:DoResize
        OF EVENT:GainFocus
        OF EVENT:Iconize
        OF EVENT:Iconized
        OF EVENT:LoseFocus
        OF EVENT:Maximize
        OF EVENT:Maximized
        OF EVENT:Move
        OF EVENT:Moved
        OF EVENT:Notify
        OF EVENT:OpenWindow
        OF EVENT:PreAlertKey
        OF EVENT:Restore
        OF EVENT:Restored
        OF EVENT:Size
        OF EVENT:Sized
        END
        ReturnValue = PARENT.TakeWindowEvent()

        CASE EVENT()
        OF EVENT:AlertKey
            CASE KeyCode()
                OF PgUpKey
                    Tpre.ScrollUpPage()
                OF PgDnKey
                    Tpre.ScrollDownPage()
            END
        OF EVENT:Sized
            Post(GS_EVENT:Sized)
        END

        If Event() = GS_EVENT:Sized
            PreviewWindow{ PROP:Pixels } = true
            GetClientArea()
            PreviewWindow{ PROP:Pixels } = false
            
            TPageList.GetArea()
            Tpre.DrawPage()
        END
        
        RETURN ReturnValue
    END !* loop *
    
    ReturnValue = Level:Fatal
    RETURN ReturnValue

! -------------------------------------------------------------------------------------------------
! ThisWindow.TakeNewSelection()
! -------------------------------------------------------------------------------------------------
ThisWindow.TakeNewSelection     procedure()
ReturnValue         BYTE,AUTO
Looped              BYTE
    CODE
    LOOP                                                     ! This method receives all NewSelection events
        IF Looped
            RETURN Level:Notify
        ELSE
            Looped = 1
        END
        CASE FIELD()
        OF ?WD:CurrentPage
        OF ?ListPages
        END
        
        ReturnValue = PARENT.TakeNewSelection()
        
        CASE FIELD()
            OF ?WD:CurrentPage
                Tpre.DrawPage()
            OF ?ListZoom

            OF ?ListPages
                TPageList.GetPage()
                Tpre.SetCurrentPage( PageQueue.PageNumber )
                Tpre.DrawPage()
        END
        RETURN ReturnValue
    END
  
    ReturnValue = Level:Fatal
    RETURN ReturnValue

! -------------------------------------------------------------------------------------------------
! ThisWindow.Init()
! -------------------------------------------------------------------------------------------------
ThisWindow.Init     procedure()
ReturnValue         BYTE,AUTO
    CODE
    GlobalErrors.SetProcedureName('GSPreviewer')
  
    IF not records(pImageQueue)
        Return(LEVEL:Fatal)
    END !* END *
  
    SELF.Request = GlobalRequest
    CLEAR(GlobalRequest)
    CLEAR(GlobalResponse)

    ReturnValue = PARENT.Init()
    IF ReturnValue THEN RETURN ReturnValue END
    SELF.FirstField = ?TogglePrintButton
    SELF.VCRRequest &= VCRRequest
    SELF.Errors &= GlobalErrors
    SELF.AddItem(Toolbar)
       
    self.Open( PreviewWindow )
    
    TPButton.Init( ?TogglePrintButton ) 
    TPButton.GetArea()    

    TPrinter.GetPrinterList( QPrinters )
    TPrinter.SetList( ?ListPrinters )
    TPrinter.SelectDefaultPrinter()

    WD.ShowPageList = pStartPageList
    IF pWindowCaption
        PreviewWindow{ Prop:Text } = Clip(pWindowCaption)
    END
    IF pMaximize
        PreviewWindow{Prop:Maximize} = True
    END 

    SELF.SetAlerts()

    Tpre.Init( PreviewWindow )
    TImage.Init( Tpre.GetCurrentImage() )
    
    TPVQueue.RenameMetaFiles()

    GSV:BorderFEQ                   = ?BorderBox
    GSV:ImageFEQ                    = ?PageImage
    GSV:RegionFEQ                   = ?BorderRegion
    !GSV:BorderFEQ {PROP:Color}    = COLOR:Gray
    GSV:BorderFEQ {PROP:Fill}       = COLOR:White
    GSV:ImageFEQ  {PROP:Color}      = COLOR:White
    GSV:ImageFEQ  {PROP:Text}       = PageQueue.WmfFile

    GSV:ImageFEQ  {Prop:Hide}       = false
    GSV:BorderFEQ {Prop:Hide}       = false
    
    GSV:ImageFEQ{ Prop:Scroll }     = true

    PreviewWindow{ Prop:Pixels }    = true
    GetClientArea()
    PreviewWindow{ Prop:Pixels }    = false                

    TPageList.Init( ?ListPages, ?ListboxPanel )
    ?ListPages{ PROPLIST:DefHdrTextColor } = COLOR:Black
    ?ListPages{ PROPLIST:DefHdrBackColor } = COLOR:LightGray

    GSV:RegionFEQ {Prop:Alrt,255} = MouseLeft
    GSV:RegionFEQ {Prop:Alrt,255} = MouseRight

    GSV:RegionFEQ {Prop:BevelOuter} = 0
    GSV:RegionFEQ {Prop:BevelInner} = 0

    Tzoom.Init()
    Tzoom.LoadQueue( QZoom )
    Tzoom.SetList( ?ListZoom )
    Tzoom.SetPageHeight( TImage.GetHeight() )
    Tzoom.SetPageWidth( TImage.GetWidth() )
    Tzoom.SetClientHeight( GSV:ClientAreaHeight )
    Tzoom.SetClientWidth( GSV:ClientAreaWidth )
    Tzoom.SetZoomByValue( pZoom )
    
    TSaveAs.SetButtons()
    
    Tpre.DrawPage()    
     
    return ReturnValue

! -------------------------------------------------------------------------------------------------
! ThisWindow.Run()
! -------------------------------------------------------------------------------------------------
ThisWindow.Run      procedure()
ReturnValue         BYTE,AUTO
    code
    ReturnValue = parent.Run()
    return ReturnValue

! -------------------------------------------------------------------------------------------------
! ThisWindow.Kill()
! -------------------------------------------------------------------------------------------------
ThisWindow.Kill     procedure()
ReturnValue         BYTE,AUTO
    code
    TPButton.Done()
       
    ReturnValue = parent.Kill()

    GlobalErrors.SetProcedureName()
    
    TPVQueue.RemoveMetaFiles()
    
    TPre.Done()
       
    RETURN ReturnValue

! -------------------------------------------------------------------------------------------------
! GetFileSize( *cstring _fname ),long
! -------------------------------------------------------------------------------------------------
GetFileSize     procedure( *cstring _fname )!,long
DQ              queue(FILE:Queue),pre(DQ)
                end
iSize           long                
    CODE
    iSize = 0
    Directory( DQ, Clip(_fname), ff_:Normal )
    if records( DQ ) > 0
        iSize = DQ.Size
    end
    Free(DQ)
    return iSize

! -------------------------------------------------------------------------------------------------
! GetReportImageSize( *cstring _fname, *long _width, *long _height )
! -------------------------------------------------------------------------------------------------
GetReportImageSize      procedure( *cstring _fname, *long _width, *long _height )
W         window
          end
TempImage long
    code
    Open(W)
    
    TempImage             = Create(0, CREATE:Image)
    TempImage {PROP:Text} = _fname
    0{PROP:Thous} = TRUE
    _width  = TempImage{ PROP:Width  }
    _height = TempImage{ PROP:Height }
    0{PROP:Thous} = FALSE
    Destroy(TempImage)
        
    Close(W)
    
! -------------------------------------------------------------------------------------------------
! GetClientArea()
! -------------------------------------------------------------------------------------------------
GetClientArea   procedure()
cH              long
    code    
    cH = Create( 0, CREATE:Region )
    cH {Prop:Xpos} = 0
    cH {Prop:Ypos} = 0
    cH {Prop:Full} = True
    
    GSV:ClientAreaWidth  = cH{Prop:Width}
    GSV:ClientAreaHeight = cH{Prop:Height}   
    
    Destroy(cH)

! -------------------------------------------------------------------------------------------------
! DeleteFile( *cstring _fname )
! -------------------------------------------------------------------------------------------------
DeleteFile              procedure( *cstring _fname )
MX_DELETION_ATTEMPTS    EQUATE(5)       ! Define the maximum number of deletion attempts
INVALID_FILE_ATTRIBUTES EQUATE(-1)      ! Define invalid file attributes
rc        long                          ! Declare a long variable for the return code
error     long                          ! Declare a long variable for the error code
cnt       long                          ! Declare a long variable for the attempt counter
    code
    rc = API_DeleteFile( _fname )

! -------------------------------------------------------------------------------------------------
! TPreViewerClass.IncPage()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.IncPage    procedure()
    code
    self.SetCurrentPage( self.CurrentPage + 1 )
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.DecPage()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.DecPage    procedure()
    code
    self.SetCurrentPage( self.CurrentPage - 1 )
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.JumpFirstPage()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.JumpFirstPage  procedure()
    code
    self.SetCurrentPage( 1 )
    self.DrawPage()
    self.WindowCtrl{Prop:VScrollPos} = 0

! -------------------------------------------------------------------------------------------------
! TPreViewerClass.JumpLastPage()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.JumpLastPage   procedure()
    code
    self.SetCurrentPage( self.TotalPages )
    self.DrawPage()
    self.WindowCtrl{Prop:VScrollPos} = 255
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.JumpNextPage()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.JumpNextPage   procedure()
    code
    if self.CurrentPage < self.TotalPages
        self.IncPage()
        self.DrawPage()
    end
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.JumpPreviousPage()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.JumpPreviousPage   procedure()
    code
    if self.CurrentPage > 1
        self.DecPage()
        self.DrawPage()
    end !* if *

! -------------------------------------------------------------------------------------------------
! TPreViewerClass.ScrollUpPage()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.ScrollUpPage   procedure()
    code
    if self.CurrentPage > 1
        if GSV:ClientAreaWidth < (TImage.GetHeight() * (Tzoom.GetValue()/100))
            if self.WindowCtrl{Prop:VScrollPos} > 0
                self.WindowCtrl{Prop:VScrollPos} = 0
            else
                self.DecPage()                
                self.DrawPage()
                self.WindowCtrl{Prop:VScrollPos} = 255
            end !* if *
        else
            self.DecPage()
            self.DrawPage()
        end !* if *
    else
        self.WindowCtrl{Prop:VScrollPos} = 0
    end !* IF *

! -------------------------------------------------------------------------------------------------
! TPreViewerClass.ScrollDownPage()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.ScrollDownPage     procedure()
    code
    if self.CurrentPage < self.TotalPages
        if GSV:ClientAreaWidth < (TImage.GetHeight() * (Tzoom.GetValue()/100))
            if self.WindowCtrl{Prop:VScrollPos} < 255
                self.WindowCtrl{Prop:VScrollPos} = 255
            else
                self.IncPage()
                self.DrawPage()
                self.WindowCtrl{Prop:VScrollPos} = 0
            end !* if *
        ELSE
            self.IncPage()
            self.DrawPage()
        END !* IF *
    ELSE
        self.WindowCtrl{Prop:VScrollPos} = 255
    END !* IF *

! -------------------------------------------------------------------------------------------------
! TPreViewerClass.ScrollUpabit()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.ScrollUpabit       procedure()
NewVSP      LONG
    CODE
    NewVSP = self.WindowCtrl{Prop:VScrollPos} - 50  !!50
    If self.CurrentPage > 1
        !If GSV:ClientAreaWidth < (GSV:ImageHeight * (Tzoom.GetValue()/100))
        If GSV:ClientAreaHeight < (TImage.GetHeight() * (Tzoom.GetValue()/100))
            If NewVSP > 0
                self.WindowCtrl{Prop:VScrollPos} = NewVSP
            Else
                self.DecPage()
                self.DrawPage()
                self.WindowCtrl{Prop:VScrollPos} = 255
            End
        Else
            self.DecPage()
            self.DrawPage()
        End
    Else
        self.WindowCtrl{Prop:VScrollPos} = 0
    End

! -------------------------------------------------------------------------------------------------
! TPreViewerClass.ScrollDownabit()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.ScrollDownabit     procedure()
NewVSP      LONG
    CODE
    NewVSP = self.WindowCtrl{Prop:VScrollPos} + 50  !!50
    if self.CurrentPage < self.TotalPages
        !If GSV:ClientAreaWidth < (GSV:ImageHeight * (Tzoom.GetValue()/100))
        if GSV:ClientAreaHeight < (TImage.GetHeight() * (Tzoom.GetValue()/100))
            if NewVSP < 255
                self.WindowCtrl{Prop:VScrollPos} = NewVSP
            else
                self.IncPage()
                self.DrawPage()
                self.WindowCtrl{Prop:VScrollPos} = 0
            end
        else
            self.IncPage()
            self.DrawPage()
        end
    else
        self.WindowCtrl{Prop:VScrollPos} = 255
    end

! -------------------------------------------------------------------------------------------------
! TPreViewerClass.DrawPage()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.DrawPage    procedure()
cX                  Long
xY                  Long
wW                  Long
wH                  Long
X                   Long
caW                 Long
lbW                 Long

CurrXpos            Long
CurrYpos            Long
CurrWidth           Long
CurrHeight          long
    code
    ! -------------------------------------------------------------------------
    ! CALC Client Area Height & Width
    ! -------------------------------------------------------------------------
    self.WindowCtrl{Prop:Pixels} = True
    lbW = ?ListboxPanel{Prop:Width}
    self.WindowCtrl{Prop:Pixels} = False

    IF WD.ShowPageList
        caW = GSV:ClientAreaWidth - lbW
    ELSE
        caW = GSV:ClientAreaWidth
    END !* IF *    
    Tzoom.SetClientHeight( GSV:ClientAreaHeight )
    Tzoom.SetClientWidth( caW )
    ! -------------------------------------------------------------------------
    self.WindowCtrl{ Prop:Pixels } = True

    self.GetCurrentPageFromQueue()
    GSV:ImageFEQ{ PROP:Text } = PageQueue.WmfFile

    CurrWidth  = TImage.GetWidth()  * (TZoom.GetValue()/100)
    CurrHeight = TImage.GetHeight() * (Tzoom.GetValue()/100)

    IF WD.ShowPageList
        ! Windows "client" area is now smaller
        cX = ((GSV:ClientAreaWidth - ?ListboxPanel{Prop:Width})/2) - ( CurrWidth / 2 )
        cX = cX + ?ListboxPanel{Prop:Width}
        X  = ?ListboxPanel{Prop:Xpos} + ?ListboxPanel{Prop:Width}
    ELSE
        cX = (GSV:ClientAreaWidth/2) - ( CurrWidth / 2 )
        X = 0
    END !* IF *

    CurrXpos = Choose( cX <= X, X, cX )
    SetPosition( GSV:BorderFEQ,  CurrXpos,   CurrYpos,   CurrWidth,  CurrHeight )
    SetPosition( GSV:ImageFEQ,   CurrXpos,   CurrYpos,   CurrWidth,  CurrHeight )
    SetPosition( GSV:RegionFEQ,  CurrXpos,   CurrYpos,   CurrWidth,  CurrHeight )
    TPButton.Draw()
    self.WindowCtrl{ Prop:StatusText, 2 } = 'Zoom: ' & Tzoom.GetValue() & '%'
    Display()
    
    self.WindowCtrl{Prop:Pixels} = False
    IF WD.ShowPageList
        TPageList.GetArea()
        TPageList.Draw()
    END !* end *

! -------------------------------------------------------------------------------------------------
! TPreViewerClass.GetTotalPages()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.GetTotalPages       procedure()
    code
    return self.TotalPages
    

! -------------------------------------------------------------------------------------------------
! TPreViewerClass.GetCurrentPageFromQueue()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.GetCurrentPageFromQueue    procedure()
    code
    get( PageQueue, self.CurrentPage )
    
! -------------------------------------------------------------------------------------------------  
! TPreViewerClass.GetCurrentImage(),*cstring
! -------------------------------------------------------------------------------------------------
TPreViewerClass.GetCurrentImage         procedure()
    code
    self.GetCurrentPageFromQueue()
    return PageQueue.WmfFile
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.GetCurrentPage(),long
! -------------------------------------------------------------------------------------------------
TPreViewerClass.GetCurrentPage     procedure()!,long
    code
    return self.CurrentPage
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.SetCurrentPage( long _page )
! -------------------------------------------------------------------------------------------------
TPreViewerClass.SetCurrentPage     procedure( long _page )
    code
    self.CurrentPage = _page
    WD.CurrentPage = self.CurrentPage
    display( ?WD:CurrentPage )
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.SearchText( *cstring _search_text ),long
! -------------------------------------------------------------------------------------------------
TPreViewerClass.SearchText  procedure( *cstring _search_text )!,long
SearchWMF               FILE,DRIVER('DOS','/FILEBUFFERS=10'),PRE(WMF),CREATE
Record                      RECORD
SBuffer                         STRING(4096)
                            END !* RECORD *
                        END !* FILE *
Ps                      cstring(21)
L                       Long
Tpercent                TPercentClass
SearchText              cstring(1000)
i                       long
is_add                  long
    code
    is_add = FALSE
    self.found = 0
    self.FindIndex = 0
   
    SearchText = clip(_search_text)
    L = len(SearchText)
    if L >= 2
        if SearchText[1] = '+'
            SearchText = sub( SearchText, 2, L )
            L = len(SearchText)
            is_add = TRUE
        end !* if *            
    
        Tpercent.Init( ?WD:Percent, self.TotalPages )
        loop while Tpercent.Next( i )
            GET( PageQueue, i )
            
            if is_add and PageQueue.Found = TRUE
                cycle
            else
                PageQueue.Found = FALSE
                PageQueue.PrintPage = FALSE
                SearchWMF{ prop:name } = Clip(PageQueue.WmfFile)
                Open(SearchWMF)
                if ErrorCode()
                    cycle
                end !* end *
                Tpercent.Update()
                
                Set(SearchWMF)
                loop 
                    Next(SearchWMF)
                    if ErrorCode()
                        break
                    elsif InString( Upper(SearchText), Upper(WMF:SBuffer), 1, 1 ) > 0
                        PageQueue.Found = TRUE
                        PageQueue.PrintPage = TRUE
                        self.found = self.found + 1
                        break
                    end !* IF *     
                end !* LOOP *
                Close(SearchWMF)
                
                PageQueue.PrintIcon = PageQueue.PrintPage + 1
                PUT( PageQueue )
            end !* if *                
        end !* LOOP *
        Tpercent.Done()
    end !* IF *
    
    if self.found > 0
        self.WindowCtrl{Prop:StatusText,1} = 'Encontradas ' & self.found & ' páginas conteniendo "' & SearchText & '".'
    else
        self.WindowCtrl{Prop:StatusText,1} = '"' & SearchText & '"' & ' no fue encontrado.'
    end !* if *
    
    return self.found
      
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.FindFirst()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.FindFirst    procedure()
i               long
    code
    self.FindIndex = 0
    loop i = 1 to self.TotalPages
        get( PageQueue, i )
        if PageQueue.Found
            self.SetCurrentPage( PageQueue.PageNumber )
            self.FindIndex = i
            break
        end !* if *
    end !* if *        
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.FindNext()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.FindNext     procedure()
i               long
    code
    loop i = self.FindIndex+1 to self.TotalPages
        get( PageQueue, i )
        if PageQueue.Found
            self.SetCurrentPage( PageQueue.PageNumber )
            self.FindIndex = i 
            break
        end !* if *
    end !* if *        
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.FindPrev()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.FindPrev     procedure()
i               long
    code
    loop i = self.FindIndex-1 to 1 by -1
        get( PageQueue, i )
        if PageQueue.Found
            self.SetCurrentPage( PageQueue.PageNumber )
            self.FindIndex = i
            break
        end !* if *
    end !* if *        
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.GetFound(),long
! -------------------------------------------------------------------------------------------------
TPreViewerClass.GetFound    procedure()!,long
    code
    return self.found
       
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.TagAllPages()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.TagAllPages     procedure()
i           long
    code
    loop i = 1 to self.TotalPages
        get( PageQueue, i )
        PageQueue.PrintPage = true
        PageQueue.PrintIcon = PageQueue.PrintPage + 1
        put( PageQueue )
    end !* loop *
        
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.TagPagesFound()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.TagPagesFound     procedure()
i           long
    code
    loop i = 1 to self.TotalPages
        get( PageQueue, i )
        PageQueue.PrintPage = PageQueue.Found
        PageQueue.PrintIcon = PageQueue.PrintPage + 1
        put( PageQueue )
    end !* loop *
        
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.SearchReset()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.SearchReset   procedure()
i           long
    code
    loop i = 1 to self.TotalPages
        get( PageQueue, i )
        PageQueue.PrintPage = true
        PageQueue.PrintIcon = PageQueue.PrintPage + 1
        PageQueue.Found = false
        put( PageQueue )
    end !* loop *
    WD:SearchString = ''
    self.WindowCtrl{ Prop:StatusText, 1 } = ''
    display( ?WD:SearchString )
        
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.Init( *window _window )
! -------------------------------------------------------------------------------------------------
TPreViewerClass.Init   procedure( *window _window )
i           long
    code   
    self.WindowCtrl &= _window    
    self.TotalPages = records( PageQueue )    
    loop i = 1 to self.TotalPages
        get( PageQueue, i )
        self.TotalFileSize = self.TotalFileSize + PageQueue.PageSize
    end !* loop *    
    self.SetCurrentPage( 1 )   
    
    ?WD:CurrentPage{ Prop:RangeLow } = 1
    IF self.TotalPages > 1
        ?WD:CurrentPage{ Prop:RangeHigh } = self.TotalPages
        ?WD:CurrentPage{ Prop:Disable   } = False
    ELSE 
        ?WD:CurrentPage {Prop:Disable} = True
    END !* end *
    
    self.WindowCtrl{ Prop:StatusText, 3 } = |
            '  ' & self.TotalPages & ' páginas, ' & |
            format( self.TotalFileSize / 1024, @n8.1 ) & 'Kb'
            
    ?OfString{ Prop:Text } = ' / ' & Left( Format( self.GetTotalPages(), @n_6 ))    
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.Run(),long
! -------------------------------------------------------------------------------------------------
TPreViewerClass.Run    procedure()
is_run      long
    code
    is_run = true
    
    return is_run
    
! -------------------------------------------------------------------------------------------------
! TPreViewerClass.Done()
! -------------------------------------------------------------------------------------------------
TPreViewerClass.Done       procedure()
    code    
    
! -------------------------------------------------------------------------------------------------
! TToPrintClass.ToPrinter( long AllPages )
! -------------------------------------------------------------------------------------------------
TToPrintClass.ToPrinter    procedure( long AllPages )
QPreV           queue(PreviewQueue)
                end 
MyReport        REPORT,AT(0,0),PRE(MyR),THOUS
MyDetail            DETAIL,AT(,,,),USE(?MyDetail)
                        IMAGE,AT(0,0),USE(?MyReportImage)
                    END !* detail *
                END !* report *
iCopies			SHORT
Total           long
S               cstring(1000)
i 				LONG
    code
    Open(MyReport)
    MyReport{PROP:THOUS}      = TRUE
    MyReport{PROP:Text}       = self.ReportJobName
    MyReport{Prop:Landscape}  = self.Landscape
    MyReport{PropPrint:Paper} = self.Paper
   
    Tpre.GetCurrentPageFromQueue()
    GetReportImageSize( PageQueue.WmfFile, self.ReportWidth, self.ReportHeight )
    MyReport{PROP:Width}      = self.ReportWidth
    MyReport{PROP:Height}     = self.ReportHeight

    TPVQueue.RestoreMetaFiles()

    TWait.Init('PRINTING')     
    IF AllPages    
        LOOP iCopies = 1 TO self.CopiesToPrint
            total = Tpre.GetTotalPages()
            loop i = 1 TO total
                get( PageQueue, I )
                IF PageQueue.PrintPage
                    MyReport$?MyReportImage{PROP:Text  } = PageQueue.WmfFile
                    MyReport$?MyReportImage{PROP:Width } = self.ReportWidth
                    MyReport$?MyReportImage{PROP:Height} = self.ReportHeight
                    Print( MyR:MyDetail )
                END !* if *
                if (i % 50) = 0 then 
                    Twait.Update( i & ' / ' & total )
                end !* if *
            END !* loop *
        END !* loop *
    ELSE
        Tpre.GetCurrentPageFromQueue()
        IF NOT ERRORCODE()
            MyReport$?MyReportImage{ PROP:Text } = PageQueue.WmfFile
            LOOP iCopies = 1 TO self.CopiesToPrint
                MyReport$?MyReportImage{ PROP:Width  } = SELF.ReportWidth
                MyReport$?MyReportImage{ PROP:Height } = SELF.ReportHeight
                Print( MyR:MyDetail )
            END !* loop *
        END !* if *
    END !* if *
    MyReport{PROP:THOUS} = FALSE
    TWait.Done()
       
    TWait.Init('CLOSE')
    Close( MyReport )
    TWait.Done()
    
    TPVQueue.RestoreMetaFiles()
    
    PRINTER{ PROPPRINT:FromPage } = -1
    PRINTER{ PROPPRINT:ToPage   } = -1   

! -------------------------------------------------------------------------------------------------
! TToPrintClass.Init()
! -------------------------------------------------------------------------------------------------
TToPrintClass.Init      procedure()
ReportRef               &REPORT
    code
    ReportRef  &= 0                                     ! Reference to the original report.
    IF ReportRef{ Prop:Type } = CREATE:Report
        self.ReportJobName = ReportRef{Prop:Text}
        self.Landscape     = ReportRef{Prop:Landscape}
        self.Paper         = ReportRef{PropPrint:Paper}
    END !* if *    
    self.CopiesToPrint = 1
    self.ReportWidth   = 0
    self.ReportHeight  = 0 
    
! -------------------------------------------------------------------------------------------------
! TToPrintClass.Run(),long
! -------------------------------------------------------------------------------------------------
TToPrintClass.Run       procedure()
is_run      long
    code
    is_run = true 
    
    return is_run
       
! -------------------------------------------------------------------------------------------------
! TToPrintClass.Done()
! -------------------------------------------------------------------------------------------------
TToPrintClass.Done      procedure()
    code
      
! -------------------------------------------------------------------------------------------------
! TImageClass.GetWidth(),long
! -------------------------------------------------------------------------------------------------
TImageClass.GetWidth                procedure()!,long
    code
    return self.ImageWidth

! -------------------------------------------------------------------------------------------------
! TImageClass.GetHeight(),long
! -------------------------------------------------------------------------------------------------
TImageClass.GetHeight               procedure()!,long
    code
    return self.ImageHeight

! -------------------------------------------------------------------------------------------------
! TImageClass.GetAspect(),real
! -------------------------------------------------------------------------------------------------
TImageClass.GetAspect               procedure()!,real
    code
    return self.AspectRatio

! -------------------------------------------------------------------------------------------------
! TImageClass.Init( *cstring _fname )
! -------------------------------------------------------------------------------------------------
TImageClass.Init    procedure( *cstring _fname )
TempImage           long
    code
    PreviewWindow{ Prop:Pixels }= True
    
    TempImage               =   Create( 0, CREATE:Image )
    TempImage{ PROP:Text }  =   _fname
    self.ImageWidth         =   TempImage{PROP:Width}
    self.ImageHeight        =   TempImage{PROP:Height}
    Destroy(TempImage)
    
    PreviewWindow{ PROP:Pixels } = False
        
    self.AspectRatio = self.ImageHeight / self.ImageWidth
        
! -------------------------------------------------------------------------------------------------
! TImageClass.Run(),long
! -------------------------------------------------------------------------------------------------
TImageClass.Run         procedure()!,long
is_run     long
    code
    is_run = true
    
    return is_run
    
! -------------------------------------------------------------------------------------------------
! TImageClass.Done()
! -------------------------------------------------------------------------------------------------

TImageClass.Done            procedure()
    code
      
! -------------------------------------------------------------------------------------------------
! TPButtonClass.GetArea()
! -------------------------------------------------------------------------------------------------
TPButtonClass.GetArea       procedure()
pbX     Long
pbY     Long
pbW     Long
pbH     Long
    code
    PreviewWindow{ Prop:Pixels } = true
    GetPosition( self.btnCtrl, pbX, pbY, pbW, pbH )
    self.Xrange[1] = pbX
    self.Xrange[2] = pbX + pbW
    self.Yrange[1] = pbY
    self.Yrange[2] = pbY + pbW
    PreviewWindow{ Prop:Pixels } = False    
    
! -------------------------------------------------------------------------------------------------
! TPButtonClass.MouseOnArea()
! -------------------------------------------------------------------------------------------------
TPButtonClass.MouseOnArea   procedure()
is_onarea       long
    code
    is_onarea = false
    if  InRange( MouseX(), self.Xrange[1], self.Xrange[2] ) and |
        InRange( MouseY(), self.Yrange[1], self.Yrange[2] ) 
        is_onarea = true        
    end !* if *        
    
    return is_onarea    

! -------------------------------------------------------------------------------------------------
! TPButtonClass.SetHide( long _on )
! -------------------------------------------------------------------------------------------------
TPButtonClass.SetHide   procedure( long _on )
    code
    self.btnCtrl{ prop:hide } = _on
      
! -------------------------------------------------------------------------------------------------
! TPButtonClass.Init( long _ctrl )
! -------------------------------------------------------------------------------------------------
TPButtonClass.Init      procedure( long _ctrl )
i           long
    code
    self.btnCtrl = _ctrl    
    
    IF WD.ShowPageList
        SetPosition( self.btnCtrl, 10, 10 )
    ELSE
        SetPosition( self.btnCtrl, 100, 10 )
    END !* if *            
    self.btnCtrl{ Prop:Flat } = True
    
    loop i = 1 to 2 
        self.Xrange[i] = 0
        self.Yrange[i] = 0
    end !* loop *
    
! -------------------------------------------------------------------------------------------------
! TPButtonClass.Draw()
! -------------------------------------------------------------------------------------------------
TPButtonClass.Draw          procedure()
    CODE
    If PageQueue.PrintPage
        self.btnCtrl{Prop:Icon} = ICON_CHECK_ON
    ELSE
        self.btnCtrl{Prop:Icon} = ICON_CHECK_OFF
    END
    Tpre.GetCurrentPageFromQueue()

! -------------------------------------------------------------------------------------------------
! TPButtonClass.Done()
! -------------------------------------------------------------------------------------------------
TPButtonClass.Done      procedure()
    code
    self.btnCtrl = 0
    
! -------------------------------------------------------------------------------------------------
! TPageListClass.GetPage()
! -------------------------------------------------------------------------------------------------
TPageListClass.GetPage      procedure()
    code
    GET( PageQueue, Choice(self.listCtrl) )
    
! -------------------------------------------------------------------------------------------------
! TPageListClass.GetArea()
! -------------------------------------------------------------------------------------------------
TPageListClass.GetArea      procedure()
plX         Long
plY         Long
plW         Long
plH         Long
pbY         Long
pbH         Long
aY          Long
aH          Long
aW          Long
    CODE
    PreviewWindow{ Prop:Pixels } = True
    GetClientArea()
    
    aW = self.listCtrl{ Prop:Width }
    SetPosition( self.panelCtrl, 1, 0, aW+4, GSV:ClientAreaHeight   )
    SetPosition( self.listCtrl,  3, 2, aW,   GSV:ClientAreaHeight-4 )

    GetPosition( self.panelCtrl, plX, plY, plW, plH )
    self.Xrange[1] = plX
    self.Xrange[2] = plX + plW
    self.Yrange[1] = plY
    self.Yrange[2] = plY + plH
    PreviewWindow{ Prop:Pixels } = False    
    
! -------------------------------------------------------------------------------------------------
! TPageListClass.MouseOnArea(),long
! -------------------------------------------------------------------------------------------------
TPageListClass.MouseOnArea   procedure()
is_onarea       long
    code
    is_onarea = false
    if  InRange( MouseX(), self.Xrange[1], self.Xrange[2] ) and |
        InRange( MouseY(), self.Yrange[1], self.Yrange[2] ) 
        is_onarea = true        
    end !* if *        
    
    return is_onarea    

! -------------------------------------------------------------------------------------------------
! TPageListClass.Init( long _ctrl, long _panel )
! -------------------------------------------------------------------------------------------------
TPageListClass.Init     procedure( long _ctrl, long _panel )
i           long
    code
    self.listCtrl = _ctrl
    self.panelCtrl = _panel
    
    loop i = 1 to 2 
        self.Xrange[i] = 0
        self.Yrange[i] = 0
    end !* loop *    
    
    self.listCtrl{ Prop:IconList, 1 } = ICON_CHECK_OFF
    self.listCtrl{ Prop:IconList, 2 } = ICON_CHECK_ON
    self.listCtrl{ PROP:LineHeight } = 10
    
    self.Draw()
    
! -------------------------------------------------------------------------------------------------
! TPageListClass.Draw()
! -------------------------------------------------------------------------------------------------
TPageListClass.Draw     procedure()
    code
    IF WD.ShowPageList
        self.listCtrl   {Prop:Hide} = False
        self.panelCtrl  {Prop:Hide} = False
        TPButton.SetHide( true )
        Select( self.listCtrl, pointer(PageQueue) )
    ELSE
        self.listCtrl   {Prop:Hide} = True
        self.panelCtrl  {Prop:Hide} = True
        TPButton.SetHide( false )
    END !* if *

! -------------------------------------------------------------------------------------------------
! TPageListClass.Done()
! -------------------------------------------------------------------------------------------------
TPageListClass.Done     procedure()
    code
    self.listCtrl = 0
    self.panelCtrl = 0

! -------------------------------------------------------------------------------------------------
! TSaveAsClass.Init()
! -------------------------------------------------------------------------------------------------
TSaveAsClass.Init   procedure()
NumOpts             byte
OutGeneratorName    cstring(255)
i                   long
    CODE    
    self.export_path = ''
    if pTargetSelector &= NULL
        self.is_enable = false
    else        
        self.is_enable = true
        NumOpts = pTargetSelector.Items()
        loop i = 1 to NumOpts
            OutGeneratorName = pTargetSelector.GetOutputGeneratorName( i )
            case OutGeneratorName
                of 'XML'
                    self.if_xml = true
                of 'PDF'
                    self.if_pdf = true
                of 'HTML'
                    self.if_html = true
                of 'TEXT'
                    self.if_text = true
                of 'PNG'
                    self.if_png = true
                of 'XLS'
                    self.if_xls = true
            end !* end *
        end !* loop *            
    end !* if *        

! -------------------------------------------------------------------------------------------------
! TSaveAsClass.SetButtons()
! -------------------------------------------------------------------------------------------------
TSaveAsClass.SetButtons     procedure()
    code
    if not self.if_xml  then ?SaveAsXML { prop:disable } = true end
    if not self.if_pdf  then ?SaveAsPDF { prop:disable } = true end
    if not self.if_text then ?SaveAsTEXT{ prop:disable } = true end
    if not self.if_html then ?SaveAsHTML{ prop:disable } = true end
    if not self.if_png  then ?SaveAsPNG { prop:disable } = true end
    if not self.if_xls  then ?SaveAsXLS { prop:disable } = true end
    
! -------------------------------------------------------------------------------------------------
! TSaveAsClass.LoadPath()
! -------------------------------------------------------------------------------------------------
TSaveAsClass.LoadPath   procedure()
    code   
    !self.export_path = acc_getvar( self.CFG_GROUP, self.CFG_VALUE, '' )    
    SetPath( self.export_path )      
    
! -------------------------------------------------------------------------------------------------
! TSaveAsClass.SavePath()
! -------------------------------------------------------------------------------------------------
TSaveAsClass.SavePath   procedure()
strFullFN       cstring(1000)
strDrive        cstring(255)
strPath         cstring(255)
strFname        cstring(255)
strExt          cstring(255)
strTargetPath   cstring(1000)
    code   
    strFullFN = clip(self.ReportTarget.GetNewName())
    
    if PathSplit( strFullFN, strDrive, strPath, strFname, strExt )   
        strTargetPath = strDrive & strPath        
        !acc_setvar( self.CFG_GROUP, self.CFG_VALUE, strTargetPath )
    end !* if *
       
! -------------------------------------------------------------------------------------------------
! TSaveAsClass.SelectOutputFile()
! -------------------------------------------------------------------------------------------------
TSaveAsClass.SelectOutputFile   procedure()!,long
strTarget       cstring(64)
strFullFN       cstring(1000)
strDrive        cstring(255)
strPath         cstring(255)
strFname        cstring(255)
strExt          cstring(255)
FileName        cstring(1000)
is_ok           long
    code
    is_ok = false
    
    !self.export_path = acc_getvar( 'ALL', 'PreViewer.ExportPath', '' )    
    SetPath( self.export_path )
    
    !message( self.export_path )
    !message( 'REPORT - GetFileName() --> ' & self.ReportTarget.GetFileName() )
    
    if FileDialogA( 'Seleccione el archivo a guardar', FileName, '*.pdf|All|*.*', FILE:KeepDir + FILE:Save + FILE:NoError + FILE:LongName )
    
        strFullFN = SELF.ReportTarget.GetFileName()
        if PathSplit( strFullFN, strDrive, strPath, strFname, strExt )
        end 
        !message( strFullFN & '-->' & strDrive & '-' & strPath  & '-' & strFname & '-' &  strExt )    
        !message( self.export_path & ' --> ' & FileName )
        is_ok = true
    end !* if *
    
    return is_ok 
    
! -------------------------------------------------------------------------------------------------
! TSaveAsClass.Run( string _type )
! -------------------------------------------------------------------------------------------------
TSaveAsClass.Run        procedure( string _type )
strTarget       cstring(256)
returnValue     long
i               long
    code
    strTarget = clip(_type)
    if InList( strTarget, 'HTML', 'TEXT', 'PDF', 'XML', 'PNG', 'XLS' ) < 1
        return false
    elsif self.is_enable        
        self.OutputFileQueue &= NEW OutputFileQueue
        self.PrevQueue       &= NEW PreviewQueue
        self.WmfParser       &= NEW WMFDocumentParser

        LOOP I = 1 TO TPre.GetTotalPages()
            GET(PageQueue, I )
            IF  PageQueue.PrintPage
                self.PrevQueue.Filename = PageQueue.WmfFile
                ADD(self.PrevQueue)
            END !* if *
        END !* loop *
    
        if records( self.PrevQueue )
            if not pTargetSelector &= NULL
                self.ReportTarget &= pTargetSelector.GetReportGenerator( strTarget )
                if self.ReportTarget.SupportResultQueue() = True
                    self.ReportTarget.SetResultQueue( self.OutputFileQueue )
                end !* if *

                self.LoadPath()                
                if self.ReportTarget.AskProperties(true) = Level:Benign
                    self.SavePath()
                  
                    self.WmfParser.Init( self.PrevQueue, self.ReportTarget )
                    ReturnValue = self.WmfParser.GenerateReport()
                    if ReturnValue = Level:Benign
                        if self.ReportTarget.SupportResultQueue() = true
                        end !* end *
                    end !* end *
                end !* end * 
            end !* end *
        end !* end *
  
        dispose(self.WmfParser)                                   ! Dispose parser
   
        free(self.OutputFileQueue)                                ! Dispose output queue
        dispose(self.OutputFileQueue)

        free(self.PrevQueue)                                      ! Dispose preview queue
        dispose(self.PrevQueue)
    END !* if *
    
    return returnValue 

! -------------------------------------------------------------------------------------------------
! TSaveAsClass.Done()
! -------------------------------------------------------------------------------------------------
TSaveAsClass.Done       procedure()
    code    
    
! -------------------------------------------------------------------------------------------------
! TPVQueueClass.LoadPagesQueue()
! -------------------------------------------------------------------------------------------------
TPVQueueClass.LoadPagesQueue  procedure()
recs        long
i           long
    code   
    !TWait.Init('LOAD')    
    
    FREE( PageQueue )
    
    loop i = 1 to records(pImageQueue)
        Get( pImageQueue, i )
        
        clear( PageQueue )
        PageQueue.WmfFile   = pImageQueue
        PageQueue.Tagged    = False
        PageQueue.PrintPage = True
        PageQueue.PrintIcon = 2
        PageQueue.PageNumber = i            
        PageQueue.PageSize = GetFileSize( PageQueue.WmfFile )
        Add(PageQueue)
    end !* loop *
    
    !Twait.Done()    

! -------------------------------------------------------------------------------------------------
! TPVQueueClass.UnloadPagesQueue()
! -------------------------------------------------------------------------------------------------
TPVQueueClass.UnloadPagesQueue     procedure()
i           long
s           cstring(1000)
    Code
    TWait.Init('UNLOAD')
    FREE( PageQueue )    
    
    loop i = 1 to records( pImageQueue )
        get( pImageQueue, i )
        
        S = clip(pImageQueue)
        DeleteFile( S )
        yield()
        
    END !* LOOP *    
    FREE(pImageQueue)
    
    TWait.Done()
    
! -------------------------------------------------------------------------------------------------
! TPVQueueClass.Init()
! -------------------------------------------------------------------------------------------------
TPVQueueClass.Init      procedure()
    code
    self.NewName &= new TQ_NewName
    free( self.NewName )
    clear( self.NewName )
    
    self.LoadPagesQueue()
    
! -------------------------------------------------------------------------------------------------
! TPVQueueClass.RestoreMetaFiles()
! -------------------------------------------------------------------------------------------------
TPVQueueClass.RestoreMetaFiles      procedure()
i           LONG
S           CSTRING(1000)
D           CSTRING(1000)
    CODE
    TWait.Init('RESTORE')
    
    LOOP i = 1 TO RECORDS( self.NewName )
        GET( self.NewName, i )
        S = self.NewName.NewName
        D = self.NewName.OldName
        COPY( S, D )
    END !* loop *   
    
    TWait.Done()
    
! -------------------------------------------------------------------------------------------------
! TPVQueueClass.RenameMetaFiles()
! -------------------------------------------------------------------------------------------------
TPVQueueClass.RenameMetaFiles   procedure()
BS          long                !! Location of backslash
S           cstring(1000)
D           cstring(1000)
i           long
    CODE
    TWait.Init( 'LOADING' )
    
    LOOP I = 1 TO RECORDS(PageQueue)
        GET( PageQueue, i )
        
        CLEAR( self.NewName )
        S = CLIP(PageQueue.WmfFile)
        D = CLIP(PageQueue.WmfFile) & '.wmf'
        BS = INSTRING('\',S,-1,Len(S))
        IF BS
            D = SUB(S,1,BS) & 'ITP_' & SUB(S,BS+1,LEN(S)) & '.wmf'
        ELSE
            D = CLIP(PageQueue.WmfFile) & '.wmf'
        END !* IF *
        COPY(S, D)
        IF NOT ERRORCODE()
            clear( self.NewName )
            self.NewName.OldName = S
            self.NewName.NewName = D
            add( self.NewName )
        END !* IF *
    END !* LOOP *
    
    TWait.Done()

! -------------------------------------------------------------------------------------------------
! TPVQueueClass.RemoveMetaFiles()
! -------------------------------------------------------------------------------------------------
TPVQueueClass.RemoveMetaFiles      procedure()
i           long
S           cstring(1000)
    CODE
    TWait.Init('REMOVE')
    
    loop i = 1 to RECORDS(self.NewName)   
        get( self.NewName, i )
        
        S = clip(self.NewName.NewName)
        DeleteFile( S )
        yield()
        
    END !* LOOP *
    free( self.NewName )
    
    TWait.Done()

! -------------------------------------------------------------------------------------------------
! TPVQueueClass.Done()
! -------------------------------------------------------------------------------------------------
TPVQueueClass.Done      procedure()
    code
    self.UnloadPagesQueue()
    
    if not self.NewName &= NULL 
        free( self.NewName )
        clear( self.NewName )
        dispose( self.NewName )
    end !* if *
    
! -------------------------------------------------------------------------------------------------
