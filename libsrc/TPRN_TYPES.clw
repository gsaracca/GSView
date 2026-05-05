SECTION('equates')

GS_PRINTER_ENUM_DEFAULT     EQUATE(00000001)
GS_PRINTER_ENUM_LOCAL       EQUATE(00000002)
GS_PRINTER_ENUM_CONNECTIONS EQUATE(00000004)
GS_PRINTER_ENUM_FAVORITE    EQUATE(00000004)
GS_PRINTER_ENUM_NAME        EQUATE(00000008)
GS_PRINTER_ENUM_REMOTE      EQUATE(00000010)
GS_PRINTER_ENUM_SHARED      EQUATE(00000020)
GS_PRINTER_ENUM_NETWORK     EQUATE(00000040)

PRN_DEFAULT_PDF 		    CSTRING('Microsoft Print to PDF')

SECTION('types')

TPrinterName            CSTRING(1000),TYPE

GS_PRINTER_INFO_4       GROUP,TYPE
pPrinterName                LONG 
pServerName                 LONG
Attributes                  LONG   
                        END !!PRINTER_INFO_4A, *PPRINTER_INFO_4A, *LPPRINTER_INFO_4A 
                       
TQ_PRINTERS_FULL        QUEUE,TYPE
PrinterName                 CSTRING(101)    ! Printer Name
ServerName                  CSTRING(101)    ! Server Name
DeviceName                  CSTRING(256)    ! Full device name
IsLocal                     Byte
                        END !* QUEUE *                        

TQ_PRINTERS				QUEUE,TYPE
PrinterName 				like(TPrinterName)
						END !* QUEUE *

SECTION('vars')
                        
!* end *