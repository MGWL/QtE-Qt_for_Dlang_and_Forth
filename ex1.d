/*------------------------------
 MGW 10.08.2013 23:46:10
 ---------------------------------
 Example of the work with the library QtE.d
 -------------------------------*/
// win: dmd main.d qte.d -L/SUBSYSTEM:WINDOWS:5.01
// lin: dmd main.d qte.d -L-ldl

import qte;                  // Work of Qt
import core.runtime;

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
		setWindowTitle(new QString("This is my main window."w));
		resize(400, 100);
		sb1 = new QStatusBar(null);
		setStatusBar(sb1);
		textEd7 = new QTextEdit(null);
		textEd7.append(new QString("<b>This is QTextEdit</b>"w));
		lcd1 = new QLCDNumber(null); lcd1.setSegmentStyle(QLCDNumber.SegmentStyle.Flat);
		spinb1 = new QSpinBox(null);
		hbl1 = new QHBoxLayout;
		vbl1 = new QVBoxLayout();
		vbl1.addWidget(textEd7);
		hbl1.addWidget(spinb1); hbl1.addWidget(lcd1);
		vbl1.addLayout(hbl1);
		w1.setLayout(vbl1);
		setCentralWidget(w1);
		// Example of binding standard signal to a standard slot
		spinb1.connect(spinb1.QtObj(), MSS("valueChanged(int)", QSIGNAL)
			, lcd1.QtObj(), MSS("display(int)", QSLOT),  1);
	}
}
	
int main(string[] args) {
	// Load library QtCore, QtGui, QtE.
	int rez = LoadQt(); if (rez==1) return 1;  // Error load libs
	
	QApplication app = new QApplication;  // Created, but the constructor of Qt is not caused by
	 // It is a call constructor Qt::QApplication
	(app.adrQApplication())(cast(void*)app.bufObj, &Runtime.cArgs.argc, Runtime.cArgs.argv);

	// Create main window
	GenaMainWin genaMain = new GenaMainWin();
	gWidget w1 = new gWidget(null, 0);
	genaMain.show();
	
	return app.exec();
}
