  MEMBER('gsview.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('gsview_BC0.CLW')
gsview_BC0:DctInit             PROCEDURE()
gsview_BC0:DctKill             PROCEDURE()
gsview_BC0:FilesInit           PROCEDURE()
    END
  END

DLLInit              DllInitializer                          !This object is used to initialize the dll, it is defined in the main program module

DctInit PROCEDURE()
  CODE
  gsview_BC0:DctInit
  gsview_BC0:FilesInit


DctKill PROCEDURE()
  CODE
  gsview_BC0:DctKill

