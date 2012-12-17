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
#include "hbqtstd.ch"

#include "hbtrace.ch"


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
   METHOD getData( cBuffer )
   METHOD getDispWidth()                          INLINE ::sl_dispWidth
   METHOD getDispHeight()                         INLINE ::sl_dispHeight
   METHOD setPosAndSize( aPos, aSize )
   METHOD setFocus( nFocusReason )
   METHOD widget( cWidget )                       SETGET
   METHOD toRow( nRow )                           SETGET
   METHOD toCol( nCol )                           SETGET
   METHOD data( xData )                           SETGET


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
   VAR    sl_dispHeight                           INIT 1
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
   VAR    oApp
   VAR    cWidget                                 INIT "QLineEdit"
   VAR    nToRow                                  INIT NIL
   VAR    nToCol                                  INIT NIL
   VAR    sl_data                                 INIT NIL

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
   METHOD postValidate()
   METHOD preValidate()
   METHOD setColor( cMode )
   METHOD connect()
   METHOD isQLineEdit()                           INLINE ::cClassName == "QLINEEDIT"

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

   METHOD end()                                   INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_End      , Qt_NoModifier      ) )
   METHOD home()                                  INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Home     , Qt_NoModifier      ) )
   METHOD left()                                  INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Left     , Qt_NoModifier      ) )
   METHOD right()                                 INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Right    , Qt_NoModifier      ) )
   METHOD toDecPos()                              INLINE iif( ::sl_dec == 0, NIL, ::oEdit:setCursorPosition( At( ::sl_decProxy, ::text() ) ) )
   METHOD wordLeft()                              INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Left     , Qt_ControlModifier ) )
   METHOD wordRight()                             INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Right    , Qt_ControlModifier ) )

   METHOD backSpace()                             INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Backspace, Qt_NoModifier      ) )
   METHOD delete()                                INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Delete   , Qt_NoModifier      ) )
   METHOD delEnd()                                INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_K        , Qt_ControlModifier ) )
   METHOD delLeft()                               INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Backspace, Qt_NoModifier      ) )
   METHOD delRight()                              INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Delete   , Qt_NoModifier      ) )
   METHOD delWordLeft()                           INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Backspace, Qt_ControlModifier ) )
   METHOD delWordRight()                          INLINE ::oApp:sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Delete   , Qt_ControlModifier ) )

   METHOD insert( cChar )                         VIRTUAL
   METHOD overStrike( cChar )                     VIRTUAL

   ACCESS buffer                                  METHOD getBuffer()
   ASSIGN buffer                                  METHOD setBuffer( cBuffer )

   METHOD varGet()
   METHOD varPut( xValue )
   METHOD display()

   ENDCLASS

/*----------------------------------------------------------------------*/

METHOD HbQtGet:new( oControl )

   ::oApp := QApplication()

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
      SWITCH ::widget
      CASE "QLineEdit"
         ::oEdit := QLineEdit( ::oParent )
         EXIT
      CASE "QPlainTextEdit"
         ::oEdit := QPlainTextEdit( ::oParent )
         ::oEdit:setTabChangesFocus( .T. )
         EXIT
      CASE "QListWidget"
         ::oEdit := QListWidget( ::oParent )
         EXIT
      CASE "QCheckBox"
         EXIT
      CASE "QPushButton"
         EXIT
      ENDSWITCH
   ENDIF
   IF ! Empty( ::name )
      ::oEdit:setObjectName( ::name() )
   ENDIF

   ::cClassName := __objGetClsName( ::oEdit )

   ::connect()

   /* Still TO be determined IF font should be of fixed pitch IF it is a user supplied control */
   IF ! HB_ISOBJECT( ::sl_font )
      ::sl_font := QFont( "Courier New", 10 )
   ENDIF

   ::oEdit:setFocusPolicy( iif( ::sl_mousable, Qt_StrongFocus, Qt_TabFocus ) )
   IF ::cClassName $ "QLINEEDIT,QPLAINTEXTEDIT,QLISTWIDGET"
      ::oEdit:setStyleSheet( ::sl_cssColor )
      ::oEdit:setFont( ::sl_font )
   ENDIF

   ::setParams()
   ::setData( ::original )

   IF ::cClassName == "QLINEEDIT"
      ::oEdit:setCursorPosition( 0 )
   ENDIF

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbQtGet:connect()

   SWITCH ::cClassName
   CASE "QLINEEDIT"
      ::oEdit:connect( "textEdited(QString)" , {|| ::lChanged := .T., ::testValid() } )
      ::oEdit:connect( "textChanged(QString)", {|| ::testValid() } )
      ::oEdit:connect( "returnPressed()"     , {|| ::returnPressed(), .F. } )

      ::oEdit:connect( QEvent_FocusOut       , {|oFocusEvent| ::execFocusOut( oFocusEvent ) } )
      ::oEdit:connect( QEvent_FocusIn        , {|oFocusEvent| ::execFocusIn( oFocusEvent ) } )
      ::oEdit:connect( QEvent_KeyPress       , {|oKeyEvent  | ::execKeyPress( oKeyEvent ) } )
      EXIT
   CASE "QPLAINTEXTEDIT"
      ::oEdit:connect( QEvent_FocusOut       , {|oFocusEvent| ::execFocusOut( oFocusEvent ) } )
      ::oEdit:connect( QEvent_FocusIn        , {|oFocusEvent| ::execFocusIn( oFocusEvent ) } )
      ::oEdit:connect( QEvent_KeyPress       , {|oKeyEvent| ::lChanged := .T., ::execKeyPress( oKeyEvent ) } )
      EXIT
   CASE "QLISTWIDGET"
      ::oEdit:connect( QEvent_FocusOut       , {|oFocusEvent| ::execFocusOut( oFocusEvent ) } )
      ::oEdit:connect( QEvent_FocusIn        , {|oFocusEvent| ::execFocusIn( oFocusEvent ) } )
      ::oEdit:connect( QEvent_KeyPress       , {|oKeyEvent| ::lChanged := .T., ::execKeyPress( oKeyEvent ) } )
      EXIT
   CASE "QCHECKBOX"
   CASE "QPUSHBUTTON"
      EXIT
   ENDSWITCH

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbQtGet:widget( cWidget )

   IF HB_ISCHAR( cWidget )
      ::cWidget := cWidget
   ENDIF

   RETURN ::cWidget

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

METHOD HbQtGet:data( xData )

   IF PCount() == 1 .AND. ! Empty( xData )
      ::sl_data := xData
   ENDIF

   RETURN ::sl_data

/*----------------------------------------------------------------------*/

METHOD HbQtGet:getList( oGetList )

   IF HB_ISOBJECT( oGetList )
      ::oGetList := oGetList
   ENDIF

   RETURN ::oGetList

/*----------------------------------------------------------------------*/

METHOD HbQtGet:setFocus( nFocusReason )

   IF HB_ISOBJECT( ::oEdit )
      IF ! Empty( nFocusReason )
         ::oEdit:setFocus( nFocusReason )
      ELSE
         ::oEdit:setFocus()
      ENDIF
   ENDIF

   RETURN Self

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

   SWITCH ::cClassName
   CASE "QLINEEDIT"
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
         ::sl_width     := Len( DToC( ::varGet() ) )
         cTmp           := Set( _SET_DATEFORMAT )
         ::sl_dispWidth := Len( Transform( ::varGet(), ::cPicture ) )
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
      EXIT
   CASE "QLISTWIDGET"
   CASE "QPLAINTEXTEDIT"
      ::sl_dispWidth  := ::nToCol - ::nCol
      ::sl_dispHeight := ::nToRow - ::nRow
      EXIT
   CASE "QCHECKBOX"
      EXIT
   ENDSWITCH


   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbQtGet:getData( cBuffer )

   SWITCH ::cClassName
   CASE "QLINEEDIT"
      hb_default( @cBuffer, ::oEdit:text() )
      SWITCH ::cType
      CASE "C"
         RETURN Pad( cBuffer, ::sl_width )
      CASE "N"
         RETURN Val( ::unTransformThis( cBuffer ) )
      CASE "D"
         RETURN CToD( cBuffer )
      CASE "L"
         RETURN Left( cBuffer, 1 ) $ "YyTt"
      ENDSWITCH
      EXIT
   CASE "QPLAINTEXTEDIT"
      hb_default( @cBuffer, ::oEdit:toPlainText() )
      RETURN cBuffer
   CASE "QLISTWIDGET"
      RETURN ::oEdit:currentItem():text()
   CASE "QCHECKBOX"
   CASE "QPUSHBUTTON"
   CASE "QCOMBOBOX"
      EXIT
   ENDSWITCH

   RETURN ""

/*----------------------------------------------------------------------*/

METHOD HbQtGet:setData( xData )
   LOCAL cTmp

   SWITCH ::cClassName
   CASE "QLINEEDIT"
      SWITCH ::cType
      CASE "C"
         RETURN ::oEdit:setText( RTrim( xData ) )
      CASE "N"
         RETURN ::oEdit:setText( ::transformThis( xData, ::cPicture ) )
      CASE "D"
         RETURN ::oEdit:setText( DToC( xData ) )
      CASE "L"
         RETURN ::oEdit:setText( iif( xData, iif( ::cPicFunc $ "Y", "Y", "T" ), iif( ::cPicFunc $ "Y", "N", "F" ) ) )
      ENDSWITCH
      EXIT
   CASE "QPLAINTEXTEDIT"
      ::oEdit:setPlainText( Trim( xData ) )
      EXIT
   CASE "QLISTWIDGET"
      ::oEdit:clear()
      IF HB_ISARRAY( ::data ) .AND. ! Empty( ::sl_data[ _QDATA_LISTBOX_ITEMS ] )
         FOR EACH cTmp IN ::sl_data[ _QDATA_LISTBOX_ITEMS ]
            ::oEdit:addItem( cTmp )
         NEXT
         IF ! Empty( cTmp := ::varGet() )
            ::oEdit:setCurrentRow( AScan( ::sl_data[ _QDATA_LISTBOX_ITEMS ], {|e| e == cTmp } ) - 1 )
         ENDIF
      ENDIF
      EXIT
   CASE "QCHECKBOX"
   CASE "QPUSHBUTTON"
   CASE "QCOMBOBOX"
      EXIT
   ENDSWITCH

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

METHOD HbQtGet:setColor( cMode )

   IF HB_ISOBJECT( ::oEdit )
      IF cMode == "normal"
         SWITCH ::cClassName
         CASE "QLINEEDIT"
         CASE "QPLAINTEXTEDIT"
         CASE "QLISTWIDGET"
            ::oEdit:setStyleSheet( "" )
            ::oEdit:setStyleSheet( ::sl_cssColor )
            ::oEdit:repaint()
            EXIT
         CASE "QPUSHBUTTON"
            // ?
            EXIT
         ENDSWITCH
      ELSEIF cMode == "warning"
         ::oEdit:setStyleSheet( "" )
         ::oEdit:setStyleSheet( ::sl_cssNotValid )
         ::oEdit:repaint()
      ENDIF
   ENDIF

   RETURN ::sl_cssColor

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

   ::setColor( "normal" )

   RETURN ::sl_color

/*----------------------------------------------------------------------*/
//                            QEvent_FocusOut
/*----------------------------------------------------------------------*/

METHOD HbQtGet:returnPressed()

   IF ::postValidate()
      IF ! Empty( ::oGetList )
         ::oGetList:goNext( Self )
      ELSE
         QApplication():sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Tab, Qt_NoModifier ) )
      ENDIF
   ENDIF
   RETURN NIL

/*----------------------------------------------------------------------*/

METHOD HbQtGet:execFocusOut( oFocusEvent )  /* Should we validate before leaving */

   LOCAL lValid := ::isBufferValid()

   IF ::cClassName == "QPLAINTEXTEDIT"
      ::cBuffer := ::oEdit:toPlainText()
      ::assign()
   ENDIF

   IF lValid
      ::hasFocus := .F.
      RETURN .F.
   ENDIF

   ::hasFocus := .T.

   oFocusEvent:ignore()
   ::setFocus()

   RETURN .T.

/*----------------------------------------------------------------------*/

METHOD HbQtGet:execFocusIn( oFocusEvent )

   IF ! Empty( ::oGetList )
      __GetListSetActive( ::oGetList )
      __GetListLast( ::oGetList )
      ::oGetList:getActive( Self )
   ENDIF

   ::hasFocus := .T.

   IF ! ::preValidate()
      oFocusEvent:accept()
      IF ! Empty( ::oGetList )
         IF oFocusEvent:reason() == Qt_TabFocusReason
            ::oGetList:goNext( Self )
         ELSE
            ::oGetList:goPrevious( Self )
         ENDIF
      ELSE
         QApplication():sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, iif( oFocusEvent:reason() == Qt_TabFocusReason, Qt_Key_Tab, Qt_Key_Backtab ), Qt_NoModifier ) )
      ENDIF
      RETURN .T.
   ENDIF

   RETURN .F.

/*----------------------------------------------------------------------*/

METHOD HbQtGet:preValidate()

   LOCAL lWhen := .T.

   IF HB_ISBLOCK( ::preBlock )
      lWhen := Eval( ::preBlock, Self )
      __GetListLast( ::oGetList )
   ENDIF

   RETURN lWhen

/*----------------------------------------------------------------------*/

METHOD HbQtGet:postValidate()

   LOCAL lValid := .T.

   IF ::isDateBad()
      RETURN .F.
   ENDIF

   IF ::changed
      ::assign()
   ENDIF

   IF HB_ISBLOCK( ::postBlock )
      lValid := Eval( ::postBlock, Self )
      __GetListLast( ::oGetList )
   ENDIF

   ::setColor( iif( lValid, "normal", "warning" ) )

   RETURN lValid

/*----------------------------------------------------------------------*/

METHOD HbQtGet:isBufferValid()

   LOCAL xValInVar, xValInBuffer
   LOCAL lValid := .T.

   IF ::isDateBad()
      RETURN ! lValid
   ENDIF

   IF HB_ISBLOCK( ::bPostBlock )
      /* Fetch Clipper Variable Value */
      xValInVar    := ::varGet()
      xValInBuffer := ::getData()
      /* Set Clipper Variable Value with Value in Buffer */
      ::varPut( xValInBuffer )
      /* Validate passing value in buffer, in case OOP gets are constructed */
      lValid := Eval( ::bPostBlock, Self )
      /* Set Clipper Variable back to Original Value */
      ::varPut( xValInVar )
   ENDIF

   RETURN lValid

/*----------------------------------------------------------------------*/

METHOD HbQtGet:testValid()
#if 0
   LOCAL lValid := ::isBufferValid()

   IF ! lValid
      ::SetColor( "warning" )
      ::oEdit:repaint()
   ELSE
      ::SetColor( "normal" )
      ::oEdit:repaint()
   ENDIF

   RETURN .F.
#else
   RETURN .T.
#endif

/*----------------------------------------------------------------------*/

METHOD HbQtGet:isDateBad()
   LOCAL cChr

   IF ::cType == "D" .AND. ::isQLineEdit()
      FOR EACH cChr IN ::oEdit:text()
         IF IsDigit( cChr )
            IF Empty( ::getData() )
               RETURN .T.
            ENDIF
         ENDIF
      NEXT
   ENDIF

   RETURN .F.

/*----------------------------------------------------------------------*/

METHOD HbQtGet:execKeyPress( oKeyEvent )

   SWITCH oKeyEvent:key()

   CASE Qt_Key_Escape
      ::varPut( ::original )
      ::setData( ::original )
      EXIT

   CASE Qt_Key_PageUp
      IF ! ( ::cClassName $ "QPLAINTEXTEDIT,QLISTWIDGET" )
         IF ::postValidate()
            IF ! Empty( ::oGetList )
               ::oGetList:goTop( Self )
            ENDIF
         ENDIF
      ENDIF
      EXIT

   CASE Qt_Key_PageDown
      IF ! ( ::cClassName $ "QPLAINTEXTEDIT,QLISTWIDGET" )
         IF ::postValidate()
            IF ! Empty( ::oGetList )
               ::oGetList:goBottom( Self )
            ENDIF
         ENDIF
      ENDIF
      EXIT

   CASE Qt_Key_Up
      IF ! ( ::cClassName $ "QPLAINTEXTEDIT,QLISTWIDGET" )
         IF ::postValidate()
            IF ! Empty( ::oGetList )
               ::oGetList:goPrevious( Self )
            ELSE
               QApplication():sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Backtab, Qt_NoModifier ) )
               RETURN .T.
            ENDIF
         ENDIF
      ENDIF
      EXIT

   CASE Qt_Key_Down
      IF ! ( ::cClassName $ "QPLAINTEXTEDIT,QLISTWIDGET" )
         IF ::postValidate()
            IF ! Empty( ::oGetList )
               ::oGetList:goNext( Self )
            ELSE
               QApplication():sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Tab, Qt_NoModifier ) )
               RETURN .T.
            ENDIF
         ENDIF
      ENDIF
      EXIT

   CASE Qt_Key_Return
      IF ::cClassName == "QLISTWIDGET"
         IF ! ::postValidate()
            oKeyEvent:accept()
            RETURN .T.
         ELSE
            IF ! Empty( ::oGetList )
               ::oGetList:goNext( Self )
            ELSE
               QApplication():sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Tab, Qt_NoModifier ) )
            ENDIF
         ENDIF
      ENDIF
      EXIT
   CASE Qt_Key_Tab
   CASE Qt_Key_Backtab
      IF ! ::lValidWhen
         ::lValidWhen := .T.
         EXIT
      ENDIF
      IF ::cClassName == "QPLAINTEXTEDIT"
         IF ::postValidate()
            IF ! Empty( ::oGetList )
               IF oKeyEvent:key() == Qt_Key_Tab
                  ::oGetList:goNext( Self )
               ELSE
                  ::oGetList:goPrevious( Self )
               ENDIF
            ELSE
               QApplication():sendEvent( ::oEdit, QKeyEvent( QEvent_KeyPress, Qt_Key_Tab, Qt_NoModifier ) )
            ENDIF
         ENDIF
         oKeyEvent:accept()
         RETURN .T.
      ELSE
         IF ! ::postValidate()
            oKeyEvent:accept()
            RETURN .T.
         ENDIF
      ENDIF
      EXIT

   ENDSWITCH

   RETURN .F.

/*----------------------------------------------------------------------*/

METHOD HbQtGet:getRgbStringFromClipperColor( cToken, lExt )

   IF Upper( Left( cToken, 3 ) ) == "RGB"    /* rgb notation : rgb(200,12,201)/rgb(104,56,19) */
      RETURN cToken
   ENDIF
   IF Left( cToken, 1 ) == "#"               /* Hex notation : #fffccc/#da3f78 */
      RETURN cToken
   ENDIF

   SWITCH Upper( cToken )                    /* Clipper notation : W+/BG* */
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

   SWITCH ::cType
   CASE "C"
      RETURN cData
   CASE "N"
      FOR EACH cChr IN cData
         IF cChr $ "+-0123456789"
            cText += cChr
         ELSEIF cChr == ::sl_decProxy
            cText += "."
         ENDIF
      NEXT
      EXIT
   CASE "L"
   CASE "D"
      RETURN cData
   ENDSWITCH

   RETURN cText

/*----------------------------------------------------------------------*/
//                          GET Specific Methods
/*----------------------------------------------------------------------*/

METHOD HbQtGet:assign()

   IF ::hasFocus
      ::varPut( ::getData() )
      ::lChanged := .F.
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
   ::cType    := ValType( ::original )

   RETURN ::bBlock

/*----------------------------------------------------------------------*/

METHOD HbQtGet:getBuffer()

   SWITCH ::cClassName
   CASE "QLINEEDIT"
      ::cBuffer := ::oEdit:text()
      EXIT
   CASE "QPLAINTEXTEDIT"
      ::cBuffer := ::oEdit:toPlainText()
      EXIT
   CASE "QLISTWIDGET"
      ::cBuffer := ::oEdit:currentItem():text()
      EXIT
   CASE "QCHECKBOX"
   CASE "QPUSHBUTTON"
   CASE "QCOMBOBOX"
      EXIT
   ENDSWITCH

   RETURN ::cBuffer

/*----------------------------------------------------------------------*/

METHOD HbQtGet:setBuffer( cBuffer )

   ::cBuffer := cBuffer

   SWITCH ::cClassName
   CASE "QLINEEDIT"
      ::oEdit:setText( ::unTransformThis( ::cBuffer ) )
      EXIT
   CASE "QPLAINTEXTEDIT"
      ::oEdit:setPlainText( ::cBuffer )
      EXIT
   CASE "QLISTWIDGET"
      ::oEdit:setCurrentRow( AScan( ::sl_data[ _QDATA_LISTBOX_ITEMS ], {|e|  e == cBuffer } ) - 1 )
      EXIT
   ENDSWITCH

   ::lChanged := .T.

   RETURN NIL

/*----------------------------------------------------------------------*/

METHOD HbQtGet:varPut( xValue )

   LOCAL aSubs
   LOCAL nLen
   LOCAL i
   LOCAL aValue

   IF HB_ISBLOCK( ::bBlock ) .AND. ValType( xValue ) $ "CNDTLU"
      aSubs := ::xSubScript
      IF HB_ISARRAY( aSubs ) .AND. ! Empty( aSubs )
         nLen := Len( aSubs )
         aValue := Eval( ::bBlock )
         FOR i := 1 TO nLen - 1
            IF HB_ISNUMERIC( aSubs[ i ] ) .OR. ;
               ( HB_ISHASH( aValue ) .AND. ValType( aSubs[ i ] ) $ "CDT" )
               aValue := aValue[ aSubs[ i ] ]
            ELSE
               EXIT
            ENDIF
         NEXT
         IF HB_ISNUMERIC( aSubs[ i ] ) .OR. ;
            ( HB_ISHASH( aValue ) .AND. ValType( aSubs[ i ] ) $ "CDT" )
            aValue[ aSubs[ i ] ] := xValue
         ENDIF
      ELSE
         Eval( ::bBlock, xValue )
      ENDIF
   ELSE
      xValue := NIL
   ENDIF

   RETURN xValue

/*----------------------------------------------------------------------*/

METHOD HbQtGet:varGet()

   LOCAL aSubs
   LOCAL nLen
   LOCAL i
   LOCAL xValue

   IF HB_ISBLOCK( ::bBlock )
      aSubs := ::xSubScript
      IF HB_ISARRAY( aSubs ) .AND. ! Empty( aSubs )
         nLen := Len( aSubs )
         xValue := Eval( ::bBlock )
         FOR i := 1 TO nLen
            IF HB_ISNUMERIC( aSubs[ i ] ) .OR. ;
               ( HB_ISHASH( xValue ) .AND. ValType( aSubs[ i ] ) $ "CDT" )
               xValue := xValue[ aSubs[ i ] ]
            ELSE
               EXIT
            ENDIF
         NEXT
      ELSE
         xValue := Eval( ::bBlock )
      ENDIF
   ELSE
      xValue := ::xVarGet
   ENDIF

   RETURN xValue

/*----------------------------------------------------------------------*/

METHOD HbQtGet:display()

   ::setData( ::varGet() )

   RETURN Self

/*----------------------------------------------------------------------*/

METHOD HbQtGet:toRow( nRow )

   IF HB_ISNUMERIC( nRow ) .AND. nRow > 0
      ::nToRow := nRow
   ENDIF

   RETURN ::nToRow

/*----------------------------------------------------------------------*/

METHOD HbQtGet:toCol( nCol )

   IF HB_ISNUMERIC( nCol ) .AND. nCol > 0
      ::nToCol := nCol
   ENDIF

   RETURN ::nToCol

/*----------------------------------------------------------------------*/

  - hbqt/tests/validator.hbp
  - hbqt/tests/validator.prg
  - hbqt/tests/validatorgets.ui
  - hbqt/tests/validatormain.ui
  * hbqt/tests/hbmk.hbm
    - Transferred: validator.hbp++ to hbqtwidgets/tests

  + hbqtwidgets/tests
  + hbqtwidgets/tests/hbmk.hbm
  + hbqtwidgets/tests/validator.hbp
  + hbqtwidgets/tests/validator.prg
  + hbqtwidgets/tests/validatorgets.ui
  + hbqtwidgets/tests/validatormain.ui
    + Transferred: from hbqt/tests.

  * hbqtwidgets/hbqtgetlist.prg
  * hbqtwidgets/hbqtgetsys.prg
  * hbqtwidgets/hbqtstd.ch
    + Implemented: @ <top>, <left>, <bottom>, <right> QGET <v> MEMOEDIT ...
                   @ <top>, <left>, <bottom>, <right> QGET <v> LISTBOX <items> ...

                   #command QSET GETSFONT [TO] <oFont>      => HbQtSet( _QSET_GETSFONT   , <oFont>   )
                   #command QSET LINESPACING [TO] <nPixels> => HbQtSet( _QSET_LINESPACING, <nPixels> )
                   #command QSET NOMOUSABLE [TO] <lMouse>   => HbQtSet( _QSET_NOMOUSABLE , <lMouse>  )

