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

QTextCodec  UTF_8;       // Кодек Linux
QTextCodec  WIN_1251;    // Кодек Windows
	
// пример работы с QPainter
class myQWidget: gWidget {
	this(gWidget parent, int fl) {
		super(parent, fl);
	}
	void paint(void* uthis) {
	    int w = width(); int h = height();
        p.setQtObj(uthis);
        for(int i=2; i<50; i=i+5) {
            p.drawLine(i, i, i, h-i); p.drawLine(i, h-i, w-i, h-i);
            p.drawLine(w-i, h-i, w-i, i);
            p.drawLine(w-i, i, i, i);
        }
	}
}

myQWidget* uw;
QPainter p; //  = new QPainter(null);

extern (C) void onPaintWidget(void* uk, void* uthis) {
    uw.paint(uthis);
}
	
int main(string[] args) {
    QApplication app;   
    QPainter pPrint;
    
    // Проверим режим загрузки. Если есть '--debug' старт в отладочном режиме
    bool fDebug; fDebug = false; foreach (arg; args[0 .. args.length])  { if (arg=="--debug") fDebug = true; }
    // Загрузка графической библиотеки
    int rez = LoadQt( dll.Core | dll.Gui | dll.QtE, fDebug); if (rez==1) return 1;  // Ошибка загрузки библиотеки
    app = new QApplication(&Runtime.cArgs.argc, Runtime.cArgs.argv, 1); 
    // ----------------------------------
    // Инициализация внутренних перекодировок
    UTF_8 = new QTextCodec("UTF-8");    WIN_1251 = new QTextCodec("Windows-1251");
    // ----------------------------------
    p = new QPainter(null);
    myQWidget w1 = new myQWidget(null, 0);
    uw = &w1;
    w1.resize(300, 200);
    w1.setPaintEvent(&onPaintWidget);
    QFont f1 = new QFont();    f1.setPointSize(14); 
    
    QByteArray ba = new QByteArray(cast(char*)"ABC".ptr);
    printf("%s", ba.data());
    
    QPrinter printer = new QPrinter();
    printer.setOutputFormat(QPrinter.OutputFormat.PdfFormat);
    printer.setOutputFileName(new QString("printer.pdf"));
    pPrint = new QPainter(null);
//    pPrint.setPaintDevice(printer.QtObj);
    pPrint.setPaintDevice(printer.thisPrinter());
    pPrint.drawLine(10, 10, 100, 100);
    pPrint.drawLine(30, 10, 200, 120);
    pPrint.drawLine(10, 300, 500, 300);
    f1.setPointSize(10); pPrint.setFont(f1);
    pPrint.drawText(120, 120, new QString("Привет Мужики!"));
    f1.setPointSize(20); f1.setFamily(new QString("Forte")); pPrint.setFont(f1);
    pPrint.drawText(120, 180, new QString("Hello world!"));
    f1.setPointSize(14); f1.setFamily(new QString("Times New Roman")); pPrint.setFont(f1);
    pPrint.drawText(120, 200, new QString("Привет Лариса!"));
    pPrint.end();
    
    w1.show();
    msgbox("Работа с принтером. Создан файл: <b>printer.pdf</b>");
    // ----------------------------------
    return app.exec();
}
