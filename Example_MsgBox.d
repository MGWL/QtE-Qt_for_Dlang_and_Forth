/*------------------------------
 MGW 10.08.2013 23:46:10
 ---------------------------------
 Пример работы с библиотекой QtE.d
 -------------------------------*/
// win: dmd main.d qte.d -L/SUBSYSTEM:WINDOWS:5.01
// lin: dmd main.d qte.d -L-ldl

//  import std.c.stdio;
import qte;                                   // Работа с Qt
import core.runtime;

// import std.encoding;
import std.stdio; // writeln

// Это наш обработчик события изменения размера окна
void resize(void* qq) {
   writeln("!");
}

// Это наш слот, вернее обработчик события вызова слота
void Кнопка1() {
	gWidget w10 = new gWidget(null, 0);
	w10.setWindowTitle(new QString("Это окно из моего слота!!!!"w));
	w10.resize(500, 150);
	w10.show();
}

int main(string[] args) {
	// Цепляем библиотеки QtCore, QtGui, QtE, QtScript или их комбинацию.
	int rez = LoadQt( dll.Core | dll.Gui | dll.QtE, false ); if (rez==1) return 1;  // Ошибка загрузки библиотеки

	
	QApplication app = new QApplication;  // Создали, но конструктор не вызван
	// Изврат связанный с тем, что  вызов конструктора QApplication
	// должен быть произведен в main(), иначе в Linux ошибка ....
	(app.adrQApplication())(cast(void*)app.bufObj, &Runtime.cArgs.argc, Runtime.cArgs.argv,true);


	// Создаём окно
	gWidget w1 = new gWidget(null, 0); 
	w1.setResizeEvent(&resize);  // Установить обработчик на resize

	QBoxLayout vl1 = new QBoxLayout(QBoxLayout.Direction.TopToBottom, w1);
	msgbox("Привет, мужики!");
	
	
	w1.resize(300, 100);	w1.show();
	wstring ss = "Привет!"w;
	wstring ss2 = ss ~ " - ура!"w;
	QString qs2 = new QString(ss2);

	gWidget w2 = new gWidget(null, 0); w2.resize(400, 50); w2.show();
	w2.setWindowTitle(new QString("Ещё одно окошко!"w));

     QTextEdit textEd7 = new QTextEdit(null);
     textEd7.append(new QString("Это textEd7 ... При изменении текста вызов сигнала textChanged() с привязкой к aboutQt()"));
	textEd7.setWindowTitle(qs2);
     textEd7.show();
     
	QByteArray ba = new QByteArray();
	w1.setWindowTitle(qs2);
	
	
	gPushButton копка1 = new gPushButton(null, qs2);
	
	QMessageBox mb1 = new QMessageBox(null);
	mb1.setWindowTitle(qs2); 
	mb1.setIcon(QMessageBox.Icon.Warning);
	mb1.setInformativeText(qs2); 
	mb1.setStandardButtons(QMessageBox.StandardButton.Cancel | QMessageBox.StandardButton.YesAll | QMessageBox.StandardButton.Abort | QMessageBox.StandardButton.Retry);
	mb1.setEscapeButton(QMessageBox.Button.Retry);
	mb1.setDefaultButton(QMessageBox.Button.Abort);
	mb1.setText(new QString("Внимание - это msgbox()"w));
	int irez = mb1.exec();
	if (irez == QMessageBox.Button.Ok) {
		writeln("pressed Ok");
	}
	if (irez == QMessageBox.StandardButton.Cancel) {
		writeln("pressed Cancel");
	}
	if (irez == QMessageBox.StandardButton.YesAll) {
		writeln("pressed YesAll");
	}
	if (irez == QMessageBox.StandardButton.Abort) {
		writeln("pressed Abort");
	}
	if (irez == QMessageBox.StandardButton.Retry) {
		writeln("pressed Retry");
	}
	writeln("-->", irez);
	
	// Пример привязки стандартного сигнала к стандартному слоту
	textEd7.connect(textEd7.QtObj(), MSS("textChanged()", QSIGNAL),  	app.QtObj(),  MSS("aboutQt()", QSLOT),  1);
	 // мы так же можем сделать свой СОБСТВЕННЫЙ СЛОТ!!! Для этого будем использовать
      // объект slot замечательного класса gSlot.
	gSlot slot0 = new gSlot(); slot0.setSlot0(&Кнопка1);  // Установить обработчик на Кнопку
	// Вяжем стандартный сигнал на наш слот
	 копка1.connect(копка1.QtObj(), MSS("clicked()", QSIGNAL),  slot0.QtObj(), MSS("Slot0()", QSLOT), 1);
	 // Вяжем наш  сигнал с стандартным слотом aboutQt
	 копка1.connect(slot0.QtObj(), MSS("Signal0()", QSIGNAL),  app.QtObj(), MSS("aboutQt()", QSLOT), 1);
	 // Инициируем наш сигнал
	 slot0.emitSignal0();
	
	копка1.show();
	return app.exec();
}
