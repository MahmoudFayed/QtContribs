/*
 * $Id$
 */

/*
 * Harbour Project source code:
 *
 *
 * Copyright 2012 Pritpal Bedi <bedipritpal@hotmail.com>
 * www - http://harbour-project.org
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

#include "hbclass.ch"
#include "hblang.ch"

#include "color.ch"
#include "setcurs.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "hblang.ch"

#include "color.ch"
#include "setcurs.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "button.ch"

#include "hbqtgui.ch"

#include "hbtrace.ch"

#define GET_CLR_UNSELECTED                        0
#define GET_CLR_ENHANCED                          1
#define GET_CLR_CAPTION                           2
#define GET_CLR_ACCEL                             3

#define _QGET_GET                                 1
#define _QGET_CAPTION                             2
#define _QGET_COLOR                               3
#define _QGET_VALIDATOR                           4
#define _QGET_NOMOUSE                             5
#define _QGET_ROW                                 6
#define _QGET_COL                                 7
#define _QGET_SAY                                 8
#define _QGET_SAYPICTURE                          9
#define _QGET_SAYCOLOR                           10
#define _QGET_CONTROL                            11

/*----------------------------------------------------------------------*/

FUNCTION _QGET_( ... )
   LOCAL aParam := hb_aParams()

   aParam[ _QGET_GET ]:row := aParam[ _QGET_ROW ]
   aParam[ _QGET_GET ]:col := aParam[ _QGET_COL ]

   aParam[ _QGET_GET ]:cargo := aParam

   RETURN aParam[ _QGET_GET ]

/*----------------------------------------------------------------------*/

FUNCTION __hbQtBindGetList( oWnd, GetList )
   LOCAL n, oGetList

   THREAD STATIC t_GetList := {}

   IF HB_ISOBJECT( oWnd )
      IF ( n := AScan( t_GetList, {|e_| e_[ 1 ] == oWnd } ) ) > 0
         oGetList := t_GetList[ n, 2 ]
      ENDIF
      IF HB_ISOBJECT( GetList )
         IF n > 0
            t_GetList[ n, 2 ] := GetList
         ELSE
            AAdd( t_GetList, { oWnd, GetList } )
         ENDIF
      ELSEIF PCount() >= 2 .AND. n > 0
         hb_ADel( t_GetList, n, .T. )
      ENDIF
   ENDIF

   RETURN oGetList

/*----------------------------------------------------------------------*/

FUNCTION HbQtReadGets( GetList, SayList, oWnd, oFont )
   LOCAL oFLayout, oEdit, aEdit, oGet, cClsName, oFontM, lFLayout
   LOCAL nLHeight, nAvgWid, cText, nObjHeight, oLabel, aPic
   LOCAL nLineSpacing := 6, nEditPadding := 4
   LOCAL nMinX := 50000, nMaxX := 0, nMinY := 50000, nMaxY := 0
   LOCAL nX, nY, nW, nH
   LOCAL aGetList := {}
   LOCAL oGetList

   IF Empty( oFont )
      oFont := QFont( QFont( "Courier New", 10 ) )
   ENDIF

   cClsName := __objGetClsName( oWnd )
   IF cClsName == "QFORMLAYOUT"
      oFLayout := oWnd
   ELSE
      oFLayout := oWnd:layout()
      IF ! Empty( oFLayout )
         oWnd:removeLayout( oFLayout )
      ENDIF
   ENDIF
   lFLayout := ! Empty( oFLayout )

   IF ! lFLayout                              /* Compute row height and formulae to have text width */
      oEdit := QLineEdit( oWnd )
      oEdit:setFont( oFont )
      oFontM     := QFontMetrics( oEdit:font() )
      nObjHeight := oFontM:height() + nEditPadding
      nAvgWid    := oFontM:averageCharWidth()
      nLHeight   := nObjHeight + nLineSpacing
      oEdit:setParent( QWidget() )
   ENDIF

   IF Len( GetList ) >= 1
      FOR EACH oGet IN GetList
         aEdit      := oGet:cargo
         IF ! Empty( aEdit[ _QGET_SAY ] )
            AAdd( SayList, { oGet:row, oGet:col, aEdit[ _QGET_SAY ], aEdit[ _QGET_SAYPICTURE ], aEdit[ _QGET_SAYCOLOR ] } )
            oGet:col += Len( Transform( aEdit[ _QGET_SAY ], aEdit[ _QGET_SAYPICTURE ] ) ) + 1
         ENDIF
      NEXT
   ENDIF

   /* This is independent of @ ... SAY ... GET combined */
   IF Len( SayList ) >= 1
      FOR EACH aPic IN SayList
         oLabel := QLabel( oWnd )
         cText  := Transform( aPic[ 3 ], aPic[ 4 ] )
         oLabel:setText( cText )
         oLabel:setFont( oFont )
         oLabel:setAlignment( Qt_AlignLeft + Qt_AlignVCenter )

         nX    := ( aPic[ 2 ] * nAvgWid ) + nLineSpacing
         nY    := aPic[ 1 ] * nLHeight
         nW    := nLineSpacing + ( Len( cText ) * nAvgWid )
         nH    := nObjHeight
         nMinX := Min( nMinX, nX )
         nMaxX := Max( nMaxX, nX + nW )
         nMinY := Min( nMinY, nY )
         nMaxY := Max( nMaxY, nY + nH )
         oLabel:move( nX, nY )
         oLabel:resize( nW, nH )
      NEXT
   ENDIF

   oGetList := HbQtGetList():New( aGetList )

   IF Len( GetList ) >= 1
      FOR EACH oGet IN GetList
         aEdit         := oGet:cargo
         oGet:cargo    := NIL

         oEdit         := HbQtGet():new()
         oEdit:parent  := oWnd
         oEdit:font    := oFont
         oEdit:getList := oGetList
         oEdit:get     := oGet   /* This is important - all variables will be initialized here instead of in :new() */

         IF ! Empty( aEdit[ _QGET_COLOR ] )
            oEdit:color := aEdit[ _QGET_COLOR ]
         ENDIF

         IF HB_ISBLOCK( aEdit[ _QGET_VALIDATOR ] )
            oEdit:inputValidator := aEdit[ _QGET_VALIDATOR ]
         ENDIF

         oEdit:mousable := ! aEdit[ _QGET_NOMOUSE ]

         oEdit:create()

         IF lFLayout
            oFLayout:addRow( iif( Empty( aEdit[ _QGET_CAPTION ] ), oGet:name(), aEdit[ _QGET_CAPTION ] ), oEdit )
         ELSE
            nX    := ( oGet:col * nAvgWid ) + nLineSpacing
            nY    := oGet:row * nLHeight
            nW    := nLineSpacing + ( oEdit:getDispWidth() * nAvgWid )
            nH    := nObjHeight
            nMinX := Min( nMinX, nX )
            nMaxX := Max( nMaxX, nX + nW )
            nMinY := Min( nMinY, nY )
            nMaxY := Max( nMaxY, nY + nH )
            //
            oEdit:setPosAndSize( { nX, nY }, { nW, nH } )
         ENDIF

         AAdd( aGetList, oEdit )
      NEXT

      aGetList[ 1 ]:edit:setFocus()
      aGetList[ 1 ]:edit:selectAll()

      oWnd:setFocusPolicy( Qt_NoFocus )
      oWnd:resize( nMaxX + nMinX, nMaxY + nMinY )  /* Fit to the contents maintaining margins */

   ENDIF

   __hbQtBindGetList( oWnd, oGetList )
   __GetListSetActive( oGetList )
   __GetListLast( oGetList )

   /* Probably will be fired only when oWnd is a top level window - needs to be investigated further */
   oWnd:connect( QEvent_Close, {|| __hbQtBindGetList( oWnd, NIL ), .F. } )

   RETURN NIL

/*----------------------------------------------------------------------*/
//                            CLASS HbQtEdit
/*----------------------------------------------------------------------*/

//CLASS HbQtGet INHERIT HB_QLineEdit, Get
CLASS HbQtGet INHERIT GET

   METHOD new( oControl )
   METHOD create( oControl )
   METHOD edit()                                  INLINE ::oEdit
   METHOD get( oGet )                             SETGET
   METHOD control( oControl )                     SETGET
   METHOD getList( oGetList )                     SETGET
   METHOD parent( oParent )                       SETGET
   METHOD picture( cPicture )                     SETGET
   METHOD color( cnaColor )                       SETGET
   METHOD font( oFont )                           SETGET
   METHOD inputValidator( bBlock )                SETGET
   METHOD mousable( lEnable )                     SETGET
   METHOD setData( xData )
   METHOD getData()
   METHOD getDispWidth()                          INLINE ::sl_dispWidth
   METHOD setPosAndSize( aPos, aSize )

   PROTECTED:
   VAR    oEdit
   VAR    oGet
   VAR    oParent
   VAR    oControl
   VAR    oGetList

   VAR    lValidWhen                              INIT .T.
   VAR    sl_maskChrs                             INIT ""
   VAR    sl_qMask                                INIT ""

   VAR    sl_color
   VAR    sl_inputValidator
   VAR    sl_mousable                             INIT .T.

   VAR    sl_dispWidth                            INIT 0
   VAR    sl_width                                INIT 0
   VAR    sl_dec                                  INIT 0
   VAR    sl_prime                                INIT 0

   VAR    sl_dFormat                              INIT Set( _SET_DATEFORMAT )

   VAR    sl_cssColor                             INIT ""
   VAR    sl_cssNotValid                          INIT "color: rgb(0,0,0); background-color: rgb(255,128,128);"
   VAR    sl_decSep                               INIT "."
   VAR    sl_decProxy                             INIT "."
   VAR    sl_commaSep                             INIT ","
   VAR    sl_commaProxy                           INIT ","
   VAR    sl_fixupCalled                          INIT .F.
   VAR    sl_font
   VAR    lUserControl                            INIT .F.
   VAR    aPos                                    INIT {}
   VAR    aSize                                   INIT {}
   VAR    cClassName                              INIT ""

   METHOD execFocusOut( oFocusEvent )
   METHOD execFocusIn( oFocusEvent )
   METHOD execKeyPress( oKeyEvent )
   METHOD testValid()
   METHOD setParams()
   METHOD getNumber( cText, nPos )
   METHOD getDate( cText, nPos )
   METHOD getLogical( cText, nPos )
   METHOD getCharacter( cText, nPos )
   METHOD getRgbStringFromClipperColor( cToken, lExt )
   METHOD transformThis( xData, cMask )
   METHOD unTransformThis( cData )
   METHOD timesOccurs( cToken, cText )
   METHOD fixup( cText )
   METHOD returnPressed()
   METHOD isBufferValid()
   METHOD isDateBad()

   EXPORTED:
   /* ::oGet operation methods overloaded from GET : begins */
   METHOD assign()
   METHOD block( bBlock )                         SETGET
   ACCESS pos                                     METHOD getPos()
   ASSIGN pos                                     METHOD setPos( nPos )
   METHOD updateBuffer()
   METHOD putMask( xValue, lEdit )
   METHOD reset()
   /* ::oGet operation methods overloaded from GET : ends */

   ENDCLASS

/*----------------------------------------------------------------------*/

METHOD HbQtGet:new( oControl )

   IF HB_ISOBJECT( oControl )
      ::oControl := oControl
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbQtGet:create( oControl )

   hb_default( @oControl, ::oControl )

   IF HB_ISOBJECT( oControl )
      ::oControl := oControl
   ENDIF

   IF HB_ISOBJECT( ::oControl )
      ::lUserControl := .T.
      ::oEdit := ::oControl
   ELSE
      ::oEdit := QLineEdit( ::oParent )
   ENDIF

   ::cClassName := __objGetClsName( ::oEdit )

   SWITCH ::cClassName
   CASE "QLINEEDIT"
      ::oEdit:connect( "textEdited(QString)" , {|| ::testValid() } )
      ::oEdit:connect( "textChanged(QString)", {|| ::testValid() } )

      ::oEdit:connect( QEvent_FocusOut       , {|oFocusEvent| ::execFocusOut( oFocusEvent ) } )

      ::oEdit:connect( "returnPressed()"     , {|| ::returnPressed(), .F. } )

      ::oEdit:connect( QEvent_FocusIn        , {|oFocusEvent| ::execFocusIn( oFocusEvent ) } )
      ::oEdit:connect( QEvent_KeyPress       , {|oKeyEvent| ::execKeyPress( oKeyEvent ) } )
      EXIT
   CASE "QCHECKBOX"
      EXIT
   CASE "QPUSHBUTTON"
      EXIT
   ENDSWITCH

   /* Still TO be determined IF font should be of fixed pitch IF it is a user supplied control */
   IF ! HB_ISOBJECT( ::sl_font )
      ::sl_font := QFont( "Courier New", 10 )
   ENDIF

   IF ! ::lUserControl
      ::oEdit:setFocusPolicy( iif( ::sl_mousable, Qt_StrongFocus, Qt_TabFocus ) )
      IF ::cClassName == "QLINEEDIT"
         ::oEdit:setStyleSheet( ::sl_cssColor )
         ::oEdit:setFont( ::sl_font )
      ENDIF
   ENDIF

   ::setParams()
   ::setData( ::original )

   IF ::cClassName == "QLINEEDIT"
      ::oEdit:setCursorPosition( 0 )
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbQtGet:control( oControl )

   IF HB_ISOBJECT( oControl )
      ::oControl := oControl
   ENDIF

   RETURN ::oControl

/*----------------------------------------------------------------------*/

METHOD HbQtGet:get( oGet )

   IF HB_ISOBJECT( oGet )
      ::oGet      := oGet

      ::subScript := ::oGet:subScript()
      ::preBlock  := ::oGet:preBlock()
      ::postBlock := ::oGet:postBlock()
      ::picture   := ::oGet:picture()
      ::name      := ::oGet:name()
      ::row       := ::oGet:row()
      ::col       := ::oGet:col()
      ::block     := ::oGet:block()
   ENDIF

   RETURN ::oGet

/*----------------------------------------------------------------------*/

METHOD HbQtGet:parent( oParent )

   IF HB_ISOBJECT( oParent )
      ::oParent := oParent
   ENDIF

   RETURN ::oParent

/*----------------------------------------------------------------------*/

METHOD HbQtGet:getList( oGetList )

   IF HB_ISOBJECT( oGetList )
      ::oGetList := oGetList
   ENDIF

   RETURN ::oGetList

/*----------------------------------------------------------------------*/

METHOD HbQtGet:font( oFont )

   IF HB_ISOBJECT( oFont )
      ::sl_font := oFont
   ENDIF

   RETURN ::sl_font

/*----------------------------------------------------------------------*/

METHOD HbQtGet:setPosAndSize( aPos, aSize )

   hb_default( @aPos, ::aPos )
   hb_default( @aSize, ::aSize )

   ::aPos := aPos
   ::aSize := aSize

   IF HB_ISARRAY( ::aPos ) .AND. Len( ::aPos ) == 2
      ::oEdit:move( ::aPos[ 1 ], ::aPos[ 2 ] )
   ENDIF
   IF HB_ISARRAY( ::aSize ) .AND. Len( ::aSize ) == 2
      ::oEdit:resize( ::aSize[ 1 ], ::aSize[ 2 ] )
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbQtGet:mousable( lEnable )

   IF HB_ISLOGICAL( lEnable )
      ::sl_mousable := lEnable
   ENDIF

   RETURN ::sl_mousable

/*----------------------------------------------------------------------*/

METHOD HbQtGet:returnPressed()

   QApplication():sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Tab, Qt_NoModifier ) )

   RETURN .T.

/*----------------------------------------------------------------------*/

METHOD HbQtGet:fixup( cText )

   ::sl_fixupCalled := .T.

   IF Len( cText ) == 0
      SWITCH ::cType
      CASE "C"   ; RETURN ""
      CASE "N"   ; RETURN "0"
      CASE "D"   ; RETURN CToD( "" )
      CASE "L"   ; RETURN "F"
      ENDSWITCH
   ENDIF

   RETURN NIL

/*----------------------------------------------------------------------*/
#if 0
 Get Picture Functions
--------------------------------------------------------------------------------
 A     C     Allow only alpha characters
 B     N     Display numbers left-justified
 C     N     Display CR after positive numbers
 D     D,N   Display dates in SET DATE format
 E     D,N   Display dates with day and month inverted independent of the current DATE SETting,
             numerics with comma and period reverse
 K     All   Delete default text if first key is not a cursor key
 R     C     Insert non-template characters in the display but do not
             save in the Get variable
 S<n>  C     Allows horizontal scrolling within a Get.  <n> is an integer
             that specifies the width of the region
 X     N     Display DB after negative numbers
 Z     N     Display zero as blanks
 (     N     Display negative numbers in parentheses with leading spaces
 )     N     Display negative numbers in parentheses without leading spaces
 !     C     Convert alphabetic character to upper case


 Get Picture Template Symbols
--------------------------------------------------------------------------------
 A    Allow only alphabetic characters
 N    Allow only alphabetic and numeric characters
 X    Allow any character
 9    Allow digits for any data type including sign for numerics
 #    Allow digits, signs and spaces for any data type
 !    Convert alphabetic character to upper case

 L    Allow only T, F, Y or N
 Y    Allow only Y or N

 $    Display a dollar sign in place of a leading space in a numeric
 *    Display an asterisk in place of a leading space in a numeric
 .    Display a decimal point
 ,    Display a comma


   Some examples
--------------------------------------------------------------------------------
 "@!"            -> all the alpha chars are uppercased
 "@! ANX9"       -> as above, but the first char must be alpha, the second alpha or numeric, the third any char, the fourth a digit
 "@E 999,999.99" -> comma is point (and viceversa) as for european numeric notation, two decimal are allowed
 "@Z 9999999"    -> no thousand separator, max 7 digits, if get value is 0 the edit buffer contains only spaces
 "999.99"        -> no thousand separator, max 3 integer (included the eventual sign) and 2 decimals, the decimal separator is point
 "@S20"          -> if the get buffer is more than 20 char long, editing after the 20th char causes the scrolling in place to manage the rest of the string
 "Y"             -> the get accept only one char corresponding to Y or N
 "L"             -> as above, but also T or F are accepted (true or false, obviously)

#endif

METHOD HbQtGet:getCharacter( cText, nPos )

   LOCAL cChr, lRet, cMask, nP

   IF ::sl_fixupCalled
      ::sl_fixupCalled := .F.
      RETURN .T.
   ENDIF

   IF Len( cText ) == 0
      RETURN .T.
   ENDIF
   cChr := SubStr( cText, nPos, 1 )

   IF "A" $ ::cPicFunc .AND. ! IsAlpha( cChr )
      RETURN .F.
   ENDIF
   IF "!" $ ::cPicFunc
      cText := Upper( cText )
   ENDIF
   IF ! Empty( ::cPicMask )
      IF cChr $ ::sl_maskChrs
         nP := nPos - 1
         cMask := SubStr( ::cPicMask, nP-1, 1 )
         cChr := SubStr( cText, nP, 1 )
      ELSE
         nP := nPos
         cMask := SubStr( ::cPicMask, nP, 1 )
      ENDIF

      SWITCH cMask
      CASE "A"
         IF ! IsAlpha( cChr )
            RETURN .F.
         ENDIF
         EXIT
      CASE "N"
         IF ! IsAlpha( cChr ) .OR. ! IsDigit( cChr )
            RETURN .F.
         ENDIF
         EXIT
      CASE "9"
         IF ! cChr $ "+-0123456789"
            RETURN .F.
         ENDIF
         EXIT
      CASE "#"
         IF ! cChr $ " +-0123456789"
            RETURN .F.
         ENDIF
         EXIT
      CASE "!"
         cText := SubStr( cText, 1, nP - 1 ) + Upper( cChr ) + SubStr( cText, nP + 1 )
         EXIT
      CASE "X"
         EXIT
      ENDSWITCH
   ENDIF
   lRet := .T.
   IF HB_ISBLOCK( ::sl_inputValidator )
      lRet := Eval( ::sl_inputValidator, @cText, @nPos )
   ENDIF

   RETURN { cText, nPos, lRet }

/*----------------------------------------------------------------------*/

METHOD HbQtGet:getNumber( cText, nPos )

   LOCAL cChr, lRet, nDecAt, lInDec, nTmp, cImage

   IF ::sl_fixupCalled
      ::sl_fixupCalled := .F.
      RETURN .T.
   ENDIF
   cImage := cText

   cChr := SubStr( cText, nPos, 1 )

   IF cChr == "-" .AND. Len( cText ) == 1
      RETURN .T.
   ENDIF
   IF ! ( cChr $ ",.+-1234567890" )   /* It must be a number character */
      cText := ::transformThis( ::unTransformThis( cText ), ::cPicture )
      RETURN { cText, nPos, .T. }
   ENDIF
   IF cChr $ "+-" .AND. nPos > 1
      RETURN .F.
   ENDIF
   IF cChr $ "+-" .AND. nPos == 1 .AND. SubStr( cText, 2, 1 ) $ "+-"
      RETURN .F.
   ENDIF
   IF cChr $ ",." .AND. ::sl_dec == 0  /* Variable does not hold decimal places */
      RETURN .F.
   ENDIF

   IF cChr $ ",."
      cText := SubStr( cText, 1, nPos - 1 ) + ::sl_decProxy + SubStr( cText, nPos + 1 )
   ENDIF

   IF cChr $ ",." .AND. ::timesOccurs( ::sl_decProxy, cText ) > 1 /* Jump to decimal if present */
      cText  := SubStr( cText, 1, nPos - 1 ) + SubStr( cText, nPos + 1 )
      nDecAt := At( ::sl_decProxy, cText )
      nPos   := nDecAt
      cText  := SubStr( cText, 1, nDecAt ) + Left( SubStr( cText, nDecAt + 1 ), ::sl_dec )
      RETURN { cText, nPos, .T. }
   ELSEIF cChr $ ",."
      cText := ::transformThis( ::unTransformThis( cText ), ::cPicture )
      RETURN { cText, nPos, .T. }
   ELSEIF Len( cText ) <= 1              /* when selectall is active and a key is pressed */
      cText := ::transformThis( ::unTransformThis( cText ), ::cPicture )
      RETURN { cText, nPos, .T. }
   ENDIF

   nDecAt := At( ::sl_decProxy, cText )

   lInDec := iif( nDecAt == 0, .F., nPos >= nDecAt )
   IF lInDec
      cText := SubStr( cText, 1, nPos - 1 ) + cChr + SubStr( cText, nPos + 2, Len( cText ) - 1 )
      cText := ::transformThis( ::unTransformThis( cText ), ::cPicture )
      RETURN { cText, nPos, .T. }
   ENDIF

   cText := ::unTransformThis( cText )
   nTmp := At( ::sl_decProxy, cText )
   IF iif( nTmp > 0, nTmp - 1, Len( cText ) ) > ::sl_prime
      RETURN .F.
   ENDIF
   cText := ::transformThis( cText, ::cPicture )

   IF nDecAt > 0
      IF At( ::sl_decProxy, cText ) > nDecAt
         nPos++
      ELSEIF At( ::sl_decProxy, cText ) < nDecAt
         nPos--
      ENDIF
   ENDIF

   lRet := .T.
   IF HB_ISBLOCK( ::sl_inputValidator )
      lRet := Eval( ::sl_inputValidator, @cText, @nPos )
   ENDIF

   IF Left( cText, 1 ) == "+"
      cText := SubStr( cText, 2 )
      nPos--
   ENDIF

   IF cChr $ "+-" .AND. Len( cText ) == 0
      RETURN { "-", 1, .T. }
   ENDIF

   IF Len( cImage ) < Len( cText )  /* Some formatting character is inserted */
      nTmp := 0
      FOR EACH cChr IN cImage
         IF SubStr( cText, cChr:__enumIndex(), 1 ) != cChr
            EXIT
         ENDIF
         nTmp++
      NEXT
      IF nTmp < nPos .AND. nPos == Len( cText ) - 1
         nPos++
      ENDIF
   ELSEIF Len( cImage ) > Len( cText )
      // Some formatting character is deleted
   ENDIF

   RETURN { cText, nPos, lRet }

/*----------------------------------------------------------------------*/

METHOD HbQtGet:getDate( cText, nPos )

   LOCAL lRet

   IF ::sl_fixupCalled
      ::sl_fixupCalled := .F.
      RETURN .T.
   ENDIF

   lRet  := .T.
   IF HB_ISBLOCK( ::sl_inputValidator )
      lRet := Eval( ::sl_inputValidator, @cText, @nPos )
   ENDIF

   RETURN { cText, nPos, lRet }

/*----------------------------------------------------------------------*/

METHOD HbQtGet:getLogical( cText, nPos )

   IF ::sl_fixupCalled
      ::sl_fixupCalled := .F.
      RETURN .T.
   ENDIF

   cText := Upper( SubStr( cText, nPos, 1 ) )

   IF ! cText $ "NnYyTtFf"
      RETURN .F.
   ENDIF
   IF "Y" $ ::cPicFunc
      IF cText $ "Tt"
         cText :=  "Y"
      ELSEIF cText $ "Ff"
         cText :=  "N"
      ENDIF
   ELSE
      IF cText $ "Yy"
         cText := "T"
      ELSEIF cText $ "Nn"
         cText := "F"
      ENDIF
   ENDIF

   IF HB_ISBLOCK( ::sl_inputValidator )
      RETURN Eval( ::sl_inputValidator, @cText, @nPos )
   ENDIF

   RETURN { cText, 0, .T. }

/*----------------------------------------------------------------------*/

METHOD HbQtGet:setParams()

   LOCAL cTmp, cChr, n

   SWITCH ::cType
   CASE "C"
      ::sl_width := Len( ::original )
      IF ! Empty( ::cPicMask )
         ::sl_width := Len( ::cPicMask )
         ::oEdit:setInputMask( ::sl_qMask )
      ENDIF
      ::sl_dispWidth := Len( Transform( ::original, ::cPicture ) )
      ::oEdit:setMaxLength( ::sl_width )
      ::oEdit:setValidator( HBQValidator( {|cText,nPos| ::getCharacter( cText, nPos ) }, {|cText| ::fixup( cText ) } ) )
      EXIT
   CASE "N"
      IF ! Empty( ::cPicMask )
         cTmp       := ::cPicMask
         n          := At( ::sl_decSep, cTmp )
         ::sl_width := ::timesOccurs( "9", cTmp ) + iif( n > 0, 1, 0 )
         ::sl_dec   := iif( n > 0, ::timesOccurs( "9", SubStr( cTmp, n+1 ) ), 0 )
         ::sl_prime := ::sl_width - iif( ::sl_dec > 0, ::sl_dec + 1, 0 )
      ELSE
         cTmp       := Str( ::original )
         ::sl_width := Len( cTmp )
         n          := At( ::sl_decSep, cTmp )
         ::sl_dec   := iif( n > 0, Len( SubStr( cTmp, n+1 ) ), 0 )
         ::sl_prime := iif( n == 0, ::sl_width, ::sl_width - 1 - ::sl_dec )
      ENDIF
      ::sl_dispWidth := Len( Transform( ::original, ::cPicture ) )
      ::oEdit:setValidator( HBQValidator( {|cText,nPos| ::getNumber( cText, nPos ) }, {|cText| ::fixup( cText ) } ) )
      IF ! ( "B" $ ::cPicFunc )
         ::oEdit:setAlignment( Qt_AlignRight )
      ENDIF
      IF "E" $ ::cPicFunc
         ::sl_decProxy := ","
         ::sl_commaProxy := "."
      ENDIF
      EXIT
   CASE "D"
      ::sl_width     := Len( DToC( ::original ) )
      cTmp           := Set( _SET_DATEFORMAT )
      ::sl_dispWidth := Len( Transform( ::original, ::cPicture ) )
      ::cPicMask      := ""
      ::sl_qMask     := ""
      FOR EACH cChr IN cTmp
         IF cChr $ "mdy"
            ::cPicMask  += "9"
            ::sl_qMask += "9"
         ELSE
            ::cPicMask  += cChr
            ::sl_qMask += cChr
         ENDIF
         ::oEdit:setInputMask( ::sl_qMask )
      NEXT
      ::oEdit:setValidator( HBQValidator( {|cText,nPos| ::getDate( cText, nPos ) }, {|cText| ::fixup( cText ) } ) )
      EXIT
   CASE "L"
      ::sl_width     := 1
      ::sl_dispWidth := 1
      ::oEdit:setValidator( HBQValidator( {|cText,nPos| ::getLogical( cText, nPos ) }, {|cText| ::fixup( cText ) } ) )
      EXIT
   ENDSWITCH

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbQtGet:getData()

   LOCAL cData := ::oEdit:text()

   SWITCH ::cType

   CASE "C"
      RETURN Pad( cData, ::sl_width )
   CASE "N"
      RETURN Val( ::unTransformThis( cData ) )
   CASE "D"
      RETURN CToD( cData )
   CASE "L"
      RETURN Left( cData, 1 ) $ "YyTt"

   ENDSWITCH

   RETURN ""

/*----------------------------------------------------------------------*/

METHOD HbQtGet:setData( xData )

   LOCAL cBuffer := ""

   SWITCH ::cType

   CASE "C"
      cBuffer := RTrim( xData )
      EXIT
   CASE "N"
      cBuffer := ::transformThis( xData, ::cPicture )
      EXIT
   CASE "D"
      cBuffer := DToC( xData )
      EXIT
   CASE "L"
      cBuffer := iif( xData, iif( ::cPicFunc $ "Y", "Y", "T" ), iif( ::cPicFunc $ "Y", "N", "F" ) )
      EXIT

   ENDSWITCH

   ::oEdit:setText( cBuffer )

   RETURN NIL

/*----------------------------------------------------------------------*/

METHOD HbQtGet:inputValidator( bBlock )

   IF HB_ISBLOCK( bBlock )
      ::sl_inputValidator := bBlock
   ENDIF

   RETURN ::sl_inputValidator

/*----------------------------------------------------------------------*/

METHOD HbQtGet:picture( cPicture )

   LOCAL n, cChr, qMask

   hb_default( @cPicture, "" )
   ::cPicture := cPicture
   cPicture := Upper( AllTrim( cPicture ) )
   IF ( n := At( " " , cPicture ) ) > 0
      ::cPicMask := AllTrim( SubStr( cPicture, n+1 ) )
      ::cPicFunc := AllTrim( SubStr( cPicture, 1, n-1 ) )
   ELSE
      ::cPicFunc := cPicture
   ENDIF

   IF ! ( "@" $ ::cPicFunc )
      ::cPicMask := ::cPicFunc
      ::cPicFunc := ""
   ENDIF
   IF ::cPicMask == "Y"
      ::cPicFunc := "Y"
      ::cPicMask := ""
   ENDIF
   IF ::cPicMask == "L"
      ::cPicFunc := ""
      ::cPicMask := ""
   ENDIF
   ::cPicFunc := StrTran( StrTran( ::cPicFunc, " " ), "@" )

   IF ! Empty( ::cPicMask )
      qMask := ""
      FOR EACH cChr IN ::cPicMask
         IF cChr $ "ALX9#!"
            qMask += "x"
         ELSE
            qMask += cChr
            ::sl_maskChrs += cChr
         ENDIF
      NEXT
      ::sl_qMask := qMask
   ENDIF

   RETURN ::cPicFunc

/*----------------------------------------------------------------------*/

METHOD HbQtGet:color( cnaColor )

   LOCAL n, lExt, xFore, xBack, cCSS := "" , cCSSF, cCSSB

   hb_default( @cnaColor, "" )
   ::sl_color := cnaColor
   IF Empty( ::sl_color )
      RETURN ""
   ENDIF

   ::sl_cssColor := ""

   SWITCH ValType( ::sl_color )
   CASE "C"
      IF ( n := At( "/", ::sl_color ) ) > 0
         xFore := AllTrim( SubStr( ::sl_color, 1, n-1 ) )
         xBack := AllTrim( SubStr( ::sl_color, n+1 ) )
      ELSE
         xFore := AllTrim( cnaColor )
         xBack := ""
      ENDIF

      IF ! Empty( xFore )
         lExt := At( "+", xFore ) > 0
         xFore := StrTran( StrTran( xFore, "+" ), "*" )
         cCSSF := ::getRgbStringFromClipperColor( xFore, lExt )
      ENDIF
      IF ! Empty( xBack )
         lExt := "+" $ xBack .OR. "*" $ xBack
         xBack := StrTran( StrTran( xBack, "+" ), "*" )
         cCSSB := ::getRgbStringFromClipperColor( xBack, lExt )
      ENDIF
      IF ! Empty( cCSSF )
         cCSS := "color: " + cCSSF
      ENDIF
      IF ! Empty( cCSSB )
         cCSS += "; background-color: " + cCSSB
      ENDIF

      IF ! Empty( cCSS )
         cCSS += ";"
         ::sl_cssColor := cCSS
      ENDIF

      EXIT
   CASE "N"
      EXIT
   CASE "A"
      EXIT

   ENDSWITCH

   IF HB_ISOBJECT( ::oEdit )
      ::oEdit:setStyleSheet( ::sl_cssColor )
   ENDIF

   RETURN ::sl_color

/*----------------------------------------------------------------------*/
//                            QEvent_FocusOut
/*----------------------------------------------------------------------*/

METHOD HbQtGet:execFocusOut( oFocusEvent )

   LOCAL lValid := ::isBufferValid()

   IF lValid
      RETURN .F.
   ENDIF

   ::hasFocus := .F.

   oFocusEvent:ignore()
   ::setFocus()

   RETURN .T.

/*----------------------------------------------------------------------*/
//                             QEvent_FocusIn
/*----------------------------------------------------------------------*/

METHOD HbQtGet:execFocusIn( oFocusEvent )

   IF ! Empty( ::oGetList )
      __GetListSetActive( ::oGetList )
      __GetListLast( ::oGetList )
      ::oGetList:getActive( Self )
   ENDIF

   ::hasFocus := .T.

   IF HB_ISBLOCK( ::bPreBlock )
      IF ! ( ::lValidWhen := Eval( ::bPreBlock, ::getData() ) )
         oFocusEvent:accept()
         QApplication():sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, iif( oFocusEvent:reason() == Qt_TabFocusReason, Qt_Key_Tab, Qt_Key_Backtab ), Qt_NoModifier ) )
         RETURN .T.
      ENDIF
   ENDIF

   RETURN .F.

/*----------------------------------------------------------------------*/

METHOD HbQtGet:isBufferValid()

   LOCAL xValInVar, xValInBuffer
   LOCAL lValid := .T.

   IF ::cType == "D"
      IF ::isDateBad()
         RETURN ! lValid
      ENDIF
   ENDIF
   IF HB_ISBLOCK( ::bPostBlock )
      /* Fetch Clipper Variable Value */
      xValInVar    := ::varGet()
      xValInBuffer := ::getData()
      /* Set Clipper Variable Value with Value in Buffer */
      ::varPut( xValInBuffer )
      /* Validate passing value in buffer, in case OOP gets are constructed */
      lValid := Eval( ::bPostBlock, xValInBuffer )
      /* Set Clipper Variable back to Original Value */
      //Eval( ::sl_dataLink, xValInVar )
      ::varPut( xValInVar )
   ENDIF

   RETURN lValid

/*----------------------------------------------------------------------*/

METHOD HbQtGet:testValid()

   LOCAL lValid := ::isBufferValid()

   IF ! lValid
      ::oEdit:setStyleSheet( "" )
      ::oEdit:setStyleSheet( ::sl_cssNotValid )
      ::oEdit:repaint()
   ELSE
      ::oEdit:setStyleSheet( "" )
      ::oEdit:setStyleSheet( ::sl_cssColor )
      ::oEdit:repaint()
   ENDIF

   RETURN .F.

/*----------------------------------------------------------------------*/

METHOD HbQtGet:isDateBad()
   LOCAL cChr

   FOR EACH cChr IN ::oEdit:text()
      IF IsDigit( cChr )
         IF Empty( ::getData() )
            RETURN .T.
         ENDIF
      ENDIF
   NEXT

   RETURN .F.

/*----------------------------------------------------------------------*/

METHOD HbQtGet:execKeyPress( oKeyEvent )

   SWITCH oKeyEvent:key()

   CASE Qt_Key_Escape
      ::varPut( ::original )
      ::setData( ::original )
      EXIT

   CASE Qt_Key_PageUp
      IF ! Empty( ::oGetList )
         ::oGetList:goTop( Self )
      ENDIF
      EXIT

   CASE Qt_Key_PageDown
      IF ! Empty( ::oGetList )
         ::oGetList:goBottom( Self )
      ENDIF
      EXIT

   CASE Qt_Key_Up
      QApplication():sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Backtab, Qt_NoModifier ) )
      RETURN .T.

   CASE Qt_Key_Down
      QApplication():sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Tab, Qt_NoModifier ) )
      RETURN .T.

   CASE Qt_Key_Tab
   CASE Qt_Key_Backtab
      IF ! ::lValidWhen
         ::lValidWhen := .T.
         EXIT
      ENDIF

      IF ::cType == "D" .AND. ::isDateBad()
         oKeyEvent:accept()
         RETURN .T.
      ENDIF

      ::original := ::getData()
      ::varPut( ::original )
      IF HB_ISBLOCK( ::bPostBlock )
         IF ! Eval( ::bPostBlock, ::original )
            oKeyEvent:accept()
            RETURN .T.
         ELSE
            ::oEdit:repaint()
         ENDIF
      ENDIF
      EXIT

   ENDSWITCH

   RETURN .F.

/*----------------------------------------------------------------------*/

METHOD HbQtGet:getRgbStringFromClipperColor( cToken, lExt )

   SWITCH Upper( cToken )
   CASE "N"
      RETURN iif( lExt, "rgb( 198,198,198 )", "rgb( 0 ,0 ,0  )"   )
   CASE "B"
      RETURN iif( lExt, "rgb( 0,0,255 )"    , "rgb( 0,0,133 )"    )
   CASE "G"
      RETURN iif( lExt, "rgb( 96,255,96 )"  , "rgb( 0 ,133,0  )"  )
   CASE "BG"
      RETURN iif( lExt, "rgb( 96,255,255 )" , "rgb( 0 ,133,133 )" )
   CASE "R"
      RETURN iif( lExt, "rgb( 248,0,38 )"   , "rgb( 133,0 ,0  )"  )
   CASE "RB"
      RETURN iif( lExt, "rgb( 255,96,255 )" , "rgb( 133,0 ,133  " )
   CASE "GR"
      RETURN iif( lExt, "rgb( 255,255,0 )"  , "rgb( 133,133,0 )"  )
   CASE "W"
      RETURN iif( lExt, "rgb( 255,255,255 )", "rgb( 96,96,96 )"   )
   ENDSWITCH
   RETURN ""

/*----------------------------------------------------------------------*/

METHOD HbQtGet:timesOccurs( cToken, cText )

   LOCAL cChr, n

   n := 0
   FOR EACH cChr IN cText
      IF cChr == cToken
         n++
      ENDIF
   NEXT

   RETURN n

/*----------------------------------------------------------------------*/

METHOD HbQtGet:transformThis( xData, cMask )

   IF ValType( xData ) == "C"
      xData := Val( AllTrim( xData ) )
   ENDIF

   RETURN AllTrim( Transform( xData, cMask ) )

/*----------------------------------------------------------------------*/

METHOD HbQtGet:unTransformThis( cData )
   LOCAL cChr, cText := ""

   FOR EACH cChr IN cData
      IF cChr $ "+-0123456789"
         cText += cChr
      ELSEIF cChr == ::sl_decProxy
         cText += "."
      ENDIF
   NEXT

   RETURN cText

/*----------------------------------------------------------------------*/
//                          GET Specific Methods
/*----------------------------------------------------------------------*/

METHOD HbQtGet:assign()

   IF ::hasFocus
      ::varPut( ::getData() )
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbQtGet:putMask( xValue, lEdit )

   hb_default( @lEdit, ::hasFocus )

   HB_SYMBOL_UNUSED( lEdit )

   RETURN Transform( xValue, ::cPicture )

/*----------------------------------------------------------------------*/

METHOD HbQtGet:updateBuffer()

   IF ::hasFocus
      ::cBuffer := ::putMask( ::varGet(), .F. )
      ::xVarGet := ::original
      ::oEdit:setText( ::cBuffer )
   ELSE
      ::varGet()
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbQtGet:reset()

   IF ::hasFocus
      ::cBuffer  := ::putMask( ::varGet(), .F. )
      ::xVarGet  := ::original
      ::cType    := ValType( ::xVarGet )
      ::pos      := 0
      ::lClear   := ( "K" $ ::cPicFunc .OR. ::cType == "N" )
      ::lEdit    := .F.
      ::lMinus   := .F.
      ::rejected := .F.
      ::typeOut  := !( ::type $ "CNDTL" ) .OR. ( ::nPos == 0 )
      ::oEdit:setText( ::cBuffer )
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbQtGet:getPos()
   RETURN ::oEdit:cursorPosition()

/*----------------------------------------------------------------------*/

METHOD HbQtGet:setPos( nPos )

   IF HB_ISNUMERIC( nPos )
      nPos := Int( nPos )

      IF ::hasFocus
         ::oEdit:setCursorPosition( nPos )
      ENDIF

      RETURN ::oEdit:cursorPosition()
   ENDIF

   RETURN 0

/*----------------------------------------------------------------------*/

METHOD HbQtGet:block( bBlock )

   IF PCount() == 0 .OR. bBlock == NIL
      RETURN ::bBlock
   ENDIF

   ::bBlock   := bBlock
   ::xVarGet  := ::original := ::varGet()
   ::cType    := ValType( ::xVarGet )

   RETURN ::bBlock

/*----------------------------------------------------------------------*/
//                           CLASS HbQtGetList
/*----------------------------------------------------------------------*/

CLASS HbQtGetList INHERIT HbGetList

   METHOD goNext( oGet )
   METHOD goPrevious( oGet )
   METHOD goTop( oGet )
   METHOD goBottom( oGet )
   METHOD isFirstGet( oGet )
   METHOD isLastGet( oGet )
   METHOD nextGet( oGet )
   METHOD previousGet( oGet )
   METHOD getIndex( oGet )

   ENDCLASS

/*----------------------------------------------------------------------*/

METHOD HbQtGetList:getIndex( oGet )
   RETURN AScan( ::aGetList, {|o| o == oGet } )

/*----------------------------------------------------------------------*/

METHOD HbQtGetList:goNext( oGet )

   LOCAL n := ::getIndex( oGet )

   IF n > 0
      IF n < Len( ::aGetList )
         ::aGetList[ n + 1 ]:setFocus()
         RETURN ::aGetList[ n + 1 ]
      ENDIF
   ENDIF

   RETURN oGet

/*----------------------------------------------------------------------*/

METHOD HbQtGetList:goPrevious( oGet )

   LOCAL n := ::getIndex( oGet )

   IF n > 0
      IF n > 1
         ::aGetList[ n - 1 ]:setFocus()
         RETURN ::aGetList[ n - 1 ]
      ENDIF
   ENDIF

   RETURN oGet

/*----------------------------------------------------------------------*/

METHOD HbQtGetList:goTop( oGet )

   LOCAL n := ::getIndex( oGet )

   IF n > 0
      IF n > 1
         ::aGetList[ 1 ]:setFocus()
         RETURN ::aGetList[ 1 ]
      ENDIF
   ENDIF

   RETURN oGet

/*----------------------------------------------------------------------*/

METHOD HbQtGetList:goBottom( oGet )

   LOCAL n := ::getIndex( oGet )

   IF n > 0
      IF n < Len( ::aGetList )
         ::aGetList[ Len( ::aGetList ) ]:setFocus()
         RETURN ::aGetList[ Len( ::aGetList ) ]
      ENDIF
   ENDIF

   RETURN oGet

/*----------------------------------------------------------------------*/

METHOD HbQtGetList:isFirstGet( oGet )
   RETURN ::getIndex( oGet ) == 1

/*----------------------------------------------------------------------*/

METHOD HbQtGetList:isLastGet( oGet )
   RETURN ::getIndex( oGet ) == Len( ::aGetList )

/*----------------------------------------------------------------------*/

METHOD HbQtGetList:nextGet( oGet )

   LOCAL n := ::getIndex( oGet )

   IF n > 0
      IF n == Len( ::aGetList )
         RETURN ::aGetList[ 1 ]
      ELSE
         RETURN ::aGetList[ n + 1 ]
      ENDIF
   ENDIF

   RETURN oGet

/*----------------------------------------------------------------------*/

METHOD HbQtGetList:previousGet( oGet )

   LOCAL n := ::getIndex( oGet )

   IF n > 0
      IF n == 1
         RETURN ATail( ::aGetList[ 1 ] )
      ELSE
         RETURN ::aGetList[ n - 1 ]
      ENDIF
   ENDIF

   RETURN oGet

/*----------------------------------------------------------------------*/

