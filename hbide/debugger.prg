/*
 * $Id$
 */

/* this file adapted FOR hbide from hwgdebug.prg by alex;(Alexey Zapolski(pepan@mail.ru))
 * (HWGUI - Harbour Win32 GUI library source code)
 * The GUI Debugger
 *
 * Copyright 2013 Alexander Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 *
 * 2014 - Adopted for HbIDE by Alex <alexeyzapolskiy@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version, with one exception:
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */


#include "fileio.ch"
#include "hbide.ch"
#include "common.ch"
#include "hbclass.ch"
#include "hbqtgui.ch"
#include "hbtoqt.ch"
#include "hbqtstd.ch"


#define MODE_INPUT                                1
#define MODE_INIT                                 2
#define MODE_WAIT_ANS                             3
#define MODE_WAIT_BR                              4

#define ANS_BRP                                   1
#define ANS_CALC                                  2
#define ANS_STACK                                 3
#define ANS_LOCAL                                 4
#define ANS_WATCH                                 5
#define ANS_AREAS                                 6
#define ANS_REC                                   7
#define ANS_OBJECT                                8
#define ANS_SETS                                  9
#define ANS_ARRAY                                 10

#define CMD_QUIT                                  1
#define CMD_GO                                    2
#define CMD_STEP                                  3
#define CMD_TRACE                                 4
#define CMD_NEXTR                                 5
#define CMD_TOCURS                                6
#define CMD_EXIT                                  7
#define CMD_STACK                                 8
#define CMD_EXP                                   9
#define CMD_LOCAL                                 10
#define CMD_STATIC                                11
#define CMD_PRIV                                  12
#define CMD_PUBL                                  13
#define CMD_WATCH                                 14
#define CMD_AREA                                  15
#define CMD_REC                                   16
#define CMD_OBJECT                                17
#define CMD_TERMINATE                             18
#define CMD_SETS                                  19
#define CMD_ARRAY                                 20

#define BUFFER_LEN                                1024

#define cMsgNotSupp                               "Command isn't supported"
#define C_C                                       " , "


CLASS IdeDebugger INHERIT IdeObject

   DATA   oIde

   DATA   nRequestedVarsIndex                     INIT 0
   DATA   lLoaded                                 INIT .F.
   DATA   nRowWatch
   DATA   nRowAreas                               INIT -1
   DATA   aSources
   DATA   lDebugging                              INIT .F.
   DATA   hRequest                                INIT -1
   DATA   hResponse                               INIT -1
   DATA   nId1                                    INIT 0
   DATA   nId2                                    INIT -1

   DATA   cAppName
   DATA   cPrgName                                INIT ""

   DATA   cInspectVar                             INIT ""
   DATA   cInspectTypes                           INIT ""
   DATA   cInspectType                            INIT ""

   DATA   aBP                                     INIT {}
   DATA   aWatches                                INIT {}
   DATA   nCurrLine                               INIT 0
   DATA   nMode                                   INIT MODE_INPUT
   DATA   nAnsType
   DATA   cPrgBP
   DATA   nLineBP
   DATA   aBPLoad                                 INIT {}
   DATA   nBPLoad

   DATA   nExitMode                               INIT 2
   DATA   nVerProto                               INIT 0
   DATA   cLastMessage                            INIT ""

   DATA   oUI
   DATA   oUI_1
   DATA   oUI_2
   DATA   cCurrentProject
   DATA   oTimer
   DATA   aTabs
   DATA   cBuffer
   DATA   lTerminated                             INIT .F.
   DATA   cExe                                    INIT ""

   METHOD init( oIde )
   METHOD create( oIde )
   METHOD start( cExe, cCmd, qStr, cWrkDir )
   METHOD stop()
   METHOD show()
   METHOD hide()
   METHOD clear()
   METHOD loadBreakPoints()
   METHOD clearBreakPoints( cPrg )
   METHOD deleteBreakPoint( cPrg, nLine )
   METHOD toggleBreakPoint( cAns, cLine )
   METHOD addBreakPoint( cPrg, nLine )
   METHOD timerProc()
   METHOD dbgRead()
   METHOD send( ... )
   METHOD setMode( newMode )
   METHOD setCurrLine( nLine, cName )
   METHOD getCurrLine()
   METHOD getCurrPrgName()
   METHOD getBP( nLine, cPrg )
   METHOD doCommand( nCmd, cDop, cDop2 )
   METHOD setWindow( cPrgName )
   METHOD stopDebug()
   METHOD inspectObject( lClicked )
   METHOD inspectObjectEx()
   METHOD manageObjectLevelUp()
   METHOD showStack( arr, n )
   METHOD showVars( arr, n, nVarType )
   METHOD showWatch( arr, n )
   METHOD showAreas( arr, n )
   METHOD requestRecord( row, col )
   METHOD requestSets()
   METHOD requestVars( index )
   METHOD requestObject()
   METHOD showRec( arr, n )
   METHOD showObject( arr, n )
   METHOD showSets( arr, n )
   METHOD wait4connection( cStr )
   METHOD ui_init( oUI )
   METHOD ui_load()
   METHOD watch_ins( lPaste, cExp )
   METHOD watch_del( lAll )
   METHOD watch_save()
   METHOD watch_rest()
   METHOD changeWatch( item )
   METHOD terminateDebug()
   METHOD exitDbg()
   METHOD fineTune( oTable )
   METHOD waitState( nSeconds )
   METHOD copyOnClipboard()
   METHOD isActive()                              INLINE ! ::lTerminated    // ::lDebugging
   METHOD raise()                                 INLINE ::oIde:oDebuggerDock:oWidget:raise()
   METHOD manageKey( nQtKey )
   METHOD switchUI()
   METHOD loadAll()

   ENDCLASS


METHOD IdeDebugger:init( oIde )
   DEFAULT oIde TO ::oIde
   ::oIde := oIde
   RETURN Self


METHOD IdeDebugger:create( oIde )

   DEFAULT oIde TO ::oIde
   ::oIde := oIde

   ::cBuffer       := Space( BUFFER_LEN )
   ::aTabs         := ::oIde:aTabs
   ::oUI_1         := hbqtui_debugger()
   ::oUI_2         := hbqtui_debugger1()
   ::ui_init( ::oUI_1 )
   ::ui_init( ::oUI_2 )

   IF ! Empty( GetEnv( "hbide_debugger_old" ) )
      ::oUI := ::oUI_1
   ELSE
      ::oUI := ::oUI_2
   ENDIF
   ::oDebuggerDock:oWidget:setWidget( ::oUI:oWidget )

   ::oTimer := QTimer()
   WITH OBJECT ::oTimer
      :setInterval( 30 )
      :connect( "timeout()",  {|| ::timerProc() } )
   ENDWITH
   RETURN Self


METHOD IdeDebugger:stop()
   RETURN .T.


METHOD IdeDebugger:clear()

   ::nRequestedVarsIndex    := 0
   ::lLoaded                := .F.
   ::nRowWatch              := NIL
   ::nRowAreas              := -1
   ::aSources               := NIL
   ::lDebugging             := .F.
   ::hRequest               := -1
   ::hResponse              := NIL
   ::nId1                   := 0
   ::nId2                   := -1
   ::cAppName               := NIL
   ::cPrgName               := ""
   ::cInspectVar            := ""
   ::cInspectType           := ""
   ::aBP                    := {}
   ::aWatches               := {}
   ::nCurrLine              := 0
   ::nMode                  := MODE_INPUT
   ::nAnsType               := NIL
   ::cPrgBP                 := NIL
   ::nLineBP                := NIL
   ::aBPLoad                := {}
   ::nBPLoad                := NIL
   ::nExitMode              := 2
   ::nVerProto              := 0
   //
   RETURN .T.


METHOD IdeDebugger:hide()
   ::oIde:oDebuggerDock:oWidget:hide()
   RETURN Self


METHOD IdeDebugger:show()
   ::oIde:oDebuggerDock:oWidget:show()
   ::raise()
   RETURN Self


METHOD IdeDebugger:start( cExe, cCmd, qStr, cWrkDir )
   LOCAL cPath, cFile, cExt

   ::setMode( MODE_INIT )

   hb_fNameSplit( cExe, @cPath, @cFile, @cExt )
   cWrkDir := hbide_pathToOSPath( iif( Empty( cWrkDir ), cPath, cWrkDir ) )

   ::cExe := cExe

   FErase( cExe + ".d1" )
   FErase( cExe + ".d2" )
   IF ( ::hRequest := FCreate( cExe + ".d1" ) ) == -1
      Alert( "Previous instance still active, cannot continue." )
   ENDIF
   FWrite( ::hRequest, "init,!" )
   ::hResponse := FCreate( cExe + ".d2" )
   FClose( ::hResponse )
   FClose( ::hRequest )

   ::hRequest := FOpen( cExe + ".d1", FO_READWRITE + FO_SHARED )
   ::hResponse := FOpen( cExe + ".d2", FO_READ + FO_SHARED )
   IF ::hRequest != -1 .AND. ::hResponse != -1
      ::cAppName := Lower( cFile + cExt )
   ELSE
      ::hRequest := ::hResponse := -1
      hbide_showWarning( "No connection !!" )
      RETURN .F.
   ENDIF

   ::show()

   QProcess():startDetached( cCmd, qStr, cWrkDir )
   ::waitState( 3 )                               // duration can be controlled by user

   ::oTimer:start()
   IF ::wait4connection( "ver" )
      ::oPM:outputText( "Connected Successfully." )
   ELSE
      ::oPM:outputText( "Not Connected, Debug Terminated !!" )
      RETURN .F.
   ENDIF

   ::timerProc()
   ::loadBreakPoints()
   ::lDebugging := .T.
   ::oPM:outputText( "Debug Started." )
   ::doCommand( CMD_GO )
   //::oIde:qCurEdit:hbSetDebuggedLine( -1 )
   RETURN .T.


METHOD IdeDebugger:loadBreakPoints()
   LOCAL i, j, oEditor, nBP, aBP, cSource

   ::oPM:outputText( "Loading breakpoints..." )
   FOR j := 1 TO Len( ::aSources )
      IF Lower( hb_FNameExt( ::aSources[ j ] ) ) $ ".prg,.hb,.c,.cpp"
         FOR i := 1 TO Len( ::aTabs )
            oEditor := ::aTabs[ i, TAB_OEDITOR ]
            IF Lower( hb_FNameName( oEditor:oTab:caption ) ) == Lower( hb_FNameName( ::aSources[ j ] ) )
               cSource := hb_FNameName( ::aSources[ j ] ) + hb_FNameExt( ::aSources[ j ] )
               aBP := hb_ATokens( oEditor:qCoEdit:qEdit:hbGetBreakPoints(), "," )
               AEval( aBP, {|e,i| aBP[ i ] := Val( e ) } )
               FOR EACH nBP IN aBP
                  IF nBP > 0
                     AAdd( ::aBPLoad, { nBP, cSource } )
                  ENDIF
               NEXT
            ENDIF
         NEXT i
      ENDIF
   NEXT j
   IF ! Empty( ::aBPLoad )
      ::nBPLoad := 1
      ::addBreakPoint( ::aBPLoad[ 1,2 ], ::aBPLoad[ 1,1 ] )
   ENDIF
   WHILE ! Empty( ::aBPLoad )
      ::timerProc()
   ENDDO
   RETURN .T.


METHOD IdeDebugger:addBreakPoint( cPrg, nLine )
   LOCAL n

   IF ::nMode != MODE_INPUT .AND. Empty( ::aBPLoad )
      RETURN NIL
   ENDIF
   IF ( n := ::getBP( nLine, cPrg ) ) == 0
      ::oPM:outputText( "Setting break point: " + cPrg + ": " + Str( nLine ) )
      ::send( "brp", "add", cPrg, LTrim( Str( nLine ) ) )
      AAdd( ::aBP, { nLine, cPrg } )
   ELSE
      ::oPM:outputText( "Deleting break point: " + cPrg + ": " + Str( nLine ) )
      ::send( "brp", "del", cPrg, LTrim( Str( nLine ) ) )
      hb_ADel( ::aBP, n, .T. )
   ENDIF
   IF ::nMode != MODE_WAIT_ANS
      ::nAnsType := ANS_BRP
      ::cPrgBP   := cPrg
      ::nLineBP  := nLine
      ::setMode( MODE_WAIT_ANS )
   ENDIF
   RETURN NIL


METHOD IdeDebugger:clearBreakPoints( cPrg )
   LOCAL n

   IF PCount() == 0
      cPrg := ""
   ENDIF
   FOR n := 1 TO Len( ::aBP )
      IF ( Empty( cPrg ) .OR. cPrg == ::aBP[ n,2 ] ) .AND. ::aBP[ n,1 ] <> 0
         ::deleteBreakPoint( ::aBP[ n,2 ], ::aBP[ n,1 ] )
         ::wait4connection( "ok" )
      ENDIF
   NEXT
   RETURN .T.


METHOD IdeDebugger:toggleBreakPoint( cAns, cLine )
   LOCAL nLine := Val( cLine ), i

   IF cAns == "line"
      FOR i := 1 TO Len( ::aBP )
         IF ::aBP[ i,1 ] == 0
            ::aBP[ i,1 ] := nLine
            ::aBP[ i,2 ] := ::cPrgBP
            EXIT
         ENDIF
      NEXT
      IF i > Len( ::aBP )
         AAdd( ::aBP, { nLine, ::cPrgBP } )
      ENDIF
   ELSE
      IF ( i := ::getBP( nLine, ::cPrgBP ) ) == 0
         hbide_showWarning( "Error deleting BP line " + cLine )
         ::oUI:activateWindow()
      ELSE
         ::aBP[ i,1 ] := 0
      ENDIF
   ENDIF
   //::setCurrLine(nLine, ::cPrgName)
   RETURN NIL


METHOD IdeDebugger:deleteBreakPoint( cPrg, nLine )
      ::send( "brp", "del", cPrg, LTrim( Str( nLine ) ) )
      IF ::nMode != MODE_WAIT_ANS
         ::nAnsType := ANS_BRP
         ::cPrgBP   := cPrg
         ::nLineBP  := nLine
         ::setMode( MODE_WAIT_ANS )
      ENDIF
   RETURN .T.


METHOD IdeDebugger:getBP( nLine, cPrg )
   cPrg := Lower( iif( cPrg == NIL, ::cPrgName, cPrg ) )
   RETURN Ascan( ::aBP, {|a_| a_[ 1 ] == nLine .and. Lower( a_[ 2 ] ) == cPrg } )


METHOD IdeDebugger:timerProc()
   LOCAL n, arr
   STATIC nLastSec := 0

   IF ::nMode != MODE_INPUT
      IF ! Empty( arr := ::dbgRead() )
         IF arr[ 1 ] == "quit"
            ::setMode( MODE_INIT )
            ::stopDebug()
            RETURN NIL
         ENDIF
         IF ::nMode == MODE_WAIT_ANS
            IF Left( arr[ 1 ], 1 ) == "b" .AND. ( n := Val( SubStr( arr[ 1 ], 2 ) ) ) == ::nId1
               IF ::nAnsType == ANS_CALC
                  IF arr[ 2 ] == "value"
                     IF ! Empty( ::cInspectVar )
                        IF Substr( Hex2Str( arr[ 3 ] ), 2, 1 ) == "O"
                           ::nMode := MODE_INPUT
                           ::inspectObject( .F. )
                           RETURN NIL
                        ELSE
                           ::oUI:tableObjectInspector:setRowCount( 0 )
                           hbide_showWarning( ::cInspectVar + " isn't an object" )
                           ::oUI:activateWindow()
                        ENDIF
                     ELSE
                        //???  ::SetResult( Hex2Str( arr[3] ) )
                     ENDIF
                  ELSE
                     ::oPM:outputText( "-- BAD ANSWER --" )
                  ENDIF
               ELSEIF ::nAnsType == ANS_BRP
                  IF arr[ 2 ] == "err"
                     ::oPM:outputText( "-- BAD LINE --" )
                     ::toggleBreakPoint( "line", Str( ::nLineBP ) )
                  ELSE
                     ::oPM:outputText( "Ok" )
                     ::toggleBreakPoint( arr[ 2 ], arr[ 3 ] )
                  ENDIF

                  IF ! Empty( ::aBPLoad )
                     IF ++::nBPLoad <= Len( ::aBPLoad )
                        ::addBreakPoint( ::aBPLoad[ ::nBPLoad,2 ], ::aBPLoad[ ::nBPLoad,1 ] )
                        RETURN NIL
                     ELSE
                        ::aBPLoad := {}
                        ::oPM:outputText( "Breakpoints loaded." )
                     ENDIF
                  ENDIF
               ELSEIF ::nAnsType == ANS_STACK
                  IF arr[ 2 ] == "stack"
                     ::showStack( arr, 3 )
                  ENDIF
               ELSEIF ::nAnsType == ANS_LOCAL
                  IF arr[ 2 ] == "valuelocal"
                     ::showVars( arr, 3, 1 )
                  ELSEIF arr[ 2 ] == "valuepriv"
                     ::showVars( arr, 3, 2 )
                  ELSEIF arr[ 2 ] == "valuepubl"
                     ::showVars( arr, 3, 3 )
                  ELSEIF arr[ 2 ] == "valuestatic"
                     ::showVars( arr, 3, 4 )
                  ENDIF
               ELSEIF ::nAnsType == ANS_WATCH
                  IF arr[ 2 ] == "valuewatch"
                     ::showWatch( arr, 3 )
                  ENDIF
               ELSEIF ::nAnsType == ANS_AREAS
                  IF arr[ 2 ] == "valueareas"
                     ::showAreas( arr, 3 )
                  ENDIF
               ELSEIF ::nAnsType == ANS_SETS
                  IF arr[ 2 ] == "valuesets"
                     ::showSets( arr, 3 )
                  ENDIF
               ELSEIF ::nAnsType == ANS_REC
                  IF arr[ 2 ] == "valuerec"
                     ::showRec( arr, 3 )
                  ENDIF
               ELSEIF ::nAnsType == ANS_OBJECT
                  IF arr[ 2 ] == "valueobj"
                     ::showObject( arr, 3 )
                  ENDIF
               ELSEIF ::nAnsType == ANS_ARRAY
                  IF arr[ 2 ] == "valuearr"
                     ::showObject( arr, 3 )
                  ENDIF
               ENDIF
               ::setMode( MODE_INPUT )
            ENDIF
         ELSE
            IF Left( arr[ 1 ], 1 ) == "a" .AND. ( n := Val( SubStr( arr[ 1 ], 2 ) ) ) > ::nId2
               ::nId2 := n
               IF arr[2] == "."
                  ::oPM:outputText( "-- BAD LINE --" )
               ELSE
                  IF ! ( ::cPrgName == arr[ 2 ] )
                     ::cPrgName := arr[ 2 ]
                     // ::setPath( ::cPaths, ::cPrgName )
                  ENDIF
                  ::oPM:outputText( "Program Stopped..." )
                  ::oUi:labelStatus:setText( "Stopped" )
                  ::setCurrLine( ::nCurrLine := Val( arr[ 3 ] ), ::cPrgName )
                  n := 4
                  DO WHILE .T.
                     IF arr[ n ] == "ver"
                        ::nVerProto := Val( arr[ n+1 ] )
                        n += 2
                     ELSEIF arr[ n ] == "stack"
                        ::showStack( arr, n+1 )
                        n += 2 + Val( arr[ n+1 ] ) * 3
                     ELSEIF arr[ n ] == "valuelocal"
                        ::showVars( arr, n+1, 1 )
                        n += 2 + Val( arr[ n+1 ] ) * 3
                     ELSEIF arr[ n ] == "valuepriv"
                        ::showVars( arr, n+1, 2 )
                        n += 2 + Val( arr[ n+1 ] ) * 3
                     ELSEIF arr[ n ] == "valuepubl"
                        ::showVars( arr, n+1, 3 )
                        n += 2 + Val( arr[ n+1 ] ) * 3
                     ELSEIF arr[ n ] == "valuestatic"
                        ::showVars( arr, n+1, 4 )
                        n += 2 + Val( arr[ n+1 ] ) * 3
                     ELSEIF arr[ n ] == "valuewatch"
                        ::showWatch( arr, n+1 )
                        n += 2 + Val( arr[ n+1 ] )
                     ELSE
                        EXIT
                     ENDIF
                     QApplication():processEvents()
                  ENDDO
                  ::requestSets()
                  ::cLastMessage := "Debugger (" + arr[ 2 ] + ", line " + arr[ 3 ] + ")"
                  ::oPM:outputText( ::cLastMessage )

                  ::ui_load()
                  ::oUI:show()
                  ::oUI:activateWindow()
               ENDIF
               ::setMode( MODE_INPUT )
               nLastSec := Seconds()
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   RETURN NIL


METHOD IdeDebugger:dbgRead()
   LOCAL n, s, arr

   FSeek( ::hResponse, 0, 0 )
   s := ""
   DO WHILE ( n := Fread( ::hResponse, @::cBuffer, BUFFER_LEN ) ) > 0
      s += Left( ::cBuffer, n )
      IF ( n := At( ",!", s ) ) > 0
         IF ( arr := hb_aTokens( Left( s, n + 1 ), "," ) ) != NIL .AND. Len( arr ) > 2 .AND. arr[ 1 ] == arr[ Len( arr ) - 1 ]
            RETURN arr
         ELSE
            EXIT
         ENDIF
      ENDIF
      QApplication():processEvents()
   ENDDO
   RETURN NIL


METHOD IdeDebugger:send( ... )
   LOCAL i
   LOCAL arr := hb_aParams()
   LOCAL s   := ""

   FSeek( ::hRequest, 0, 0 )
   FOR i := 1 TO Len( arr )
      s += arr[ i ] + ","
   NEXT
   FWrite( ::hRequest, LTrim( Str( ++::nId1 ) ) + "," + s + LTrim( Str( ::nId1 ) ) + ",!" )
   RETURN NIL


METHOD IdeDebugger:setMode( newMode )
   ::nMode := newMode
   IF newMode == MODE_INPUT
   ELSE
      IF newMode == MODE_WAIT_ANS .OR. newMode == MODE_WAIT_BR
         IF newMode == MODE_WAIT_BR
            ::nCurrLine := 0
         ENDIF
      ELSEIF newMode == MODE_INIT
         ::lDebugging := .F.
      ENDIF
   ENDIF
   RETURN NIL


METHOD IdeDebugger:doCommand( nCmd, cDop, cDop2 )
   LOCAL oCursor
   IF ::nMode == MODE_INPUT
      IF nCmd == CMD_GO
         ::oIde:qCurEdit:hbSetDebuggedLine( -1 )
         oCursor := ::oIde:qCurEdit:textCursor()
         oCursor:movePosition( QTextCursor_Down, QTextCursor_MoveAnchor, 1 )
         ::oIde:qCurEdit:setTextCursor( oCursor )
         QApplication():processEvents()
         oCursor := ::oIde:qCurEdit:textCursor()
         oCursor:movePosition( QTextCursor_Up, QTextCursor_MoveAnchor, 1 )
         ::oIde:qCurEdit:setTextCursor( oCursor )
         QApplication():processEvents()

         ::oPM:outputText( "Command GO Issued."   )
         ::oPM:outputText( "Program Executing..." )
         ::oUi:labelStatus:setText( "Program Executing..." )
         ::send( "cmd", "go" )

      ELSEIF nCmd == CMD_STEP
         ::oPM:outputText( "Command STEP Issued." )
         ::oPM:outputText( "Program Executing..." )
         ::oUi:labelStatus:setText( "Program Executing..." )
         ::send( "cmd", "step" )

      ELSEIF nCmd == CMD_TOCURS
         ::oPM:outputText( "Command TOCURS Issued." )
         ::oPM:outputText( "Program Executing..." )
         ::oUi:labelStatus:setText( "Program Executing..." )
         ::send( "cmd", "to", ::getCurrPrgName(), Ltrim( Str( ::getCurrLine() ) ) )

      ELSEIF nCmd == CMD_TRACE
         ::oPM:outputText( "Command TRACE Issued."   )
         ::oPM:outputText( "Program Executing..." )
         ::oUi:labelStatus:setText( "Program Executing..." )
         ::send( "cmd", "trace" )

      ELSEIF nCmd == CMD_NEXTR
         ::oPM:outputText( "Command NEXTR Issued."   )
         ::oPM:outputText( "Program Executing..." )
         ::oUi:labelStatus:setText( "Program Executing..." )
         ::send( "cmd", "nextr" )

      ELSEIF nCmd == CMD_EXP
         ::send( "exp", cDop )
         ::nAnsType := ANS_CALC
         ::setMode( MODE_WAIT_ANS )
         RETURN NIL

      ELSEIF nCmd == CMD_STACK
         ::send( "view", "stack", cDop )
         ::nAnsType := ANS_STACK
         ::setMode( MODE_WAIT_ANS )
         RETURN NIL

      ELSEIF nCmd == CMD_LOCAL
         ::send( "view", "local", cDop )
         ::nAnsType := ANS_LOCAL
         ::setMode( MODE_WAIT_ANS )
         RETURN NIL

      ELSEIF nCmd == CMD_PRIV
         IF ::nVerProto > 1
            ::send( "view", "priv", cDop )
            ::nAnsType := ANS_LOCAL
            ::setMode( MODE_WAIT_ANS )
         ELSE
            hbide_showWarning( cMsgNotSupp )
            ::oUI:activateWindow()
         ENDIF
         RETURN NIL

      ELSEIF nCmd == CMD_PUBL
         IF ::nVerProto > 1
            ::send( "view", "publ", cDop )
            ::nAnsType := ANS_LOCAL
            ::setMode( MODE_WAIT_ANS )
         ELSE
            hbide_showWarning( cMsgNotSupp )
            ::oUI:activateWindow()
         ENDIF
         RETURN NIL

      ELSEIF nCmd == CMD_STATIC
         IF ::nVerProto > 1
            ::send( "view", "static", cDop )
            ::nAnsType := ANS_LOCAL
            ::setMode( MODE_WAIT_ANS )
         ELSE
            hbide_showWarning( cMsgNotSupp )
            ::oUI:activateWindow()
         ENDIF
         RETURN NIL

      ELSEIF nCmd == CMD_WATCH
         IF Empty( cDop2 )
            ::send( "view", "watch", cDop )
         ELSE
            ::send( "watch", cDop, cDop2 )
         ENDIF
         ::nAnsType := ANS_WATCH
         ::setMode( MODE_WAIT_ANS )
         RETURN NIL

      ELSEIF nCmd == CMD_AREA
         ::send( "view", "areas" )
         ::nAnsType := ANS_AREAS
         ::setMode( MODE_WAIT_ANS )
         RETURN NIL

      ELSEIF nCmd == CMD_SETS
         ::send( "view", "sets" )
         ::nAnsType := ANS_SETS
         ::setMode( MODE_WAIT_ANS )
         RETURN NIL

      ELSEIF nCmd == CMD_REC
         IF ::nVerProto > 1
            ::send( "insp", "rec", cDop )
            ::nAnsType := ANS_REC
            ::setMode( MODE_WAIT_ANS )
         ELSE
            hbide_showWarning( cMsgNotSupp )
            ::oUI:activateWindow()
         ENDIF
         RETURN NIL

      ELSEIF nCmd == CMD_OBJECT
         IF ::nVerProto > 1
            ::send( "insp", "obj", cDop )
            ::nAnsType := ANS_OBJECT
            ::setMode( MODE_WAIT_ANS )
         ELSE
            hbide_showWarning( cMsgNotSupp )
            ::oUI:activateWindow()
         ENDIF
         RETURN NIL

      ELSEIF nCmd == CMD_ARRAY
         IF ::nVerProto > 1
            ::send( "insp", "arr", cDop, "", "" )
            ::nAnsType := ANS_ARRAY
            ::setMode( MODE_WAIT_ANS )
         ELSE
            hbide_showWarning( cMsgNotSupp )
            ::oUI:activateWindow()
         ENDIF
         RETURN NIL

      ELSEIF nCmd == CMD_QUIT
         ::nExitMode := 2
         RETURN NIL

      ELSEIF nCmd == CMD_EXIT
         ::nExitMode := 1
         RETURN NIL

      ELSEIF nCmd == CMD_TERMINATE
         ::send( "cmd", "quit" )
         ::lDebugging := .F.
         ::stopDebug()

      ENDIF

      ::setMode( MODE_WAIT_BR )

   ELSEIF nCmd == CMD_EXIT
      ::nExitMode := 1

   ENDIF
   RETURN NIL


METHOD IdeDebugger:setCurrLine( nLine, cName )
   LOCAL qCursor

   IF ! ::lDebugging
      ::lDebugging := .T.
   ENDIF
   ::oIde:qCurEdit:hbSetDebuggedLine( -1 )

   ::setWindow( cName )

   ::oIde:qCurEdit:hbSetDebuggedLine( nLine )
   qCursor := ::oIde:qCurEdit:textCursor()

   qCursor:movePosition( QTextCursor_Down, QTextCursor_MoveAnchor, nLine - 1 )
   ::oIde:qCurEdit:setTextCursor( qCursor )
   ::oIde:qCurEdit:centerCursor()
   ::oIde:manageFocusInEditor()

   ::oUI:activateWindow()
   RETURN NIL


METHOD IdeDebugger:getCurrLine()
   RETURN ::oIde:qCurEdit:textCursor():blockNumber() + 1


METHOD IdeDebugger:getCurrPrgName()
   LOCAL oEditor := ::oIde:oCurEditor
   RETURN oEditor:cFile + oEditor:cExt


METHOD IdeDebugger:setWindow( cPrgName )
   LOCAL qCursor, oSource, cSource, cPath, cName, cExt, cNme, cEtn
   LOCAL oProject := ::oPM:getProjectByTitle( ::cCurrentProject )

   cNme := Lower( hb_FNameName( cPrgName ) )
   cEtn := Lower( hb_FNameExt( cPrgName ) )
   FOR EACH oSource IN oProject:hSources
      hb_FNameSplit( oSource:original, @cPath, @cName, @cExt )
      IF Lower( cName ) + Lower( cExt ) == cNme + cEtn
         cSource := cPath + cName + cExt
         EXIT
      ENDIF
   NEXT
   IF Empty( cSource )
      FOR EACH cPath IN ::oINI:aSourcePaths
         IF hb_FileExists( hbide_pathToOSPath( cPath + cPrgName ) )
            cSource := hbide_pathToOSPath( cPath + cPrgName )
            EXIT
         ENDIF
      NEXT
   ENDIF
   IF ! Empty( cSource )
      ::oIde:oSM:editSource( cSource, 0, 0, 0, NIL, NIL, .F., .T., NIL, NIL, NIL )
      qCursor := ::oIde:qCurEdit:textCursor()
      qCursor:setPosition( 0 )
      ::oIde:qCurEdit:setTextCursor( qCursor )
   ELSE
      Alert( "Exact location of source " + cPrgName + " could not been detected." )
   ENDIF
   RETURN .T.


METHOD IdeDebugger:stopDebug()
   IF ! ::isActive()
      RETURN Self
   ENDIF
   ::oIde:qCurEdit:hbSetDebuggedLine( -1 )
   IF ::oTimer:isActive()
      ::oTimer:stop()
   ENDIF
   FClose( ::hRequest )
   FClose( ::hResponse )
   ::hRequest := ::hResponse := -1
   FErase( ::cExe + ".d1" )
   FErase( ::cExe + ".d2" )

   ::oUI:tableWatchExpressions:setRowCount( 0 )
   ::oUI:tableStack           :setRowCount( 0 )
   ::oUI:tableVarLocal        :setRowCount( 0 )
   ::oUI:tableVarPrivate      :setRowCount( 0 )
   ::oUI:tableVarPublic       :setRowCount( 0 )
   ::oUI:tableVarStatic       :setRowCount( 0 )
   ::oUI:tableOpenTables      :setRowCount( 0 )
   ::oUI:tableCurrentRecord   :setRowCount( 0 )
   ::oUI:tableObjectInspector :setRowCount( 0 )
   ::oUI:tableSets            :setRowCount( 0 )

   ::oUi:labelStatus:setText( "Debug Stopped and Exiting..." )
   ::oPM:outputText( "Debug Stopped and Exiting..." )
   ::hide()
   ::lTerminated := .T.
   RETURN NIL


METHOD IdeDebugger:manageObjectLevelUp()
   LOCAL n, cObject

   IF Len( ::cInspectTypes ) > 1
      cObject := ::cInspectVar

      IF Right( cObject, 1 ) == "]"
         n := RAt( "[", cObject )
      ELSE
         n := RAt( ":", cObject )
      ENDIF
      cObject := SubStr( cObject, 1, n-1 )
      ::cInspectTypes := SubStr( ::cInspectTypes, 1, Len( ::cInspectTypes ) - 1 )

      ::cInspectVar := cObject
      ::cInspectType := Right( ::cInspectTypes, 1 )

      ::oUI:btnObjBack:setEnabled( Len( ::cInspectTypes ) > 1 )
      ::requestObject()
   ENDIF
   RETURN NIL


METHOD IdeDebugger:inspectObjectEx()
   LOCAL oTable := ::oUI:tableObjectInspector
   LOCAL nIndex := oTable:currentRow()
   LOCAL oItem, cType, cObject, cOType

   IF nIndex >= 0
      IF ! Empty( oItem := oTable:item( nIndex, 1 ) )
         cType := oItem:text()
         IF cType $ "A,O"
            cObject := ::cInspectVar
            cOType  := ::cInspectType
            IF cType == "A"
               IF cOType == "O"
                  cObject := cObject + ":" + oTable:item( nIndex, 0 ):text()
               ELSE
                  cObject := cObject + "[" + hb_ntos( nIndex + 1 ) + "]"
               ENDIF
            ELSEIF cType == "O"
               IF cOType == "A"
                  cObject := cObject + "[" + hb_ntos( nIndex + 1 ) + "]"
               ELSE
                  cObject := cObject + ":" + oTable:item( nIndex, 0 ):text()
               ENDIF
            ENDIF
            ::cInspectVar   := cObject
            ::cInspectType  := cType
            ::cInspectTypes += cType
            ::oUI:btnObjBack:setEnabled( Len( ::cInspectTypes ) > 1 )
            ::requestObject()
         ENDIF
      ENDIF
   ENDIF
   RETURN NIL


METHOD IdeDebugger:inspectObject( lClicked )
   LOCAL index, oTable, nRow, cObjName
   LOCAL cType := ""

   IF lClicked
      ::oUI:btnObjBack:setEnabled( .F. )

      index := ::oUI:tabWidget:currentIndex()
      DO CASE
      CASE index = 0
         oTable := ::oUI:tableVarLocal
      CASE index = 1
         oTable := ::oUI:tableVarPrivate
      CASE index = 2
         oTable := ::oUI:tableVarPublic
      CASE index = 3
         oTable := ::oUI:tableVarStatic
      ENDCASE

      IF oTable:rowCount() == 0
         RETURN NIL
      ENDIF

      nRow := oTable:currentRow()
      IF nRow >= 0
         cType := oTable:item( nRow, 1 ):text()
      ENDIF
      IF ! ( cType $ "O,A" )
         hbide_showWarning( "Please select a variable of type O'bject or A'rray!" )
         ::oUI:activateWindow()
         RETURN NIL
      ENDIF

      cObjName := oTable:item( nRow, 0 ):text()
      ::cInspectVar := cObjName
      ::cInspectType := cType
      ::cInspectTypes := cType
   ENDIF

   ::requestObject()
   //
   RETURN NIL


METHOD IdeDebugger:showStack( arr, n )
   LOCAL i
   LOCAL nLen := Val( arr[ n ] )

   ::oUI:tableStack:setRowCount( nLen )
   FOR i := 1 TO nLen
      ::oUI:tableStack:setItem( i - 1, 0, QTableWidgetItem( AllTrim( arr[ ++n ] ) ) )
      ::oUI:tableStack:setItem( i - 1, 1, QTableWidgetItem( AllTrim( arr[ ++n ] ) ) )
      ::oUI:tableStack:setItem( i - 1, 2, QTableWidgetItem( AllTrim( arr[ ++n ] ) ) )
   NEXT
   RETURN NIL


METHOD IdeDebugger:showVars( arr, n, nVarType )
   LOCAL nLen := Val( arr[n] )
   LOCAL i, oTable
   //::oUI:tabWidget:setCurrentIndex(nVarType)

   DO CASE
   CASE nVarType = 1
      oTable := ::oUI:tableVarLocal
   CASE nVarType = 2
      oTable := ::oUI:tableVarPrivate
   CASE nVarType = 3
      oTable := ::oUI:tableVarPublic
   CASE nVarType = 4
      oTable := ::oUI:tableVarStatic
   ENDCASE
   oTable:setRowCount( nLen )
   FOR i := 1 TO nLen
      oTable:setItem( i-1, 0, QTableWidgetItem( AllTrim( Hex2Str( arr[ ++n ] ) ) ) )
      oTable:setItem( i-1, 1, QTableWidgetItem( AllTrim( Hex2Str( arr[ ++n ] ) ) ) )
      oTable:setItem( i-1, 2, QTableWidgetItem( AllTrim( Hex2Str( arr[ ++n ] ) ) ) )
   NEXT
   RETURN NIL


METHOD IdeDebugger:showWatch( arr, n )
   LOCAL nWatch
   LOCAL nWatches := Val( arr[ n ] )

   FOR nWatch := 1 TO nWatches
      IF nWatch <= Len( ::aWatches )
         ::oUI:tableWatchExpressions:setItem( ::aWatches[ nWatch,1 ], 1, QTableWidgetItem( AllTrim( Hex2Str( arr[ ++n ] ) ) ) )
      ENDIF
   NEXT
   RETURN NIL


METHOD IdeDebugger:showAreas( arr, n )
   LOCAL i, j
   LOCAL nAreas := Val( arr[ n ] )
   LOCAL nAItems := Val( Hex2Str( arr[ ++n ] ) )

   ::oUI:tableOpenTables:setRowCount( nAreas )
   FOR i := 1 TO nAreas
      FOR j := 1 TO nAItems
         ::oUI:tableOpenTables:setItem( i - 1, j - 1, QTableWidgetItem( AllTrim( Hex2Str( arr[ ++n ] ) ) ) )
      NEXT
   NEXT
   IF nAreas == 0
      ::oUI:tableCurrentRecord:setRowCount( 0 )
   ELSE
      ::oUI:tableOpenTables:setCurrentCell( 0, 0 )
      ::requestRecord( 0, 0 )
   ENDIF
   RETURN NIL


METHOD IdeDebugger:showRec( arr, n )
   LOCAL i, j
   LOCAL nRows  := Val( arr[ n ] )
   LOCAL cAlias := Hex2Str( arr[ ++n ] )
   LOCAL cRec   := Hex2Str( arr[ ++n ] )

   ::oUI:labelCurrentRecord:setText( "Record Inspector [ " + cAlias + " : " + cRec + " ]" )
   ::oUI:tableCurrentRecord:setRowCount( nRows )
   FOR i := 1 TO nRows
      FOR j := 1 TO 4
         ::oUI:tableCurrentRecord:setItem( i - 1, j - 1, QTableWidgetItem( AllTrim( Hex2Str( arr[ ++n ] ) ) ) )
      NEXT
   NEXT
   RETURN NIL


METHOD IdeDebugger:showSets( arr, n )
   LOCAL i, j
   LOCAL nSets := Val( arr[ n ] )

   ::oUI:tableSets:setRowCount( nSets )
   FOR i := 1 TO nSets
      FOR j := 1 TO 2
         ::oUI:tableSets:setItem( i - 1, j - 1, QTableWidgetItem( AllTrim( Hex2Str( arr[ ++n ] ) ) ) )
      NEXT
   NEXT
   RETURN NIL


METHOD IdeDebugger:showObject( arr, n )
   LOCAL i, j
   LOCAL nLen := Val( arr[ n ] )

   ::oUI:tableObjectInspector:setRowCount( nLen )
   IF nLen == 0
      ::oUI:labelObjectInspector:setText( "Object Inspector" )
      ::cInspectVar := ""
      ::cInspectType := ""
   ELSE
      IF ::cInspectType == "O"
         ::oUI:labelObjectInspector:setText( "Object Inspector [" + ::cInspectVar + "]" )
         FOR i := 1 TO nLen
            FOR j := 1 TO 3
               ::oUI:tableObjectInspector:setItem( i - 1, j - 1, QTableWidgetItem( AllTrim( Hex2Str( arr[ ++n ] ) ) ) )
            NEXT
         NEXT
      ELSEIF ::cInspectType == "A"
         ::oUI:labelObjectInspector:setText( "Array Inspector [" + ::cInspectVar + "]" )
         n += 2
         FOR i := 1 TO nLen
            ::oUI:tableObjectInspector:setItem( i - 1, 0, QTableWidgetItem( "Ele: " + hb_ntos( i ) ) )
            FOR j := 1 TO 2
               ::oUI:tableObjectInspector:setItem( i - 1, j, QTableWidgetItem( AllTrim( Hex2Str( arr[ ++n ] ) ) ) )
            NEXT
         NEXT
      ENDIF
   ENDIF
   RETURN NIL


METHOD IdeDebugger:copyOnClipboard()
   LOCAL aData, s
   LOCAL txt_:={}

   AAdd( txt_, "PROJECT: " + ::cCurrentProject + " [" + DToC( Date() ) + "  " + Time() + "]" )
   AAdd( txt_, ::cLastMessage )
   AAdd( txt_, " " )
   AAdd( txt_, " " )

   IF ! Empty( aData :=__pullData( ::oUI:tableVarLocal ) )
      AAdd( txt_, "LOCAL VARIABLES" )
      __formatData( txt_, { "Name", "Type", "Value" }, aData, { 10, 4, 80 } )
   ENDIF
   IF ! Empty( aData :=__pullData( ::oUI:tableVarPrivate ) )
      AAdd( txt_, "PRIVATE VARIABLES" )
      __formatData( txt_, { "Name", "Type", "Value" }, aData, { 10, 4, 80 } )
   ENDIF
   IF ! Empty( aData :=__pullData( ::oUI:tableVarPublic ) )
      AAdd( txt_, "PUBLIC VARIABLS" )
      __formatData( txt_, { "Name", "Type", "Value" }, aData, { 10, 4, 80 } )
   ENDIF
   IF ! Empty( aData :=__pullData( ::oUI:tableVarStatic ) )
      AAdd( txt_, "STATIC VARIABLS" )
      __formatData( txt_, { "Name", "Type", "Value" }, aData, { 10, 4, 80 } )
   ENDIF
   IF ! Empty( aData :=__pullData( ::oUI:tableWatchExpressions ) )
      AAdd( txt_, "WATCHES" )
      __formatData( txt_, { "Expression", "Value" }, aData, { 25, 72 } )
   ENDIF
   IF ! Empty( aData :=__pullData( ::oUI:tableOpenTables ) )
      AAdd( txt_, "WORKAREAS" )
      __formatData( txt_, { "Alias", "Area", "Rdd","Records","CurRec","Bof","Eof","Found","Del","Filter","TagName","IndexKey" }, ;
                      aData, { 10,4,8,10,8,3,3,3,3,30,10,30 } )
   ENDIF
   IF ! Empty( aData :=__pullData( ::oUI:tableCurrentRecord ) )
      AAdd( txt_, Upper( ::oUI:labelCurrentRecord:text() ) )
      __formatData( txt_, { "Name", "Type", "Len", "Value" }, aData, { 10, 4, 4, 73 } )
   ENDIF
   IF ! Empty( aData :=__pullData( ::oUI:tableObjectInspector ) )
      AAdd( txt_, Upper( ::oUI:labelObjectInspector:text() ) )
      __formatData( txt_, { "Name", "Type", "Value" }, aData, { 20, 4, 70 } )
   ENDIF
   IF ! Empty( aData :=__pullData( ::oUI:tableStack ) )
      AAdd( txt_, "STACK" )
      __formatData( txt_, { "Source", "Procedure", "Line" }, aData, { 20, 40, 6 } )
   ENDIF
   IF ! Empty( aData :=__pullData( ::oUI:tableSets ) )
      AAdd( txt_, "SETS" )
      __formatData( txt_, { "Set", "Value" }, aData, { 30, 67 } )
   ENDIF

   s := ""
   AEval( txt_, {|e| s += e + Chr( 13 ) + Chr( 10 ) } )
   QApplication():clipboard():setText( s )

   Alert( "Debug info copied to clipboard successfully!" )
   RETURN Self


STATIC FUNCTION __formatData( txt_, aHdrs, aData, aWidths )
   LOCAL nCols := Len( aHdrs )
   LOCAL aRec, j, s

   s := "   "
   FOR j := 1 TO nCols
      s += Pad( aHdrs[ j ], aWidths[ j ] ) + iif( j == nCols, "", C_C )
   NEXT
   AAdd( txt_, s )
   FOR EACH aRec IN aData
      s := "   "
      FOR j := 1 TO nCols
         //s += Pad( AllTrim( aRec[ j ] ), aWidths[ j ] ) + iif( j == nCols, "", C_C )
         s += Pad( aRec[ j ], aWidths[ j ] ) + iif( j == nCols, "", C_C )
      NEXT
      AAdd( txt_, s )
   NEXT
   AAdd( txt_, " " )
   AAdd( txt_, " " )
   RETURN NIL


STATIC FUNCTION __pullData( oTable )
   LOCAL aData := {}
   LOCAL nRows, nCols, nRow, nCol, oItem, aRec

   nRows  := oTable:rowCount()
   nCols  := oTable:columnCount()
   //
   FOR nRow := 0 TO nRows - 1
      aRec := {}
      FOR nCol := 0 TO nCols - 1
         IF ! Empty( oItem := oTable:item( nRow, nCol ) )
            AAdd( aRec, StrTran( oItem:text(), ",", ";" ) )
         ELSE
            AAdd( aRec, "" )
         ENDIF
      NEXT
      AAdd( aData, aRec )
   NEXT
   RETURN aData


METHOD IdeDebugger:wait4connection( cStr )
   LOCAL n
   LOCAL nSec := Seconds()

   ::oTimer:stop()
   DO WHILE .T.
      IF ::lTerminated
         EXIT
      ENDIF
      FSeek( ::hResponse, 0, 0 )
      n := Fread( ::hResponse, @::cBuffer, BUFFER_LEN )
      IF n > 0
         IF cStr == "ok"
            IF At( "err", ::cBuffer ) > 0 .OR. At( "ok", ::cBuffer ) > 0
               EXIT
            ENDIF
         ELSE
            IF At( cStr, ::cBuffer ) > 0
               EXIT
            ENDIF
         ENDIF
      ENDIF
      IF Seconds() - nSec > 5
         ::oPM:outputText( "Waited for " + cStr + ". No answer. May be a bad query." )
         ::oUI:activateWindow()
         ::oTimer:start()
         RETURN .F.
      ENDIF
      ::waitState( 0.3 )
      QApplication():processEvents()
   ENDDO
   ::oTimer:start()
   RETURN .T.


METHOD IdeDebugger:requestRecord( row, col )
   LOCAL item, cAlias

   IF ::oUi:labelStatus:text() != "Stopped"
      RETURN NIL
   ENDIF

   HB_SYMBOL_UNUSED( col )
   IF row == ::nRowAreas
      RETURN NIL
   ELSE
      ::nRowAreas := row
   ENDIF
   item := ::oUI:tableOpenTables:item( row, 0 )
   IF Left( item:text(), 1 ) == "*"
      cAlias := Right( item:text(), Len( item:text() ) - 1 )
   ELSE
      cAlias = item:text()
   ENDIF
   ::setMode( MODE_INPUT )
   ::doCommand( CMD_REC, cAlias )
   ::wait4connection( "valuerec" )
   ::timerProc()
   RETURN NIL


METHOD IdeDebugger:requestSets()

   IF ::oUi:labelStatus:text() != "Stopped"
      RETURN NIL
   ENDIF
   ::setMode( MODE_INPUT )
   ::doCommand( CMD_SETS )
   ::wait4connection( "valuesets" )
   ::timerProc()
   RETURN NIL


METHOD IdeDebugger:requestObject()

   IF ::oUi:labelStatus:text() != "Stopped"
      RETURN NIL
   ENDIF
   IF ! ::isActive()
      RETURN NIL
   ENDIF
   ::setMode( MODE_INPUT )
   IF ::cInspectType == "O"
      ::doCommand( CMD_OBJECT, ::cInspectVar )
      ::wait4connection( "valueobj" )
   ELSEIF ::cInspectType == "A"
      ::doCommand( CMD_ARRAY, ::cInspectVar  )
      ::wait4connection( "valuearr" )
   ENDIF
   ::timerProc()
   RETURN NIL


METHOD IdeDebugger:requestVars( index )

   IF ::oUi:labelStatus:text() != "Stopped"
      RETURN NIL
   ENDIF
   ::nRequestedVarsIndex := index
   ::setMode( MODE_INPUT )

   DO CASE
   CASE index == 0
      ::doCommand( CMD_LOCAL, "on" )
      ::wait4connection( "valuelocal" )
   CASE index == 1
      ::doCommand( CMD_PRIV, "on" )
      ::wait4connection( "valuepriv" )
   CASE index == 2
      ::doCommand( CMD_PUBL, "on" )
      ::wait4connection( "valuepubl" )
   CASE index == 3
      ::doCommand( CMD_STATIC, "on" )
      ::wait4connection( "valuestatic" )
   ENDCASE
   ::timerProc()
   RETURN NIL


METHOD IdeDebugger:loadAll()
   IF ! ::isActive()
      RETURN Self
   ENDIF

   ::setMode( MODE_INPUT )
   ::doCommand( CMD_STACK, "on" )
   ::wait4connection( "stack" )
   ::timerProc()

   ::setMode( MODE_INPUT )
   ::doCommand( CMD_AREA )
   ::wait4connection( "valueareas" )
   ::timerProc()

   ::requestVars( ::oUI:tabWidget:currentIndex() )
   ::requestSets()
   //::requestRecord()

   ::doCommand( CMD_WATCH, "on" )
   ::timerProc()
   RETURN Self


METHOD IdeDebugger:ui_load()
   IF ! ::isActive()
      RETURN Self
   ENDIF

   IF ! ::lLoaded
      ::setMode( MODE_INPUT )
      ::doCommand( CMD_STACK, "on" )
      ::wait4connection( "stack" )
      ::timerProc()

      ::requestVars( ::oUI:tabWidget:currentIndex() )

      ::lLoaded := .T.
   ELSE
      IF ::nRequestedVarsIndex != ::oUI:tabWidget:currentIndex()
         ::requestVars( ::oUI:tabWidget:currentIndex() )
      ENDIF
   ENDIF

   ::setMode( MODE_INPUT )
   ::doCommand( CMD_AREA )
   ::wait4connection( "valueareas" )
   ::timerProc()

   IF ! Empty( ::cInspectVar )
      ::inspectObject( .F. )
   ENDIF

   ::doCommand( CMD_WATCH, "on" )
   ::nRowAreas := -1
   RETURN NIL


METHOD IdeDebugger:waitState( nSeconds )
   LOCAL nSecs := Seconds()
   DO WHILE Abs( Seconds() - nSecs ) < nSeconds
      QApplication():processEvents()
   ENDDO
   RETURN NIL


METHOD IdeDebugger:watch_rest()
   LOCAL cFile, aWatches, cWatch, nSel

   IF .T.
      cFile := hbide_fetchAFile( ::oDlg, "Select a Watches File", { { "Watches", "*.wch" } }, ;
                                      ::oPM:getProjectPathFromTitle( ::cCurrentProject ), "wch", .F. )
      IF ! Empty( cFile ) .AND. hb_FileExists( cFile )
         aWatches := hbide_readSource( cFile )
         nSel := Alert( "Merge with existing watches ?", { "Yes", "No" } )
         QApplication():processEvents()
         IF nSel != 1
            ::watch_del( .T. )
         ENDIF
         FOR EACH cWatch IN aWatches
            IF ! Empty( cWatch )
               ::watch_ins( .T., cWatch )
               QApplication():processEvents()
            ENDIF
         NEXT
      ENDIF
   ENDIF
   RETURN Self


METHOD IdeDebugger:watch_save()
   LOCAL oTable   := ::oUI:tableWatchExpressions
   LOCAL nRows    := oTable:rowCount()
   LOCAL aWatches := {}
   LOCAL i, cFile, s, cPath, cName, cExt, oItem

   FOR i := 1 TO nRows
      IF ! Empty( oItem := oTable:item( i-1, 0 ) ) .AND. ! Empty( oItem:text() )
         AAdd( aWatches, oItem:text() )
      ENDIF
   NEXT
   IF ! Empty( aWatches )
      cFile := hbide_fetchAFile( ::oDlg, "Select a Watches File", { { "Watches", "*.wch" } }, ;
                                      ::oPM:getProjectPathFromTitle( ::cCurrentProject ), "wch", .F. )
      IF ! Empty( cFile )
         hb_FNameSplit( cFile, @cPath, @cName, @cExt )
         IF ! ( Left( cName, Len( ::cCurrentProject ) ) == ::cCurrentProject )
            cName := ::cCurrentProject + "_" + cName
            IF Lower( cExt ) != ".wch"
               cExt := ".wch"
            ENDIF
         ENDIF
         cFile := cPath + cName + cExt
         s := ""
         AEval( aWatches, {|e| s += e + Chr( 13 )+Chr( 10 ) } )
         hb_MemoWrit( cFile, s )
         IF hb_FileExists( cFile )
            Alert( "Watches has been saved in " + cFile )
         ENDIF
      ENDIF
   ENDIF
   RETURN Self


METHOD IdeDebugger:watch_ins( lPaste, cExp )
   LOCAL i, oItem, nRow
   LOCAL oTable := ::oUI:tableWatchExpressions

   DEFAULT lPaste TO .F.
   IF lPaste
      DEFAULT cExp TO ::oEM:getSelectedText()
   ELSE
      cExp := ""
   ENDIF
   IF lPaste .AND. Empty( cExp )
      RETURN Self
   ENDIF
   FOR i := 1 TO oTable:rowCount()
      oItem := oTable:item( i - 1, 0 )
      IF oItem == NIL .OR. Empty( oItem:text() )
         EXIT
      ENDIF
   NEXT
   IF i > oTable:rowCount()
      oTable:insertRow( oTable:rowCount() )
      nRow := oTable:rowCount() - 1
      AAdd( ::aWatches, { nRow, cExp } )
   ELSE
      nRow := i - 1
   ENDIF
   oTable:setItem( nRow, 0, QTableWidgetItem( cExp ) )
   ::waitState( 0.25 )
   RETURN NIL


METHOD IdeDebugger:watch_del( lAll )
   LOCAL i, nn
   LOCAL oTable := ::oUI:tableWatchExpressions
   LOCAL nRow   := oTable:currentRow()
   local ri     := 0
   LOCAL nEmptyNames := 0

   DEFAULT lAll TO .F.

   IF ! lAll .AND. nRow < 0
      RETURN NIL
   ELSEIF lAll .AND. oTable:rowCount() == 0
      RETURN NIL
   ENDIF
   FOR i := 0 TO nRow
      IF Empty( ::aWatches[ i+1, 2 ] )
         nEmptyNames++
      ENDIF
   NEXT
   IF lAll
      DO WHILE ! Empty( ::aWatches )
         nn := Len( ::aWatches )
         IF ! Empty( ::aWatches[ nn,2 ] )
            hb_ADel( ::aWatches, nn, .T. )
            ::setMode( MODE_INPUT )
            ::doCommand( CMD_WATCH, "del", LTrim( Str( nn - nEmptyNames ) ) )
            ::wait4connection( "b" + LTrim( Str( ::nId1 ) ) )
         ENDIF
         QApplication():processEvents()
      ENDDO
      oTable:setRowCount( 0 )
   ELSE
      FOR i := 1 TO Len( ::aWatches )
         IF ::aWatches[ i,1 ] == nRow
            ri := i
            IF ! Empty( ::aWatches[ i,2 ] )
               ::setMode( MODE_INPUT )
               ::doCommand( CMD_WATCH, "del", LTrim( Str( i - nEmptyNames ) ) )
            ENDIF
         ENDIF
         IF ::aWatches[ i,1 ] > nRow
            --::aWatches[ i,1 ]
         ENDIF
      NEXT
      IF ri > 0
         hb_ADel( ::aWatches, ri, .T. )
      ENDIF
      oTable:removeRow( nRow )
   ENDIF
   RETURN NIL


METHOD IdeDebugger:changeWatch( item )
   LOCAL i, xTmp
   LOCAL r := 0
   LOCAL nEmptyNames := 0

   IF item:column() == 0
      ::oTimer:stop()
      ::nRowWatch := item:Row()
      FOR i := 0 TO ::nRowWatch
         IF Empty( ::aWatches[ i+1, 2 ] )
            nEmptyNames++
         ENDIF
      NEXT

      FOR i := 1 TO Len( ::aWatches )
         IF ::aWatches[ i, 1 ] == ::nRowWatch
            IF Empty( item:text() )
               item:setText( ::aWatches[ i, 2 ] )
               RETURN NIL
            ENDIF
            IF Empty( ::aWatches[ i, 2 ] )
               ::aWatches[ i, 2 ] := item:text()
            ELSE
               IF ! Empty( xTmp := ::oUI:tableWatchExpressions:item( ::nRowWatch, 1 ) )
                  r := i
                  ::setMode( MODE_INPUT )
                  ::doCommand( CMD_WATCH, "del", Ltrim( Str( i - nEmptyNames ) ) )
                  ::wait4connection( "b" + LTrim( Str( ::nId1 ) ) )
               ENDIF
            ENDIF
         ENDIF
      NEXT

      IF ! Empty( item:text() )
         IF r > 0
            hb_ADel( ::aWatches, r, .T. )
            AAdd( ::aWatches, { ::nRowWatch, item:text() } )
         ENDIF
         ::setMode( MODE_INPUT )
         ::doCommand( CMD_WATCH, "add", Str2Hex( item:text() ) )
      ELSE
         ::aWatches[ r,2 ] := ""
      ENDIF
      ::oTimer:start()
   ENDIF
   HB_SYMBOL_UNUSED( xTmp )
   RETURN NIL


METHOD IdeDebugger:terminateDebug()
   ::SetMode( MODE_INPUT )
   ::doCommand( CMD_TERMINATE )
   RETURN NIL


METHOD IdeDebugger:exitDbg()
   IF ::nExitMode == 1
      IF ::hRequest != -1
         ::send( "cmd", "exit" )
      ENDIF
   ELSEIF ::nExitMode == 2
      ::send( "cmd", "quit" )
   ENDIF
   ::lDebugging := .F.
   ::stopDebug()
   RETURN .T.


METHOD IdeDebugger:ui_init( oUI )
   LOCAL oHeaders

   WITH OBJECT oHeaders := QStringList()
      :append( "Expression" )
      :append( "Value"      )
   ENDWITH
   oUI:tableWatchExpressions:setHorizontalHeaderLabels( oHeaders )
   ::fineTune( oUI:tableWatchExpressions )
   oUI:tableWatchExpressions:setEditTriggers( QAbstractItemView_DoubleClicked )

   WITH OBJECT oHeaders := QStringList()
      :append( "Source" )
      :append( "Proc"   )
      :append( "Line"   )
   ENDWITH
   oUI:tableStack:setHorizontalHeaderLabels( oHeaders )
   ::fineTune( oUI:tableStack )

   WITH OBJECT oHeaders := QStringList()
      :append( "Name"  )
      :append( "Typ"   )
      :append( "Value" )
   ENDWITH
   oUI:tableVarLocal  :setHorizontalHeaderLabels( oHeaders )
   oUI:tableVarPrivate:setHorizontalHeaderLabels( oHeaders )
   oUI:tableVarPublic :setHorizontalHeaderLabels( oHeaders )
   oUI:tableVarStatic :setHorizontalHeaderLabels( oHeaders )

   ::fineTune( oUI:tableVarLocal   )
   ::fineTune( oUI:tableVarPrivate )
   ::fineTune( oUI:tableVarPublic  )
   ::fineTune( oUI:tableVarStatic  )

   WITH OBJECT oHeaders := QStringList()
      :append( "Alias"          )
      :append( "Area"           )
      :append( "Rdd"            )
      :append( "Records"        )
      :append( "Current"        )
      :append( "Bof"            )
      :append( "Eof"            )
      :append( "Found"          )
      :append( "Del"            )
      :append( "Filter"         )
      :append( "TagName"        )
      :append( "IndexCondition" )
   ENDWITH
   oUI:tableOpenTables:setHorizontalHeaderLabels( oHeaders )
   ::fineTune( oUI:tableOpenTables )

   WITH OBJECT oHeaders := QStringList()
      :append( "FieldName" )
      :append( "Typ"   )
      :append( "Len"   )
      :append( "Value" )
   ENDWITH
   oUI:tableCurrentRecord:setHorizontalHeaderLabels( oHeaders )
   ::fineTune( oUI:tableCurrentRecord )

   WITH OBJECT oHeaders := QStringList()
      :append( "Name"  )
      :append( "Typ"   )
      :append( "Value" )
   ENDWITH
   oUI:tableObjectInspector:setHorizontalHeaderLabels( oHeaders )
   ::fineTune( oUI:tableObjectInspector )

   WITH OBJECT oHeaders := QStringList()
      :append( "Set"   )
      :append( "Value" )
   ENDWITH
   oUI:tableSets:setHorizontalHeaderLabels( oHeaders )
   ::fineTune( oUI:tableSets )

   oUI:btnObjBack           :connect( "clicked()", { || ::manageObjectLevelUp() } )
   oUI:btnObjBack:setEnabled( .F. )

   oUI:btnGo                :connect( "clicked()", { || ::doCommand( CMD_GO     ), ::waitState( 0.2 ) } )
   oUI:btnNextR             :connect( "clicked()", { || ::doCommand( CMD_NEXTR  ), ::waitState( 0.2 ) } )
   oUI:btnStep              :connect( "clicked()", { || ::doCommand( CMD_STEP   ), ::waitState( 0.2 ) } )
   oUI:btnToCursor          :connect( "clicked()", { || ::doCommand( CMD_TOCURS ), ::waitState( 0.2 ) } )
   oUI:btnTrace             :connect( "clicked()", { || ::doCommand( CMD_TRACE  ), ::waitState( 0.2 ) } )
   oUI:btnClipboard         :connect( "clicked()", { || ::copyOnClipboard() } )
   oUI:btnSwitch            :connect( "clicked()", { || ::switchUI()        } )
   oUI:btnExit              :connect( "clicked()", { || ::nExitMode := 2, ::exitDbg()         } )

   oUI:btnAddWatch          :connect( "clicked()", { || ::watch_ins()       } )
   oUI:btnPasteWatch        :connect( "clicked()", { || ::watch_ins( .T. )  } )
   oUI:btnDeleteWatch       :connect( "clicked()", { || ::watch_del()       } )
   oUI:btnClearWatches      :connect( "clicked()", { || ::watch_del( .T. )  } )
   oUI:btnSaveWatches       :connect( "clicked()", { || ::watch_save()      } )
   oUI:btnRestWatches       :connect( "clicked()", { || ::watch_rest()      } )

   oUI:tableWatchExpressions:connect( "itemChanged(QTableWidgetItem*)", {| item | ::changeWatch( item )           } )
   oUI:tableOpenTables      :connect( "cellActivated(int,int)"        , {| row, col | ::requestRecord( row, col ) } )
   oUI:tabWidget            :connect( "currentChanged(int)"           , {|index| ::requestVars( index )           } )

   oUI:tableVarLocal        :connect( "itemDoubleClicked(QTableWidgetItem*)", {|/*oItem*/| ::inspectObject( .T. ) } )
   oUI:tableVarPrivate      :connect( "itemDoubleClicked(QTableWidgetItem*)", {|/*oItem*/| ::inspectObject( .T. ) } )
   oUI:tableVarPublic       :connect( "itemDoubleClicked(QTableWidgetItem*)", {|/*oItem*/| ::inspectObject( .T. ) } )
   oUI:tableVarStatic       :connect( "itemDoubleClicked(QTableWidgetItem*)", {|/*oItem*/| ::inspectObject( .T. ) } )

   oUI:tableObjectInspector :connect( "itemDoubleClicked(QTableWidgetItem*)", {|/*oItem*/| ::inspectObjectEx() } )

   oUI:labelSets            :connect( QEvent_MouseButtonPress, {|oEvent| iif( oEvent:button() == Qt_LeftButton, ::requestSets(), NIL ) } )
   //oUI                      :connect( QEvent_Close           , {|| ::exitDbg() } )
   oUI                      :connect( QEvent_KeyPress        , {|oEvent| ::manageKey( oEvent:key() ) } )
   RETURN NIL


METHOD IdeDebugger:switchUI()
   IF ::oUI:btnSwitch:text() == "UI_1"
      ::oUI := ::oUI_1
   ELSE
      ::oUI := ::oUI_2
   ENDIF
   ::oDebuggerDock:oWidget:setWidget( ::oUI:oWidget )
   ::oDebuggerDock:oWidget:hide()
   ::oDebuggerDock:oWidget:show()
   ::oDebuggerDock:oWidget:raise()
   ::oUI:show()
   RETURN Self


METHOD IdeDebugger:manageKey( nQtKey )
   IF ::isActive()
      SWITCH nQtKey
      CASE Qt_Key_F5 ; ::doCommand( CMD_GO     ) ; EXIT
      CASE Qt_Key_F6 ; ::doCommand( CMD_NEXTR  ) ; EXIT
      CASE Qt_Key_F7 ; ::doCommand( CMD_TOCURS ) ; EXIT
      CASE Qt_Key_F8 ; ::doCommand( CMD_STEP   ) ; EXIT
      CASE Qt_Key_F10; ::doCommand( CMD_TRACE  ) ; EXIT
      ENDSWITCH
   ENDIF
   RETURN .F.


METHOD IdeDebugger:fineTune( oTable )
   LOCAL i

   FOR i := 1 TO oTable:columnCount()
      oTable:horizontalHeader:setSectionResizeMode( i-1, QHeaderView_ResizeToContents )
   NEXT
   oTable:horizontalHeader:setHighlightSections( .F. )

   oTable:setEditTriggers( QAbstractItemView_NoEditTriggers )
   oTable:setSelectionBehavior( QAbstractItemView_SelectItems )
   oTable:setSelectionMode( QAbstractItemView_SingleSelection )
   RETURN Self


STATIC FUNCTION Int2Hex( n )
   LOCAL n1 := Int( n/16 ), n2 := n % 16

   IF n > 255
      RETURN "XX"
   ENDIF
   RETURN Chr( iif( n1 < 10, n1 + 48, n1 + 55 ) ) + Chr( iif( n2 < 10, n2 + 48, n2 + 55 ) )


STATIC FUNCTION Str2Hex( stroka )
   LOCAL i
   LOCAL cRes := ""
   LOCAL nLen := Len( stroka )

   FOR i := 1 to nLen
      cRes += Int2Hex( Asc( Substr( stroka, i, 1 ) ) )
   NEXT
   RETURN cRes


STATIC FUNCTION Hex2Str( stroka )
   LOCAL cRes := ""
   LOCAL i    := 1
   LOCAL nLen := Len( stroka )

   IF nLen > 0
      DO WHILE i <= nLen
         cRes += Chr( Hex2Int( Substr( stroka, i, 2 ) ) )
         i += 2
      ENDDO
   ENDIF
   RETURN cRes


STATIC FUNCTION Hex2Int( stroka )
   LOCAL res
   LOCAL i := Asc( stroka )

   IF i > 64 .AND. i < 71
      res := ( i - 55 ) * 16
   ELSEIF i > 47 .AND. i < 58
      res := ( i - 48 ) * 16
   ELSE
      RETURN 0
   ENDIF
   i := Asc( SubStr( stroka, 2, 1 ) )
   IF i > 64 .AND. i < 71
      res += i - 55
   ELSEIF i > 47 .AND. i < 58
      res += i - 48
   ENDIF
   RETURN res

