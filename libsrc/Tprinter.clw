! -------------------------------------------------------------------------------------------------
! Gustavo Saracca - (C) - 2023
!
! TPrinterClass
!
! Printer Class Helper
! -------------------------------------------------------------------------------------------------
    member
                    
    map
        module('win32.lib')
            EnumPrinters( LONG Flags,              | !printer object types
                            <*CSTRING>,            | !Ponter to string containing name of printer object
                            LONG Level,            | !information level
                            *? pPrinterEnum,       | !Pointer to printer information buffer
                            LONG cbBuf,            | !size of printer information buffer
                            *? pcbNeeded,          | !pointer to DWORD of bytes received or required
                            *? pcReturned          | !pointer to DWORD of number of printers enumerated
                        ),BOOL,PASCAL,RAW,NAME('EnumPrintersA')
            GetLastError(),LONG,PASCAL,NAME('GetLastError')
!            EnumPrinters( ULong Flags, |                ! [in]        printer object types
!                          <*CString pPrinterName>, |    ! [in/null]   name of printer object     
!                          ULong Level, |                ! [in]        information level [1,2,4(nt),5]
!                          <*String pPrinterEnum>, |     ! [out]       printer information buffer
!                          ULong cbBuf, |                ! [in]        size of printer information buffer
!                          *ULong pcbNeeded, |           ! [out]       bytes received (success) or required (buff is too small)
!                          *ULong pcReturned), |         ! [out]       number of printers enumerated 
!                          Bool,Pascal,Raw,Name('EnumPrintersA'),Proc
        end !* module *
    end !* map *

include( 'TPRN_TYPES.CLW', 'equates' ),once
include( 'Tprinter.inc' ),once
include( 'PrnProp.clw' ),once

TPrinterClass.SaveDefault       procedure()
    code
    self.save_default = PRINTER{ PropPrint:Device }
    
TPrinterClass.RestoreDefault    procedure()    
    code
    PRINTER{ PropPrint:Device } = self.save_default
    
TPrinterClass.Search    procedure( *cstring _printer )!,long        
is_found                long
    code
    is_found = false
    
    clear( self.Printers )
    self.Printers.PrinterName = clip(_printer)
    get( self.Printers, self.Printers.PrinterName )
    if not errorcode()  
        is_found = true
    end !* if *
    
    return is_found 

TPrinterClass.SearchAndSet  procedure( *cstring _printer )!,long    
    code
    if self.Search( _printer )
        self.SetDefault( _printer )
    end !* if *
    return false
    
TPrinterClass.SetDefault    procedure( *cstring _printer )
    code
    PRINTER{ PropPrint:Device } = _printer
    
TPrinterClass.GetDefault    procedure()!,string    
    code
    return self.default_printer
    
TPrinterClass.toPrinter     procedure()
    code
    self.ifFile = false
    self.toFileName = ''    
    
    Printer{ PROPPRINT:PrintToFile } = self.ifFile
    Printer{ PROPPRINT:PrintToName } = self.toFileName
    
TPrinterClass.toFile        procedure( string _file )   
    code
    self.ifFile = true
    self.toFileName = clip(_file)
    
    Printer{ PROPPRINT:PrintToFile } = self.ifFile
    Printer{ PROPPRINT:PrintToName } = self.toFileName

TPrinterClass.EnumPrinters  procedure()!,long
Ret                         bool
    code
    loop
        self.PrinterInfoBuffer &= NEW( STRING(self.BytesNeeded) )
        Ret = EnumPrinters( GS_PRINTER_ENUM_LOCAL + GS_PRINTER_ENUM_CONNECTIONS, , 4, self.PrinterInfoBuffer, size(self.PrinterInfoBuffer), self.BytesNeeded, self.PrinterCount )
        IF Ret = 0
            IF GetLastError() = 122
                dispose( self.PrinterInfoBuffer )
                self.PrinterCount = 0
                cycle
            ELSE
                self.PrinterCount = 0
                break
            END !* if *
            message('ITPR: ERROR: ' & GetLastError() )
        ELSE
            BREAK
        END !* if *
    END !* if *
  
    IF self.PrinterCount
        !! AB 2011-05-12:  Pass the buffer, bytes needed and number of printers to load into the Printers queue.
        self.FillQueue()
    END !* if *
    return self.PrinterCount
       
TPrinterClass.FillQueue     procedure()
PI4G                LIKE(GS_PRINTER_INFO_4)
PI4D                STRING(SIZE(GS_PRINTER_INFO_4)),OVER(PI4G)
PI4Size             LONG
i                   LONG
PN                  &CSTRING
    code
    self.Printers &= new(TQ_PRINTERS_FULL)
    free( self.Printers )
    
    PI4Size = SIZE(GS_PRINTER_INFO_4)
    loop i = 0 to self.PrinterCount - 1
    
        clear( self.Printers )
        PI4D = self.PrinterInfoBuffer[ I * PI4Size + 1 : PI4Size * (I + 1) ]
        
        PN &= (PI4G.pPrinterName)
        self.Printers.PrinterName = PN
        PN &= (PI4G.pServerName)  
        self.Printers.ServerName  = PN
        if self.Printers.ServerName
            if InString( self.Printers.ServerName, self.Printers.PrinterName, 1, 1 )
                self.Printers.PrinterName = self.Printers.PrinterName[LEN(SELF.Printers.ServerName) + 2 : LEN(SELF.Printers.PrinterName)]
            end !* if *
            self.Printers.DeviceName = self.Printers.ServerName & '\' & self.Printers.PrinterName
            self.Printers.IsLocal    = FALSE
        else
            self.Printers.DeviceName = SELF.Printers.PrinterName
            self.Printers.IsLocal    = TRUE
        end !* if *
        add( self.Printers )
        
    end !* loop *
    
TPrinterClass.SetList           procedure( long _list )
    code
    self.ListCtrl = _list
    self.ListCtrl{ Prop:LineHeight } = 12
    
TPrinterClass.SelectDefaultPrinter  procedure()
    code
    self.Printers.PrinterName = self.default_printer
    get( self.Printers, self.Printers.PrinterName )
    if not errorcode()
        self.SelectPrinter( pointer( self.Printers ) )
    end !* end *
    
TPrinterClass.SelectPrinter     procedure( long _idx )
    code
    select( self.ListCtrl, _idx )
    
TPrinterClass.LoadPrinters      procedure()
    code
    self.PrinterCount = 0
    if self.EnumPrinters()
        self.FillQueue()
    end !* if *
    
TPrinterClass.LoadDefault       procedure()
    code
    self.default_printer = PRINTER{ PropPrint:Device }
    self.save_default = ''
    self.SaveDefault()
    
TPrinterClass.GetPrinterList    procedure( TQ_PRINTERS _qprints )
i               long
    code
    free( _qprints )
    loop i = 1 to records( self.Printers )
        get( self.Printers, i )
                
        if clip(self.Printers.PrinterName) <> ''   
            clear( _qprints )
            _qprints.PrinterName = clip(self.Printers.PrinterName)
            add( _qprints )
        end !* if *            
    end !* loop *            
    
TPrinterClass.Init      procedure()
    code   
    self.toPrinter()
    self.LoadPrinters()
    self.LoadDefault()
        
TPrinterClass.Run           procedure()
    code
    return false
    
TPrinterClass.Done          procedure()
    code
    if not self.Printers &= NULL
        free( self.Printers )
        dispose( self.Printers )
    end !* if *
    
    self.RestoreDefault()
    
!* end *