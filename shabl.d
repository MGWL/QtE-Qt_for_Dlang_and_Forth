/*------------------------------
 MGW 29.06.2015 14:25:10
 ---------------------------------
 Пример работы с библиотекой QtE.d
 -------------------------------*/
//   Win: dmd shabl qte -L/SUBSYSTEM:WINDOWS:5.01  --> без окна DOS
//   Win: dmd shabl qte
// Linux: dmd shabl qte -L-ldl

import qte;                             // Работа с Qt
import core.runtime;
import std.stdio;                       // writeln

QTextCodec  UTF_8;       // Кодек Linux
QTextCodec  WIN_1251;    // Кодек Windows
	
class FormaMain: QMainWindow {
    // Главный конструктор. Создать форму
    this() {
        super();
        setWindowTitle("*** Пример работы с QtE4 ***");
        resize(700, 400);
    }
}

int main(string[] args) {
    // Проверим режим загрузки. Если есть '--debug' старт в отладочном режиме
    bool fDebug; fDebug = false; foreach (arg; args[0 .. args.length])  { if (arg=="--debug") fDebug = true; }
    // Загрузка графической библиотеки
    int rez = LoadQt( dll.Core | dll.Gui | dll.QtE, fDebug); if (rez==1) return 1;  // Ошибка загрузки библиотеки
    QApplication app = new QApplication(&Runtime.cArgs.argc, Runtime.cArgs.argv, 1); 
    // ----------------------------------
    // Инициализация внутренних перекодировок
    UTF_8 = new QTextCodec("UTF-8");    WIN_1251 = new QTextCodec("Windows-1251");
    // ----------------------------------
    

    FormaMain formaMain = new FormaMain();
    formaMain.show();

    return app.exec();
}