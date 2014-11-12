// Compile:
// ------------------------------
// Linux:    dmd ex1.d qte.d -L-ldl
// Windows:  dmd ex1.d qte.d
// ------------------------------

import qte;                                   // work with Qt
import core.runtime;                    // parametr start
import std.stdio;                          // writeln();

int main(string[] args) {
    QApplication app;       // Application
    QTextCodec UTF_8;
    QTextCodec WIN_1251;
    QTextCodec IBM866;  
    QString tmpQs;
    QByteArray ba;
    QLabel label;

     
    // Проверим режим загрузки. Если есть '--debug' старт в отладочном режиме с показом диагностики загрузки QtE
    // Check the boot mode. If there is a '--debug' start in debug mode with display of the diagnostic boot QtE
    bool fDebug; foreach(arg; args) if (arg=="--debug") fDebug = true; 
    
    // Загрузка графической библиотеки. fDebug=F без диагностики, T=Диагностика загрузки
    // Load the graphics library. fDebug=F without a diagnosis, T=Diagnostics download enable
    int rez = LoadQt( dll.Core | dll.Gui | dll.QtE, fDebug); if (rez==1) return 1;  // Ошибка загрузки библиотеки
    
    // Инициализация Qt. Посл параметр T=GUI, F=консольное приложение
    // Initialization Of Qt. The last parameter T=GUI F=console application
    app = new QApplication(&Runtime.cArgs.argc, Runtime.cArgs.argv, 1); 
    
    // Инициализация внутренних перекодировок
    // Initialize internal levels
    tmpQs = new QString(); 
    UTF_8 = new QTextCodec("UTF-8");            // Linux
    WIN_1251 = new QTextCodec("Windows-1251");  // Windows
    IBM866 = new QTextCodec("IBM 866");         // DOS
    
    // Сформируем строку с приветствием
    // Generate the string with a greeting
    tmpQs.toUnicode(cast(char*)("<h2>Привет из (Hello from)  <font color=red size=5>QtE.d</font></h2>".ptr), UTF_8);

    // Изготовим QLabel
    // make QLabel
    label = new QLabel(null);
    label.setText(tmpQs); label.setAlignment(QtE.AlignmentFlag.AlignCenter); // We write the text and alignment
    label.resize(300, 130); // размер label
    
    // Пример работы с DOS консолью
    // Example of working with the DOS console
    ba = new QByteArray(cast(char*)("Привет из QtE.d - обратите внимание на перекодировку в DOS".ptr));  // This in UTF-8
    tmpQs.toUnicode(cast(char*)ba.data(), UTF_8);  // This in Ubicod   это в Юникоде
    version(Windows) {  // для win вернее дос нужна особая перекодировка // for win rather DOS needs a special transcoding
        tmpQs.fromUnicode(cast(char*)ba.data(), IBM866);
    }
    version(linux) {    // в Linux работает UTF-8, но можно конвертнуть в любую другую таблицу // in Linux is UTF-8, but you can конвертнуть in any other table
        tmpQs.fromUnicode(cast(char*)ba.data(), UTF_8);
    }
    printf("%s", ba.data());

    label.show();
    
    return app.exec();
}
