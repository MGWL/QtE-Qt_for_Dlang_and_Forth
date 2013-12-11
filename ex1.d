// Compile:
// ------------------------------
// Linux:    dmd ex1.d qte.d -L-ldl
// Windows:  dmd ex1.d qte.d
// ------------------------------

import qte;                                   // Работа с Qt
import core.runtime;                    // Параметры запуска
import std.stdio;                          // writeln();

int main(string[] args) {
    QApplication app;       // Приложение
    QTextCodec UTF_8;
    QTextCodec WIN_1251;
    QTextCodec IBM866;  
    QString tmpQs;
    QByteArray ba;
    QLabel label;
    
    // Проверим режим загрузки. Если есть '--debug' старт в отладочном режиме с показом диагностики загрузки QtE
    bool fDebug; fDebug = false; foreach (arg; args[0 .. args.length])  { if (arg=="--debug") fDebug = true; }
    
    // Загрузка графической библиотеки. fDebug=F без диагностики, T=Диагностика загрузки
    int rez = LoadQt( dll.Core | dll.Gui | dll.QtE, fDebug); if (rez==1) return 1;  // Ошибка загрузки библиотеки
    
    // Инициализация Qt. Посл параметр T=GUI, F=консольное приложение
    app = new QApplication; (app.adrQApplication())(cast(void*)app.bufObj, &Runtime.cArgs.argc, Runtime.cArgs.argv, true);
    
    // Инициализация внутренних перекодировок
    tmpQs = new QString(); 
    UTF_8 = new QTextCodec("UTF-8");            // Linux
    WIN_1251 = new QTextCodec("Windows-1251");  // Windows
    IBM866 = new QTextCodec("IBM 866");         // DOS
    
    // Сформируем строку с приветствием
    tmpQs.toUnicode(cast(char*)("<h2>Привет из <font color=red size=5>QtE.d</font></h2>".ptr), UTF_8);

    // Изготовим QLabel
    label = new QLabel(null);
    label.setText(tmpQs); label.setAlignment(QtE.AlignmentFlag.AlignCenter); // Запишем текст и выравнивание
    label.resize(300, 130); // размер label
    
    // Пример работы с DOS консолью
    ba = new QByteArray(cast(char*)("Привет из QtE.d - обратите внимание на перекодировку в DOS".ptr));  // Это в UTF-8
    tmpQs.toUnicode(cast(char*)ba.data(), UTF_8);  // это в Юникоде
    version(Windows) {  // для win вернее дос нужна особая перекодировка
        tmpQs.fromUnicode(cast(char*)ba.data(), IBM866);
    }
    version(linux) {    // в Linux работает UTF-8, но можно конвертнуть в любую другую таблицу 
        tmpQs.fromUnicode(cast(char*)ba.data(), UTF_8);
    }
    printf("%s", ba.data());

    
    label.show();
    
    return app.exec();
}
