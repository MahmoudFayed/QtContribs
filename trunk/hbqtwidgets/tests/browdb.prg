      /*
 * $Id$
 */

/*
 * Copyright 2012 Pritpal Bedi <bedipritpal@hotmail.com>
 * www - http://harbour-project.org
 */


#include "hbtoqt.ch"
#include "hbqtstd.ch"
#include "hbqtgui.ch"
#include "inkey.ch"


REQUEST DBFCDX

STATIC nLastKey

FUNCTION Main()

   LOCAL oMain, oBrw

   hbqt_errorSys()

   oMain := QMainWindow()
   oMain:setWindowTitle( "Database TBrowse Implemented !" )

   oBrw := BrowseMe( oMain )
   IF ! Empty( oBrw )
      oMain:setCentralWidget( oBrw:oWidget )
   ENDIF

   oMain:resize( 900, 450 )
   oMain:show()

   QApplication():exec()

   dbCloseAll()

   RETURN NIL


STATIC FUNCTION BrowseMe( oWnd )
   LOCAL oBrowse, oColumn
   LOCAL cPath := hb_DirBase() + ".." + hb_ps() + ".." + hb_ps() + ".." + hb_ps() + "tests" + hb_ps()
   LOCAL aIndexes := {}

   Set( _SET_DATEFORMAT, "yyyy.mm.dd" )

   USE ( cPath + "test.dbf" ) NEW SHARED VIA 'DBFCDX'
   IF NetErr()
      Alert( "Could not open table!" )
      RETURN NIL
   ENDIF
   IF ! hb_FileExists( cPath + "test.cdx" )
      INDEX ON test->last TAG "LAST" TO ( cPath + "test.cdx" )
   ENDIF
   SET INDEX TO ( cPath + "test.cdx" )

   DbGotop()

   oBrowse := HbQtBrowseNew( 0,0, 20, 80, oWnd, QFont( "Courier New", 10 ) )

   oBrowse:colorSpec := "N/W*, N/W, W+/R*, W+/B*, N/GR*, B+/GR*, N/R*"

   /* Navigation Blocks */
   oBrowse:skipBlock           := {|n| DbSkipBlock( n ) }
   oBrowse:goTopBlock          := {| | DbGoTop()        }
   oBrowse:goBottomBlock       := {| | DbGoBottom()     }

   /* Blocks TO control Scroolbars */
   oBrowse:firstPosBlock       := {| | 1                }    /* Not a TBrowse METHOD */
   oBrowse:lastPosBlock        := {| | LastRec()        }    /* Not a TBrowse METHOD */
   IF indexOrd() == 0
      oBrowse:posBlock         := {| | RecNo()          }    /* Not a TBrowse METHOD */
      oBrowse:goPosBlock       := {|n| DbGoto( n )      }    /* Not a TBrowse METHOD */
      oBrowse:phyPosBlock      := {| | RecNo()          }    /* Not a TBrowse METHOD */
   ELSE
      oBrowse:posBlock         := {| | OrdKeyNo()       }    /* Not a TBrowse METHOD */
      oBrowse:goPosBlock       := {|n| OrdKeyGoto( n )  }    /* Not a TBrowse METHOD */
      oBrowse:phyPosBlock      := {| | OrdKeyNo()       }    /* Not a TBrowse METHOD */
   ENDIF

   oColumn            := HbQtColumnNew( "Record #"   , {|| RecNo()        } )
   oBrowse:addColumn( oColumn )

   oColumn            := HbQtColumnNew( "Last Name"  , {|| TEST->last     } )
   oColumn:colorBlock := {|| iif( SubStr( TEST->first,1,1 ) $ "ANLH", { 6,2 }, { 1,2 } ) }
   oBrowse:addColumn( oColumn )

   oColumn            := HbQtColumnNew( "First Name" , {|| TEST->first    } )
   oBrowse:addColumn( oColumn )

   oColumn            := HbQtColumnNew( "Salary"     , {|| TEST->salary   } )
   oColumn:picture    := "@Z 999,999.00"
   oColumn:colorBlock := {|x| iif( x < 40000, { 7,2 }, { 1,2 } ) }
   oBrowse:addColumn( oColumn )

   oColumn            := HbQtColumnNew( "HireDate"   , {|| TEST->hireDate } )
   oBrowse:addColumn( oColumn )

   oColumn            := HbQtColumnNew( "Age"        , {|| TEST->age      } )
   oBrowse:addColumn( oColumn )

   oColumn            := HbQtColumnNew( "City"       , {|| TEST->city     } )
   oBrowse:addColumn( oColumn )

   oColumn            := HbQtColumnNew( "State"      , {|| TEST->state    } )
   oBrowse:addColumn( oColumn )

   oColumn            := HbQtColumnNew( "Zip"        , {|| TEST->zip      } )
   oBrowse:addColumn( oColumn )

   oColumn            := HbQtColumnNew( "Notes"      , {|| TEST->notes    } )
   oBrowse:addColumn( oColumn )

   /* HbQtBrowse Extentions */
   oBrowse:horizontalScrollbar := .T.                        /* Not a TBrowse METHOD */
   oBrowse:verticalScrollbar   := .F.                        /* Not a TBrowse METHOD */
// oBrowse:cursorMode          := HBQTBRW_CURSOR_ROW         /* Not a TBrowse METHOD */
   oBrowse:toolbar         := .T.
   oBrowse:statusbar       := .T.
   oBrowse:statusMessage   := "This is Harbour TBrowse's Complete Implementation in HbQt Widgets with many Additional Goodies!"
   oBrowse:editBlock       := {|aMod,aData,oBrw| SaveMyRecord( aMod,aData,oBrw ) }
   oBrowse:searchBlock     := {|xValue,nMode,oBrw| LookMySearch( xValue,nMode,oBrw ) }
   oBrowse:navigationBlock := {|nKey,xData,oBrw|  HandleMyOptions( nKey,xData,oBrw ) }

   AAdd( aIndexes, { "Natural Order", {|oBrw| dbSetOrder( 0 ), oBrw:refreshAll(), oBrw:forceStable() } } )
   AAdd( aIndexes, { "Last Name"    , {|oBrw| dbSetOrder( 1 ), oBrw:refreshAll(), oBrw:forceStable() } } )
   oBrowse:indexes         := { aIndexes, 2 }

   oBrowse:gotoBlock       := {|| GotoMyRecord() }

   RETURN oBrowse


STATIC FUNCTION HandleMyOptions( nKey,xData,oBrowse )
   LOCAL xResult, i
   LOCAL lHandelled := .T.

   HB_SYMBOL_UNUSED( xData )

   nLastKey := nKey

   DO CASE

   CASE nKey == K_CTRL_F
      oBrowse:search()
   CASE nKey == K_F6
      oBrowse:freeze++
   CASE nKey == K_F7
      oBrowse:freeze--
   CASE nKey == K_F12
      oBrowse:edit( "Update Field Values", .T., .T. )
   CASE nKey == K_SH_F12
      IF dbRLock()
         oBrowse:panHome()
         oBrowse:Right()
         FOR i := 2 TO oBrowse:colCount()
            xResult := oBrowse:editCell()  /* HbQt Entention */
            IF xResult == NIL
               EXIT                        /* ESCape is pressed */
            ENDIF
            SWITCH oBrowse:getColumn( i ):heading
            CASE "Last Name"  ; REPLACE TEST->last     WITH xResult ; EXIT
            CASE "First Name" ; REPLACE TEST->first    WITH xResult ; EXIT
            CASE "Salary"     ; REPLACE TEST->Salary   WITH xResult ; EXIT
            CASE "HireDate"   ; REPLACE TEST->HireDate WITH xResult ; EXIT
            CASE "Age"        ; REPLACE TEST->Age      WITH xResult ; EXIT
            CASE "City"       ; REPLACE TEST->City     WITH xResult ; EXIT
            CASE "State"      ; REPLACE TEST->State    WITH xResult ; EXIT
            CASE "Zip"        ; REPLACE TEST->Zip      WITH xResult ; EXIT
            CASE "Notes"      ; REPLACE TEST->Notes    WITH xResult ; EXIT
            ENDSWITCH
            oBrowse:refreshCurrent()
            IF i < oBrowse:colCount()
               oBrowse:Right()
            ENDIF
         NEXT
         IF xResult != NIL
            dbCommit()
         ENDIF
         dbRUnlock()
      ENDIF
   OTHERWISE
      lHandelled := .F.
   ENDCASE

   RETURN lHandelled


STATIC FUNCTION SaveMyRecord( aMod,aData,oBrw )
   LOCAL cColumn, nField

   IF dbRLock()
      FOR EACH cColumn IN aData[ 2 ]
         nField := cColumn:__enumIndex()
         IF aMod[ nField ] != aData[ 1, nField ]   /* DATA Changed or Not */
            SWITCH cColumn
            CASE "First Name"                      /* We are interested IN editing these two fields only */
               REPLACE TEST->first WITH aMod[ nField ]
               EXIT
            CASE "Last Name"
               REPLACE TEST->last  WITH aMod[ nField ]
               EXIT
            ENDSWITCH
         ENDIF
      NEXT
      dbCommit()
      dbRUnlock()
      oBrw:refreshCurrent()
   ENDIF

   RETURN .T.


STATIC FUNCTION DbSkipBlock( n )
   LOCAL nSkipped := 0

   if n == 0
      DBSkip( 0 )

   elseif n > 0
      do while nSkipped != n .and. TBNext()
         nSkipped++
      enddo
   else
      do while nSkipped != n .and. TBPrev()
         nSkipped--
      enddo
   endif

   RETURN  nSkipped


STATIC FUNCTION TBNext()
   LOCAL nSaveRecNum := recno()
   LOCAL lMoved := .T.

   if Eof()
      lMoved := .F.
   else
      DBSkip( 1 )
      if Eof()
         lMoved := .F.
         DBGoTo( nSaveRecNum )
      endif
   endif

   RETURN lMoved


STATIC FUNCTION TBPrev()
   LOCAL nSaveRecNum := Recno()
   LOCAL lMoved := .T.

   DBSkip( -1 )

   if Bof()
      DBGoTo( nSaveRecNum )
      lMoved := .F.
   endif

   RETURN lMoved


STATIC FUNCTION LookMySearch( xValue,nMode,oBrw )
   LOCAL nRec

   IF xValue == NIL .AND. oBrw == NIL
      /* search is finished, take other action, this will help to build a selectable browser */
      Alert( "Current Record Number Is : " + hb_ntos( RecNo() ) )

   ELSEIF xValue == NIL                           /* Interface is requesting to initiate search */
      IF IndexOrd() == 1
         RETURN { Space( Len( TEST->last ) ), NIL, HBQTBRW_SEARCH_INCREMENTAL }
      ELSE
         RETURN { NIL, NIL, HBQTBRW_SEARCH_BYFIELD }
      ENDIF

   ELSE
      IF IndexOrd() == 1                          /* Interface is requesting to do the search as per needs */
         nRec := RecNo()
         IF ! dbSeek( Trim( xValue ) )
            dbGoto( nRec )
         ELSE
            oBrw:refreshAll()
         ENDIF
      ELSEIF nMode == HBQTBRW_SEARCH_BYFIELD
         IF nLastKey == K_ESC
            nLastKey := 0
            RETURN .T.
         ENDIF
         RETURN Eval( oBrw:getColumn( oBrw:colPos ):block ) = xValue

      ENDIF

   ENDIF

   RETURN .T.


STATIC FUNCTION GotoMyRecord()
   LOCAL nPRec := RecNo()
   LOCAL nRec

   IF ( nRec := HbQtBulkGet( nPRec, "Record Number", , , , "GoTo ?" ) ) > 0
      dbGoto( nRec )
   ELSE
      RETURN .F.
   ENDIF

   RETURN nPRec != nRec

