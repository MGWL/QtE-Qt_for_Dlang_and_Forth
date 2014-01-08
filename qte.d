// Written in the D programming language. Мохов Геннадий Владимирович 2013
// Версия v1.002
/**
  * <b><u>Работа с Qt в Windows 32 и Linux 32 и 64. </u></b>
  *  <br>Зависит от QtE.DLL  (Win32)   или  QtE.so.1.0.0 (Linux32, Linux64)
  *  Version: 1.0a
  *  Authors: Мохов Г.В.  mgw@yandex.ru ( MGW 02.08.2013 23:37:57  )
  *  Date: Июль 30, 2013
  *   http: mgw.narod.ru
  *   License: use freely for any purpose
  *
  *   <b><u>Компиляция:</u></b>
  *   <br>Windows 32: dmd main.d qte.d -L/SUBSYSTEM:WINDOWS:5.01
  *   <br>Linux 32: dmd main.d qte.d -L-ldl
  *
  *   <b><u>Алгоритм:</u></b>
  *   <br>Подключить и использовать небольшое подмножество Qt из D.
  * 	  <br>Где возможно, обращается сразу в Qt, где нет в QtE.dll
  *    <br><code>
  *             main.d ---> lib_qt.d ----> QtE.dll  ----> ( QtGui.dll, QtCore.dll )
  *   <br>или main.d ---> lib_qt.d --------------------> ( QtGui.dll, QtCore.dll )
  *    </code>
  */
 /++
 + Example:
 + ---
 + import lib_qt;
 + int main(string[] args) {
 + {
 +    /* Цепляем библиотеки QtCore, QtGui, QtE. */
 +     int rez = LoadQt(); if (rez==1) return 1;  // Ошибка загрузки библиотеки
 +	  // Изврат связанный с тем, что  вызов конструктора QApplication 
 +	  // должен быть произведен в main() 
 +	  (app.adrQApplication())(cast(void*)app.bufObj, &Runtime.cArgs.argc, Runtime.cArgs.argv);
 +    // Создать окно, изм размер и отобразить
 +	   gWidget w2 = new gWidget(null, 0); w2.resize(400, 50); w2.show();
 +    // Ждать и обрабатывать графические события
 +     return app.exec();
 + }
 + ---
 +/  
module qte;
import std.c.stdio;

// Отладка
import std.stdio;

version(Windows) {
	import std.c.windows.windows;
}
version(linux) {
	import core.sys.posix.dlfcn;
	import std.stdio;
}

int verQtEu = 1;
int verQtEl = 2;  // ver 1.1  64 разрядов на Linux
                  // ver 1.2  изменен eSlot + хранение ID (N) 

enum dll {
        Core = 0x1, Gui = 0x2, QtE = 0x4, Script = 0x8, Web = 0x16, Net = 0x32
    } /// Загрузка DLL. Необходимо выбрать какие грузить. Load DLL, we mast change load

public void* pFunQt[200];   /// Масив указателей на функции из DLL

immutable int QMETHOD =  0;                        // member type codes
immutable int QSLOT  = 1;
immutable int QSIGNAL  = 2;

// ----- Описание типов, фактически указание компилятору как вызывать -----

// alias void   function(void*, void*) 	t_void__voidz_voidz;
// alias char*  function()  		        t_charP__void;

alias void** GetObjQt_t;   // Дай тип Qt. Происходит неявное преобразование. cast(GetObjQt_t)Z == *Z на любой тип.

private extern (C) alias void  function(int)                                t_v__i;
private extern (C) alias void  function(void*) 	            				t_v__vp;
private extern (C) alias void  function(void*, void*) 	    				t_v__vp_vp;
private extern (C) alias void  function(void*, int)                         t_v__vp_i;
private extern (C) alias void  function(void*, void*, void*)   				t_v__vp_vp_vp;
private extern (C) alias void  function(void*, int, int)     		        t_v__vp_i_i;
private extern (C) alias void  function(void*, void*, int, int)     		t_v__vp_vp_i_i;
private extern (C) alias void  function(void*, void*, int)          		t_v__vp_vp_i;
private extern (C) alias int   function(void*, void*, void*)   				t_i__vp_vp_vp;
private extern (C) alias void* function(void*, void*) 	    				t_vp__vp_vp;
private extern (C) alias void* function(void*, char,  int)                  t_vp__vp_c_i;
private extern (C) alias void* function(void*, char*, int)                  t_vp__vp_cp_i;

private extern (C) alias void  function(void*, QMessageBox.Icon) 			t_v__vp_icon;
private extern (C) alias void  function(void*, QMessageBox.StandardButton) 	t_v__vp_StandardButton;
private extern (C) alias void  function(void*, QLCDNumber.SegmentStyle) 	t_v__vp_SegmentStyle;
private extern (C) alias void* function() 									t_vp__v;
private extern (C) alias void  function() 	                 				t_v__v;
private extern (C) alias void* function(void*) 								t_vp__vp;
private extern (C) alias void* function(void*, int) 						t_vp__vp_i;
private extern (C) alias void* function(void*, int, int)                    t_vp__vp_i_i;
private extern (C) alias void* function(void*, int, void*)                  t_vp__vp_i_vp;
private extern (C) alias void* function(void*, void*, int)                  t_vp__vp_vp_i;

private extern (C) alias void  function(void*, int, int, int, int)  		t_v__vp_i_i_i_i;
private extern (C) alias void  function(void*, int, int, void*)     		t_v__vp_i_i_vp;
private extern (C) alias void  function(int, void*, void*)          		t_v__i_vp_vp;
private extern (C) alias void* function(void*, void*, bool)     	    	t_vp__vp_vp_bool;
private extern (C) alias void* function(int, void*, bool)                   t_vp__i_vp_bool;
private extern (C) alias int   function(void*)                   	    	t_i__vp;
private extern (C) alias int   function()                                   t_i__v;
private extern (C) alias int   function(void*, bool*, int)                  t_i__vp_vbool_i;

private extern (C) alias void* function(void*, int, void*, int)           	t_vp__vp_i_vp_i;
private extern (C) alias void* function(void*, int, int, void*)           	t_vp__vp_i_i_vp;
private extern (C) alias void* function(void*, void*, int, int)             t_vp__vp_vp_i_i;

private extern (C) alias void* function(void*, void*, ushort, int)           t_vp__vp_vp_us_i;
private extern (C) alias void  function(void*, void*, ushort, int)           t_v__vp_vp_us_i;
private extern (C) alias void  function(void*, QObject, ushort, int)         t_v__vp_obj_us_i;
private extern (C) alias bool  function(void*)                               t_bool__vp;
private extern (C) alias bool  function(void*, void*)                        t_bool__vp_vp;
private extern (C) alias void  function(void*, bool)                         t_v__vp_bool;
private extern (C) alias void  function(void*, int, void*, ushort, int)      t_v__vp_i_vp_us_i;
private extern (C) alias void* function(void*, void*, void*)                 t_vp__vp_vp_vp;


private extern (C) alias long function(void*, void*, long)                   t_l__vp_vp_l;
private extern (C) alias long function(void*)                                t_l__vp;

private extern (C) alias void* function(void*, void*, void*, void*, void*, void*, void*) t_vp__vp_vp_vp_vp_vp_vp_vp;
private extern (C) alias void* function(void*, void*, void*, void*, void*, void*, void*, void*) t_vp__vp_vp_vp_vp_vp_vp_vp_vp;

//    void* getOpenFileName(QWidget parent = null, QString caption = null, 
//        QString dir = null, QString filter = null, QString selectedFilter = null, options = 0) {

// QApplication
private extern (C) alias void  function(void*, int*, char**)  	t_QApplication_QApplication; 
private extern (C) alias void  function(void*, int*, char**, bool)  	t_QApplication_QApplication_Gui; 
private extern (C) alias int   function(void*)                  t_QApplication_Exec; 
// QWidget
private extern (C) alias void  function(void*, void*, void*)    t_QWidget_QWidget;
private extern (C) alias void function(void*) 					t_destQWidget;
private extern (C) alias void  function(void*, bool) 			t_QWidget_setVisible;
private extern (C) alias void  function(void*, int, int) 	   	t_resize_QWidget;
// eQWidget
// extern (C) alias eQWidget* function(void*, void*) t_eQWidget_eQWidget;
private extern (C) alias int function() 						t_size_eQWidget;
// extern (C) alias void   function(void*, void*) 			t_v__vp_vp;
// QChar
private extern (C) alias void  function(void*, char) 			t_QChar_QChar;
// QString
private extern (C) alias void*  function(wchar*, size_t) 			t_QString_wchar;
// extern (C) alias void  function(void*, QChar) 		t_QString_QString;
private extern (C) alias void  function(void*) 					t_QString_clear;
private extern (C) alias void*  function() 						t_new_QString;
private extern (C) alias void function(void*, void*, int)       t_QString_fromUtf8;
private extern (C) alias char* function(void*) 					t_QString_toAscii;
private extern (C) alias char* function()						t_getAdrNameCodec;

// QNameCodec
private extern (C) alias void* function(char*)					t_QNameCodec;
private extern (C) alias void function(void*, void*, void*)	t_QNameCodec_toUnicode;
private extern (C) alias void function(void*, void*, void*)	t_QNameCodec_fromUnicode;

private extern (C) alias void*  function() 						t_qs_test;
private extern (C) alias  void* function(void*, ptrdiff_t)   			t_p_QWidget;
// QByteArray
private extern (C) alias  void* function()   					t_new_QByteArray;
private extern (C) alias  ubyte* function(void*)   				t_QByteArray_data;
// QTextEdit
private extern (C) alias  void* function(void*)   				t_p_QTextEdit;
private extern (C) alias  void function(void*)   				t_p_QTextEdit_clear;
// QPushButton
// QObject
private extern (C) alias void* function(void*) 					t_QObject;
private extern (C) alias void function(void*, char*, void*, char*, int)	t_QObject_connect;
// eSlot
private extern (C) alias void* function(void*) t_gSlot;
private extern (C) alias void function(void*) 					t_eSlot_setSignal0;
// QMessageBox
private extern (C) alias  void* function()   					t_new_QMessageBox;
private extern (C) alias  int function(void*)  			t_QMessageBox_exec;
// QBoxLayout
private extern (C) alias void* function(QBoxLayout.Direction, void*) t_QBoxLayout;
// QWebView
//private extern (C) alias void* function(QBoxLayout.Direction, void*) t_QBoxLayout;
private extern (C) alias  ubyte* function(void*)  			t_ub__vp;

/++
	Сообщение (andalog msgbox() VBA). Пример: msgbox("Это msgbox!", "Проверка!");
+/		
static void msgbox(string text = null, string caption = null, QMessageBox.Icon icon = QMessageBox.Icon.Information) {
	QString qs_str = new QString();	qs_str.setNameCodec("UTF-8");
	QMessageBox soob = new QMessageBox(null);
	if (caption is null) {
		qs_str.set(cast(char*)"Внимание!");	soob.setWindowTitle(qs_str);
	}
	else {
		qs_str.set(cast(char*)caption);	soob.setWindowTitle(qs_str);
	}
	if (text is null) {
		qs_str.set(cast(char*)". . . . .");	soob.setText(qs_str);
	}
	else {
		qs_str.set(cast(char*)text);	soob.setText(qs_str);
	}
	soob.setIcon(icon);
	soob.setStandardButtons(QMessageBox.StandardButton.Ok);
	soob.exec();
}
static void msgbox(QByteArray text = null, QByteArray caption = null, QMessageBox.Icon icon = QMessageBox.Icon.Information) {
    QString qs_str = new QString(); qs_str.setNameCodec("UTF-8");
    QMessageBox soob = new QMessageBox(null);
    if (caption is null) {
        qs_str.set(cast(char*)"Внимание!"); soob.setWindowTitle(qs_str);
    }
    else {
        qs_str.set(cast(char*)(caption.data())); soob.setWindowTitle(qs_str);
    }
    if (text is null) {
        qs_str.set(cast(char*)". . . . ."); soob.setText(qs_str);
    }
    else {
        qs_str.set(cast(char*)(text.data()));    soob.setText(qs_str);
    }
    soob.setIcon(icon);
    soob.setStandardButtons(QMessageBox.StandardButton.Ok);
    soob.exec();
}

// Загрузить DLL. Load DLL (.so)
private void* GetHlib(const char* name) {
	version(Windows) {
	  return LoadLibraryA(name);
	}
	version(linux) {
	  return dlopen(name, RTLD_GLOBAL || RTLD_LAZY);
	}
}
// Найти адреса функций в DLL
private void* GetPrAddres(bool isLoad, void* hLib, const char* nameFun) {
	if (isLoad) {   // Искать или не искать функцию. Find or not find function in library
		version(Windows) {
		  return GetProcAddress(hLib, nameFun);
		}
		version(linux) {
		  return dlsym(hLib, nameFun);
		}
	}
	return cast(void*)1;
}
// Сообщить об ошибке загрузки. Message on error.
private void MessageErrorLoad(bool showError, wstring s, int sw) {
	if (showError) {
		wstring soob;	
		if (sw==1) {	soob = "Error load: " ~ s; }	
		if (sw==2) {	soob = "Error find function: " ~ s; }	
	   version(Windows) {
		MessageBoxW(null,  cast(wchar*)soob, "Warning!",  MB_ICONERROR);
	   }
	   version(linux) {
		writeln(soob);
	   }
	}
} /// Message on error. s - text error, sw=1 - error load dll and sw=2 - error find function

char* MSS(string s, int n) {
	if (n == QMETHOD) return cast(char*)("0" ~ s).ptr; 
	if (n == QSLOT)   return cast(char*)("1" ~ s).ptr; 
	if (n == QSIGNAL) return cast(char*)("2" ~ s).ptr; 
	return null;
} /// Моделирует макросы QT. Model macros Qt. For n=2->SIGNAL(), n=1->SLOT(), n=0->METHOD().

// Скопировать строку с 0 в конце. Copy stringz.
void copyz(char* from, char* to) { for( int i=0; ; i++ ) {	*(to+i) = *(from+i); if (*(from+i) == '\0')  break;	} }
// Длина строки без 0
int strlenz(char* from) { int i; for( i=0; ; i++ ) { if (*(from+i) == '\0')  break;	} return i; }

int LoadQt(dll ldll, bool showError) {   ///  Загрузить DLL-ки Qt и QtE
	void* hQtGui; void* hQtCore; void* hQtE; void* hQtScript; void* hQtWeb; void* hQtNet;             // handes for dll
	string  cQtCore; string  cQtGui; string  cQtE;  string cQtScript; string cQtWeb; string cQtNet;   // strigs for win api LoadLibrary
	wstring wQtCore; wstring wQtGui; wstring wQtE; wstring wQtScript; wstring wQtWeb; wstring wQtNet; // wstring for wrete error D
	bool bCore; bool bGui; bool bQtE; bool bScript; bool bWeb; bool bNet;
	
	version(Windows) {
		cQtCore = "QtCore4.dll"; cQtGui = "QtGui4.dll"; cQtE = "QtE.dll"; cQtScript = "QtScript4.dll"; cQtWeb = "QtWebKit4.dll"; cQtNet = "QtNetwork4.dll";
		wQtCore = "QtCore4.dll"; wQtGui = "QtGui4.dll"; wQtE = "QtE.dll"; wQtScript = "QtScript4.dll"; wQtWeb = "QtWebKit4.dll"; wQtNet = "QtNetwork4.dll";
	}
	 version(linux) {
		cQtCore = "libQtCore.so"; cQtGui = "libQtGui.so"; cQtE = "QtE.so.1.0.0"; cQtScript = "libQtScript.so"; cQtWeb = "libQtWebKit.so"; cQtNet = "libQtNetwork.so";
		wQtCore = "libQtCore.so"; wQtGui = "libQtGui.so"; wQtE = "QtE.so.1.0.0"; wQtScript = "libQtScript.so"; wQtWeb = "libQtWebKit.so"; wQtNet = "libQtNetwork.so";
	}
	const QtCore   = cast(char*)cQtCore;
	const QtGui    = cast(char*)cQtGui;
	const QtE      = cast(char*)cQtE;
	const QtScript = cast(char*)cQtScript;
    const QtWeb    = cast(char*)cQtWeb;
    const QtNet    = cast(char*)cQtNet;

    // Флаги для определения списка загружаемых DLL. Flags for load dll.
    bCore = cast(bool)(ldll & dll.Core); bGui = cast(bool)(ldll & dll.Gui); bQtE = cast(bool)(ldll & dll.QtE); 
    bScript = cast(bool)(ldll & dll.Script); bWeb = cast(bool)(ldll & dll.Web); bNet = cast(bool)(ldll & dll.Net); 
    // Load library in memory
    if (bCore)   {	hQtCore   = GetHlib(QtCore);   if (!hQtCore) { MessageErrorLoad(showError, wQtCore, 1);     return 1; } }
    if (bGui)    {	hQtGui    = GetHlib(QtGui);    if (!hQtGui)  { MessageErrorLoad(showError, wQtGui, 1);      return 1; } }
    if (bQtE)    {	hQtE      = GetHlib(QtE);      if (!hQtE)    { MessageErrorLoad(showError, wQtE, 1);        return 1; } }
    if (bScript) {  hQtScript = GetHlib(QtScript); if (!hQtScript) { MessageErrorLoad(showError, wQtScript, 1); return 1; } }
    if (bWeb)    {  hQtWeb    = GetHlib(QtWeb);    if (!hQtWeb) { MessageErrorLoad(showError, wQtWeb, 1);       return 1; } }
    if (bNet)    {  hQtNet    = GetHlib(QtNet);    if (!hQtNet) { MessageErrorLoad(showError, wQtNet, 1);       return 1; } }
	
	// +++ Проверка Lazarus
	pFunQt[98] = GetPrAddres(bQtE, hQtE, "QApplication_create"); if (!pFunQt[98]) MessageErrorLoad(showError, "QApplication_create"w, 2);
	pFunQt[97] = GetPrAddres(bQtE, hQtE, "QApplication_exec");   if (!pFunQt[97]) MessageErrorLoad(showError, "QApplication_exec"w, 2);
	
	// --- Проверка Lazarus
	// QApplication
	pFunQt[100] = GetPrAddres(bGui, hQtGui, "_ZN12QApplicationC1ERiPPcb"); if (!pFunQt[100]) MessageErrorLoad(showError, cast(wstring)"QApp:QApp_Gui"w, 2);
	pFunQt[0] = GetPrAddres(bGui, hQtGui, "_ZN12QApplicationC1ERiPPc"); if (!pFunQt[0]) MessageErrorLoad(showError, cast(wstring)"QApp:QApp"w, 2);
	pFunQt[1] = GetPrAddres(bGui, hQtGui, "_ZN12QApplication4execEv"); if (!pFunQt[1])  MessageErrorLoad(showError, cast(wstring)"QApp:exec"w, 2);
	pFunQt[63] = GetPrAddres(bGui, hQtGui, "_ZN12QApplication10setPaletteERK8QPalettePKc"); if (!pFunQt[63]) MessageErrorLoad(showError, "QApp:setPalette"w, 2);
	pFunQt[64] = GetPrAddres(bQtE, hQtE, "QT_QApp_setPalette"); if (!pFunQt[64]) MessageErrorLoad(showError, "QtE:QApp:setPalette"w, 2);
	pFunQt[59] = GetPrAddres(bGui, hQtGui, "_ZN12QApplication7paletteEv"); if (!pFunQt[59]) MessageErrorLoad(showError, "QApp_palette"w, 2);
	// eQWidget
	pFunQt[2] = GetPrAddres(bQtE, hQtE, "_ZN8eQWidgetC1EP7QWidget"); if (!pFunQt[2]) MessageErrorLoad(showError, cast(wstring)"eQWidget:eQWidget"w, 2);
	pFunQt[6] = GetPrAddres(bQtE, hQtE, "size_eQWidget"); if (!pFunQt[6]) MessageErrorLoad(showError, cast(wstring)"size_eQWidget"w, 2);
	pFunQt[12] = GetPrAddres(bQtE, hQtE, "p_QWidget"); if (!pFunQt[12]) MessageErrorLoad(showError, "p_QWidget"w, 2);
	pFunQt[23] = GetPrAddres(bQtE, hQtE, "setResizeEvent"); if (!pFunQt[23]) MessageErrorLoad(showError, "QWidget_setResizeEvent"w, 2);
	pFunQt[93] = GetPrAddres(bQtE, hQtE, "p_eQWidget_del"); if (!pFunQt[93]) MessageErrorLoad(showError, "p_eQWidget_del"w, 2);
	// QWidget
	pFunQt[3] = GetPrAddres(bGui, hQtGui, "_ZN7QWidgetC1EPS_6QFlagsIN2Qt10WindowTypeEE"); if (!pFunQt[3]) MessageErrorLoad(showError, "QWidget:QWidget"w, 2);
	pFunQt[4] = GetPrAddres(bGui, hQtGui, "_ZThn8_N7QWidgetD0Ev"); if (!pFunQt[4])  MessageErrorLoad(showError, "QWidget:~QWidget"w, 2);
	pFunQt[5] = GetPrAddres(bGui, hQtGui, "_ZN7QWidget10setVisibleEb"); if (!pFunQt[5]) MessageErrorLoad(showError, "QWidget:setVisible"w, 2);
	pFunQt[8] = GetPrAddres(bGui, hQtGui, "_ZN7QWidget14setWindowTitleERK7QString"); if (!pFunQt[8]) MessageErrorLoad(showError, "setWindoowTitle"w, 2);
	pFunQt[19] = GetPrAddres(bQtE, hQtE, "resize_QWidget"); if (!pFunQt[19]) MessageErrorLoad(showError, "resize_QWidget"w, 2);
	pFunQt[50] = GetPrAddres(bGui, hQtGui, "_ZN7QWidget9setLayoutEP7QLayout"); if (!pFunQt[50]) MessageErrorLoad(showError, "QWidget_setLayout"w, 2);
	// QChar
	pFunQt[7] = GetPrAddres(bCore, hQtCore, "_ZN5QCharC2Ec"); if (!pFunQt[7]) MessageErrorLoad(showError, "QChar:QChar"w, 2);
	// QString
	pFunQt[9] = GetPrAddres(bCore, hQtCore, "_ZN7QStringC1E5QChar"); if (!pFunQt[9]) MessageErrorLoad(showError, "Qstring:Qstring"w, 2);
	pFunQt[11] = GetPrAddres(bCore, hQtCore, "_ZN7QString5clearEv"); if (!pFunQt[11]) MessageErrorLoad(showError, "Qstring:clear"w, 2);
	pFunQt[13] = GetPrAddres(bQtE, hQtE, "new_QString"); if (!pFunQt[13]) MessageErrorLoad(showError, "new_Qstring"w, 2);
	pFunQt[14] = GetPrAddres(bCore, hQtCore, "_ZN7QString8fromUtf8EPKci"); if (!pFunQt[14]) MessageErrorLoad(showError, "Qstring_fromUtf8"w, 2);
	pFunQt[15] = GetPrAddres(bCore, hQtCore, "_ZNK7QString7toAsciiEv"); if (!pFunQt[15]) MessageErrorLoad(showError, "Qstring_toAscii"w, 2);
	pFunQt[18] = GetPrAddres(bQtE, hQtE, "new_QString_wchar"); if (!pFunQt[18]) MessageErrorLoad(showError, "Qstring_wchar"w, 2);
	pFunQt[30] = GetPrAddres(bQtE, hQtE, "adrNameCodec"); if (!pFunQt[30]) MessageErrorLoad(showError, "adrNameCodec"w, 2);
	pFunQt[31] = GetPrAddres(bQtE, hQtE, "QT_QString_set"); if (!pFunQt[31]) MessageErrorLoad(showError, "QT_QString_set"w, 2);
	pFunQt[32] = GetPrAddres(bQtE, hQtE, "QT_QString_text"); if (!pFunQt[32]) MessageErrorLoad(showError, "QT_QString_text"w, 2);
	pFunQt[67] = GetPrAddres(bQtE, hQtE, "QT_QString_toUnicode"); if (!pFunQt[67]) MessageErrorLoad(showError, "QT_QString_toUnicode"w, 2);
	pFunQt[68] = GetPrAddres(bQtE, hQtE, "QT_QString_fromUnicode"); if (!pFunQt[68]) MessageErrorLoad(showError, "QT_QString_fromUnicode"w, 2);
	// QNameCodec
	pFunQt[33] = GetPrAddres(bQtE, hQtE, "p_QTextCodec"); if (!pFunQt[33]) MessageErrorLoad(showError, "p_QTextCodec"w, 2);
	pFunQt[34] = GetPrAddres(bQtE, hQtE, "QT_QTextCodec_toUnicode"); if (!pFunQt[34]) MessageErrorLoad(showError, "QT_QTextCodec_toUnicode"w, 2);
	pFunQt[35] = GetPrAddres(bQtE, hQtE, "QT_QTextCodec_fromUnicode"); if (!pFunQt[35]) MessageErrorLoad(showError, "QT_QTextCodec_fromUnicode"w, 2);
	// QByteArray
	pFunQt[16] = GetPrAddres(bQtE, hQtE, "new_QByteArray"); if (!pFunQt[16]) MessageErrorLoad(showError, "new_QByteArray"w, 2);
	pFunQt[17] = GetPrAddres(bQtE, hQtE, "new_QByteArray_data"); if (!pFunQt[17]) MessageErrorLoad(showError, "QByteArray_data"w, 2);
	pFunQt[10] = GetPrAddres(bQtE, hQtE, "qs_test"); if (!pFunQt[10]) MessageErrorLoad(showError, "qs_test"w, 2);
	// QTextEdit
	pFunQt[20] = GetPrAddres(bQtE, hQtE, "p_QTextEdit"); if (!pFunQt[20]) MessageErrorLoad(showError, "p_QTextEdit"w, 2);
	pFunQt[21] = GetPrAddres(bGui, hQtGui, "_ZN9QTextEdit6appendERK7QString"); if (!pFunQt[21]) MessageErrorLoad(showError, "TextEdit_append"w, 2);
	pFunQt[22] = GetPrAddres(bGui, hQtGui, "_ZN9QTextEdit5clearEv"); if (!pFunQt[22]) MessageErrorLoad(showError, "TextEdit_clear"w, 2);
	// QPushButton
	pFunQt[24] = GetPrAddres(bQtE, hQtE, "QT_QPushButton"); if (!pFunQt[24]) MessageErrorLoad(showError, "QT_QPushButton"w, 2);
	// QObject
	pFunQt[26] = GetPrAddres(bQtE, hQtE, "QT_QObject"); if (!pFunQt[26]) MessageErrorLoad(showError, "QT_QObject"w, 2);
	pFunQt[27] = GetPrAddres(bCore, hQtCore, "_ZN7QObject7connectEPKS_PKcS1_S3_N2Qt14ConnectionTypeE"); if (!pFunQt[27]) MessageErrorLoad(showError, "QT_connect"w, 2);
	// eSlot
	pFunQt[25] = GetPrAddres(bQtE, hQtE, "eSlot_setSignal0"); if (!pFunQt[25]) MessageErrorLoad(showError, "eSlot_setSignal0"w, 2);
	pFunQt[28] = GetPrAddres(bQtE, hQtE, "qte_eSlot"); if (!pFunQt[28]) MessageErrorLoad(showError, "qte_eSlot"w, 2);
	pFunQt[29] = GetPrAddres(bQtE, hQtE, "eSlot_setSlot0"); if (!pFunQt[29]) MessageErrorLoad(showError, "eSlot_setSlot0"w, 2);
	pFunQt[94] = GetPrAddres(bQtE, hQtE, "eSlot_setSlot"); if (!pFunQt[94]) MessageErrorLoad(showError, "eSlot_setSlot"w, 2);
	// QMessageBox
	pFunQt[36] = GetPrAddres(bQtE, hQtE, "QT_QMessageBox"); if (!pFunQt[36]) MessageErrorLoad(showError, "QT_QMessageBox"w, 2);
	pFunQt[37] = GetPrAddres(bGui, hQtGui, "_ZN11QMessageBox7setTextERK7QString"); if (!pFunQt[37]) MessageErrorLoad(showError, "QMessageBox_setText"w, 2);
	pFunQt[38] = GetPrAddres(bQtE, hQtE, "QT_QMessageBox_exec"); if (!pFunQt[38]) MessageErrorLoad(showError, "QT_QMessageBox_exec"w, 2);
	pFunQt[39] = GetPrAddres(bGui, hQtGui, "_ZN11QMessageBox14setWindowTitleERK7QString"); if (!pFunQt[39]) MessageErrorLoad(showError, "QT_QMessageBox_setWindowTitle"w, 2);
	pFunQt[40] = GetPrAddres(bGui, hQtGui, "_ZN11QMessageBox7setIconENS_4IconE"); if (!pFunQt[40]) MessageErrorLoad(showError, "QT_QMessageBox_setIcon"w, 2);
	pFunQt[41] = GetPrAddres(bGui, hQtGui, "_ZN11QMessageBox18setInformativeTextERK7QString"); if (!pFunQt[41]) MessageErrorLoad(showError, "QT_QMessageBox_setInformativeText"w, 2);
	pFunQt[42] = GetPrAddres(bGui, hQtGui, "_ZN11QMessageBox18setStandardButtonsE6QFlagsINS_14StandardButtonEE"); if (!pFunQt[42]) MessageErrorLoad(showError, "QT_QMessageBox_setStandardButtons"w, 2);
	pFunQt[43] = GetPrAddres(bGui, hQtGui, "_ZN11QMessageBox16setDefaultButtonENS_14StandardButtonE"); if (!pFunQt[43]) MessageErrorLoad(showError, "QT_QMessageBox_setDefaultButton"w, 2);
	pFunQt[44] = GetPrAddres(bGui, hQtGui, "_ZN11QMessageBox15setEscapeButtonENS_14StandardButtonE"); if (!pFunQt[44]) MessageErrorLoad(showError, "QT_QMessageBox_setEscapeButton"w, 2);
  // QBoxLayout
	pFunQt[47] = GetPrAddres(bQtE, hQtE, "QT_QBoxLayout"); if (!pFunQt[47]) MessageErrorLoad(showError, "QT_QBoxLayout"w, 2);

	pFunQt[48] = GetPrAddres(bQtE, hQtE, "QT_QBoxLayout_addWidget"); if (!pFunQt[48]) MessageErrorLoad(showError, "QT_QBoxLayout_addWidget"w, 2);
	pFunQt[49] = GetPrAddres(bQtE, hQtE, "QT_QBoxLayout_addLayout"); if (!pFunQt[49]) MessageErrorLoad(showError, "QT_QBoxLayout_addLayout"w, 2);

  // QVBoxLayout
	pFunQt[45] = GetPrAddres(bQtE, hQtE, "QT_QVBoxLayout"); if (!pFunQt[45]) MessageErrorLoad(showError, "QT_QVBoxLayout"w, 2);
  // QHBoxLayout
	pFunQt[46] = GetPrAddres(bQtE, hQtE, "QT_QHBoxLayout"); if (!pFunQt[46]) MessageErrorLoad(showError, "QT_QHBoxLayout"w, 2);
  // QMainWindow
	pFunQt[54] = GetPrAddres(bQtE, hQtE, "QT_QMainWindow"); if (!pFunQt[54]) MessageErrorLoad(showError, "QT_QMainWindow"w, 2);
	pFunQt[52] = GetPrAddres(bGui, hQtGui, "_ZN11QMainWindow12setStatusBarEP10QStatusBar"); if (!pFunQt[52]) MessageErrorLoad(showError, "QT_QMainWindow_setStatusBar"w, 2);
	pFunQt[53] = GetPrAddres(bGui, hQtGui, "_ZN11QMainWindow16setCentralWidgetEP7QWidget"); if (!pFunQt[53]) MessageErrorLoad(showError, "QT_QMainWindow_setCentralWidget"w, 2);
	pFunQt[87] = GetPrAddres(bQtE, hQtE, "QT_QMainWindow_setMenuBar"); if (!pFunQt[87]) MessageErrorLoad(showError, "QT_QMainWindow_setMenuBar"w, 2);
  // QStatusBar
	pFunQt[51] = GetPrAddres(bQtE, hQtE, "QT_QStatusBar"); if (!pFunQt[51]) MessageErrorLoad(showError, "QT_QStatusBar"w, 2);
  // QLCDNumber
	pFunQt[55] = GetPrAddres(bQtE, hQtE, "QT_QLCDNumber"); if (!pFunQt[55]) MessageErrorLoad(showError, "QT_QLCDNumber"w, 2);
	pFunQt[57] = GetPrAddres(bGui, hQtGui, "_ZN10QLCDNumber15setSegmentStyleENS_12SegmentStyleE"); if (!pFunQt[57]) MessageErrorLoad(showError, "QLCDNumber_setSegmentStyle"w, 2);
  // QSpinBox
	pFunQt[56] = GetPrAddres(bQtE, hQtE, "QT_QSpinBox"); if (!pFunQt[56]) MessageErrorLoad(showError, "QT_QSpinBox"w, 2);
  // QPalette
	pFunQt[58] = GetPrAddres(bQtE, hQtE, "QT_QPalette"); if (!pFunQt[58]) MessageErrorLoad(showError, "QT_QPalette"w, 2);
	pFunQt[62] = GetPrAddres(bQtE, hQtE, "QT_QPalette_setColor"); if (!pFunQt[62]) MessageErrorLoad(showError, "QT_QPalette_setColor"w, 2);
	pFunQt[65] = GetPrAddres(bQtE, hQtE, "QT_QPalette_setColor2"); if (!pFunQt[65]) MessageErrorLoad(showError, "QT_QPalette_setColor2"w, 2);
  // QColor
	pFunQt[60] = GetPrAddres(bQtE, hQtE, "QT_QColor"); if (!pFunQt[60]) MessageErrorLoad(showError, "QT_QColor"w, 2);
	pFunQt[61] = GetPrAddres(bGui, hQtGui, "_ZN6QColor6setRgbEiiii"); if (!pFunQt[61]) MessageErrorLoad(showError, "QT_QColor_setRgb"w, 2);
  // QScriptEngine
	pFunQt[66] = GetPrAddres(bQtE, hQtE, "QT_QScriptEngine"); if (!pFunQt[66]) MessageErrorLoad(showError, "QT_QScriptEngine"w, 2);
  // QLineEdit
  	pFunQt[71] = GetPrAddres(bQtE, hQtE, "QT_QLineEdit"); if (!pFunQt[71]) MessageErrorLoad(showError, "QT_QLineEdit"w, 2);
  	pFunQt[72] = GetPrAddres(bQtE, hQtE, "QT_QLineEdit_onreturnPressed"); if (!pFunQt[72]) MessageErrorLoad(showError, "QT_QLineEdit_onreturnPressed"w, 2);
  	pFunQt[73] = GetPrAddres(bQtE, hQtE, "QT_QLineEdit_text"); if (!pFunQt[73]) MessageErrorLoad(showError, "QT_QLineEdit_text"w, 2);
  	pFunQt[74] = GetPrAddres(bQtE, hQtE, "QT_QLineEdit_set"); if (!pFunQt[74]) MessageErrorLoad(showError, "QT_QLineEdit_set"w, 2);
  	pFunQt[75] = GetPrAddres(bQtE, hQtE, "QT_QLineEdit_setfocus"); if (!pFunQt[75]) MessageErrorLoad(showError, "QT_QLineEdit_setfocus"w, 2);
  	pFunQt[76] = GetPrAddres(bQtE, hQtE, "QT_QLineEdit_clear"); if (!pFunQt[76]) MessageErrorLoad(showError, "QT_QLineEdit_clear"w, 2);
  // QAction
  	pFunQt[77] = GetPrAddres(bQtE, hQtE, "QT_QAction"); if (!pFunQt[77]) MessageErrorLoad(showError, "QT_QAction"w, 2);
//  	pFunQt[78] = GetPrAddres(bQtE, hQtE, "QT_QAction_setText"); if (!pFunQt[78]) MessageErrorLoad(showError, "QT_QAction_setText"w, 2);
  	pFunQt[78] = GetPrAddres(bGui, hQtGui, "_ZN7QAction7setTextERK7QString"); if (!pFunQt[78]) MessageErrorLoad(showError, "_ZN7QAction7setTextERK7QString"w, 2);
  	pFunQt[79] = GetPrAddres(bQtE, hQtE, "QT_QAction_setHotKey"); if (!pFunQt[79]) MessageErrorLoad(showError, "QT_QAction_setHotKey"w, 2);
  	pFunQt[80] = GetPrAddres(bQtE, hQtE, "QT_QAction_onClick"); if (!pFunQt[80]) MessageErrorLoad(showError, "QT_QAction_onClick"w, 2);
  // QMenuBar
  	pFunQt[81] = GetPrAddres(bQtE, hQtE, "QT_QMenuBar"); if (!pFunQt[81]) MessageErrorLoad(showError, "QT_QMenuBar"w, 2);
//  	pFunQt[82] = GetPrAddres(bQtE, hQtE, "QT_QMenuBar_addMenu"); if (!pFunQt[82]) MessageErrorLoad(showError, "QT_QMenuBar_addMenu"w, 2);
  	pFunQt[82] = GetPrAddres(bGui, hQtGui, "_ZN8QMenuBar7addMenuEP5QMenu"); if (!pFunQt[82]) MessageErrorLoad(showError, "_ZN8QMenuBar7addMenuEP5QMenu"w, 2);
  // QMenu
  	pFunQt[83] = GetPrAddres(bQtE, hQtE, "QT_QMenu"); if (!pFunQt[83]) MessageErrorLoad(showError, "QT_QMenu"w, 2);
  	pFunQt[84] = GetPrAddres(bQtE, hQtE, "QT_QMenu_addAction"); if (!pFunQt[84]) MessageErrorLoad(showError, "QT_QMenu_addAction"w, 2);
   	pFunQt[85] = GetPrAddres(bGui, hQtGui, "_ZN5QMenu12addSeparatorEv"); if (!pFunQt[85]) MessageErrorLoad(showError, "_ZN5QMenu12addSeparatorEv"w, 2);
//  	pFunQt[85] = GetPrAddres(bQtE, hQtE, "QT_QMenu_addSep"); if (!pFunQt[85]) MessageErrorLoad(showError, "QT_QMenu_addSep"w, 2);
//  	pFunQt[86] = GetPrAddres(bQtE, hQtE, "QT_QMenu_setTitle"); if (!pFunQt[86]) MessageErrorLoad(showError, "QT_QMenu_setTitle"w, 2);
  	pFunQt[86] = GetPrAddres(bGui, hQtGui, "_ZN5QMenu8setTitleERK7QString"); if (!pFunQt[86]) MessageErrorLoad(showError, "_ZN5QMenu8setTitleERK7QString"w, 2);
    // 87 - занят
  // QWebView
  	pFunQt[88] = GetPrAddres(bQtE, hQtE, "QT_QWebView"); if (!pFunQt[88]) MessageErrorLoad(showError, "QT_QWebView"w, 2);
  	pFunQt[91] = GetPrAddres(bQtE, hQtE, "QT_QWebView_load"); if (!pFunQt[91]) MessageErrorLoad(showError, "QT_QWebView_load"w, 2);
  // QUrl
  	pFunQt[89] = GetPrAddres(bQtE, hQtE, "QT_QUrl"); if (!pFunQt[89]) MessageErrorLoad(showError, "QT_QUrl"w, 2);
  	pFunQt[90] = GetPrAddres(bCore, hQtCore, "_ZN4QUrl6setUrlERK7QString"); if (!pFunQt[90]) MessageErrorLoad(showError, "QUrl::setUrl(QString)"w, 2);

  	pFunQt[92] = GetPrAddres(bQtE, hQtE, "setCloseEvent"); if (!pFunQt[92]) MessageErrorLoad(showError, "setCloseEvent"w, 2);
  // QString - обработка строк
	pFunQt[101] = GetPrAddres(bCore, hQtCore, "_ZN7QString6appendERKS_"); if (!pFunQt[101]) MessageErrorLoad(showError, "Qstring_append"w, 2);
	pFunQt[102] = GetPrAddres(bQtE, hQtE, "QString_data"); if (!pFunQt[102]) MessageErrorLoad(showError, "QString_data"w, 2);
	pFunQt[103] = GetPrAddres(bQtE, hQtE, "QString_size"); if (!pFunQt[103]) MessageErrorLoad(showError, "QString_size"w, 2);
	pFunQt[104] = GetPrAddres(bCore, hQtCore, "_ZN7QString6insertEiPK5QChari"); if (!pFunQt[104]) MessageErrorLoad(showError, "QString_insert"w, 2);
	pFunQt[105] = GetPrAddres(bCore, hQtCore, "_ZN7QString7replaceEiiRKS_"); if (!pFunQt[105]) MessageErrorLoad(showError, "QString_replace"w, 2);

	pFunQt[106] = GetPrAddres(bQtE, hQtE, "QT_QWebViewDel"); if (!pFunQt[106]) MessageErrorLoad(showError, "QT_QWebViewDel"w, 2);
    pFunQt[107] = GetPrAddres(bQtE, hQtE, "QT_QSpinBoxDel"); if (!pFunQt[107]) MessageErrorLoad(showError, "QT_QSpinBoxDel"w, 2);
    pFunQt[108] = GetPrAddres(bQtE, hQtE, "QMainWindowDel"); if (!pFunQt[108]) MessageErrorLoad(showError, "QMainWindowDel"w, 2);

    pFunQt[109] = GetPrAddres(bQtE, hQtE, "QT_QWebView_size"); if (!pFunQt[109]) MessageErrorLoad(showError, "QT_QWebView_size"w, 2);

    pFunQt[110] = GetPrAddres(bWeb, hQtWeb, "_ZN8QWebViewC2EP7QWidget"); if (!pFunQt[110]) MessageErrorLoad(showError, "QWebView::QWebView(QWidget*)"w, 2);
    pFunQt[111] = GetPrAddres(bWeb, hQtWeb, "_ZN8QWebView4loadERK4QUrl"); if (!pFunQt[111]) MessageErrorLoad(showError, "QWebView::load(QUrl const&)"w, 2);

    pFunQt[112] = GetPrAddres(bGui, hQtGui, "_ZN12QApplicationD1Ev"); if (!pFunQt[112]) MessageErrorLoad(showError, "QApplication::~QApplication()"w, 2);
  // QProgressBar
    pFunQt[113] = GetPrAddres(bQtE, hQtE, "QT_QProgressBar"); if (!pFunQt[113]) MessageErrorLoad(showError, "QT_QProgressBar"w, 2);
  // QCheckBox
    pFunQt[114] = GetPrAddres(bQtE, hQtE, "QT_QCheckBox"); if (!pFunQt[114]) MessageErrorLoad(showError, "QT_QCheckBox"w, 2);
    pFunQt[115] = GetPrAddres(bGui, hQtGui, "_ZN15QAbstractButton7setTextERK7QString"); if (!pFunQt[115]) MessageErrorLoad(showError, "AbstractButton::setText"w, 2);
  // Layout
    pFunQt[116] = GetPrAddres(bGui, hQtGui, "_ZN7QLayout9setMarginEi"); if (!pFunQt[116]) MessageErrorLoad(showError, "QLayout::setMargin(int)"w, 2);
    pFunQt[117] = GetPrAddres(bGui, hQtGui, "_ZN7QLayout10setSpacingEi"); if (!pFunQt[117]) MessageErrorLoad(showError, "QLayout::setSpacing(int)"w, 2);
    pFunQt[118] = GetPrAddres(bGui, hQtGui, "_ZN7QWidget13setStyleSheetERK7QString"); if (!pFunQt[118]) MessageErrorLoad(showError, "QWidget::setStyleSheet(QString const&)"w, 2);
  
    pFunQt[119] = GetPrAddres(bGui, hQtGui, "_ZN10QStatusBar11showMessageERK7QStringi"); if (!pFunQt[119]) MessageErrorLoad(showError, "QStatusBar::ShowMessage(QStrin, int)"w, 2);
    pFunQt[120] = GetPrAddres(bGui, hQtGui, "_ZN10QStatusBar12clearMessageEv"); if (!pFunQt[120]) MessageErrorLoad(showError, "QStatusBar::clearMessage()"w, 2);
    pFunQt[121] = GetPrAddres(bGui, hQtGui, "_ZN12QProgressBar10setMaximumEi"); if (!pFunQt[121]) MessageErrorLoad(showError, "QProgressBar::setMaximum(int)"w, 2);
    pFunQt[122] = GetPrAddres(bGui, hQtGui, "_ZN12QProgressBar10setMinimumEi"); if (!pFunQt[122]) MessageErrorLoad(showError, "QProgressBar::setMinimum(int)"w, 2);
    pFunQt[123] = GetPrAddres(bGui, hQtGui, "_ZN12QProgressBar8setValueEi"); if (!pFunQt[123]) MessageErrorLoad(showError, "QProgressBar::setValue(int)"w, 2);

    pFunQt[124] = GetPrAddres(bGui, hQtGui, "_ZN7QWidget14setMinimumSizeEii"); if (!pFunQt[124]) MessageErrorLoad(showError, "QWidget::setMinimumSize(int, int)"w, 2);
  // сокеты
    pFunQt[125] = GetPrAddres(bQtE, hQtE, "QT_QTcpSocket"); if (!pFunQt[125]) MessageErrorLoad(showError, "QT_QTcpSocket"w, 2);

    pFunQt[126] = GetPrAddres(bNet, hQtNet, "_ZN15QAbstractSocket5abortEv"); if (!pFunQt[126]) MessageErrorLoad(showError, "AbstractSocket::abort()"w, 2);
    pFunQt[127] = GetPrAddres(bNet, hQtNet, "_ZN15QAbstractSocket5closeEv"); if (!pFunQt[127]) MessageErrorLoad(showError, "AbstractSocket::close()"w, 2);

    
    pFunQt[128] = GetPrAddres(bQtE, hQtE, "QIODevice_readLine"); if (!pFunQt[128]) MessageErrorLoad(showError, "QIODevice_readLine"w, 2);
    
    // Мда... что делать не знаю. Не могу выполнить в D след. С++ код: QString str = *ustr; // где QString* ustr;
    // из за этого не могу вызвать [128] функцию и пришлось вписывать её в QtE.dll в [129] функцию ---> 
//    pFunQt[128] = GetPrAddres(bNet, hQtNet, "_ZN15QAbstractSocket13connectToHostERK7QStringt6QFlagsIN9QIODevice12OpenModeFlagEE"); if (!pFunQt[128]) MessageErrorLoad(showError, "QAbstractSocket::connectToHost(const QString &hostName, quint16 port, OpenMode openMode = ReadWrite )"w, 2);
    // ----> в которой и приходится делать такое преобразование.
    pFunQt[129] = GetPrAddres(bQtE, hQtE, "QT_QTcpSocket_connectToHost"); if (!pFunQt[129]) MessageErrorLoad(showError, "QT_QTcpSocket_connectToHost"w, 2);
    pFunQt[130] = GetPrAddres(bNet, hQtNet, "_ZNK9QIODevice11canReadLineEv"); if (!pFunQt[130]) MessageErrorLoad(showError, "QIODevice::canReadLine()"w, 2);
    pFunQt[131] = GetPrAddres(bQtE, hQtE, "QIODevice_setTextModeEnabled"); if (!pFunQt[131]) MessageErrorLoad(showError, "QIODevice_setTextModeEnabled"w, 2);
    pFunQt[132] = GetPrAddres(bQtE, hQtE, "QIODevice_write"); if (!pFunQt[132]) MessageErrorLoad(showError, "QIODevice_write"w, 2);

  // QDataStream
    pFunQt[133] = GetPrAddres(bQtE, hQtE, "QT_QDataStream"); if (!pFunQt[133]) MessageErrorLoad(showError, "QT_QDataStream"w, 2);
    pFunQt[134] = GetPrAddres(bQtE, hQtE, "QT_QDataStream_ReadRawData"); if (!pFunQt[134]) MessageErrorLoad(showError, "QT_QDataStream_ReadRawData"w, 2);
    pFunQt[135] = GetPrAddres(bQtE, hQtE, "QT_QDataStream_WriteRawData"); if (!pFunQt[135]) MessageErrorLoad(showError, "QT_QDataStream_WriteRawData"w, 2);
    pFunQt[136] = GetPrAddres(bQtE, hQtE, "QT_QDataStream_setVersion"); if (!pFunQt[136]) MessageErrorLoad(showError, "QT_QDataStream_setVersion"w, 2);
  // QByteArray
    pFunQt[137] = GetPrAddres(bQtE, hQtE, "new_QByteArray_vc"); if (!pFunQt[137]) MessageErrorLoad(showError, "new_QByteArray_vc"w, 2);
    pFunQt[138] = GetPrAddres(bQtE, hQtE, "QByteArray_size"); if (!pFunQt[138]) MessageErrorLoad(showError, "QByteArray_size"w, 2);
    pFunQt[139] = GetPrAddres(bQtE, hQtE, "delete_QByteArray"); if (!pFunQt[139]) MessageErrorLoad(showError, "delete_QByteArray"w, 2);
    pFunQt[140] = GetPrAddres(bQtE, hQtE, "QByteArray_operator2r1"); if (!pFunQt[140]) MessageErrorLoad(showError, "QByteArray_operator2r1"w, 2);
    pFunQt[141] = GetPrAddres(bQtE, hQtE, "QT_QDataStream3"); if (!pFunQt[141]) MessageErrorLoad(showError, "QT_QDataStream3"w, 2);
    pFunQt[142] = GetPrAddres(bCore, hQtCore, "_ZN11QDataStream9setDeviceEP9QIODevice"); if (!pFunQt[142]) MessageErrorLoad(showError, "_ZN11QDataStream9setDeviceEP9QIODevice"w, 2);

    pFunQt[143] = GetPrAddres(bCore, hQtCore, "_ZN10QByteArray4fillEci"); if (!pFunQt[143]) MessageErrorLoad(showError, "QByteArray::fill(char, int)"w, 2);
    pFunQt[144] = GetPrAddres(bCore, hQtCore, "_ZN10QByteArray11fromRawDataEPKci"); if (!pFunQt[144]) MessageErrorLoad(showError, "QByteArray::fromRawData(char const*, int)"w, 2);
    pFunQt[145] = GetPrAddres(bCore, hQtCore, "_ZNK10QByteArray7indexOfERKS_i"); if (!pFunQt[145]) MessageErrorLoad(showError, "QByteArray::indexOf(QByteArray const&, int) const"w, 2);
    pFunQt[146] = GetPrAddres(bCore, hQtCore, "_ZNK10QByteArray7indexOfEPKci"); if (!pFunQt[146]) MessageErrorLoad(showError, "QByteArray::indexOf(char const*, int) const"w, 2);
    pFunQt[147] = GetPrAddres(bCore, hQtCore, "_ZNK10QByteArray7indexOfEci"); if (!pFunQt[147]) MessageErrorLoad(showError, "QByteArray::indexOf(char, int) const"w, 2);

    pFunQt[148] = GetPrAddres(bCore, hQtCore, "_ZN10QByteArrayaSERKS_"); if (!pFunQt[148]) MessageErrorLoad(showError, "QByteArray::operator=(QByteArray const&)"w, 2);
    pFunQt[149] = GetPrAddres(bQtE, hQtE, "QByteArray_left"); if (!pFunQt[149]) MessageErrorLoad(showError, "QByteArray::left(int) const"w, 2);
    pFunQt[150] = GetPrAddres(bQtE, hQtE, "QByteArray_mid"); if (!pFunQt[150]) MessageErrorLoad(showError, "QByteArray::mid(int, int) const"w, 2);

    pFunQt[151] = GetPrAddres(bCore, hQtCore, "_ZN10QByteArray6appendEPKci"); if (!pFunQt[151]) MessageErrorLoad(showError, "QByteArray::append(char const*, int)"w, 2);

    pFunQt[152] = GetPrAddres(bCore, hQtCore, "_ZN10QByteArray6appendEPKc"); if (!pFunQt[152]) MessageErrorLoad(showError, "QByteArray::append(char const*)"w, 2);
    pFunQt[153] = GetPrAddres(bCore, hQtCore, "_ZN10QByteArray5clearEv"); if (!pFunQt[153]) MessageErrorLoad(showError, "QByteArray::clear()"w, 2);
    pFunQt[154] = GetPrAddres(bCore, hQtCore, "_ZN10QByteArray6appendEc"); if (!pFunQt[154]) MessageErrorLoad(showError, "QByteArray::append(char)"w, 2);
    pFunQt[155] = GetPrAddres(bCore, hQtCore, "_ZN10QByteArray6appendERKS_"); if (!pFunQt[155]) MessageErrorLoad(showError, "QByteArray::append(QByteArray const&)"w, 2);
    pFunQt[156] = GetPrAddres(bCore, hQtCore, "_ZN10QByteArray6resizeEi"); if (!pFunQt[156]) MessageErrorLoad(showError, "QByteArray::resize(int)"w, 2);
    pFunQt[157] = GetPrAddres(bCore, hQtCore, "_ZN10QByteArray6removeEii"); if (!pFunQt[157]) MessageErrorLoad(showError, "QByteArray::remove(int, int)"w, 2);
    pFunQt[158] = GetPrAddres(bCore, hQtCore, "_ZNK10QByteArray5toIntEPbi"); if (!pFunQt[158]) MessageErrorLoad(showError, "QByteArray::toInt(bool*, int)"w, 2);
    pFunQt[159] = GetPrAddres(bCore, hQtCore, "_ZNK9QIODevice14bytesAvailableEv"); if (!pFunQt[159]) MessageErrorLoad(showError, "QIODevice::bytesAvailable() const"w, 2);
    pFunQt[160] = GetPrAddres(bNet, hQtNet,   "_ZNK15QAbstractSocket14bytesAvailableEv"); if (!pFunQt[160]) MessageErrorLoad(showError, "QAbstractSocket::bytesAvailable() const"w, 2);
    pFunQt[161] = GetPrAddres(bNet, hQtNet,   "_ZNK15QAbstractSocket11canReadLineEv"); if (!pFunQt[161]) MessageErrorLoad(showError, "QAbstractSocket::canReadLine()"w, 2);
// ============ QLabel =======================================
    pFunQt[162] = GetPrAddres(bQtE, hQtE,   "QT_QLabel_new"); if (!pFunQt[162]) MessageErrorLoad(showError, "QLabel new"w, 2);
    pFunQt[163] = GetPrAddres(bQtE, hQtE,   "delete_QT_QLabel"); if (!pFunQt[163]) MessageErrorLoad(showError, "QLabel delete"w, 2);
    pFunQt[164] = GetPrAddres(bGui, hQtGui,   "_ZN6QLabel7setTextERK7QString"); if (!pFunQt[164]) MessageErrorLoad(showError, "QLabel::setText(QString const&)"w, 2);
// ============ QFrame =======================================
    pFunQt[165] = GetPrAddres(bGui, hQtGui,   "_ZN6QFrame13setFrameShapeENS_5ShapeE"); if (!pFunQt[165]) MessageErrorLoad(showError, "QFrame::setFrameShape(QFrame::Shape)"w, 2);
    pFunQt[166] = GetPrAddres(bGui, hQtGui,   "_ZN6QFrame14setFrameShadowENS_6ShadowE"); if (!pFunQt[166]) MessageErrorLoad(showError, "QFrame::setFrameShadow(QFrame::Shadow)"w, 2);
    pFunQt[167] = GetPrAddres(bGui, hQtGui,   "_ZN7QWidget14setMaximumSizeEii"); if (!pFunQt[167]) MessageErrorLoad(showError, "QWidget::setMaximumSize(int, int)"w, 2);
    pFunQt[168] = GetPrAddres(bGui, hQtGui,   "_ZN6QLabel12setAlignmentEi"); if (!pFunQt[168]) MessageErrorLoad(showError, "setAlignment(QFlags<Qt::AlignmentFlag>)"w, 2);

    pFunQt[169] = GetPrAddres(bQtE, hQtE,    "QT_QObject_parent"); if (!pFunQt[169]) MessageErrorLoad(showError, "QObject::parent"w, 2);

	pFunQt[170] = GetPrAddres(bQtE, hQtE, "eSlot_setSlotN"); if (!pFunQt[170]) MessageErrorLoad(showError, "eSlot_setSlotN"w, 2);
    pFunQt[171] = GetPrAddres(bGui, hQtGui, "_ZN7QWidget10setEnabledEb"); if (!pFunQt[171]) MessageErrorLoad(showError, "QWidget::setEnabled(bool)"w, 2);
// ============ setToolTip =======================================
    pFunQt[172] = GetPrAddres(bGui, hQtGui, "_ZN7QWidget10setToolTipERK7QString"); if (!pFunQt[172]) MessageErrorLoad(showError, "QWidget::setToolTip(QString const&)"w, 2);
    pFunQt[173] = GetPrAddres(bGui, hQtGui, "_ZN7QAction10setToolTipERK7QString"); if (!pFunQt[173]) MessageErrorLoad(showError, "QAction::setToolTip(QString const&)"w, 2);
// ============ QGroupBox =======================================
    pFunQt[174] = GetPrAddres(bQtE, hQtE, "p_QGroupBox"); if (!pFunQt[174]) MessageErrorLoad(showError, "QGroupBox::p_QGroupBox()"w, 2);
    pFunQt[175] = GetPrAddres(bGui, hQtGui, "_ZN9QGroupBox8setTitleERK7QString"); if (!pFunQt[175]) MessageErrorLoad(showError, "QGroupBox::setTitle(QString const&)"w, 2);
  // QRadioButton
    pFunQt[176] = GetPrAddres(bQtE, hQtE, "QT_QRadioButton"); if (!pFunQt[176]) MessageErrorLoad(showError, "QT_QRadioButton::QT_QRadioButton"w, 2);
// ============ QBoxlayout =======================================
    pFunQt[177] = GetPrAddres(bGui, hQtGui, "_ZN10QBoxLayout10addSpacingEi"); if (!pFunQt[177]) MessageErrorLoad(showError, "QBoxLayout::addSpacing(int)"w, 2);
    pFunQt[178] = GetPrAddres(bGui, hQtGui, "_ZN10QBoxLayout10addStretchEi"); if (!pFunQt[178]) MessageErrorLoad(showError, "QBoxLayout::addStretch(int)"w, 2);
    pFunQt[179] = GetPrAddres(bGui, hQtGui, "_ZN10QBoxLayout8addStrutEi"); if (!pFunQt[179]) MessageErrorLoad(showError, "QBoxLayout::addStrut(int)"w, 2);
// ============ Эксперементальный класс DQByteArray == Работа с объектом С++ без компилятора ===============
    pFunQt[180] = GetPrAddres(bCore, hQtCore, "_ZN10QByteArrayC1EPKc"); if (!pFunQt[180]) MessageErrorLoad(showError, "QByteArray::QByteArray(char const*)"w, 2);
// ============ QString + QFileDialog ===============
    pFunQt[181] = GetPrAddres(bQtE, hQtE, "del_QString"); if (!pFunQt[181]) MessageErrorLoad(showError, "delete QString"w, 2);
    pFunQt[182] = GetPrAddres(bQtE, hQtE, "QT_QFileDialog"); if (!pFunQt[182]) MessageErrorLoad(showError, "QT_QFileDialog"w, 2);
    pFunQt[183] = GetPrAddres(bQtE, hQtE, "QT_QFileDialogDELETE"); if (!pFunQt[183]) MessageErrorLoad(showError, "delete QFileDialog"w, 2);
    pFunQt[184] = GetPrAddres(bGui, hQtGui, "_ZN11QFileDialog15getOpenFileNameEP7QWidgetRK7QStringS4_S4_PS2_6QFlagsINS_6OptionEE"); if (!pFunQt[184]) 
        MessageErrorLoad(showError, "QFileDialog::getOpenFileName(QWidget*, QString const&, QString const&, QString const&, QString*, QFlags<QFileDialog::Option>)"w, 2);
    pFunQt[185] = GetPrAddres(bQtE, hQtE, "QT_QFileDialog_getOpenFileName"); if (!pFunQt[185]) MessageErrorLoad(showError, "QT_QFileDialog_getOpenFileName"w, 2);
    
    return 0;
} ///  Загрузить DLL-ки Qt и QtE. Найти в них адреса функций и заполнить ими таблицу


/++
	Класс констант. В нем кое что из Qt::     
+/		
class QtE {
	enum Key {
	    Key_ControlModifier = 0x04000000,
        Key_Escape = 0x01000000,                // misc keys
        Key_Tab = 0x01000001,
        Key_Backtab = 0x01000002,
        Key_Backspace = 0x01000003,
        Key_Return = 0x01000004,
        Key_Enter = 0x01000005,
        Key_Insert = 0x01000006,
        Key_Delete = 0x01000007,
        Key_Pause = 0x01000008,
        Key_Print = 0x01000009,
        Key_SysReq = 0x0100000a,
        Key_Clear = 0x0100000b,
        Key_Home = 0x01000010,                // cursor movement
        Key_End = 0x01000011,
        Key_Left = 0x01000012,
        Key_Up = 0x01000013,
        Key_Right = 0x01000014,
        Key_Down = 0x01000015,
        Key_PageUp = 0x01000016,
        Key_Shift = 0x01000020,                // modifiers
        Key_Control = 0x01000021,
        Key_Meta = 0x01000022,
        Key_Alt = 0x01000023,
        Key_CapsLock = 0x01000024,
        Key_NumLock = 0x01000025,
        Key_ScrollLock = 0x01000026,
        Key_F1 = 0x01000030,                // function keys
        Key_F2 = 0x01000031,
        Key_F3 = 0x01000032,
        Key_F4 = 0x01000033,
        Key_F5 = 0x01000034,
        Key_F6 = 0x01000035,
        Key_F7 = 0x01000036,
        Key_F8 = 0x01000037,
        Key_F9 = 0x01000038,
        Key_F10 = 0x01000039,
        Key_F11 = 0x0100003a,
        Key_F12 = 0x0100003b,
        Key_F13 = 0x0100003c,
        Key_F14 = 0x0100003d,
        Key_F15 = 0x0100003e,
        Key_F16 = 0x0100003f,
        Key_F17 = 0x01000040,
        Key_F18 = 0x01000041,
        Key_F19 = 0x01000042,
        Key_F20 = 0x01000043,
        Key_F21 = 0x01000044,
        Key_F22 = 0x01000045,
        Key_F23 = 0x01000046,
        Key_F24 = 0x01000047,
        Key_F25 = 0x01000048,                // F25 .. F35 only on X11
        Key_F26 = 0x01000049,
        Key_F27 = 0x0100004a,
        Key_F28 = 0x0100004b,
        Key_F29 = 0x0100004c,
        Key_F30 = 0x0100004d,
        Key_F31 = 0x0100004e,
        Key_F32 = 0x0100004f,
        Key_F33 = 0x01000050,
        Key_F34 = 0x01000051,
        Key_F35 = 0x01000052,
        Key_Super_L = 0x01000053,                 // extra keys
        Key_Super_R = 0x01000054,
        Key_Menu = 0x01000055,
        Key_Hyper_L = 0x01000056,
        Key_Hyper_R = 0x01000057,
        Key_Help = 0x01000058,
        Key_Direction_L = 0x01000059,
        Key_Direction_R = 0x01000060,
        Key_Space = 0x20,                // 7 bit printable ASCII
        Key_Any = Key_Space,
        Key_Exclam = 0x21,
        Key_QuoteDbl = 0x22,
        Key_NumberSign = 0x23,
        Key_Dollar = 0x24,
        Key_Percent = 0x25,
        Key_Ampersand = 0x26,
        Key_Apostrophe = 0x27,
        Key_ParenLeft = 0x28,
        Key_ParenRight = 0x29,
        Key_Asterisk = 0x2a,
        Key_Plus = 0x2b,
        Key_Comma = 0x2c,
        Key_Minus = 0x2d,
        Key_Period = 0x2e,
        Key_Slash = 0x2f,
        Key_0 = 0x30,
        Key_1 = 0x31,
        Key_2 = 0x32,
        Key_3 = 0x33,
        Key_4 = 0x34,
        Key_5 = 0x35,
        Key_6 = 0x36,
        Key_7 = 0x37,
        Key_8 = 0x38,
        Key_9 = 0x39,
        Key_Colon = 0x3a,
        Key_Semicolon = 0x3b,
        Key_Less = 0x3c,
        Key_Equal = 0x3d,
        Key_Greater = 0x3e,
        Key_Question = 0x3f,
        Key_At = 0x40,
        Key_A = 0x41,
        Key_B = 0x42,
        Key_C = 0x43,
        Key_D = 0x44,
        Key_E = 0x45,
        Key_F = 0x46,
        Key_G = 0x47,
        Key_H = 0x48,
        Key_I = 0x49,
        Key_J = 0x4a,
        Key_K = 0x4b,
        Key_L = 0x4c,
        Key_M = 0x4d,
        Key_N = 0x4e,
        Key_O = 0x4f,
        Key_P = 0x50,
        Key_Q = 0x51,
        Key_R = 0x52,
        Key_S = 0x53,
        Key_T = 0x54,
        Key_U = 0x55,
        Key_V = 0x56,
        Key_W = 0x57,
        Key_X = 0x58,
        Key_Y = 0x59,
        Key_Z = 0x5a,
        Key_BracketLeft = 0x5b,
        Key_Backslash = 0x5c,
        Key_BracketRight = 0x5d,
        Key_AsciiCircum = 0x5e,
        Key_Underscore = 0x5f,
        Key_QuoteLeft = 0x60,
        Key_BraceLeft = 0x7b,
        Key_Bar = 0x7c,
        Key_BraceRight = 0x7d,
        Key_AsciiTilde = 0x7e,
        Key_nobreakspace = 0x0a0,
        Key_exclamdown = 0x0a1,
        Key_cent = 0x0a2,
        Key_sterling = 0x0a3,
        Key_currency = 0x0a4,
        Key_yen = 0x0a5,
        Key_brokenbar = 0x0a6,
        Key_section = 0x0a7,
        Key_diaeresis = 0x0a8,
        Key_copyright = 0x0a9,
        Key_ordfeminine = 0x0aa,
        Key_guillemotleft = 0x0ab,        // left angle quotation mark
        Key_notsign = 0x0ac,
        Key_hyphen = 0x0ad,
        Key_registered = 0x0ae,
        Key_macron = 0x0af,
        Key_degree = 0x0b0,
        Key_plusminus = 0x0b1,
        Key_twosuperior = 0x0b2,
        Key_threesuperior = 0x0b3,
        Key_acute = 0x0b4,
        Key_mu = 0x0b5,
        Key_paragraph = 0x0b6,
        Key_periodcentered = 0x0b7,
        Key_cedilla = 0x0b8,
        Key_onesuperior = 0x0b9,
        Key_masculine = 0x0ba,
        Key_guillemotright = 0x0bb,        // right angle quotation mark
        Key_onequarter = 0x0bc,
        Key_onehalf = 0x0bd,
        Key_threequarters = 0x0be,
        Key_questiondown = 0x0bf,
        Key_Agrave = 0x0c0,
        Key_Aacute = 0x0c1,
        Key_Acircumflex = 0x0c2,
        Key_Atilde = 0x0c3,
        Key_Adiaeresis = 0x0c4,
        Key_Aring = 0x0c5,
        Key_AE = 0x0c6,
        Key_Ccedilla = 0x0c7,
        Key_Egrave = 0x0c8,
        Key_Eacute = 0x0c9,
        Key_Ecircumflex = 0x0ca,
        Key_Ediaeresis = 0x0cb,
        Key_Igrave = 0x0cc,
        Key_Iacute = 0x0cd,
        Key_Icircumflex = 0x0ce,
        Key_Idiaeresis = 0x0cf,
        Key_ETH = 0x0d0,
        Key_Ntilde = 0x0d1,
        Key_Ograve = 0x0d2,
        Key_Oacute = 0x0d3,
        Key_Ocircumflex = 0x0d4,
        Key_Otilde = 0x0d5,
        Key_Odiaeresis = 0x0d6,
        Key_multiply = 0x0d7,
        Key_Ooblique = 0x0d8,
        Key_Ugrave = 0x0d9,
        Key_Uacute = 0x0da,
        Key_Ucircumflex = 0x0db,
        Key_Udiaeresis = 0x0dc,
        Key_Yacute = 0x0dd,
        Key_THORN = 0x0de,
        Key_ssharp = 0x0df,
        Key_division = 0x0f7,
        Key_ydiaeresis = 0x0ff,
        Key_AltGr               = 0x01001103,
        Key_Multi_key           = 0x01001120,  // Multi-key character compose
        Key_Codeinput           = 0x01001137,
        Key_SingleCandidate     = 0x0100113c,
        Key_MultipleCandidate   = 0x0100113d,
        Key_PreviousCandidate   = 0x0100113e,
        Key_unknown = 0x01ffffff
    }

    enum AlignmentFlag {
        AlignLeft = 0x0001,
        AlignLeading = AlignLeft,
        AlignRight = 0x0002,
        AlignTrailing = AlignRight,
        AlignHCenter = 0x0004,
        AlignJustify = 0x0008,
        AlignAbsolute = 0x0010,
        AlignHorizontal_Mask = AlignLeft | AlignRight | AlignHCenter | AlignJustify | AlignAbsolute,

        AlignTop = 0x0020,
        AlignBottom = 0x0040,
        AlignVCenter = 0x0080,
        AlignVertical_Mask = AlignTop | AlignBottom | AlignVCenter,
        AlignCenter = AlignVCenter | AlignHCenter, 
        AlignAuto = AlignLeft
    }
    enum GlobalColor {
        color0,
        color1,
        black,
        white,
        darkGray,
        gray,
        lightGray,
        red,
        green,
        blue,
        cyan,
        magenta,
        yellow,
        darkRed,
        darkGreen,
        darkBlue,
        darkCyan,
        darkMagenta,
        darkYellow,
        transparent
    }
}

// ================ QObject ================
/++
	Базовый класс.  Хранит в себе ссылку на реальный объект в Qt C++
+/		
class QObject {
	void* p_QObject;		/// Адрес самого объекта из C++ Qt
   ~this() {
        // writeln("~QObject ", this);
    }
	this() {	
        // writeln(" QObject ", this);
	} /// спец Конструктор, что бы не делать реальный объект из Qt при наследовании
	this(void* parent) {
		p_QObject = (cast(t_QObject)pFunQt[26])(parent);
	} /// Конструктор. Создает рельный QObject и сохраняет его адрес в p_QObject
	@property void* QtObj() {
		return p_QObject;  
	} /// Выдать указатель на реальный объект Qt C++
	void setNullQtObj() {
		p_QObject = null;
	}
	void connect (void*  obj1, char* ssignal, void* obj2, char* sslot, int type) {
		(cast(t_QObject_connect)pFunQt[27])(obj1, ssignal, obj2, sslot, type);
	}
	void* parent() {
        return (cast(t_vp__vp)pFunQt[169])(p_QObject);
	} /// Вернуть из C++ реального родителя
}
// ================ QTextCodec ==================
/++
	Преобразование в - из кодовых страниц в unicod
+/		
class QTextCodec {
	void* p_QObject;		/// Адрес самого объекта из C++ Qt
	this(string strNameCodec) {
		p_QObject = (cast(t_QObject)pFunQt[33])(cast(char*)strNameCodec.ptr);
	}
	QString toUnicode(string str, QString qstr) {
		(cast(t_QNameCodec_toUnicode)pFunQt[34])(p_QObject, qstr.QtObj, cast(void*)str.ptr);
		return qstr;
	}
	char* fromUnicode(char* str, QString qstr) {
		(cast(t_QNameCodec_toUnicode)pFunQt[35])(p_QObject, qstr.QtObj, str);
		return str;
	}
	@property void* QtObj() {
		return p_QObject;  
	} /// Выдать указатель на реальный объект Qt C++
}
// ================ QApplication ================
/++
	Класс приложения. <b>Внимание:</b>
	<br>Определяется один раз в main() и обязательно формат вызова как в примере
	<br>(см. выше), иначе в Linux ошибка --> Segn... fault.
+/		
class QApplication: QObject {
	size_t bufObj[2];     // данные объекта, 8=w32, 16=w64
	this() {
		super(); p_QObject = &bufObj;
    } /// При создании QApplication адрес объекта C++, сохранить в QObject
/*
	this(int m_argc, char** m_argv, bool gui) {
//		(adrQApplication())(cast(void*)bufObj, &m_argc, m_argv);
        (cast(t_QApplication_QApplication_Gui)pFunQt[100])(cast(void*)bufObj, &m_argc, m_argv, gui);
//		p_QObject = (cast(t_vp__i_vp_bool)pFunQt[98])(m_argc, m_argv, gui);
	}
*/
   ~this() {
        (cast(t_v__vp)pFunQt[112])(p_QObject); p_QObject = null;
    }
	t_QApplication_QApplication_Gui adrQApplication() {
        		// return cast(t_QApplication_QApplication)pFunQt[0];
        		return cast(t_QApplication_QApplication_Gui)pFunQt[100];
	} /// Выдать адрес конструктора C++ QApplication, для выполнения в main()
	void create(int m_argc, char** m_argv) {
		(cast(t_QApplication_QApplication)pFunQt[0])(cast(void*)bufObj, &m_argc, m_argv);
	} /// Обычный вариант конструктора. В Linux не работает
	int exec() {
		return (cast(t_QApplication_Exec)pFunQt[1])(cast(void*)bufObj);
//		return cast(int)(cast(t_vp__v)pFunQt[97])();
	} /// Обычный QApplication::exec()
	void* palette() {
		return (cast(t_vp__vp)pFunQt[59])(cast(void*)bufObj);
	} /// Выдать палитру приложения
	void setPalette(QPalette pal) {
		(cast(t_v__vp_vp)pFunQt[64])(cast(void*)bufObj, pal.QtObj);
	} /// Вставить палитру
}
class QFrame: QObject {
    enum Shape {
        NoFrame     = 0,      // no frame
        Box         = 0x0001, // rectangular box
        Panel       = 0x0002, // rectangular panel
        WinPanel    = 0x0003, // rectangular panel (Windows)
        HLine       = 0x0004, // horizontal line
        VLine       = 0x0005, // vertical line
        StyledPanel = 0x0006  // rectangular panel depending on the GUI style
    }
    enum Shadow {
        Plain  = 0x0010, // plain line
        Raised = 0x0020, // raised shadow effect
        Sunken = 0x0030  // sunken shadow effect
    }

   ~this() {
        p_QObject = null;
     }
	this() {
		super();
	}  /// Конструктор
	void setFrameShape(Shape sh) {
        (cast(t_v__vp_i)pFunQt[165])(QtObj, sh);
	}
    void setFrameShadow(Shadow sh) {
        (cast(t_v__vp_i)pFunQt[166])(QtObj, sh);
    }
}

// ================ gWidget ================
/++
	QWidget (Окно), но немного модифицированный в QtE.DLL. 
	<br>Хранит в себе ссылку на реальный С++ класс gWidget из QtE.dll
	<br>Добавлены свойства хранящие адреса для вызова обратных функций
	для реакции на события.
+/		
class gWidget: QFrame  {
    void del() {
        if (p_QObject) {
            (cast(t_v__vp)pFunQt[93])(p_QObject);
            p_QObject = null;
        }
    }
   ~this() {
        if (p_QObject) {
             p_QObject = null;
        }
     }
	this(gWidget parent, int fl) {
		super();
		// Т.к. p_QObject хранит реальную ссылку на QWidget, а не на наши суррогаты
		// то приходится её подсововать разименовывая p_QObject
		if (parent) {
			p_QObject = (cast(t_p_QWidget)pFunQt[12])(parent.p_QObject, fl);
		}
		else {
			p_QObject = (cast(t_p_QWidget)pFunQt[12])(null, fl);
		}
  //      writeln("gWidget this() parent = ", this.parent(), "  myParent = ", p_QObject);
        // writeln("CALL      from  Ctrate gWidget = ", p_QObject);
	}  /// Конструктор
	this() {	
		super();
	} /// спец Конструктор, что бы не делать реальный объект из Qt при наследовании
	void setVisible(bool f) {					// Скрыть, Показать виджет
            (cast(t_QWidget_setVisible)pFunQt[5])(p_QObject, f);
	}  /// Включить/Выключить - это реальный setVisible из QtGui.dll
	void show() {
		setVisible(true);
	} ///  Показать виджет
	void hide() {										
		setVisible(false);
	} /// Скрыть виджет
	void setWindowTitle(QString qstr) {	// Установить заголовок окна
		(cast(t_v__vp_vp)pFunQt[8])(p_QObject,  qstr.QtObj);
	} /// Установить заголовок окна
	void resize(int w, int h) {					// Изменить размер виджета
		(cast(t_resize_QWidget)pFunQt[19])(p_QObject, w, h);
	} /// Изменить размер виджета
	void setLayout(QBoxLayout layout) {
		(cast(t_v__vp_vp)pFunQt[50])(p_QObject, layout.QtObj);
	} /// Вставить в виджет выравниватель
	void setResizeEvent(void* adr) {		// Установить обработчик на событие ResizeWidget
		(cast(t_v__vp_vp)pFunQt[23])(p_QObject, adr);
	} /++ Установить обработчик на событие ResizeWidget. Здесь <u>adr</u> - адрес на функцию D
	  + обрабатывающую событие.  Обработчик получает аргумент. См. док. Qt
	  + Пример:<code>
	  + <br>. . .
	  + <br>void ОбработкаСобытия(void* adrQResizeEvent) {
	  + <br>    writeln("Изменен размер виджета");
	  + <br>}
	  +  <br>. . .
	  +  <br>gWidget w = new gWidget(null, 0); w.setOnClick(&ОбработкаСобытия);
	  +  <br>. . .
	  + </code>
	  +/
	void setCloseEvent(void* adr) {		// Установить обработчик на событие CloseEvent
		(cast(t_v__vp_vp)pFunQt[92])(p_QObject, adr);
	} /++ Установить обработчик на событие CloseEvent. Здесь <u>adr</u> - адрес на функцию D +/
	void setStyleSheet(QString str) {
        (cast(t_v__vp_vp)pFunQt[118])(p_QObject, cast(GetObjQt_t)str.QtObj);
	} /// При помощи строки задать описание эл. Цвет и т.д.
	void setMinimumSize(int w, int h) {
        (cast(t_v__vp_i_i)pFunQt[124])(p_QObject, w, h);
	} /// Минимальный размер в лайоутах
    void setMaximumSize(int w, int h) {
        (cast(t_v__vp_i_i)pFunQt[167])(p_QObject, w, h);
    } /// Максимальный размер в лайоутах
    void setEnabled(bool fl) {
        (cast(t_v__vp_bool)pFunQt[171])(QtObj, fl);
    } /// Доступен или нет
    void setToolTip(QString str) {
        (cast(t_v__vp_vp)pFunQt[172])(QtObj, str.QtObj);
    } /// Добавить строку всплывающей подсказки
}
// ================ QByteArray ================
class QByteArray: QObject {
	this() {
	    super();
		p_QObject = (cast(t_new_QByteArray)pFunQt[16])();
	}
    this(char* buf) {
        super();
        p_QObject = (cast(t_vp__vp)pFunQt[137])(cast(void*)buf);
    }
   ~this() {
        (cast(t_v__vp)pFunQt[139])(QtObj);
    }
    int size() {
        return (cast(t_i__vp)pFunQt[138])(QtObj);
    }
    int length() {
        return size();
    }
//	void setByteArray(void* u) {
//		p_QByteArray = u;
//	}
	ubyte* data() {
		return (cast(t_QByteArray_data)pFunQt[17])(QtObj);
	}
	bool arrIsEquals(QByteArray ab) {
        return (cast(t_bool__vp_vp)pFunQt[140])(QtObj, ab.QtObj);
	}
	// Забить массив символом ch и если указан resize изменить размер
	void* fill(char ch, int resize=-1) {
        return (cast(t_vp__vp_c_i)pFunQt[143])(QtObj, ch, resize);
	}
    // Создать массив из сырых байтов без NULL в конце из s размером n
    void* fromRawData(char* s, int n) {
        return (cast(t_vp__vp_cp_i)pFunQt[144])(QtObj, s, n);
    }
    // Искать позицию вхождения подстроки в массиве
    int indexOf(QByteArray str, int poz = 0) {
        return (cast(t_i__vp_vp_vp)pFunQt[145])(QtObj, str.QtObj, cast(void*)poz);
    }
    // Искать позицию вхождения подстроки в массиве
    int indexOf(char* str, int poz = 0) {
        return (cast(t_i__vp_vp_vp)pFunQt[146])(QtObj, cast(void*)str, cast(void*)poz);
    }
    // Искать позицию вхождения подстроки в массиве
    int indexOf(char ch, int poz = 0) {
        return (cast(t_i__vp_vp_vp)pFunQt[147])(QtObj, cast(void*)ch, cast(void*)poz);
    }
    void* operator1(QByteArray mas) {
        return (cast(t_vp__vp_vp)pFunQt[148])(QtObj, mas.QtObj);
    }
    // Вынимает левые n байт и запихивает их в QByteArray arr
    void* left(QByteArray arr, int n) {
        return (cast(t_vp__vp_vp_i)pFunQt[149])(QtObj, arr.QtObj, n);
    } /// Вынимает левые n байт и запихивает их в QByteArray arr

    void clear() {
        (cast(t_v__vp)pFunQt[153])(QtObj);
    } /// Очищает массив и сбрасывает его длину в 0
    void resize(int rez) {
        (cast(t_v__vp_i)pFunQt[156])(QtObj, rez);
    } /// Очищает массив и сбрасывает его длину в 0
    
    void* mid(QByteArray arr, int pos, int len = -1) {
        return (cast(t_vp__vp_vp_i_i)pFunQt[150])(QtObj, arr.QtObj, pos, len);
    } /// Вынимает левые len байт с позиции pos и запихивает их в QByteArray arr

    void* append(char* str, int len) {
        return (cast(t_vp__vp_vp_i)pFunQt[151])(QtObj, str, len);
    } /// дописывает строку длиной n в конец
    void* append(char* str) {
        return (cast(t_vp__vp_vp)pFunQt[152])(QtObj, str);
    } /// дописывает строку в конец
    void* append(char s) {
        return (cast(t_vp__vp_i)pFunQt[154])(QtObj, cast(int)s);
    } /// дописывает char в конец
    void* append(QByteArray arr) {
        return (cast(t_vp__vp_vp)pFunQt[155])(QtObj, arr.QtObj);
    } /// дописывает char в конец
    void* remove( int pos, int len) {
        return (cast(t_vp__vp_i_i)pFunQt[157])(QtObj, pos, len);
    } /// дописывает char в конец
    int toInt(bool* b = null, int base = 10) {
        return (cast(t_i__vp_vbool_i)pFunQt[158])(QtObj, b, base);
    }
    
    /*
 ZZZZZZZZZ pFunQt[145] = GetPrAddres(bCore, hQtCore, "_ZNK10QByteArray7indexOfERKS_i"); if (!pFunQt[145]) MessageErrorLoad(showError, "QByteArray::indexOf(QByteArray const&, int) const"w, 2);
    pFunQt[146] = GetPrAddres(bCore, hQtCore, "_ZNK10QByteArray7indexOfEPKci"); if (!pFunQt[146]) MessageErrorLoad(showError, "QByteArray::indexOf(char const*, int) const"w, 2);
    pFunQt[147] = GetPrAddres(bCore, hQtCore, "_ZNK10QByteArray7indexOfEci"); if (!pFunQt[147]) MessageErrorLoad(showError, "QByteArray::indexOf(char, int) const"w, 2);

    pFunQt[149] = GetPrAddres(bCore, hQtCore, "_ZNK10QByteArray4leftEi"); if (!pFunQt[149]) MessageErrorLoad(showError, "QByteArray::left(int) const"w, 2);
    */   
    
 void opAssign(void* mas)    {
        (cast(t_vp__vp_vp)pFunQt[148])(QtObj, mas);
    }
// Brrrrrrrr .... 
override bool opEquals(Object o) { 
        string s_this; string s_o;  bool rez;  rez = false;
        s_this = this.toString();  s_o    =    o.toString();
        if(s_this == s_o) {
            rez = (cast(t_bool__vp_vp)pFunQt[140])(QtObj, (cast(QByteArray)o).QtObj);
        }
        else {  // Ещё будем сравнивать с другими типами например char*
        }
        writeln("!!!!!!!! ==== opEquals =======!!!!!!!");
        writeln("   o = [",o.toString(),"]");
        writeln("this = [",this.toString(),"]");
        writeln(this, "  =  ", o);
        return rez;
    } /// Перегрузка операторов == и !=
}
// ================ QString ================
/++
	Чистый QString  (Строка). 
	<br>Хранит в себе ссылку на реальный С++ класс QString из QtCore.dll
+/

// Отладчик
void deb(ubyte* uk) {
	writeln(cast(ubyte)*(uk+0),"=",cast(ubyte)*(uk+1),"=",cast(ubyte)*(uk+2),"="
		   ,cast(ubyte)*(uk+3),"=",cast(ubyte)*(uk+4),"=",cast(ubyte)*(uk+5),"="
		   ,cast(ubyte)*(uk+6),"=",cast(ubyte)*(uk+7),"=",cast(ubyte)*(uk+8),"="
		   ,cast(ubyte)*(uk+9),"=",cast(ubyte)*(uk+10),"=",cast(ubyte)*(uk+11),"="
           ,cast(ubyte)*(uk+12),"=",cast(ubyte)*(uk+13),"=",cast(ubyte)*(uk+14),"="
           ,cast(ubyte)*(uk+15),"=",cast(ubyte)*(uk+16),"=",cast(ubyte)*(uk+17)
			);
}

class QString: QObject {
	// void* p_QString;  /// Адрес реального QString
	this() {
		p_QObject = (cast(t_new_QString)pFunQt[13])();
	} /// Конструктор пустого QString
	this(wstring s) {
		p_QObject = (cast(t_QString_wchar)pFunQt[18])(cast(wchar*)s, s.length);
	} /// Конструктор где s - unicod. Пример: QString qs = new QString("Привет!"w);
   ~this() {
        (cast(t_v__vp)pFunQt[181])(p_QObject);
    }
	void clear() {
		(cast(t_QString_clear)pFunQt[11])(p_QObject);
	} /// Очистить строку
	void fromUtf8(char* str, int dl = -1) {
		(cast(t_QString_fromUtf8)pFunQt[14])(p_QObject, str, dl);
	} /// Из внутреннего кода в char*, или всё ( нет второго аргумента )или кол символов (второй аргумент)
	void* toAscii() {
		return (cast(t_QString_toAscii)pFunQt[15])(p_QObject);
	} /// В ascii
	//@property void* QtObj() {
	//	return p_QObject;
	//} /// Вернуть сам QString
	void fromUnicode(char* str, QTextCodec codec) {
		(cast(t_i__vp_vp_vp)pFunQt[68])(p_QObject, str, codec.QtObj);
	} /// Записать в строку из QString с использованием QTextCodec. Write to string from QString with QTextCodec.
	QString toUnicode(char* str, QTextCodec codec) {
		(cast(t_v__vp_vp_vp)pFunQt[67])(p_QObject, cast(void*)str, codec.QtObj); return this;
	} /// В строку из QString с использованием QTextCodec. From string to QString with QTextCodec.
	QString toUnicode(string str, QTextCodec codec) {
		(cast(t_v__vp_vp_vp)pFunQt[67])(p_QObject, cast(void*)str.ptr, codec.QtObj); return this;
	} /// В строку из QString с использованием QTextCodec. From string to QString with QTextCodec.
	
	ubyte* data() { return (cast(t_ub__vp)pFunQt[102])(p_QObject);
	} /// Указатель на UNICODE
	int size() { return (cast(t_i__vp)pFunQt[103])(p_QObject);
	} /// Размер в UNICODE символах
	QString insert(int poz, QString s) { (cast(t_vp__vp_i_vp_i)pFunQt[104])(p_QObject, poz, s.data(), s.size()); return this;
   	} /// Вставить с позиции poz.
	QString prepend(QString s) { insert(0, s);	return this;
	} /// Вставить в начало.
	QString append(QString s) {	(cast(t_vp__vp_vp)pFunQt[101])(p_QObject, s.QtObj); 	return this;
	} /// Добавить в конец строку s
	QString replace(int poz, int n, QString s) { (cast(t_vp__vp_i_i_vp)pFunQt[105])(p_QObject, poz, n, s.QtObj); return this;
	} /// Заменить с позиции poz размера n на строку s 


	// !!!!!!!!!!!!!!!! Устаревшее
	void set(char* str) {
		(cast(t_v__vp_vp)pFunQt[31])(p_QObject, str);
	}; /// Установить строку str с учетом кодовой таблицы
	void text(char* str) {
		(cast(t_v__vp_vp)pFunQt[32])(p_QObject, str);
	}; /// Записать строку в буфер по указателю str с учетом кодовой таблицы
	// !!!!!!!!!!!!!!!! Устаревшее
	void setNameCodec(string NameCodec) {
		char* adrNameCodec = (cast(t_getAdrNameCodec)pFunQt[30])();
		copyz(cast(char*)NameCodec, adrNameCodec);
	}   /// Установить кодовую таблицу
}
// ================ QTextEdit ================
/++
	Чистый QTextEdit (ТекстовыйРедактор). 
	<br>Хранит в себе ссылку на реальный С++ класс QTextEdit из QtGui.dll
+/		
class QTextEdit: gWidget {
	this(gWidget parent) {
		super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
		if (parent) {
			p_QObject = (cast(t_p_QTextEdit)pFunQt[20])(parent.p_QObject);
		}
		else {
			p_QObject = (cast(t_p_QTextEdit)pFunQt[20])(null);
		}
        // writeln("CALL      from  Ctrate QTextEdit = ", p_QObject);
	} /// Конструктор, где parent - сылка на родительский виджет
	void append(QString str) {
		(cast(t_v__vp_vp)pFunQt[21])(p_QObject, str.QtObj);
	} /// Добавить строку str
	void clear() {
		(cast(t_p_QTextEdit_clear)pFunQt[22])(p_QObject);
	} /// Очистить все строки
}

// ================ QPushButton ================
/++
	QPushButton (Нажимаемая кнопка), но немного модифицированный в QtE.DLL. 
	<br>Хранит в себе ссылку на реальный С++ класс QPushButtong из QtGui.dll
	<br>Добавлены свойства хранящие адреса для вызова обратных функций
	для реакции на события. 
+/		
class gPushButton: QAbstractButton {
	this(gWidget parent, QString str) {
		super();	// Это фактически заглушка, что бы сделать наследование, 
				// не создавая промежуточного экземпляра в Qt
		if (parent) {
			p_QObject = (cast(t_vp__vp_vp)pFunQt[24])(parent.p_QObject, str.QtObj);
		}
		else {
			p_QObject = (cast(t_vp__vp_vp)pFunQt[24])(null, str.QtObj);
		}
	} /// Создать кнопку. 
}

// ================ QLineEdit ================
/++
	QLineEdit (Строка ввода с редактором), но немного модифицированный в QtE.DLL. 
	<br>Хранит в себе ссылку на реальный С++ класс QLineEdit из QtGui.dll
	<br>Добавлены свойства хранящие адреса для вызова обратных функций
	для реакции на события. 
+/		
class QLineEdit: gWidget {
	this(gWidget parent) {
		super();	// Это фактически заглушка, что бы сделать наследование, 
				// не создавая промежуточного экземпляра в Qt
		if (parent) {
			p_QObject = (cast(t_vp__vp)pFunQt[71])(parent.p_QObject);
		}
		else {
			p_QObject = (cast(t_vp__vp)pFunQt[71])(null);
		}
	} /// Создать LineEdit. 
	void setOnReturnPressed(void* adr) {		// Установить обработчик на событие OnReturnPressed
		(cast(t_v__vp_vp)pFunQt[72])(p_QObject, adr);
	} /++ Установить обработчик на событие OnReturnPressed. Здесь <u>adr</u> - адрес на функцию D
	  + обрабатывающую событие.  Обработчик получает аргумент. См. док. Qt
	  +/
	void set(QString adr) {	
		(cast(t_v__vp_vp)pFunQt[74])(p_QObject, adr.QtObj);
	} /// Установить значение QString в QLineEdit
	void text(QString adr) {	
		(cast(t_v__vp_vp)pFunQt[73])(p_QObject, adr.QtObj);
	} /// Забрать значение из QLineEdit в QString
	void setFocus() {	
		(cast(t_v__vp)pFunQt[75])(p_QObject);
	} /// Установить фокус на QLineEdit
	void clear() {	
		(cast(t_v__vp)pFunQt[76])(p_QObject);
	} /// Очистить строку
}

// ================ gSlot ================
/++
	gSlot - это набор слотов, хранящих в себе адрес вызываемой функции из D.
	<br>В D нет возможности создать слот, по этому в QtE.dll создан класс, который есть набор слотов
	с разными типами вызовов функции на D. Без аргументов, с одним аргументом с двумя и т.д.
	для реакции на события. 
+/		
class gSlot: QObject  {
	this() {
		super();
		p_QObject = (cast(t_gSlot)pFunQt[28])(null);
	}
	// Слот с параметром. При установке setSlotN устанавливается адрес callback и параметр n
	// который будет возвращен при срабатывании слота и позволит идентифицировать того, кто
	// вызвал callback
	void setSlotN(void* adr, long n) {
		(cast(t_v__vp_vp_i)pFunQt[170])(p_QObject, adr, cast(int)n);
	} /// Установить адрес функции D в слот n
	void setSlot(int n, void* adr) {
		(cast(t_v__i_vp_vp)pFunQt[94])(n, p_QObject, adr);
	} /// Установить адрес функции D в слот n
	void setSlot0(void* adr) {
		(cast(t_v__vp_vp)pFunQt[29])(p_QObject, adr);
	} /// Установить адрес вызываемой функции D без аргументов
	void emitSignal0() {
		(cast(t_eSlot_setSignal0)pFunQt[25])(p_QObject);
	} /// Послать сигнал "Signal0()"без аргументов
}
// ================ QMessageBox ================
/++
	QMessageBox - это стандартный класс сообщений. 
+/		
class QMessageBox: gWidget {
	enum Icon {
        NoIcon = 0,
        Information = 1,
        Warning = 2,
        Critical = 3,
        Question = 4
	}
    enum ButtonRole {
        // keep this in sync with QDialogButtonBox::ButtonRole
        InvalidRole = -1,
        AcceptRole,
        RejectRole,
        DestructiveRole,
        ActionRole,
        HelpRole,
        YesRole,
        NoRole,
        ResetRole,
        ApplyRole,

        NRoles
    }

    enum StandardButton {
        // keep this in sync with QDialogButtonBox::StandardButton
        NoButton           = 0x00000000,
        Ok                 = 0x00000400,
        Save               = 0x00000800,
        SaveAll            = 0x00001000,
        Open               = 0x00002000,
        Yes                = 0x00004000,
        YesToAll           = 0x00008000,
        No                 = 0x00010000,
        NoToAll            = 0x00020000,
        Abort              = 0x00040000,
        Retry              = 0x00080000,
        Ignore             = 0x00100000,
        Close              = 0x00200000,
        Cancel             = 0x00400000,
        Discard            = 0x00800000,
        Help               = 0x01000000,
        Apply              = 0x02000000,
        Reset              = 0x04000000,
        RestoreDefaults    = 0x08000000,

        FirstButton        = Ok,                // internal
        LastButton         = RestoreDefaults,   // internal

        YesAll             = YesToAll,          // obsolete
        NoAll              = NoToAll,           // obsolete

        Default            = 0x00000100,        // obsolete
        Escape             = 0x00000200,        // obsolete
        FlagMask           = 0x00000300,        // obsolete
        ButtonMask         = ~FlagMask          // obsolete
    }
	alias StandardButton Button;
	
	this(gWidget parent) {
		super();	// Это фактически заглушка, что бы сделать наследование, 
				// не создавая промежуточного экземпляра в Qt
		if (parent) {
			p_QObject = (cast(t_new_QMessageBox)pFunQt[36])();
		}
		else {
			p_QObject = (cast(t_new_QMessageBox)pFunQt[36])();
		}
	} /// Конструктор
	void setText(QString msg) {
		(cast(t_v__vp_vp)pFunQt[37])(p_QObject, msg.QtObj);
	} /// Установить текст
	override void setWindowTitle(QString msg) {
		(cast(t_v__vp_vp)pFunQt[39])(p_QObject, msg.QtObj);
	} /// Установить текст Заголовка
	void setInformativeText(QString msg) {
		(cast(t_v__vp_vp)pFunQt[41])(p_QObject, msg.QtObj);
	} /// Установить текст Заголовка
	void setStandardButtons(QMessageBox.StandardButton buttons) {
		(cast(t_v__vp_vp)pFunQt[42])(p_QObject, &buttons);
	} /// Установить текст Заголовка
	void setDefaultButton(QMessageBox.StandardButton button) {
		(cast(t_v__vp_StandardButton)pFunQt[43])(p_QObject, button);
	} /// Установить кнопку по умолчанию
	void setEscapeButton(QMessageBox.StandardButton button) {
		(cast(t_v__vp_StandardButton)pFunQt[44])(p_QObject, button);
	} /// Установить кнопку по Escape
	void setIcon(QMessageBox.Icon icon) {
		(cast(t_v__vp_icon)pFunQt[40])(p_QObject, icon);
	} /// Установить стандартную иконку из числа QMessage.Icon. (NoIcon, Information, Warning, Critical, Question)
	int exec() {
		return (cast(t_QMessageBox_exec)pFunQt[38])(p_QObject);
	} /// Показать диалог и вернуть код выбранной кнопки
}
// ================ QBoxLayout ================
/++
	QBoxLayout - это класс выравнивателей. Они управляют размещением
	элементов на форме. 
+/		
class QBoxLayout: QObject  {
	enum Direction {
        LeftToRight = 0,
        RightToLeft = 1,
        TopToBottom = 2,
        BottomToTop = 3
	} /// enum Direction { LeftToRight, RightToLeft, TopToBottom, BottomToTop }
	this() {	
	} /// спец Конструктор, что бы не делать реальный объект из Qt при наследовании
	this(QBoxLayout.Direction dir, gWidget parent) {
		super();
		if (parent) {
			p_QObject = (cast(t_QBoxLayout)pFunQt[47])(dir, parent.QtObj);
		}
		else {
			p_QObject = (cast(t_QBoxLayout)pFunQt[47])(dir, null);
		}
	} /// Создаёт выравниватель, типа dir и вставляет в parent 
	void addWidget(gWidget wd) {
		(cast(t_v__vp_vp)pFunQt[48])(p_QObject, wd.QtObj);
	} /// Добавить виджет в выравниватель 
	void addLayout(QBoxLayout layout) {
		(cast(t_v__vp_vp)pFunQt[49])(p_QObject, layout.QtObj);
	} /// Добавить выравниватель в выравниватель 
	void setMargin(int mar) {
		(cast(t_v__vp_vp)pFunQt[116])(p_QObject, cast(void*)mar);
	}
	void setSpacing(int mar) {
		(cast(t_v__vp_vp)pFunQt[117])(p_QObject, cast(void*)mar);
	}
	void addSpacing(int mar) {
		(cast(t_v__vp_vp)pFunQt[177])(p_QObject, cast(void*)mar);
	}  /// фиксированный отступ
	void addStretch(int mar) {
		(cast(t_v__vp_vp)pFunQt[178])(p_QObject, cast(void*)mar);
	} /// Распорка
	void addStrut(int mar) {
		(cast(t_v__vp_vp)pFunQt[179])(p_QObject, cast(void*)mar);
	}
}
class QVBoxLayout: QBoxLayout  {
	this() {
		super();
		p_QObject = (cast(t_vp__v)pFunQt[45])();
	}
}
class QHBoxLayout: QBoxLayout  {
	this() {
		super();
		p_QObject = (cast(t_vp__v)pFunQt[46])();
	}
}
// ================ QMainWindow ================
/++
	QMainWindow - основное окно приложения  
+/		
class QMainWindow: gWidget {
	this() {
		super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
		p_QObject = (cast(t_vp__v)pFunQt[54])();
//       writeln("QMainWindow this() parent = ", parent(), "  myParent = ", p_QObject);
	} /// Конструктор основного окна приложения
    ~this() {
 //      writeln("QMainWindow ~this() parent = ", parent(), "  myParent = ", p_QObject);
       p_QObject = null;
    }       
	void setStatusBar(QStatusBar sb) {
		(cast(t_v__vp_vp)pFunQt[52])(p_QObject, sb.QtObj);
	} /// Вставить строку состояния sb
	void setCentralWidget(gWidget wd) {
		(cast(t_v__vp_vp)pFunQt[53])(p_QObject, wd.QtObj);
	} /// Вставить главный виджет
	void setMenuBar(QMenuBar menub) {
		(cast(t_v__vp_vp)pFunQt[87])(p_QObject, menub.QtObj);
	} /// Вставить верхнию строчку меню
}

// ================ QStatusBar ================
/++
	QStatusBar - строка сообщений
+/		
class QStatusBar: gWidget {
	this(gWidget parent) {
		super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
		if (parent) {
			p_QObject = (cast(t_vp__vp)pFunQt[51])(parent.p_QObject);
		}
		else {
			p_QObject = (cast(t_vp__vp)pFunQt[51])(null);
		}
	} /// Конструктор, где parent - сылка на родительский виджет
	void showMessage(QString msg, int timeout = 0) {
        (cast(t_v__vp_vp_vp)pFunQt[119])(p_QObject, msg.QtObj, cast(void*)timeout);
	} /// Установить сообщение в строке
	void clearMessage() {
        (cast(t_v__vp)pFunQt[120])(p_QObject);
	} /// Очистить сообщение в строке
}
// ================ QLCDNumber ================
/++
	QLCDNumber - цифровой индикатор
+/		
class QLCDNumber: gWidget {
	enum Mode { Hex, Dec, Oct, Bin }
    enum SegmentStyle { Outline, Filled, Flat }

	this(gWidget parent) {
		super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
		if (parent) {
			p_QObject = (cast(t_vp__vp)pFunQt[55])(parent.p_QObject);
		}
		else {
			p_QObject = (cast(t_vp__vp)pFunQt[55])(null);
		}
	} /// Конструктор, где parent - сылка на родительский виджет
	void setSegmentStyle(QLCDNumber.SegmentStyle style) {
		(cast(t_v__vp_SegmentStyle)pFunQt[57])(p_QObject, style);
	} /// Способ изображения сегментов
}
// ================ QSpinBox ================
/++
	QSpinBox - счетчик
+/		
class QSpinBox: gWidget {
	this(gWidget parent) {
		super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
		if (parent) {
			p_QObject = (cast(t_vp__vp)pFunQt[56])(parent.p_QObject);
		}
		else {
			p_QObject = (cast(t_vp__vp)pFunQt[56])(null);
		}
	} /// Конструктор, где parent - сылка на родительский виджет
    ~this() {
        if (p_QObject) {
            p_QObject = null;
        }
    }       
}
// ================ QPalette ================
/++
	QPalette - Палитры цветов
+/		
class QPalette: QObject {
    enum ColorGroup { Active, Disabled, Inactive, NColorGroups, Current, All, Normal = Active };
    enum ColorRole { WindowText, Button, Light, Midlight, Dark, Mid,
                     Text, BrightText, ButtonText, Base, Window, Shadow,
                     Highlight, HighlightedText,
                     Link, LinkVisited, // ### Qt 5: remove
                     AlternateBase,
                     NoRole, // ### Qt 5: value should be 0 or -1
                     ToolTipBase, ToolTipText,
                     NColorRoles = ToolTipText + 1,
                     Foreground = WindowText, Background = Window // ### Qt 5: remove
                   };	
	this() {
		super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
		p_QObject = (cast(t_vp__v)pFunQt[58])();
	} /// Конструктор
	this(void* uk) {
		super();  
		p_QObject = uk;
	} /// Используется, для присвоения уже готового адреса на истинный QPalette
	void setColor(QPalette.ColorGroup cg, QPalette.ColorRole cr, QColor color) {
		(cast(t_v__vp_i_i_vp)pFunQt[62])(p_QObject, cast(int)cg, cast(int)cr, color.QtObj);
	} /// Установим цвет заданный QColor
	void setColor(QPalette.ColorGroup cg, QPalette.ColorRole cr, QtE.GlobalColor color) {
		(cast(t_v__vp_i_i_vp)pFunQt[65])(p_QObject, cast(int)cg, cast(int)cr, cast(void*)color);
	} /// Установим цвет заданный Константой
}
// ================ QColor ================
/++
	QColor - Цвет
+/		
class QColor: QObject {
	this() {
		super();
		p_QObject = (cast(t_vp__v)pFunQt[60])();
	} /// Конструктор
	void setRgb( int r, int g, int b, int a = 255 ) {
		(cast(t_v__vp_i_i_i_i)pFunQt[61])(p_QObject, r, g, b, a);
	} /// Sets the RGB value to r, g, b and the alpha value to a. All the values must be in the range 0-255.
}
// ================ QScriptEngine ================
/++
	QScriptEngine - Поддержка скриптов
+/		
class QScriptEngine: QObject  {
	this() {	
	} /// Constructor not make object for inherit
	this(gWidget parent) {
		super();
		p_QObject = (cast(t_vp__v)pFunQt[66])();
	} /// 
}
// ================ QAction ================
/++
	QAction - это класс выполнителей (действий). Объеденяют в себе
	различные формы вызовов: из меню, из горячих кнопок, их панели с кнопками
	и т.д. Реально представляет собой строку меню в вертикальном боксе.
+/		
class QAction: QObject  {
	this() {	
	} /// спец Конструктор, что бы не делать реальный объект из Qt при наследовании
	this(QObject parent) {
		super();
		if (parent) {
			p_QObject = (cast(t_vp__vp)pFunQt[77])(parent.QtObj);
		}
		else {
			p_QObject = (cast(t_vp__vp)pFunQt[77])(null);
		}
	} /// Создаёт выполнитель.
	void setText(QString msg) {
		(cast(t_v__vp_vp)pFunQt[78])(p_QObject, msg.QtObj);
	} /// Установить текст
	void setHotKey(QtE.Key key) {
		(cast(t_vp__vp_i)pFunQt[79])(p_QObject, cast(int)key);
	} /// Определить горячую кнопку 
	void onClick(void* adr) {
		(cast(t_v__vp_vp)pFunQt[80])(p_QObject, adr);
	} /// Учтановить функцию обработки этого действия 
    void setToolTip(QString str) {
        (cast(t_v__vp_vp)pFunQt[173])(QtObj, str.QtObj);
    } /// Добавить строку всплывающей подсказки
}
// ============ QMenuBar =======================================
/++
	QMenuBar - строка меню самого верхнего уровня. Горизонтальная.
+/		
class QMenuBar: gWidget {
	this(gWidget parent) {
		super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
		if (parent) {
			p_QObject = (cast(t_vp__vp)pFunQt[81])(parent.p_QObject);
		}
		else {
			p_QObject = (cast(t_vp__vp)pFunQt[81])(null);
		}
	} /// Конструктор, где parent - сылка на родительский виджет
	void addMenu(QMenu menu) {
		(cast(t_v__vp_vp)pFunQt[82])(p_QObject, cast(void*)menu.QtObj);
	} /// Вставить мертикальное меню 
}
// ============ QMenu =======================================
/++
	QMenu - колонка меню. Вертикальная.
+/		
class QMenu: gWidget {
	this(gWidget parent) {
		super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
		if (parent) {
			p_QObject = (cast(t_vp__vp)pFunQt[83])(parent.p_QObject);
		}
		else {
			p_QObject = (cast(t_vp__vp)pFunQt[83])(null);
		}
	} /// Конструктор, где parent - сылка на родительский виджет
	void addAction(QAction act) {
		(cast(t_v__vp_vp)pFunQt[84])(p_QObject, cast(void*)act.QtObj);
	} /// Вставить мертикальное меню 
	void addSeparator() {
		(cast(t_v__vp)pFunQt[85])(p_QObject);
	} /// Добавить сепаратор 
	void setTitle(QString str) {
		(cast(t_v__vp_vp)pFunQt[86])(p_QObject, cast(void*)str.QtObj);
	} /// Добавить сепаратор 
}
// ============ QWebView =======================================
class QWebView: gWidget {
/*
    this(gWidget parent) {
        // int sizeQWebView = (cast(t_i__v)pFunQt[109])();
        // ubyte[] buf = new ubyte[(cast(t_i__v)pFunQt[109])()];
//        p_QObject = cast(void*)(new ubyte[(cast(t_i__v)pFunQt[109])()]);
        super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
        if (parent) {
            (cast(t_v__vp_vp)pFunQt[110])(cast(void*)p_QObject, cast(void*)parent);
        }
        else {
            (cast(t_v__vp_vp)pFunQt[110])(cast(void*)p_QObject, null);
        }
        // Вызов конструктора QWebView
    }
*/    
	this(gWidget parent) {
		super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
		if (parent) {
			p_QObject = (cast(t_vp__vp)pFunQt[88])(parent.p_QObject);
		}
		else {
			p_QObject = (cast(t_vp__vp)pFunQt[88])(null);
		}
	} /// Конструктор, где parent - сылка на родительский виджет
    ~this() {
        if (p_QObject) {
            // (cast(t_v__vp)pFunQt[106])(p_QObject); p_QObject = null;
            p_QObject = null;
        }
    }		
	void load(QUrl url) {
        (cast(t_v__vp_vp)pFunQt[91])(p_QObject, cast(void*)url.QtObj);
	} /// Загрузит страницу по url
}
// ============ QUrl =======================================
class QUrl: QObject  {
	this() {
		super();
			p_QObject = (cast(t_vp__v)pFunQt[89])();
	}
    ~this() {
    }		
	void setUrl(QString str) {
		(cast(t_v__vp_vp)pFunQt[90])(p_QObject,  cast(GetObjQt_t)str.QtObj);
	} /// Добавить сепаратор 
}
// ============ QProgressBar =======================================
class QProgressBar: gWidget {
    this(gWidget parent) {
        super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
        if (parent) {
            p_QObject = (cast(t_vp__vp)pFunQt[113])(parent.p_QObject);
        }
        else {
            p_QObject = (cast(t_vp__vp)pFunQt[113])(null);
        }
    } /// Конструктор, где parent - сылка на родительский виджет
    ~this() {
        if (p_QObject) {
            p_QObject = null;
        }
    }  
    void setMinimum( int n) {
        (cast(t_v__vp_i)pFunQt[122])(p_QObject, n);
    } /// Установить нижнию границу
    void setMaximum( int n) {
        (cast(t_v__vp_i)pFunQt[121])(p_QObject, n);
    } /// Установить верхнию границу
    void setValue( int n) {
        (cast(t_v__vp_i)pFunQt[123])(p_QObject, n);
    } /// Установить текущее положение
}
// ============ QAbstractButton =======================================
class QAbstractButton: gWidget {
    this() {
        super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
    }
    this(gWidget parent) {
        super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
    } /// Не визуальный класс. Только для объеденения свойств создан
    ~this() {
        if (p_QObject) {
            p_QObject = null;
        }
    }       
    void setText(QString str) {
        (cast(t_v__vp_vp)pFunQt[115])(QtObj /* p_QObject */, cast(GetObjQt_t)str.QtObj);
    }
}
// ============ QCheckBox =======================================
class QCheckBox: QAbstractButton {
    this(gWidget parent) {
        super(parent);
        if (parent) {
            p_QObject = (cast(t_vp__vp)pFunQt[114])(parent.p_QObject);
        }
        else {
            p_QObject = (cast(t_vp__vp)pFunQt[114])(null);
        }
    } /// Конструктор, где parent - сылка на родительский виджет
    ~this() {
        if (p_QObject) {
            p_QObject = null;
        }
    }       
}
// ============ QRadioButton =======================================
class QRadioButton: QAbstractButton {
    this(gWidget parent) {
        super(parent);
        if (parent) {
            p_QObject = (cast(t_vp__vp)pFunQt[176])(parent.p_QObject);
        }
        else {
            p_QObject = (cast(t_vp__vp)pFunQt[176])(null);
        }
    } /// Конструктор, где parent - сылка на родительский виджет
    ~this() {
        if (p_QObject) {
            p_QObject = null;
        }
    }       
}
// ============ QIODevice =======================================
class QIODevice: QObject  {
    enum OpenMode {
        NotOpen    = 0x0000,  // The device is not open.
        ReadOnly   = 0x0001,  // The device is open for reading.
        WriteOnly  = 0x0002,  // The device is open for writing.
        ReadWrite  = ReadOnly | WriteOnly,  //  The device is open for reading and writing.
        Append     = 0x0004,  // The device is opened in append mode, so that all data is written to the end of the file.
        Truncate   = 0x0008,  // If possible, the device is truncated before it is opened. All earlier contents of the device are lost.
        Text       = 0x0010,  // When reading, the end-of-line terminators are translated to '\n'. When writing, the end-of-line terminators are translated to the local encoding, for example '\r\n' for Win32.
        Unbuffered = 0x0020   // Any buffer in the device is bypassed.
    }
	this() {	
	} /// спец Конструктор, что бы не делать реальный объект из Qt при наследовании
	this(QObject parent) {
        super();                        // Отсечение ветки конструкторов D
        if (parent) {
//            p_QObject = (cast(t_vp__vp)pFunQt[114])(parent.p_QObject);
        }
        else {
//            p_QObject = (cast(t_vp__vp)pFunQt[114])(null);
        }
    } /// Конструктор, где parent - сылка на родительский виджет
    ~this() {
    }
    long readLine(char* buf, long size) {
        return (cast(t_l__vp_vp_l)pFunQt[128])(QtObj, buf, size);
    } /// Прочитать из устройства в буфер buf количество байт size
    long write(char* buf, long size) {
        return (cast(t_l__vp_vp_l)pFunQt[132])(QtObj, buf, size);
    } /// Записать из буфера в устройство количество байт size
    bool canReadLine() {
        return (cast(t_bool__vp)pFunQt[130])(QtObj);
    }
    void setTextModeEnabled(bool mode) {
        (cast(t_v__vp_bool)pFunQt[131])(QtObj, mode);
    }
    long bytesAvailable() {
        return (cast(t_l__vp)pFunQt[159])(QtObj);
    }
}
// ============ QAbstractSocket =======================================
class QAbstractSocket: QIODevice  {
	enum SocketType {
        TcpSocket = 0,
        UdpSocket = 1,
        UnknownSocketType = -1
	} /// enum SocketType { TcpSocket, UdpSocket, UnknownSocketType }
	enum SocketState {
        UnconnectedState = 0,  // нет коннекта
        HostLookupState = 1,   // сокет ищет хост
        ConnectingState = 2,   // сокет начинает установку соединения
        ConnectedState = 3,    // есть соединение
        BoundState = 4,        // Сокет связывается с адресом и портом (для серверов).
        ClosingState = 6,      // сокет закрыт
        ListeningState = 5     // сокет слушает
	} /// enum SocketState see dokum Qt
	enum SocketError {
	    ConnectionRefusedError, // Соединение отвергнуто коллегой (или по тайм-ауту).
        RemoteHostClosedError, // Удаленный хост закрыл соединение. Обратите внимание, 
                               // что сокет клиента (т.е., этот сокет) будет закрыт 
                               // после удаленного уведомления.
        HostNotFoundError,     // Хост-адрес не найден.
        SocketAccessError,     // ошибка, не хватало необходимых привилегий.
        SocketResourceError,   // Локальная система: не хватило ресурсов (напр., слишком много сокетов).
        SocketTimeoutError,                     /* 5 */
        DatagramTooLargeError, // Датаграмма была больше, чем установленное ограничение в операционной системе (которая может быть как низкий, как 8192 байт).
        NetworkError,          // Ошибка сети (напр., сетевой кабель не случайно был подключен).
        AddressInUseError,     // Адрес, указанный в QUdpSocket::bind() уже используется и был эксклюзивный
        SocketAddressNotAvailableError, // Адрес, указанный в QUdpSocket::bind() не принадлежит к хозяину.
        UnsupportedSocketOperationError, // Тип сокета не поддерживается ОС (напр., отсутствие поддержки IPv6).
        UnfinishedSocketOperationError, // Используется только QAbstractSocketEngine, последняя операция предпринята еще не завершен (еще продолжается в фоновом режиме).
        ProxyAuthenticationRequiredError, // Сокет с помощью прокси-сервер и прокси-сервер требует аутентификации.
        SslHandshakeFailedError, // SSL/TLS handshake не удалось, поэтому соединение закрыто (используется только в QSslSocket)
        ProxyConnectionRefusedError, // Не удалось связаться с прокси-сервера, потому что подключение к серверу было отказано
        ProxyConnectionClosedError,  // Подключения к прокси-серверу неожиданно закрыто (до подключения к окончательной peer был создан)
        ProxyConnectionTimeoutError, // Подключения к прокси-серверу истекло или прокси-сервер перестал отвечать на фазе аутентификации.
        ProxyNotFoundError, // Адрес прокси-сервера, установите с setProxy() (или прокси приложения) не найден.
        ProxyProtocolError, // ответ от прокси-сервера не могут быть поняты.
        UnknownSocketError = -1
	}
    enum NetworkLayerProtocol {
        IPv4Protocol,
        IPv6Protocol,
        UnknownNetworkLayerProtocol = -1
	}
	this() {	
	} /// спец Конструктор, что бы не делать реальный объект из Qt при наследовании
	this(SocketType socketType, QObject parent) {
        super();                        // Отсечение ветки конструкторов D
    } /// Конструктор, где parent - сылка на родительский виджет
    ~this() {
    }
    void abort() {
        (cast(t_vp__vp)pFunQt[126])(QtObj);
    } /// Закрывает сокет. В отличие от disconnectFromHost(), эта функция немедленно закрывает сокет, отбрасывая любые Отложенные данные в буфер записи		
    void close() {
        (cast(t_vp__vp)pFunQt[127])(QtObj);
    } /// Закрывает сокет, отключает от хостоа, сбрасывает имя, адрес, номер порта и т.д.
    void connectToHost (QString hostName, ushort port, QIODevice.OpenMode openMode = QIODevice.OpenMode.ReadWrite ) {
        (cast(t_v__vp_vp_us_i)pFunQt[129])(QtObj, hostName.QtObj, port, openMode);
    } /// Открыть сокет по hostName и порту port
override long bytesAvailable() { 
        return (cast(t_l__vp)pFunQt[160])(QtObj);
    } /// Сколько байт в доступно для чтения?
override bool canReadLine() {
        return (cast(t_bool__vp)pFunQt[161])(QtObj);
    } /// можно прочитать строку?
}

// ============ QDataStream =======================================
class QDataStream: QObject {
    this() {    
    } /// спец Конструктор, что бы не делать реальный объект из Qt при наследовании
    this(QObject parent) {
        super();                        // Отсечение ветки конструкторов D
        if (parent) {
            p_QObject = (cast(t_vp__vp)pFunQt[133])(parent.p_QObject);
        }
        else {
            p_QObject = (cast(t_vp__vp)pFunQt[133])(null);
        }
    } /// Конструктор, где parent - сылка на родительский виджет
    this(QByteArray ba, QIODevice.OpenMode mode) {
        super();                        // Отсечение ветки конструкторов D
        p_QObject = (cast(t_vp__vp_i)pFunQt[141])(ba.QtObj, cast(int)mode);
    }
    ~this() {
    }
    int ReadRawData(char* s, int len) {
        return (cast(t_i__vp_vp_vp)pFunQt[134])(QtObj, s, cast(void*)len);
    } /// Читать сырые байты из потока в буфер s
    int WriteRawData(char* s, int len) {
        return (cast(t_i__vp_vp_vp)pFunQt[135])(QtObj, s, cast(void*)len);
    } /// Писать сырые байты в поток из буфера s
    void setVersion(int ver) {
        (cast(t_v__vp_i)pFunQt[136])(QtObj, ver);
    }
    void setDevice(QIODevice dev) {
        (cast(t_v__vp_vp)pFunQt[142])(QtObj, dev.QtObj);
    }
}
// ============ QTcpSocket =======================================
class QTcpSocket: QAbstractSocket  {
	this() {	
	} /// спец Конструктор, что бы не делать реальный объект из Qt при наследовании
	this(QObject parent = null) {
        super();                        // Отсечение ветки конструкторов D
        if (parent) {
            p_QObject = (cast(t_vp__vp)pFunQt[125])(parent.p_QObject);
        }
        else {
            p_QObject = (cast(t_vp__vp)pFunQt[125])(null);
        }
    } /// Конструктор, где parent - сылка на родительский виджет
    ~this() {
    }		
}
// ============ QLabel =======================================
class QLabel: gWidget  {
    this(gWidget parent) {
        super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
        if (parent) {
            p_QObject = (cast(t_vp__vp)pFunQt[162])(parent.p_QObject);
        }
        else {
            p_QObject = (cast(t_vp__vp)pFunQt[162])(null);
        }
    }
    ~this() {
       // (cast(t_v__vp)pFunQt[163])(QtObj);
    }
    void setText(QString str) {
        (cast(t_v__vp_vp)pFunQt[164])(QtObj, str.QtObj);
    } /// Установить текст на QLabel
    void setAlignment(QtE.AlignmentFlag fl) {
        (cast(t_v__vp_i)pFunQt[168])(QtObj, fl);
    } /// Выравнивание
}
// ============ QGroupBox =======================================
class QGroupBox: gWidget  {
    this(gWidget parent) {
        super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
        if (parent) {
            p_QObject = (cast(t_vp__vp)pFunQt[174])(parent.p_QObject);
        }
        else {
            p_QObject = (cast(t_vp__vp)pFunQt[174])(null);
        }
    }
    ~this() {
       // (cast(t_v__vp)pFunQt[163])(QtObj);
    }
    void setTitle(QString str) {
        (cast(t_v__vp_vp)pFunQt[175])(QtObj, str.QtObj);
    } /// Установить заголовок
}
// ================ QFileDialog ================
class QFileDialog: gWidget {
    enum Option {
        ShowDirsOnly = 0x00000001,
        DontResolveSymlinks = 0x00000002,
        DontConfirmOverwrite = 0x00000004,
        DontUseNativeDialog = 0x00000010,
        ReadOnly = 0x00000020,
        HideNameFilterDetails = 0x00000040,
        DontUseSheet = 0x00000008
    }
    this(gWidget parent) {
        super();  //  Это заглушка, что бы наследовать D класс не создавая экземпляра в Qt C++
        if (parent) {
            p_QObject = (cast(t_vp__vp)pFunQt[182])(parent.p_QObject);
        }
        else {
            p_QObject = (cast(t_vp__vp)pFunQt[182])(null);
        }
    }
    ~this() {
       // (cast(t_v__vp)pFunQt[183])(QtObj);
    }
    // Тяжкое наследие С++ Надо разобраться, почему валится на возвращаемом значении
    void* getOpenFileNamePabic(gWidget parent = null, QString caption = null,
            QString dir = null, QString filter = null, QString selectedFilter = null, int options = Option.DontUseNativeDialog) {
        QString s2; QString s3; QString s4; QString s5; int o6 = Option.DontUseNativeDialog;
        void* p1; if(parent)  { p1=parent.QtObj; }
        void* p2; if(caption) { p2=caption.QtObj; } else { s2 = new QString(); p2 = s2.QtObj; }
        void* p3; if(dir)     { p3=dir.QtObj; } else { s3 = new QString(); p3 = s3.QtObj; }
        void* p4; if(filter)  { p4=filter.QtObj; } else { s4 = new QString(); p4 = s4.QtObj; } 
        void* p5; if(selectedFilter) { p5=selectedFilter.QtObj; } else { s5 = new QString(); p5 = s5.QtObj; } 
        o6 = options;
        (cast(t_vp__vp_vp_vp_vp_vp_vp_vp)pFunQt[184])(QtObj, p1, p2, p3, p4, p5, &o6);
        return null;
    }
    QString getOpenFileName(QString rez, gWidget parent = null, QString caption = null,
            QString dir = null, QString filter = null, QString selectedFilter = null, 
            int options = Option.DontUseNativeDialog ) {
        QString s2; QString s3; QString s4; QString s5; int o6;
        void* p1; if(parent)  { p1=parent.QtObj; }
        void* p2; if(caption) { p2=caption.QtObj; } else { s2 = new QString(); p2 = s2.QtObj; }
        void* p3; if(dir)     { p3=dir.QtObj; } else { s3 = new QString(); p3 = s3.QtObj; }
        void* p4; if(filter)  { p4=filter.QtObj; } else { s4 = new QString(); p4 = s4.QtObj; } 
        void* p5; if(selectedFilter) { p5=selectedFilter.QtObj; } else { s5 = new QString(); p5 = s5.QtObj; } 
        o6 = options;
        (cast(t_vp__vp_vp_vp_vp_vp_vp_vp_vp)pFunQt[185])(QtObj, p1, p2, p3, p4, p5, cast(void*)o6, rez.QtObj);
        return rez;
    }
}
// ============ Эксперементальный класс DQByteArray == Работа с объектом С++ без компилятора ===============
class DQByteArray {
    size_t QtObj;       // Сам объект
    this(immutable(char)* buf) {
        (cast(t_v__vp_vp)pFunQt[180])(cast(void*)&QtObj, cast(void*)buf);
    }
    void v() {
        writeln(QtObj);
    }
	ubyte* data() {
		return (cast(t_QByteArray_data)pFunQt[17])(cast(void*)&QtObj);
	}
	// Забить массив символом ch и если указан resize изменить размер
	void* fill(char ch, int resize=-1) {
        return (cast(t_vp__vp_c_i)pFunQt[143])(cast(void*)&QtObj, ch, resize);
	}
//    void opAssign(DQByteArray ba)    {
//        (cast(t_vp__vp_vp)pFunQt[148])(cast(void*)&QtObj, &ba.QtObj);
//    }
    // QByteArray::operator=(QByteArray const&)
}
