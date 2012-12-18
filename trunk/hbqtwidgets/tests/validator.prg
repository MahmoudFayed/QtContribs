/*
 * $Id$
 */

/*
 * Copyright 2012 Pritpal Bedi <bedipritpal@hotmail.com>
 * www - http://harbour-project.org
 */


#include "hbqtgui.ch"
#include "set.ch"

#include "hbqtstd.ch"
#include "hbtrace.ch"


FUNCTION Main()
   LOCAL oMain

   hbqt_errorSys()

   oMain := hbqtui_validatormain()
   oMain:oWidget:connect( QEvent_KeyPress, {|oKeyEvent| iif( oKeyEvent:key() == Qt_Key_Escape, QApplication():sendEvent( QApplication(), QCloseEvent() ), NIL ) } )

   oMain:btnClipper   : connect( "clicked()", {|| Clipper( oMain:oWidget ) } )
   oMain:btnOOPLayout : connect( "clicked()", {|| OOPLayout( oMain:oWidget ) } )
   oMain:btnUI        : connect( "clicked()", {|| UIGets( oMain:oWidget ) } )

   oMain:show()
   QApplication():exec()

   RETURN NIL


STATIC FUNCTION Clipper( oMain )

   LOCAL oWnd
   LOCAL nPdL := 22, nColGet := 25

   LOCAL cText  := "ABC"
   LOCAL dDate  := 0d19560604
   LOCAL nNumb  := 6030.130001
   LOCAL lMrd   := .T.
   LOCAL cTele  := "(999)684-7318"
   LOCAL cJust  := Space( 20 )
   LOCAL cCata  := "IT3-BEL-903533AST63Z"
   LOCAL nSlry  := 3000
   LOCAL cNotes := "We, the Harboureans, are entering a new era of true GUI implementation of our beloved Clipper language, let us keep the emotions high..."
   LOCAL cList  := "Two"
   LOCAL aList  := { "One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten" }
   LOCAL lOk    := .F.
   LOCAL lCancel := .F.

   LOCAL GetList := {}
   LOCAL SayList := {}
   LOCAL GetParent := NIL

   LOCAL val := Array( 3 )

   val[ 1 ] := Space( 10 )
   val[ 2 ] := 0
   val[ 3 ] := ctod( "" )

   /* Harbour Standard Settings */
   Set( _SET_DATEFORMAT, "yyyy-mm-dd" )

   /* HbQt Widgets Standard Settings */
   /* Sets the number of pixels for spacing between lines; default is 6 */
   HbQtSet( _QSET_LINESPACING, 2 )
   /* Set thread wide FONT object used to distribute the space for GETs; default is "Courier New",10 */
   QSET GETSFONT TO QFont( "Courier New", 8 )

   /* A window to host different GUI elements including a window to host GET objects. This window itself can be the host of GET objects. */
   /* A typical terminal window per GT can be thought of synonimous to this window if it itself is hosting GET objects */
   oWnd := QScrollArea( oMain )
   oWnd:setWindowFlags( Qt_Sheet )
   oWnd:setWindowTitle( "Clipper Get System - Scrollable Widget" )
   /* Presseing ESCape will request window to close itself */
   oWnd:connect( QEvent_KeyPress, {|oKeyEvent| iif( oKeyEvent:key() == Qt_Key_Escape, QApplication():sendEvent( oWnd, QCloseEvent() ), NIL ) } )

   /* A window to host GET objects. This window can be any container type, e.g., QWidget, QDialog, QFrame, QGroupBox */
   /* A typical terminal window per GT can be thought of synonimous to this window */
   GetParent := QFrame( oWnd )

   /* Set QFrame as the exposed widget TO QScrollArea. This facilitates TO host as many GET objects as application needs without the  */
   /* constraint of width and height limitations. QScrollArea will expose the scrollbars TO bring desired GETs into viewport */
   oWnd:setWidget( GetParent )

   /* Harbour standards SAYs and GETs */
   @ 1, 02 QSAY PadL( "Upper Cased Alphabets:", nPdL ) QGET cText VALID {|oGet| cText == "ABC" .OR. cText == "DEF" .OR. Udf1( oGet ) } PICTURE "@!A"

   @ 2, 02 QSAY PadL( "Birthday:", nPdL )
   @ 2, nColGet QGET dDate WHEN {|| cText == "ABC" } COLOR "B/GR*" VALID dDate >= 0d19560604

   @ 3, 02 QSAY PadL( "Max 6 Decimals:", nPdL )
   @ 3, nColGet QGET nNumb PICTURE "@Z 9,999,999.999999" VALID nNumb > 600 .AND. nNumb < 6000000

   @ 4, 02 QSAY PadL( "Logical - Married:", nPdL ) QGET lMrd  PICTURE "Y"

   @ 5, 02 QSAY PadL( "Telephone Number:", nPdL )
   @ 5, nColGet QGET cTele PICTURE "@! (999)999-9999"

   @ 6, 02 QSAY PadL( "Upper Lower Upper:", nPdL )
   @ 6, nColGet QGET cJust PICTURE "@A" COLOR "W+/B*" VALIDATOR {|cText,nPos| UpperLowerUpper( @cText, @nPos ) }

   @ 7, 02 QSAY PadL( "Scrolling Catalog:", nPdL )
   @ 7, nColGet QGET cCata PICTURE "@S15 !!!-!!!-!!!!!!!!!!!!"

   @ 1, 52 QSAY "Val[1]"
   @ 1, 60 QGET val[1] PICTURE "@!"
   @ 2, 52 QSAY "Val[2]"
   @ 2, 60 QGET val[2] PICTURE "99"
   @ 3, 52 QSAY "Val[3]"
   @ 3, 60 QGET val[3]

   @ 7, 52 QSAY "Salary:"
   @ 7, 60 QGET nSlry PICTURE "@E 99,999" VALID {|| nSlry > 600 .AND. nSlry < 17000 }

   @ 9, 02 QSAY "Notes:"
   @ 10, 02, 17, 55 QGET cNotes MEMOEDIT COLOR "N/rgb(255,255,230)" WHEN cText == "DEF" VALID "Harbour" $ cNotes

   @ 9, 60 QSAY "Select:"
   @ 10, 59, 17, 69 QGET cList LISTBOX aList WHEN cText == "ABC" VALID {|| HB_TRACE( HB_TR_ALWAYS, cList ), .T. }

   @ 19, 25, 20, 44 QGET lOk     PUSHBUTTON "OK"     ACTION {|| HB_TRACE( HB_TR_ALWAYS, "OK Pushed"     ) }    WHEN nSlry > 700 .AND. nSlry < 17000 VALID nSlry == 6000
   @ 19, 50, 20, 69 QGET lCancel PUSHBUTTON "Cancel" ACTION {|v| v := HbQtAlert( "Cancel Pressed!;Please allow to terminate the GETs.", { "Ok","Cancel" } ), iif( v == 1, QApplication():sendEvent( oWnd, QCloseEvent() ), NIL ) }


   /* QREAD creates the above GETs. In Clipper GET object is created at the time of @...GET is encountered,
    * but in HbQt it is not possible because PARENT window is not known until QREAD to bind the GETs
    */
   QREAD PARENT GetParent

   /* IMPORTANT: to release memory associated with this window and contained getlist
    * If oWnd would been the parent of GETs then 2nd param <GetParent> needs not be passed.
    */
   oWnd:connect( QEvent_Close, {|| HbQtClearGets( oWnd, GetParent ) } )

   /* Show up the GET screen ready to receive user input */
   oWnd:show()

   RETURN NIL


STATIC FUNCTION UiGets( oMain )

   LOCAL oWnd
   LOCAL nPdL := 22

   LOCAL cText := "ABC"
   LOCAL dDate := 0d19560604
   LOCAL nNumb := 6030.130001
   LOCAL lMrd  := .T.
   LOCAL cTele := "(999)684-7318"
   LOCAL cJust := Space( 20 )
   LOCAL cCata := "IT3-BEL-903533AST63Z"
   LOCAL nSlry := 3000
   LOCAL val   := Array( 3 )
   LOCAL cNotes := "We, the Harboureans, are entering a new era of true GUI implementation of our beloved Clipper language, let us keep the emotions high..."
   LOCAL cList  := "Two"
   LOCAL aList  := { "One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten" }

   LOCAL GetList := {}
   LOCAL SayList := {}
   LOCAL GetParent

   val[ 1 ] := Space( 10 )
   val[ 2 ] := 0
   val[ 3 ] := ctod( "" )

   /* Harbour Standard Settings */
   Set( _SET_DATEFORMAT, "yyyy-mm-dd" )

   oWnd := hbqtui_validatorGets( oMain )
   oWnd:setWindowFlags( Qt_Sheet )
   oWnd:setWindowTitle( "Qt Designer Integrated GETs" )
   oWnd:connect( QEvent_KeyPress, {|oKeyEvent| iif( oKeyEvent:key() == Qt_Key_Escape, QApplication():sendEvent( oWnd:oWidget, QCloseEvent() ), NIL ) } )

   GetParent := oWnd:oWidget

   @ 1, 02 QSAY PadL( "Upper Cased Alphabets:", nPdL ) QGET cText  CONTROL oWnd:editUpper  PICTURE "@!A" VALID {|oGet| oGet:varGet() == "ABC" .OR. cText == "DEF" }

   @ 2, 02 QSAY PadL( "Birthday:", nPdL )              QGET dDate  CONTROL oWnd:editBDay   COLOR   "B/GR*" WHEN {|| cText == "ABC" }  VALID dDate >= 0d19560604

   @ 3, 02 QSAY PadL( "Max 6 Decimals:", nPdL )        QGET nNumb  CONTROL oWnd:edit6dec   PICTURE "@Z 9,999,999.999999" VALID nNumb > 600 .AND. nNumb < 6000000

   @ 4, 02 QSAY PadL( "Logical - Married:", nPdL )     QGET lMrd   CONTROL oWnd:editMrd    PICTURE "Y"

   @ 5, 02 QSAY PadL( "Telephone Number:", nPdL )      QGET cTele  CONTROL oWnd:editTele   PICTURE "@! (999)999-9999"

   @ 6, 02 QSAY PadL( "Upper Lower Upper:", nPdL )     QGET cJust  CONTROL oWnd:editULU    PICTURE "@A" COLOR "W+/B*" VALIDATOR {|cText,nPos| UpperLowerUpper( @cText, @nPos ) }

   @ 7, 02 QSAY PadL( "Scrolling Catalog:", nPdL )     QGET cCata  CONTROL oWnd:editCata   PICTURE "@S15 !!!-!!!-!!!!!!!!!!!!"

   @ 1, 52 QSAY "Val[1]"                               QGET val[1] CONTROL oWnd:editVal1   PICTURE "@!"
   @ 2, 52 QSAY "Val[2]"                               QGET val[2] CONTROL oWnd:editVal2   PICTURE "99"
   @ 3, 52 QSAY "Val[3]"                               QGET val[3] CONTROL oWnd:editVal3

   @ 7, 52 QSAY "Salary:"                              QGET nSlry  CONTROL oWnd:editSalary PICTURE "@E 99,999" VALID {|| nSlry > 600 .AND. nSlry < 17000 }

   @ 9, 02, 12, 30                                     QGET cNotes MEMOEDIT CONTROL oWnd:editNotes COLOR "N/rgb(255,255,230)" WHEN cText == "DEF" VALID "Harbour" $ cNotes
   @ 10, 60, 17, 70                                    QGET cList  LISTBOX aList CONTROL oWnd:listSelect WHEN cText == "ABC" VALID {|| HB_TRACE( HB_TR_ALWAYS, cList ), .T. } COLOR "N/#CCCCFF"

   /* Prepares the widget for user input */
   QREAD

   /* IMPORTANT: to release memory associated with this window and contained getlist */
   oWnd:connect( QEvent_Close, {|| HbQtClearGets( oWnd:oWidget ) } )

   /* Show up the GET screen ready to receive user input */
   oWnd:show()

   RETURN NIL


STATIC FUNCTION OOPLayout( oMain )
   LOCAL oWnd, oFLayout
   LOCAL oEdit1, oEdit2, oEdit3, oEdit4, oEdit5, oEdit6, oEdit7, oEdit8

   LOCAL cText := "ABC"
   LOCAL dDate := 0d19560604
   LOCAL nNumb := 6030.130001
   LOCAL lMrd  := .T.
   LOCAL cTele := "(999)684-7318"
   LOCAL cJust := Space( 20 )
   LOCAL cCata := "IT3-BEL-903533AST63Z"
   LOCAL nSlry := 3000

   LOCAL GetParent := NIL

   LOCAL val := Array( 3 )

   val[ 1 ] := Space( 10 )
   val[ 2 ] := 0
   val[ 3 ] := ctod( "" )

   oWnd := QWidget( oMain )
   oWnd:setWindowFlags( Qt_Sheet )
   oWnd:setWindowTitle( "Clipper Get System - Layout" )
   oWnd:connect( QEvent_KeyPress, {|oKeyEvent| iif( oKeyEvent:key() == Qt_Key_Escape, QApplication():sendEvent( oWnd, QCloseEvent() ), NIL ) } )

   oFLayout := QFormLayout( oWnd )
   oFLayout:setLabelAlignment( Qt_AlignRight )
   oFLayout:setFieldGrowthPolicy( QFormLayout_FieldsStayAtSizeHint )
   oFLayout:setFormAlignment( Qt_AlignHCenter )

   oEdit1                := HbQtGet():new()
   oEdit1:parent         := oWnd
   oEdit1:postBlock      := {|oGet| oGet:varGet() == "ABC" .OR. oGet:varGet() == "DEF" }
   oEdit1:picture        := "@!A"
   oEdit1:block          := {|x| iif( x == NIL, cText, cText := x ) }
   oEdit1:create()
   oFLayout:addRow( "Alpha - Upper Cased Alphabets:", oEdit1:edit() )

   oEdit2                := HbQtGet():new()
   oEdit2:parent         := oWnd
   oEdit2:block          := {|x| iif( x == NIL, dDate, dDate := x ) }
   oEdit2:preBlock       := {|| cText == "ABC" }
   oEdit2:postBlock      := {|| dDate >= 0d19560604 }
   oEdit2:color          := "B/GR*"
   oEdit2:create()
   oFLayout:addRow( "Date - Birthday:", oEdit2:edit() )

   oEdit3                := HbQtGet():new()
   oEdit3:parent         := oWnd
   oEdit3:block          := {|x| iif( x == NIL, nNumb, nNumb := x ) }
   oEdit3:postBlock      := {|| nNumb > 600 .AND. nNumb < 6000000 }
   oEdit3:picture        := "9,999,999.999999"
   oEdit3:create()
   oFLayout:addRow( "Numeric - Max 6 Decimals:", oEdit3:edit() )

   oEdit4                := HbQtGet():new()
   oEdit4:parent         := oWnd
   oEdit4:picture        := "@Y"
   oEdit4:block          := {|x| iif( x == NIL, lMrd, lMrd := x ) }
   oEdit4:create()
   oFLayout:addRow( "Logical - Married:", oEdit4:edit() )

   oEdit5                := HbQtGet():new()
   oEdit5:parent         := oWnd
   oEdit5:block          := {|x| iif( x == NIL, cTele, cTele := x ) }
   oEdit5:picture        := "(999)999-9999"
   oEdit5:create()
   oFLayout:addRow( "Telephone Number:", oEdit5:edit() )

   oEdit6                := HbQtGet():new()
   oEdit6:parent         := oWnd
   oEdit6:block          := {|x| iif( x == NIL, cJust, cJust := x ) }
   oEdit6:inputValidator := {|cText,nPos| UpperLowerUpper( @cText, @nPos ) }
   oEdit6:color          := "W+/B*"
   oEdit6:create()
   oFLayout:addRow( "Alpha - Upper Lower Upper:", oEdit6:edit() )

   oEdit7                := HbQtGet():new()
   oEdit7:parent         := oWnd
   oEdit7:block          := {|x| iif( x == NIL, cCata, cCata := x ) }
   oEdit7:picture        := "!!!-!!!-!!!!!!!!!!!!"
   oEdit7:create()
   oFLayout:addRow( "Catalog Item:", oEdit7:edit() )

   oEdit8                := HbQtGet():new()
   oEdit8:parent         := oWnd
   oEdit8:block          := {|x| iif( x == NIL, nSlry, nSlry := x ) }
   oEdit8:postBlock      := {|| nSlry > 600 .AND. nSlry < 17000 }
   oEdit8:picture        := "@Z 99,999"
   oEdit8:create()
   oFLayout:addRow( "Salary:", oEdit8:edit() )

   /* IMPORTANT: to release memory associated with this window and contained getlist */
   oWnd:connect( QEvent_Close, {|| HbQtClearGets( oWnd ) } )

   /* Show up the GET screen ready to receive user input */
   oWnd:show()

   RETURN NIL


STATIC FUNCTION UpperLowerUpper( cText, nPos )
   LOCAL cChr, s

   HB_SYMBOL_UNUSED( nPos )

   s := ""
   FOR EACH cChr IN cText
      IF cChr:__enumIndex() % 2 == 0
         s += Lower( cChr )
      ELSE
         s += Upper( cChr )
      ENDIF
   NEXT
   cText := s

   RETURN .T.  /* Must always return TRUE/FALSE */


STATIC FUNCTION Udf1( oGet )

   IF "TST" $ oGet:buffer
      oGet:varPut( "DEF" )
      oGet:display()
      RETURN .T.
   ENDIF

   RETURN .F.

