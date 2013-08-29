// Written in the D programming language.
 
/**
  * <b><u>Работа с Qt в Windows и Linux. </u></b>
  *  <br>Зависит от QtE.DLL  (Win32)   или  QtE.so.1.0.0 (Linux32)
  *  Version: 1.0a
  *  Authors: Мохов Г.В.  mgw@yandex.ru ( MGW 02.08.2013 23:37:57  )
  *  Date: Июль 30, 2013
  *   http: mgw.narod.ru
  *   License: use freely for any purpose
  *
  *   <b><u>Компиляция:</u></b>
  *   <br>Windows 32: dmd main.d lib_qt.d -L/SUBSYSTEM:WINDOWS:5.01
  *   <br>Linux 32: dmd main.d lib_qt.d -L-ldl
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

void* pFunQt[60];   /// Масив указателей на функции из DLL

immutable QMETHOD =  0;                        // member type codes
immutable QSLOT  = 1;
immutable QSIGNAL  = 2;

// ----- Описание типов, фактически указание компилятору как вызывать -----

// alias void   function(void*, void*) 	t_void__voidz_voidz;
// alias char*  function()  		        t_charP__void;

extern (C) alias void  function(void*, void*) 	    				t_v__vp_vp;
extern (C) alias void* function(void*, void*) 	    				t_vp__vp_vp;
extern (C) alias void  function(void*, QMessageBox.Icon) 			t_v__vp_icon;
extern (C) alias void  function(void*, QMessageBox.StandardButton) 	t_v__vp_StandardButton;
extern (C) alias void  function(void*, QLCDNumber.SegmentStyle) 	t_v__vp_SegmentStyle;
extern (C) alias void* function() 									t_vp__v;
extern (C) alias void* function(void*) 								t_vp__vp;

// QApplication
extern (C) alias void  function(void*, int*, char**)  	t_QApplication_QApplication; 
extern (C) alias int   function(void*)                  t_QApplication_Exec; 
// QWidget
extern (C) alias void  function(void*, void*, void*)    t_QWidget_QWidget;
extern (C) alias void function(void*) 					t_destQWidget;
extern (C) alias void  function(void*, bool) 			t_QWidget_setVisible;
extern (C) alias void  function(void*, int, int) 	   	t_resize_QWidget;
// eQWidget
// extern (C) alias eQWidget* function(void*, void*) t_eQWidget_eQWidget;
extern (C) alias int function() 						t_size_eQWidget;
// extern (C) alias void   function(void*, void*) 			t_v__vp_vp;
// QChar
extern (C) alias void  function(void*, char) 			t_QChar_QChar;
// QString
extern (C) alias void*  function(wchar*, int) 			t_QString_wchar;
// extern (C) alias void  function(void*, QChar) 		t_QString_QString;
extern (C) alias void  function(void*) 					t_QString_clear;
extern (C) alias void*  function() 						t_new_QString;
extern (C) alias void function(void*, void*, int)       t_QString_fromUtf8;
extern (C) alias char* function(void*) 					t_QString_toAscii;
extern (C) alias char* function()						t_getAdrNameCodec;

// QNameCodec
extern (C) alias void* function(char*)					t_QNameCodec;
extern (C) alias void function(void*, void*, void*)	t_QNameCodec_toUnicode;
extern (C) alias void function(void*, void*, void*)	t_QNameCodec_fromUnicode;

extern (C) alias void*  function() 						t_qs_test;
extern (C) alias  void* function(void*, int)   			t_p_QWidget;
// QByteArray
extern (C) alias  void* function()   					t_new_QByteArray;
extern (C) alias  ubyte* function(void*)   				t_QByteArray_data;
// QTextEdit
extern (C) alias  void* function(void*)   				t_p_QTextEdit;
extern (C) alias  void function(void*)   				t_p_QTextEdit_clear;
// QPushButton
// QObject
extern (C) alias void* function(void*) 					t_QObject;
extern (C) alias void function(void*, char*, void*, char*, int)	t_QObject_connect;
// eSlot
extern (C) alias void* function(void*) t_gSlot;
extern (C) alias void function(void*) 					t_eSlot_setSignal0;
// QMessageBox
extern (C) alias  void* function()   					t_new_QMessageBox;
extern (C) alias  int function(void*)  			t_QMessageBox_exec;
// QBoxLayout
extern (C) alias void* function(QBoxLayout.Direction, void*) t_QBoxLayout;
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
// Загрузить DLL
private void* GetHlib(const char* name) {
	version(Windows) {
	  return LoadLibraryA(name);
	}
	version(linux) {
	  return dlopen(name, RTLD_GLOBAL || RTLD_LAZY);
	}
}
// Найти адреса функций в DLL
private void* GetPrAddres(void* hLib, const char* nameFun) {
	version(Windows) {
	  return GetProcAddress(hLib, nameFun);
	}
	version(linux) {
	  return dlsym(hLib, nameFun);
	}
}
// Сообщить об ошибке загрузки
private void MessageErrorLoad(wstring s, int sw) {
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

char* MSS(string s, int n) {
	if (n == QMETHOD) return cast(char*)("0" ~ s); 
	if (n == QSLOT) return cast(char*)("1" ~ s); 
	if (n == QSIGNAL) return cast(char*)("2" ~ s); 
	return null;
} /// Моделирует макросы QT.  Где n=2->SIGNAL(), n=1->SLOT(), n=0->METHOD().

// Скопировать строку с 0 в конце
void copyz(char* from, char* to) {
	for( int i=0; ; i++ ) {
		*(to+i) = *(from+i); if (*(from+i) == '\0')  break;
	}
}

int LoadQt() {   ///  Загрузить DLL-ки Qt и QtE
	void* hQtGui; void* hQtCore; void* hQtE; 
	string cQtCore; string cQtGui; string cQtE;
	wstring wQtCore; wstring wQtGui; wstring wQtE;
	
	version(Windows) {
		cQtCore = "QtCore4.dll"; cQtGui = "QtGui4.dll"; cQtE = "QtE.dll";
		wQtCore = "QtCore4.dll"; wQtGui = "QtGui4.dll"; wQtE = "QtE.dll";
	}
	 version(linux) {
		cQtCore = "libQtCore.so.4"; cQtGui = "libQtGui.so.4"; cQtE = "QtE.so.1.0.0";
		wQtCore = "libQtCore.so.4"; wQtGui = "libQtGui.so.4"; wQtE = "QtE.so.1.0.0";
	}
	const QtCore = cast(char*)cQtCore; //wQtCore = cast(wstring)QtCore;
	const QtGui  = cast(char*)cQtGui;
	const QtE    = cast(char*)cQtE;

	hQtCore = GetHlib(QtCore);  if (!hQtCore) { MessageErrorLoad(wQtCore, 1);  return 1; }
	hQtGui = GetHlib(QtGui);    if (!hQtGui)  { MessageErrorLoad(wQtGui, 1);   return 1; }
	hQtE = GetHlib(QtE);        if (!hQtE)    { MessageErrorLoad(wQtE, 1);     return 1; }
	
	// QApplication
	pFunQt[0] = GetPrAddres(hQtGui, "_ZN12QApplicationC1ERiPPc"); if (!pFunQt[0]) MessageErrorLoad(cast(wstring)"QApp:QApp"w, 2);
	pFunQt[1] = GetPrAddres(hQtGui, "_ZN12QApplication4execEv"); if (!pFunQt[1])  MessageErrorLoad(cast(wstring)"QApp:exec"w, 2);
	// eQWidget
	pFunQt[2] = GetPrAddres(hQtE, "_ZN8eQWidgetC1EP7QWidget"); if (!pFunQt[2]) MessageErrorLoad(cast(wstring)"eQWidget:eQWidget"w, 2);
	pFunQt[6] = GetPrAddres(hQtE, "size_eQWidget"); if (!pFunQt[6]) MessageErrorLoad(cast(wstring)"size_eQWidget"w, 2);
	pFunQt[12] = GetPrAddres(hQtE, "p_QWidget"); if (!pFunQt[12]) MessageErrorLoad("p_QWidget"w, 2);
	pFunQt[23] = GetPrAddres(hQtE, "setResizeEvent"); if (!pFunQt[23]) MessageErrorLoad("QWidget_setResizeEvent"w, 2);
	// QWidget
	pFunQt[3] = GetPrAddres(hQtGui, "_ZN7QWidgetC1EPS_6QFlagsIN2Qt10WindowTypeEE"); if (!pFunQt[3]) MessageErrorLoad("QWidget:QWidget"w, 2);
	pFunQt[4] = GetPrAddres(hQtGui, "_ZThn8_N7QWidgetD0Ev"); if (!pFunQt[4])  MessageErrorLoad("QWidget:~QWidget"w, 2);
	pFunQt[5] = GetPrAddres(hQtGui, "_ZN7QWidget10setVisibleEb"); if (!pFunQt[5]) MessageErrorLoad("QWidget:setVisible"w, 2);
	pFunQt[8] = GetPrAddres(hQtGui, "_ZN7QWidget14setWindowTitleERK7QString"); if (!pFunQt[8]) MessageErrorLoad("setWindoowTitle"w, 2);
	pFunQt[19] = GetPrAddres(hQtE, "resize_QWidget"); if (!pFunQt[19]) MessageErrorLoad("resize_QWidget"w, 2);
	pFunQt[50] = GetPrAddres(hQtGui, "_ZN7QWidget9setLayoutEP7QLayout"); if (!pFunQt[50]) MessageErrorLoad("QWidget_setLayout"w, 2);
	// QChar
	pFunQt[7] = GetPrAddres(hQtCore, "_ZN5QCharC2Ec"); if (!pFunQt[7]) MessageErrorLoad("QChar:QChar"w, 2);
	// QString
	pFunQt[9] = GetPrAddres(hQtCore, "_ZN7QStringC1E5QChar"); if (!pFunQt[9]) MessageErrorLoad("Qstring:Qstring"w, 2);
	pFunQt[11] = GetPrAddres(hQtCore, "_ZN7QString5clearEv"); if (!pFunQt[11]) MessageErrorLoad("Qstring:clear"w, 2);
	pFunQt[13] = GetPrAddres(hQtE, "new_QString"); if (!pFunQt[13]) MessageErrorLoad("new_Qstring"w, 2);
	pFunQt[14] = GetPrAddres(hQtCore, "_ZN7QString8fromUtf8EPKci"); if (!pFunQt[14]) MessageErrorLoad("Qstring_fromUtf8"w, 2);
	pFunQt[15] = GetPrAddres(hQtCore, "_ZNK7QString7toAsciiEv"); if (!pFunQt[15]) MessageErrorLoad("Qstring_toAscii"w, 2);
	pFunQt[18] = GetPrAddres(hQtE, "new_QString_wchar"); if (!pFunQt[18]) MessageErrorLoad("Qstring_wchar"w, 2);
	pFunQt[30] = GetPrAddres(hQtE, "adrNameCodec"); if (!pFunQt[30]) MessageErrorLoad("adrNameCodec"w, 2);
	pFunQt[31] = GetPrAddres(hQtE, "QT_QString_set"); if (!pFunQt[31]) MessageErrorLoad("QT_QString_set"w, 2);
	pFunQt[32] = GetPrAddres(hQtE, "QT_QString_text"); if (!pFunQt[32]) MessageErrorLoad("QT_QString_text"w, 2);
	// QNameCodec
	pFunQt[33] = GetPrAddres(hQtE, "p_QTextCodec"); if (!pFunQt[33]) MessageErrorLoad("p_QTextCodec"w, 2);
	pFunQt[34] = GetPrAddres(hQtE, "QT_QTextCodec_toUnicode"); if (!pFunQt[34]) MessageErrorLoad("QT_QTextCodec_toUnicode"w, 2);
	pFunQt[35] = GetPrAddres(hQtE, "QT_QTextCodec_fromUnicode"); if (!pFunQt[35]) MessageErrorLoad("QT_QTextCodec_fromUnicode"w, 2);
	// QByteArray
	pFunQt[16] = GetPrAddres(hQtE, "new_QByteArray"); if (!pFunQt[16]) MessageErrorLoad("new_QByteArray"w, 2);
	pFunQt[17] = GetPrAddres(hQtCore, "_ZN10QByteArray4dataEv"); if (!pFunQt[17]) MessageErrorLoad("QByteArray_data"w, 2);
	pFunQt[10] = GetPrAddres(hQtE, "qs_test"); if (!pFunQt[10]) MessageErrorLoad("qs_test"w, 2);
	// QTextEdit
	pFunQt[20] = GetPrAddres(hQtE, "p_QTextEdit"); if (!pFunQt[20]) MessageErrorLoad("p_QTextEdit"w, 2);
	pFunQt[21] = GetPrAddres(hQtGui, "_ZN9QTextEdit6appendERK7QString"); if (!pFunQt[21]) MessageErrorLoad("TextEdit_append"w, 2);
	pFunQt[22] = GetPrAddres(hQtGui, "_ZN9QTextEdit5clearEv"); if (!pFunQt[22]) MessageErrorLoad("TextEdit_clear"w, 2);
	// QPushButton
	pFunQt[24] = GetPrAddres(hQtE, "QT_QPushButton"); if (!pFunQt[24]) MessageErrorLoad("QT_QPushButton"w, 2);
	// QObject
	pFunQt[26] = GetPrAddres(hQtE, "QT_QObject"); if (!pFunQt[26]) MessageErrorLoad("QT_QObject"w, 2);
	pFunQt[27] = GetPrAddres(hQtCore, "_ZN7QObject7connectEPKS_PKcS1_S3_N2Qt14ConnectionTypeE"); if (!pFunQt[27]) MessageErrorLoad("QT_connect"w, 2);
	// eSlot
	pFunQt[25] = GetPrAddres(hQtE, "eSlot_setSignal0"); if (!pFunQt[25]) MessageErrorLoad("eSlot_setSignal0"w, 2);
	pFunQt[28] = GetPrAddres(hQtE, "qte_eSlot"); if (!pFunQt[28]) MessageErrorLoad("qte_eSlot"w, 2);
	pFunQt[29] = GetPrAddres(hQtE, "eSlot_setSlot0"); if (!pFunQt[29]) MessageErrorLoad("eSlot_setSlot0"w, 2);
	// QMessageBox
	pFunQt[36] = GetPrAddres(hQtE, "QT_QMessageBox"); if (!pFunQt[36]) MessageErrorLoad("QT_QMessageBox"w, 2);
	pFunQt[37] = GetPrAddres(hQtGui, "_ZN11QMessageBox7setTextERK7QString"); if (!pFunQt[37]) MessageErrorLoad("QMessageBox_setText"w, 2);
	pFunQt[38] = GetPrAddres(hQtE, "QT_QMessageBox_exec"); if (!pFunQt[38]) MessageErrorLoad("QT_QMessageBox_exec"w, 2);
	pFunQt[39] = GetPrAddres(hQtGui, "_ZN11QMessageBox14setWindowTitleERK7QString"); if (!pFunQt[39]) MessageErrorLoad("QT_QMessageBox_setWindowTitle"w, 2);
	pFunQt[40] = GetPrAddres(hQtGui, "_ZN11QMessageBox7setIconENS_4IconE"); if (!pFunQt[40]) MessageErrorLoad("QT_QMessageBox_setIcon"w, 2);
	pFunQt[41] = GetPrAddres(hQtGui, "_ZN11QMessageBox18setInformativeTextERK7QString"); if (!pFunQt[41]) MessageErrorLoad("QT_QMessageBox_setInformativeText"w, 2);
	pFunQt[42] = GetPrAddres(hQtGui, "_ZN11QMessageBox18setStandardButtonsE6QFlagsINS_14StandardButtonEE"); if (!pFunQt[42]) MessageErrorLoad("QT_QMessageBox_setStandardButtons"w, 2);
	pFunQt[43] = GetPrAddres(hQtGui, "_ZN11QMessageBox16setDefaultButtonENS_14StandardButtonE"); if (!pFunQt[43]) MessageErrorLoad("QT_QMessageBox_setDefaultButton"w, 2);
	pFunQt[44] = GetPrAddres(hQtGui, "_ZN11QMessageBox15setEscapeButtonENS_14StandardButtonE"); if (!pFunQt[44]) MessageErrorLoad("QT_QMessageBox_setEscapeButton"w, 2);
  // QBoxLayout
	pFunQt[47] = GetPrAddres(hQtE, "QT_QBoxLayout"); if (!pFunQt[47]) MessageErrorLoad("QT_QBoxLayout"w, 2);

	pFunQt[48] = GetPrAddres(hQtE, "QT_QBoxLayout_addWidget"); if (!pFunQt[48]) MessageErrorLoad("QT_QBoxLayout_addWidget"w, 2);
	pFunQt[49] = GetPrAddres(hQtE, "QT_QBoxLayout_addLayout"); if (!pFunQt[49]) MessageErrorLoad("QT_QBoxLayout_addLayout"w, 2);

  // QVBoxLayout
	pFunQt[45] = GetPrAddres(hQtE, "QT_QVBoxLayout"); if (!pFunQt[45]) MessageErrorLoad("QT_QVBoxLayout"w, 2);
  // QHBoxLayout
	pFunQt[46] = GetPrAddres(hQtE, "QT_QHBoxLayout"); if (!pFunQt[46]) MessageErrorLoad("QT_QHBoxLayout"w, 2);
  // QMainWindow
	pFunQt[54] = GetPrAddres(hQtE, "QT_QMainWindow"); if (!pFunQt[54]) MessageErrorLoad("QT_QMainWindow"w, 2);
	pFunQt[52] = GetPrAddres(hQtGui, "_ZN11QMainWindow12setStatusBarEP10QStatusBar"); if (!pFunQt[52]) MessageErrorLoad("QT_QMainWindow_setStatusBar"w, 2);
	pFunQt[53] = GetPrAddres(hQtGui, "_ZN11QMainWindow16setCentralWidgetEP7QWidget"); if (!pFunQt[53]) MessageErrorLoad("QT_QMainWindow_setCentralWidget"w, 2);
  // QStatusBar
	pFunQt[51] = GetPrAddres(hQtE, "QT_QStatusBar"); if (!pFunQt[51]) MessageErrorLoad("QT_QStatusBar"w, 2);
  // QLCDNumber
	pFunQt[55] = GetPrAddres(hQtE, "QT_QLCDNumber"); if (!pFunQt[55]) MessageErrorLoad("QT_QLCDNumber"w, 2);
	pFunQt[57] = GetPrAddres(hQtGui, "_ZN10QLCDNumber15setSegmentStyleENS_12SegmentStyleE"); if (!pFunQt[57]) MessageErrorLoad("QLCDNumber_setSegmentStyle"w, 2);
  // QSpinBox
	pFunQt[56] = GetPrAddres(hQtE, "QT_QSpinBox"); if (!pFunQt[56]) MessageErrorLoad("QT_QSpinBox"w, 2);
  
	return 0;
} ///  Загрузить DLL-ки Qt и QtE. Найти в них адреса функций и заполнить ими таблицу


/++
	Класс констант. В нем кое что из Qt::
+/		
class QtE {
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
}

// ================ QObject ================
/++
	Базовый класс.  Хранит в себе ссылку на реальный объект в Qt C++
+/		
class QObject {
	void* p_QObject;		/// Адрес самого объекта из C++ Qt
	this() {	
	} /// спец Конструктор, что бы не делать реальный объект из Qt при наследовании
	this(void* parent) {
		p_QObject = (cast(t_QObject)pFunQt[26])(parent);
	} /// Конструктор. Создает рельный QObject и сохраняет его адрес в p_QObject
	void* QtObj() {
		return p_QObject;  
	} /// Выдать указатель на реальный объект Qt C++
	void connect (void*  obj1, char* ssignal, void* obj2, char* sslot, int type) {
		(cast(t_QObject_connect)pFunQt[27])(obj1, ssignal, obj2, sslot, type);
	}
}
// ================ QTextCodec ==================
/++
	Преобразование в - из кодовых страниц в unicod
+/		
class QTextCodec {
	void* p_QObject;		/// Адрес самого объекта из C++ Qt
	this(string strNameCodec) {
		p_QObject = (cast(t_QObject)pFunQt[33])(cast(char*)strNameCodec);
	}
	/*
	void toUnicode(string str, QString qstr) {
		(cast(t_QNameCodec_toUnicode)pFunQt[34])(p_QObject, qstr.QtObj(), cast(char*)str);
	}
	*/
	QString toUnicode(string str, QString qstr) {
		(cast(t_QNameCodec_toUnicode)pFunQt[34])(p_QObject, qstr.QtObj(), cast(char*)str);
		return qstr;
	}
	/*
	void fromUnicode(string str, QString qstr) {
		(cast(t_QNameCodec_toUnicode)pFunQt[34])(p_QObject, qstr.QtObj(), cast(char*)str);
	}
	*/
	char* fromUnicode(char* str, QString qstr) {
		(cast(t_QNameCodec_toUnicode)pFunQt[35])(p_QObject, qstr.QtObj(), str);
		return str;
	}
	void* QtObj() {
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
	byte bufObj[8];     // данные объекта
	this() {
		super(); p_QObject = &bufObj;
} /// При создании QApplication адрес объекта C++, сохранить в QObject

//	this(int m_argc, char** m_argv) {
//		(cast(t_QApplication_QApplication)pFunQt[0])(bufObj, &m_argc, m_argv);
//	}

	t_QApplication_QApplication adrQApplication() {
        		return cast(t_QApplication_QApplication)pFunQt[0];
	} /// Выдать адрес конструктора C++ QApplication, для выполнения в main()
	void create(int m_argc, char** m_argv) {
		(cast(t_QApplication_QApplication)pFunQt[0])(cast(void*)bufObj, &m_argc, m_argv);
	} /// Обычный вариант конструктора. В Linux не работает
	int exec() {
		return (cast(t_QApplication_Exec)pFunQt[1])(cast(void*)bufObj);
	} /// Обычный QApplication::exec()
}
// ================ gWidget ================
/++
	QWidget (Окно), но немного модифицированный в QtE.DLL. 
	<br>Хранит в себе ссылку на реальный С++ класс gWidget из QtE.dll
	<br>Добавлены свойства хранящие адреса для вызова обратных функций
	для реакции на события.
+/		
class gWidget: QObject  {
	// void* p_QObject;								/// Адрес самого виджета gWidget из QtE.dll
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
		(cast(t_v__vp_vp)pFunQt[8])(p_QObject,  qstr.QtObj());
	} /// Установить заголовок окна
	void resize(int w, int h) {					// Изменить размер виджета
		(cast(t_resize_QWidget)pFunQt[19])(p_QObject, w, h);
	} /// Изменить размер виджета
	void setLayout(QBoxLayout layout) {
		(cast(t_v__vp_vp)pFunQt[50])(p_QObject, layout.QtObj());
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
}
// ================ QByteArray ================
class QByteArray {
	void* p_QByteArray;
	this() {
		p_QByteArray = (cast(t_new_QByteArray)pFunQt[16])();
	}
	void setByteArray(void* u) {
		p_QByteArray = u;
	}
	ubyte* data() {
		return (cast(t_QByteArray_data)pFunQt[17])(p_QByteArray);
	}
}
// ================ QString ================
/++
	Чистый QString  (Строка). 
	<br>Хранит в себе ссылку на реальный С++ класс QString из QtCore.dll
+/
class QString {
	void* p_QString;  /// Адрес реального QString
	this() {
		p_QString = (cast(t_new_QString)pFunQt[13])();
	} /// Конструктор пустого QString
	this(wstring s) {
		p_QString = (cast(t_QString_wchar)pFunQt[18])(cast(wchar*)s, s.length);
	} /// Конструктор где s - unicod. Пример: QString qs = new QString("Привет!"w);
	void clear() {
		(cast(t_QString_clear)pFunQt[11])(p_QString);
	} /// Очистить строку
	void fromUtf8(char* str, int dl = -1) {
		(cast(t_QString_fromUtf8)pFunQt[14])(p_QString, str, dl);
	} /// Из внутреннего кода в char*, или всё ( нет второго аргумента )или кол символов (второй аргумент)
	void* toAscii() {
		return (cast(t_QString_toAscii)pFunQt[15])(p_QString);
	} /// В ascii
	void* QtObj() {
		return p_QString;
	} /// Вернуть сам QString
	void set(char* str) {
		(cast(t_v__vp_vp)pFunQt[31])(p_QString, str);
	}; /// Установить строку str с учетом кодовой таблицы
	void text(char* str) {
		(cast(t_v__vp_vp)pFunQt[32])(p_QString, str);
	}; /// Записать строку в буфер по указателю str с учетом кодовой таблицы
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
	} /// Конструктор, где parent - сылка на родительский виджет
	void append(QString str) {
		(cast(t_v__vp_vp)pFunQt[21])(p_QObject, str.QtObj());
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
class gPushButton: gWidget {
	this(gWidget parent, QString str) {
		super();	// Это фактически заглушка, что бы сделать наследование, 
				// не создавая промежуточного экземпляра в Qt
		if (parent) {
			p_QObject = (cast(t_vp__vp_vp)pFunQt[24])(parent.p_QObject, str.QtObj());
		}
		else {
			p_QObject = (cast(t_vp__vp_vp)pFunQt[24])(null, str.QtObj());
		}
	} /// Создать кнопку. 
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
		(cast(t_v__vp_vp)pFunQt[37])(p_QObject, msg.QtObj());
	} /// Установить текст
	override void setWindowTitle(QString msg) {
		(cast(t_v__vp_vp)pFunQt[39])(p_QObject, msg.QtObj());
	} /// Установить текст Заголовка
	void setInformativeText(QString msg) {
		(cast(t_v__vp_vp)pFunQt[41])(p_QObject, msg.QtObj());
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
			p_QObject = (cast(t_QBoxLayout)pFunQt[47])(dir, parent.QtObj());
		}
		else {
			p_QObject = (cast(t_QBoxLayout)pFunQt[47])(dir, null);
		}
	} /// Создаёт выравниватель, типа dir и вставляет в parent 
	void addWidget(gWidget wd) {
		(cast(t_v__vp_vp)pFunQt[48])(p_QObject, wd.QtObj());
	} /// Добавить виджет в выравниватель 
	void addLayout(QBoxLayout layout) {
		(cast(t_v__vp_vp)pFunQt[49])(p_QObject, layout.QtObj());
	} /// Добавить выравниватель в выравниватель 
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
	} /// Конструктор основного окна приложения
	void setStatusBar(QStatusBar sb) {
		(cast(t_v__vp_vp)pFunQt[52])(p_QObject, sb.QtObj());
	} /// Вставить строку состояния sb
	void setCentralWidget(gWidget wd) {
		(cast(t_v__vp_vp)pFunQt[53])(p_QObject, wd.QtObj());
	} /// Вставить строку состояния sb
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
}

