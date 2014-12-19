// instqte - install library QtE
// 27.11.2014 20:15:47
// -------------------------------

import std.file;
import std.stdio;
import std.path;
import std.conv;
import std.string;
import asc1251;
import std.net.curl;
// import std.c.stdio;

version(Windows) {
	import std.c.windows.windows;
}
version(linux) {
	import core.sys.posix.dlfcn;
	import std.stdio;
}

int		os;		// 1=Linux32, 2=Linux64, 3=Windows=32, 4=Windows64
string e[6];    // En message
string r[6];    // Ru message
string me[7];
string mr[7];

string nameZip = "QtE_zip.zip";

int    nomEk;   // n screen
bool   lng;     // Language message F = En, T = Ru
// --------------
auto pre = "Q is exit. Select number string  ---> ";
auto prr = "Q - выход. Выберите номер строки ---> ";

void init() {
e[0] = "
Welcome in QtE!
---------------

Choose language of messages:
    1 - English
    2 - Russian
    
";
e[1] ="
Specify a platform for installation QtE.
----------------------------------------
    1 - Linux 32
    2 - Linux 64
    3 - Windows 32
    4 - Windows 64 
";
e[2] ="
Some files from library Qt4 are necessary for normal job QtE.
Wish to check up presence install Qt4?
------------------------------------
    1 - To check up presence of necessary files from Qt4
    2 - Not to check ...
";
e[3] ="
Now it is necessary to prepare QtE.dll (so). 
Certainly it can be compiled using C ++ the compiler,
but it long and is labour-consuming. To load already ready,
compiled version easier.. 

Wish to load ZIP archive with ready QtE.dll (so) ?
------------------------------------
    1 - Download ZIP archive with ready QtE.dll (so) ?
    2 - Not to load ...
";
e[4] ="
Loading is Ok. Wish to take from ZIP archive ready QtE.dll (so)
------------------------------------
    1 - Unzip QtE.dll (so) from ZIP archive?
    2 - Not ...
";
e[5] ="
All libraries are loaded successfully. All is ready for job
with QtE. The batch file in which compilation and start
of the graphic program with QtE is shown will be now made.
";


r[0] ="
Добро пожаловать в QtE
----------------------
";
r[1] ="
Укажите платформу для установки QtE.
------------------------------------
    1 - Linux 32
    2 - Linux 64
    3 - Windows 32
    4 - Windows 64 
";
r[2] ="
Для нормальной работы QtE необходимы некоторые файлы из состава Qt4.
Желаете проверить наличие установленной Qt4?
------------------------------------
    1 - Проверить наличие Qt4 файлов
    2 - Не проверять ...
";
r[3] ="
Теперь надо подготовить QtE.dll (so). Конечно её можно скомпилировать
используя C++ компилятор, но это доло и трудоёмко. Проще загрузить уже
готовую, скомпилированную версию. 

Желаете загрузить ZIP архив с готовой QtE.dll (so) ?
------------------------------------
    1 - Загрузить ZIP архив с готовой QtE.dll (so) ?
    2 - Не загружать ...
";
r[4] ="
Загрузка закончена. Желаете извлечь из ZIP архива готовую
QtE.dll (so)
------------------------------------
    1 - Извлечь QtE.dll (so) из ZIP архива?
    2 - Не извлекать ...
";
r[5] ="
Все библиотеки загружены успешно. Всё готово для работы с QtE.
Сейчас будет изготовлен командный файл, в котором показана компиляция
и запуск графической программы с QtE.
";


mr[0] ="
Выбран русский язык. 
--------------------
";
mr[1] ="
--------------------
";
mr[2] ="
Всё нормально! Нужные файлы найдены!
	libQtCore.so.4, libQtGui.so.4, libQtScript.so.4, libQtWebKit.so.4, libQtNetwork.so.4
-----------------------------------------------------------------------------------------
";
mr[3] ="
Всё нормально! Нужные файлы найдены!
	QtCore4.dll, QtGui4.dll, QtScript4.dll, QtWebKit4.dll, QtNetwork4.dll
-------------------------------------------------------------------------
";
mr[4] ="
В связи с тем, что основные файлы Qt не найдены, то их можно
скачать в ZIP архиве содержащим RunTime версию Qt 4.8. Далее
будет предложено скачать этот файл
-------------------------------------------------------------------------
";
mr[5] ="

Формирую: testQtE.sh

Запуск: sh testQtE.sh
-------------------------------------------------------------------------
";
mr[6] ="

Формирую: testQtE.bat

Запуск: testQtE.bat
-------------------------------------------------------------------------
";


me[0] ="
English language is chosen.
---------------------------
";
me[1] ="
--------------------
";
me[2] ="
Ok! Files is!
	libQtCore.so.4, libQtGui.so.4, libQtScript.so.4, libQtWebKit.so.4, libQtNetwork.so.4
----------------------------------------------------------------------------------------
";
me[3] ="
Ok! Files is!
	QtCore4.dll, QtGui4.dll, QtScript4.dll, QtWebKit4.dll, QtNetwork4.dll
-------------------------------------------------------------------------
";
me[4] ="
Because basic files Qt are not found, they can be downloaded
in ZIP archive containing RunTime version Qt 4.8. Further 
it will be offered to download this file.
-------------------------------------------------------------------------
";
me[5] ="

Create: testQtE.sh

Start: sh testQtE.sh
-------------------------------------------------------------------------
";
me[6] ="

Create: testQtE.bat

Start: testQtE
-------------------------------------------------------------------------
";

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
int LoadQt() {  
	void* hQtGui; void* hQtCore; void* hQtE; void* hQtScript; void* hQtWeb; void* hQtNet;             // handes for dll
	string  cQtCore; string  cQtGui; string  cQtE;  string cQtScript; string cQtWeb; string cQtNet;   // strigs for win api LoadLibrary
	wstring wQtCore; wstring wQtGui; wstring wQtE; wstring wQtScript; wstring wQtWeb; wstring wQtNet; // wstring for wrete error D
	bool bCore; bool bGui; bool bQtE; bool bScript; bool bWeb; bool bNet;
	
	version(Windows) {
		cQtCore = "_QtCore4.dll"; cQtGui = "QtGui4.dll"; cQtE = "QtE.dll"; cQtScript = "QtScript4.dll"; cQtWeb = "QtWebKit4.dll"; cQtNet = "QtNetwork4.dll";
		wQtCore = "QtCore4.dll"; wQtGui = "QtGui4.dll"; wQtE = "QtE.dll"; wQtScript = "QtScript4.dll"; wQtWeb = "QtWebKit4.dll"; wQtNet = "QtNetwork4.dll";
	}
	 version(linux) {
		cQtCore = "libQtCore.so.4"; cQtGui = "libQtGui.so.4"; cQtE = "QtE.so.1.0.0"; cQtScript = "libQtScript.so.4"; cQtWeb = "libQtWebKit.so.4"; cQtNet = "libQtNetwork.so.4";
		wQtCore = "libQtCore.so.4"; wQtGui = "libQtGui.so.4"; wQtE = "QtE.so.1.0.0"; wQtScript = "libQtScript.so.4"; wQtWeb = "libQtWebKit.so.4"; wQtNet = "libQtNetwork.so.4";
	}
	const QtCore   = cast(char*)cQtCore;
	const QtGui    = cast(char*)cQtGui;
	const QtE      = cast(char*)cQtE;
	const QtScript = cast(char*)cQtScript;
    const QtWeb    = cast(char*)cQtWeb;
    const QtNet    = cast(char*)cQtNet;
	
    hQtCore   = GetHlib(QtCore);   if (!hQtCore)    return 1;
    hQtGui    = GetHlib(QtGui);    if (!hQtGui)     return 1; 
    hQtScript = GetHlib(QtScript); if (!hQtScript)  return 1;
    hQtWeb    = GetHlib(QtWeb);    if (!hQtWeb)     return 1;
    hQtNet    = GetHlib(QtNet);    if (!hQtNet)     return 1;
	return 0;
}

// is Qt4?
bool isQt4(int os) {
	string mr1 = "
ВНИМАНИЕ! Не найдена одна или несколько библиотек из состава Qt4.
Проверьте наличеие следующих файлов:	
	libQtCore.so.4
	libQtGui.so.4
	libQtScript.so.4
	libQtWebKit.so.4
	libQtNetwork.so.4
Это файлы из состава следующих пакетов:
		qt.i686
		qtwebkit.i686
";
	string me1 = "
WARNING! Not found files from library Qt4.
Testing exists files:	
	libQtCore.so.4
	libQtGui.so.4
	libQtScript.so.4
	libQtWebKit.so.4
	libQtNetwork.so.4
This files is in:	
		qt.i686
		qtwebkit.i686
";
	string mr2 = "
ВНИМАНИЕ! Не найдена одна или несколько библиотек из состава Qt4.
Проверьте наличеие следующих файлов:	
	QtCore4.dll
	QtGui4.dll
	QtScript4.dll
	QtWebKit4.dll
	QtNetwork4.dll
Это файлы из состава Qt 4.8
";
	string me2 = "
WARNING! Not found files from library Qt4.
Testing exists files:	
	QtCore4.dll
	QtGui4.dll
	QtScript4.dll
	QtWebKit4.dll
	QtNetwork4.dll
This files is in Qt 4.8:	
";

	if(LoadQt() != 0) {
		if((os == 1) || (os == 2)) {
			if(lng) write(toCON(mr1));
			else    write(me1);
		}
		if((os == 3) || (os == 4)) {
			if(lng) write(toCON(mr2));
			else    write(me2);
		}
		return false;	
	}
	return true;
}

int main(string[] args) {
    int tekScr;         // Текущий экран
    string line;
    bool fExit;
    string msg;
    init();

    while(!fExit) {
        if(lng)  msg = r[nomEk];  else  msg = e[nomEk];
        // show next screen
        writeln("os = ", os, "  ", toCON(msg));
        
        if(lng) write(toCON(prr));
        else    write(pre);
        
        // Ask answer
        line = stripRight(stdin.readln());
        if((line == "Q") || (line == "q")) fExit = true;
        
        if(nomEk == 0) {
            if(line == "2") {  lng = true; writeln(toCON(mr[0])); }
            if(line == "1") {  writeln(toCON(me[0])); }
            nomEk = 1;
            goto next;
        }
        if(nomEk == 1) {
            if(line == "1") {  // Linux 32
				os = 1;
            }
            if(line == "3") {  // Windows 32
				os = 3;
            }
            nomEk = 2;
            goto next;
        }
        if(nomEk == 2) {
            if(line == "1") {  // Linux 32
				if(isQt4(os)) {
					if(os == 1) {
						if(lng)  msg = mr[nomEk];  else  msg = me[nomEk];
					}
					if(os == 3) {
						if(lng)  msg = mr[3];  else  msg = me[3];
					}
				}
				else {
					if(lng)  msg = mr[4];  else  msg = me[4];
				}
				writeln(toCON(msg)); 
            }
            nomEk = 3;
            goto next;
        }
        if(nomEk == 3) {
            if(line == "1") {  // Linux 32
				// Начать загрузку ZIP
				if(lng)  msg = "\nНачинаю загрузку --> " ~ nameZip;  else  msg = "\nStart load --> " ~ nameZip;
				writeln(toCON(msg)); 
				if(!exists(nameZip)) {
					download("http://qte.ucoz.ru/load/0-0-0-10-20", nameZip);
				}
				if(exists(nameZip)) {
					if(lng)  msg = "\nЗагрузка закончена ...";  else  msg = "\nDownload Ok ...";
					writeln(toCON(msg)); 
				}
				else {
					if(lng)  msg = "\nОшибка загрузки ...";  else  msg = "\nDownload error ...";
					writeln(toCON(msg)); 
				}

				// writeln(toCON(msg)); 
            }
            nomEk = 4;
            goto next;
        }
        if(nomEk == 4) {
			string nameQtEdll = "QtE.so.1.0.0";
            if(line == "1") {  // Извлечь QtE из ZIP
				if(exists(nameQtEdll)) {
					// Уже извлекли
				}
				else {			// Будем извлекать ...
					if(exists(nameQtEdll)) {
					}
				}
			}
            nomEk = 5;
            goto next;
		}
        if(nomEk == 5) {
			// Создать файл 
			File fhFileSh;
			if(os == 1) {
				if(lng)  msg = mr[5];  else  msg = me[5];
				writeln(toCON(msg));
				string nameSh = "testQtE.sh";
				// Формируем строку добавления
				try {
					fhFileSh = File(nameSh, "w");
				}
				catch {
					writeln("Error create " ~ nameSh);
				}
				fhFileSh.writeln("LD_LIBRARY_PATH=`pwd`; export LD_LIBRARY_PATH");
				fhFileSh.writeln("dmd Hello_world qte -L-ldl");
				fhFileSh.writeln("./Hello_world");
			}
			if(os == 3) {
				if(lng)  msg = mr[6];  else  msg = me[6];
				writeln(toCON(msg));
				string nameSh = "testQtE.bat";
				// Формируем строку добавления
				try {
					fhFileSh = File(nameSh, "w");
				}
				catch {
					writeln("Error create " ~ nameSh);
				}
				fhFileSh.writeln("dmd Hello_world qte");
				fhFileSh.writeln("Hello_world");
			}
			fExit = true;
		}
        // writeln("[", line, "]");
next:        
    }
	
    return 0;
}