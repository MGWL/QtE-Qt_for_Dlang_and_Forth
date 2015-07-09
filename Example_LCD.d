/*------------------------------
 MGW 10.08.2013 23:46:10
 ---------------------------------
 Пример работы с библиотекой QtE.d
 -------------------------------*/
// win: dmd main.d lib_qt.d -L/SUBSYSTEM:WINDOWS:5.01
// lin: dmd main.d lib_qt.d -L-ldl

//  import std.c.stdio;
import qte;                                   // Работа с Qt
import core.runtime;

// import std.encoding;
import std.stdio; // writeln

class GenaMainWin: QMainWindow {
	QStatusBar sb1;
	QTextEdit textEd7;
	QTextEdit textEd8;
	QVBoxLayout vbl1;
	QHBoxLayout hbl1;
	QLCDNumber lcd1;
	QSpinBox spinb1;
	gWidget w1;
	
	this() {
		super();
		w1 = new gWidget(null, 0);
		setWindowTitle(new QString("Это моё основное окно."w));
		resize(400, 100);
		sb1 = new QStatusBar(null);
		setStatusBar(sb1);
		textEd7 = new QTextEdit(null);
		lcd1 = new QLCDNumber(null); lcd1.setSegmentStyle(QLCDNumber.SegmentStyle.Flat);
		spinb1 = new QSpinBox(null);
		hbl1 = new QHBoxLayout;
		vbl1 = new QVBoxLayout();
		vbl1.addWidget(textEd7);
		hbl1.addWidget(spinb1); hbl1.addWidget(lcd1);
		vbl1.addLayout(hbl1);
		w1.setLayout(vbl1);
		setCentralWidget(w1);
		// Пример привязки стандартного сигнала к стандартному слоту
		spinb1.connect(spinb1.QtObj(), MSS("valueChanged(int)", QSIGNAL)
			, lcd1.QtObj(), MSS("display(int)", QSLOT),  1);
	}
}
	
int main(string[] args) {
	// Цепляем библиотеки QtCore, QtGui, QtE, QtScript или их комбинацию.
	int rez = LoadQt( dll.Core | dll.Gui | dll.QtE, true ); if (rez==1) return 1;  // Ошибка загрузки библиотеки
	
//	QApplication app = new QApplication(Runtime.cArgs.argc, Runtime.cArgs.argv, true);  // Создали, но конструктор не вызван
	QApplication app = new QApplication;  // Создали, но конструктор не вызван
	// Изврат связанный с тем, что  вызов конструктора QApplication
	// должен быть произведен в main(), иначе в Linux ошибка ....
	(app.adrQApplication())(cast(void*)app.bufObj, &Runtime.cArgs.argc, Runtime.cArgs.argv, true);
        gWidget w1 = new gWidget(null, 0);
        w1.show();

	// Создаём основное окно приложения
	GenaMainWin genaMain = new GenaMainWin();
	// gWidget w1 = new gWidget(null, 0);
	genaMain.show();
	
	return app.exec();
}
