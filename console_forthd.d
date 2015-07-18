/*------------------------------
 MGW 29.06.2015 14:25:10
 ---------------------------------
 Консоль для forthD
 -------------------------------*/
// win: dmd main.d lib_qt.d -L/SUBSYSTEM:WINDOWS:5.01
// lin: dmd main.d lib_qt.d -L-ldl

//  import std.c.stdio;
// import std.string;
import qte;                           // Работа с Qt
import core.runtime;
import std.string: strip;
import forth;
import std.stdio;

QTextCodec  UTF_8;       // Кодек Linux
QTextCodec  WIN_1251;    // Кодек Windows
QString     tmpQs;

QFont       fontElements;         // Шрифт для элементов программы

const strElow  = "background: #F8FFA1";  // image: url(Time-For-Lunch-2.jpg)

extern (C) {
    void on_knEval() { formaMain.EvalString();   }
    void on_knLoad() { formaMain.IncludedFile(); }
    void on_knHelp() { formaMain.Help();         }
	void on_returnPress() { formaMain.Cr();      }
}


class FormaMain: QMainWindow {
//    import std.stdio;
//    import std.file;
    
	QFrame			frAll;			// Общий фрейм для всей формы
	QHBoxLayout 	hblKeys;		// Выравниватель для кнопок горизонтальный
	QVBoxLayout 	vblAll;			// Общий вертикальный выравниватель
    QLineEdit		leCmdStr;		// Строка команды
	QPlainTextEdit	teLog;			// Окно лога
	gPushButton		knEval;			// Кнопка Eval
	gPushButton		knHelp;			// Кнопка Help
	gPushButton		knLoad;			// Кнопка Included файл
	
	// Главный конструктор. Создать форму
    this() {
        super();
		setWindowTitle("*** Консоль forthD ***");
        resize(700, 400);
        fontElements = new QFont(); fontElements.setPointSize(12); setFont(fontElements);
		vblAll  = new  QVBoxLayout();			// Главный выравниватель
		hblKeys = new  QHBoxLayout();			// Выравниватель для кнопок
		leCmdStr = new QLineEdit(null);			// Строка команды
		teLog = new QPlainTextEdit();			// окно log
		frAll = new QFrame();					// Вместо главного виджета
		vblAll.addWidget(teLog);				// 1 - самое верхнее окно лога
		vblAll.addWidget(leCmdStr);				// 2 - строка ввода команды
		knEval = new gPushButton(this, "Eval(string)");
		knHelp = new gPushButton(this, "Помощь");
		knLoad = new gPushButton(this, "INCLUDED string");
		hblKeys.addWidget(knEval); hblKeys.addWidget(knLoad); hblKeys.addWidget(knHelp);
		vblAll.addLayout(hblKeys);				// 2 - строка ввода команды
		
		frAll.setLayout(vblAll);				// Вертикальный, главный выравниватель на фрейм
		setCentralWidget(frAll);				// Устанавливаем центральный виджет
		// ---- Включим события ----
        gSlot slot_knEval = new gSlot(); slot_knEval.setSlot(0, &on_knEval);
        connect(knEval.QtObj, MSS("clicked()", QSIGNAL), slot_knEval.QtObj, MSS("Slot0()", QSLOT), 
            QObject.ConnectionType.QueuedConnection);
        gSlot slot_knLoad = new gSlot(); slot_knLoad.setSlot(0, &on_knLoad);
        connect(knLoad.QtObj, MSS("clicked()", QSIGNAL), slot_knLoad.QtObj, MSS("Slot0()", QSLOT), 
            QObject.ConnectionType.QueuedConnection);
        gSlot slot_knHelp = new gSlot(); slot_knHelp.setSlot(0, &on_knHelp);
        connect(knHelp.QtObj, MSS("clicked()", QSIGNAL), slot_knHelp.QtObj, MSS("Slot0()", QSLOT), 
            QObject.ConnectionType.QueuedConnection);
		// Обработка Cr в LineEdit
		leCmdStr.setOnReturnPressed(&on_returnPress);
		// ---- Дизайн ----
		leCmdStr.setStyleSheet(new QString(strElow));
		// ---- Forth ----
    	initForth(); 		// Активизируем Форт
	}
	// Загрузка файла Forth
	void IncludedFile() {
	    string cmd = leCmdStr.text(); includedForth(cmd); teLog.appendPlainText(cmd); leCmdStr.clear();
	}
	// Выполнить строку Eval
	void EvalString() {
	    string cmd = strip(leCmdStr.text());
		if(cmd.length != 0) {
			evalForth(cmd); teLog.appendPlainText(cmd); leCmdStr.clear();
		}
	}
	// Обработка нажатия CR в LineEdit формы
	void Cr() {
	    EvalString();
	}
	// Help
	void Help() {
	    msgbox("Help ...");
	}
}

FormaMain formaMain;

int main(string[] args) {
    // Проверим режим загрузки. Если есть '--debug' старт в отладочном режиме
    bool fDebug; fDebug = false; foreach (arg; args[0 .. args.length])  { if (arg=="--debug") fDebug = true; }
    // Загрузка графической библиотеки
    int rez = LoadQt( dll.Core | dll.Gui | dll.QtE, fDebug); if (rez==1) return 1;  // Ошибка загрузки библиотеки
    QApplication app = new QApplication(&Runtime.cArgs.argc, Runtime.cArgs.argv, 1); 
    // ----------------------------------
    // Инициализация внутренних перекодировок
    tmpQs = new QString(); UTF_8 = new QTextCodec("UTF-8");    WIN_1251 = new QTextCodec("Windows-1251");
    // ----------------------------------
    

	formaMain = new FormaMain();
	formaMain.show();
	
	return app.exec();
}
