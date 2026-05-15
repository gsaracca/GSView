! -----------------------------------------------------------------------------
! CLASS : Printer
! -----------------------------------------------------------------------------

  OMIT('_EndOfInclude_', _TPRINTER_PRESENT_ )
_TPRINTER_PRESENT_  EQUATE(1)

include( 'TPRN_TYPES.CLW', 'types' ),once
                                 
TPrinterClass           class,type,module( 'TPrinter.clw' ),link( 'TPrinter.clw' )
default_printer             like(TprinterName),private
save_default                like(TPrinterName),private
ifFile                      long,private
toFileName                  cstring(1000),private
ListCtrl                    long,private

BytesNeeded                 long(512),private
PrinterInfoBuffer           &string,private
Printers                    &TQ_PRINTERS_FULL,private       ! QUEUE for Printers
PrinterCount                long,private

SaveDefault                 procedure()
RestoreDefault              procedure()
Search                      procedure( *cstring _printer ),long
SearchAndSet                procedure( *cstring _printer ),long

SetDefault                  procedure( *cstring _printer )
GetDefault                  procedure(),string

toPrinter                   procedure()
toFile                      procedure( string _file )

EnumPrinters                procedure(),long,private
FillQueue                   procedure(),private

SetList                     procedure( long _list )
SelectDefaultPrinter        procedure()
SelectPrinter               procedure( long _idx )

LoadPrinters                procedure(),private
LoadDefault                 procedure(),private
GetPrinterList              procedure( TQ_PRINTERS _qprints )

Init                        procedure()
Run                         procedure(),long
Done                        procedure()
                        end !* class *

!* END *

  _EndOfInclude_