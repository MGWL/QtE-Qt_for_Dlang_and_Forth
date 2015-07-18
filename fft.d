/**
 * Быстрый поиск в именах файлов Win 32/64, Linux 32/64
 *
 * MGW 18.07.2015 11:15:44
 * ------------------------------------------------
 * По сравнению с FF редактор заменен на таблицу
 *
 *
 */
import std.datetime;

 
import core.runtime;    // Обработка входных параметров 
import asc1251;
import std.path;
import std.file;
import std.conv;
import std.stdio;
import std.string;
import std.file;
import std.c.string;
import std.datetime;
import std.process;
import core.sys.windows.windows;
import qte;             // Работа с Qt

import std.ascii;
// import std.parallelism;

QString     tmpQs;      // Временная строка для всего на свете
QTextCodec  UTF_8;      // Кодек Linux
QTextCodec  WIN_1251;   // Кодек Windows

const int wr = 1000;
int   mNamelength;

// Расскраска для виджетов
string strElow  = "background: #FCFDC6"; //#F8FFA1";
string strBlue  = "background: #ACFFF2";

QApplication app;       // Основной цикл Qt
ClassMain wd_Main;

char[]  mPath[];        // массив Путей. Номер соответствует полнуму пути
size_t  iPath[];        // Массив списка длинн

struct StNameFile {
    size_t      FullPath;       // Полный путь из массива mPath
    char[]      NameFile;       // Имя файла
}
string  nameFileIndex;          // Имя файла индекса
StNameFile mName[];             // массив имен файлов
char    razd = '|';
// size_t     vec[1000];           // вектор кеша на строки до 1000 символов 

bool    runFind;                // Искать или нет

// Записать строку в QString tmpQs
QString tmpQsSet(string s) {
    char strBuf[1000];       // Буфер под строку
    size_t dl = s.length;
    sprintf(cast(char*)strBuf.ptr, cast(char*)s.ptr); strBuf[dl] = '\0';
    tmpQs.toUnicode(cast(char*)strBuf.ptr, UTF_8);
    return tmpQs;
}

// Обработка кнопки Поиска
extern (C) void onKnFind() {
    wd_Main.ViewStrs();
}
// Обработка кнопки Стоп
extern (C) void onKnStop() {
    wd_Main.knpStop();
}
// Обработка кнопки Word
extern (C) void onKnOpen() {
    wd_Main.knpWord();
}
// Обработка кнопки ОткрытьКаталог
extern (C) void onOpenDir() {
    wd_Main.knpOpenDir();
}
// Обрботка события, выделение текста в QTextEdit
extern (C) void onChText() {
    msgbox("Есть событие с QTextEdit");
}
// Обрботка события, F1 - Инструкция
extern (C) void onF1() {
//            wd_Main.loadIndex();
}

/*
bool fShowMain;
extern (C) void onLoadFile() {
    try {
        if(!fShowMain) {
            fShowMain = true;
            wd_Main.loadIndex();
        }
//        writeln("--1--");
//        wd_Main.loadIndex();
    }
    catch { }
}
*/

// Обрботка события, Enter - Поиск
extern (C) void onEnter() {
    msgbox("Событие Enter - Поиск");
}
// AboutQt
extern (C) void onAboutQt() {
   app.aboutQt();
}
// About Program
extern (C) void onAboutProgram() {
   // writeln("extern (C) void onAboutProgram()");
msgbox("<h2><p align=center><i><u><font color=red>FF - быстрый поиск файла.</font></i></u></p></h2>
<p><b>MGW © 2014г. (mgw@yandex.ru)</b></p>
<p>Ver 1.0  Windows 32/64 and Linux 32/64</p>
<hr>
Source:
<ol>
	<li>DMD 32/64 v2.065 <A HREF='http://dlang.org/'>http://dlang.org</A></li>
	<li>QtE 32/64 for D v1.3 <A HREF='http://qte.ucoz.ru/'>http://qte.ucoz.ru</A></li>
	<li>Qt  32/64 v8.x</li>
</ol>
<hr>
<p>
Программа состоит из двух частей:
<ol>
    <li>ffc.exe - Консольная. Создаёт индексый файл.</li>
    <li>ff.exe  - GUI. Поиск по индексному файлу и визуализация.</li>
</ol>
</p>
<hr>
<p>Компиляция Linux 32/64 где -mXX соответственно -m32 или -m64:</p>
<ol>
    <li>dmd ff.d asc1251.d qte.d -mXX -release -O -L-ldl -offf.exe</li>
    <li>dmd ffc.d asc1251.d -mXX -release -O -L-ldl -offfc.exe</li>
</ol>
<p>Компиляция Windows 32/64 где -mXX соответственно -m32 или -m64:</p>
<ol>
    <li>dmd ff.d asc1251.d qte.d -mXX -release -O -offf.exe</li>
    <li>dmd ffc.d asc1251.d -mXX -release -O -offfc.exe</li>
</ol>
", "О программе FF");
}


// Основная форма
class ClassMain: QMainWindow {
    gWidget     wd_main;                    // Главное окно
    QLabel      lb_capt1, lb_capt2;         // Подсказка
    QLineEdit   le_s1,le_s2,le_s3,le_s4;    // 2 x 2 поля ввода строк поиска
    gPushButton kn_Find;                    // Кнопка старта поиска
    QTableWidget te_list;                   // Вывод результата
    QStatusBar  sb_pbar;                    // Статус бар
    QHBoxLayout lh_param;                   // Строка параметров
    QHBoxLayout lh_button;                  // Строка кнопок 
    QVBoxLayout lv_main;                    // Вертикальный выравниватель
    QCheckBox   cb_12, cb_23;
    QProgressBar   prb_prog;
    gPushButton kn_Edit, kn_Word, kn_Excel, kn_PDF, kn_Help, kn_Exit;
    QFont       f1;
    // Центральная строка меню
    QMenuBar menuBar; 
    // Выполнители
    QAction act11;
    QAction act12;
    QAction act13;
    QAction act14;
    QAction act15;
    
    QAction act21;
    QAction act22;
    QAction act23;
    
    // Вертикальное меню
    QMenu menu11;
    QMenu menu12;
    
    // ----------------------------------------------------------
    this() {
        super();
        wd_main     = new gWidget(this, 0);
        lh_param    = new QHBoxLayout();
        lh_button   = new QHBoxLayout();
        lv_main     = new QVBoxLayout();
      
        sb_pbar     = new QStatusBar(this);
        te_list     = new QTableWidget(null);
        le_s1       = new QLineEdit(null);
        cb_12       = new QCheckBox(null);
        le_s2       = new QLineEdit(null); le_s2.setStyleSheet(tmpQsSet(strElow));
        cb_23       = new QCheckBox(null); 
        le_s3       = new QLineEdit(null); le_s3.setStyleSheet(tmpQsSet(strElow));
        le_s4       = new QLineEdit(null); le_s4.setStyleSheet(tmpQsSet(strElow));
        tmpQsSet("Если выключен = ищется любая комбинайия левой И правой строки\n
        Если включен, то только левая ИЛИ только правая.\n
        Регистр не важен."); 
        cb_23.setToolTip(tmpQs);
        tmpQsSet("Подстрока в ПУТИ файла. Регистр не важен."); 
        le_s2.setToolTip(tmpQs);
        tmpQsSet("Подстрока в ИМЕНИ файла. Регистр не важен."); 
        le_s3.setToolTip(tmpQs);
        le_s4.setToolTip(tmpQs);
        lb_capt1    = new QLabel(null);
        lb_capt2    = new QLabel(null);
        prb_prog     = new QProgressBar(null);
        prb_prog.setStyleSheet(tmpQsSet(strBlue));


        f1 = new QFont();    f1.setPointSize(10);   setFont(f1);
		// Таблица
		te_list.setColumnCount(4); // Четыре колонки
		te_list.setColumnWidth(0, 200);
		te_list.setColumnWidth(1, 100);
		te_list.setColumnWidth(2, 100);
		te_list.setColumnWidth(3, 400);

        // Кнопки
        kn_Find     = new gPushButton(wd_main, new QString("Поиск F5"));
        tmpQsSet("Начать поиск ..."); 
        kn_Find.setToolTip(tmpQs);
        kn_Edit     = new gPushButton(wd_main, new QString("Стоп"));
        tmpQsSet("Остановить поиск ..."); 
        kn_Edit.setToolTip(tmpQs);
        kn_Word     = new gPushButton(wd_main, new QString("Открыть файл"));
        tmpQsSet("Windows: Открыть файл использую АССОЦИРОВАННУЮ программу\n
        Linux: Открыть файл используя текстовый редактор kwrite"); 
        kn_Word.setToolTip(tmpQs);
        kn_Excel    = new gPushButton(wd_main, new QString("Открыть папку с файлом"));
        tmpQsSet("Открыть папку содержащию указаный файл."); 
        kn_Excel.setToolTip(tmpQs);

        le_s1.setEnabled(false);
        cb_12.setEnabled(false);

        lb_capt1.setText(new QString("Полный путь файла:"));  
        lb_capt2.setText(new QString("Имя файла:"));  
        // Соберем строку с полями вводи и кнопкой. Гориз выравниватель
        lh_param.addWidget(lb_capt1); /* lh_param.addWidget(le_s1); lh_param.addWidget(cb_12); */ lh_param.addWidget(le_s2);  
        lh_param.addWidget(lb_capt2); lh_param.addWidget(le_s3); lh_param.addWidget(cb_23);  lh_param.addWidget(le_s4);
        cb_12.setText(new QString("или")); cb_23.setText(new QString("или"));
        // Соберем кнопки
        lh_button.addWidget(kn_Find);
        lh_button.addWidget(kn_Edit);
        lh_button.addWidget(kn_Word);
        lh_button.addWidget(kn_Excel);
        // Соберем вертикальный выравниватель
        lv_main.addLayout(lh_param);
        lv_main.addWidget(te_list);
        lv_main.addWidget(prb_prog);
        lv_main.addLayout(lh_button);
        
        wd_main.setLayout(lv_main);
        
        setCentralWidget(wd_main);
        setStatusBar(sb_pbar);
        
        // Привяжем кнопку
        gSlot slotknFind = new gSlot(); 
        slotknFind.setSlot(0, &onKnFind);  // Установить обработчик на Кнопку
        connect(kn_Find.QtObj, MSS("clicked()", QSIGNAL), slotknFind.QtObj, MSS("Slot0()", QSLOT), 1);

        gSlot slotknEdit = new gSlot(); 
        slotknEdit.setSlot(0, &onKnStop);  // Установить обработчик на Кнопку
        connect(kn_Edit.QtObj, MSS("clicked()", QSIGNAL), slotknEdit.QtObj, MSS("Slot0()", QSLOT), 1);

        gSlot slotknWord = new gSlot(); 
        slotknWord.setSlot(0, &onKnOpen);  // Установить обработчик на Кнопку
        connect(kn_Word.QtObj, MSS("clicked()", QSIGNAL), slotknWord.QtObj, MSS("Slot0()", QSLOT), 1);

        gSlot slotknDir = new gSlot(); 
        slotknDir.setSlot(0, &onOpenDir);  // Установить обработчик на Кнопку
        connect(kn_Excel.QtObj, MSS("clicked()", QSIGNAL), slotknDir.QtObj, MSS("Slot0()", QSLOT), 1);
        
        // Напишем заголовок окна.
        QString tmpQs = new QString("Использую файл индекса: ");
        QString tmpQs1 = new QString("\0");
        tmpQs1.toUnicode(cast(char*)nameFileIndex.ptr, UTF_8);
        tmpQs.append(tmpQs1);
        setWindowTitle(tmpQs);
        resize(900, 500);
        
        // Центральная строка меню
        menuBar = new QMenuBar(null);
        // Выполнители
        act11 = new QAction(null);  act21 = new QAction(null);
        act12 = new QAction(null);  act22 = new QAction(null);
        act13 = new QAction(null);  act23 = new QAction(null);
        act14 = new QAction(null);
        act15 = new QAction(null);
        // Вертикальное меню
        menu11 = new QMenu(null);   menu12 = new QMenu(null);  
        tmpQs.toUnicode("Действия", UTF_8); menu11.setTitle(tmpQs);
        tmpQs.toUnicode("Помощь", UTF_8); menu12.setTitle(tmpQs);
        
        menu11.addAction(act11); tmpQs.toUnicode("Поиск", UTF_8);           act11.setText(tmpQs); // act11.onClick(&onKnFind);
        act11.setHotKey(QtE.Key.Key_F5 /*QtE.Key.Key_ControlModifier + QtE.Key.Key_Enter*/);   act11.onClick(&onKnFind);

        menu11.addAction(act12); tmpQs.toUnicode("Стоп", UTF_8);            act12.setText(tmpQs); // act11.onClick(&onKnFind);
        act12.setHotKey(QtE.Key.Key_Escape);   act12.onClick(&onKnStop);
        menu11.addAction(act13); tmpQs.toUnicode("Открыть файл", UTF_8);    act13.setText(tmpQs); // act11.onClick(&onKnFind);
        act13.setHotKey(QtE.Key.Key_F6);   act13.onClick(&onKnOpen);
        menu11.addAction(act14); tmpQs.toUnicode("Открыть папку", UTF_8);   act14.setText(tmpQs); // act11.onClick(&onKnFind);
        act14.setHotKey(QtE.Key.Key_F7);   act14.onClick(&onOpenDir);
        menu11.addSeparator();
        menu11.addAction(act15); tmpQs.toUnicode("Выход", UTF_8);           act15.setText(tmpQs); // act11.onClick(&onKnFind);
        act21.setHotKey(QtE.Key.Key_F1);

        menu12.addAction(act21); tmpQs.toUnicode("Инструкция", UTF_8);      act21.setText(tmpQs); // act11.onClick(&onKnFind);
        act21.setHotKey(QtE.Key.Key_F1); act21.onClick(&onF1);
        menu12.addSeparator();
        menu12.addAction(act22); tmpQs.toUnicode("О Программе", UTF_8);     act22.setText(tmpQs); // act11.onClick(&onKnFind);
        act22.onClick(&onAboutProgram);
        menu12.addAction(act23); tmpQs.toUnicode("О Qt", UTF_8);            act23.setText(tmpQs); // act11.onClick(&onKnFind);
        act23.onClick(&onAboutQt);
        menuBar.addMenu(menu11);        
        menuBar.addMenu(menu12);        
        // Отобразим меню
        setMenuBar(menuBar);
        // Событие на открытие окна
        // setResizeEvent(&onLoadFile);
    }
    // ----------------------------------------------------------
    void knpOpenDir() {     // Открыть каталог с файлом
        try {
            string nameProc = te_list.stringFromCell(te_list.currentRow(), 3);
            // Это реакция на кнопку открыть папку
            version(Windows) {
                auto pid = spawnProcess(["explorer", dirName(nameProc)]);
            }
            version(linux) {
                auto pid = spawnProcess(["dolphin", "--select", nameProc]);
            }
        }
        catch { msgbox("Осуществите поиск и укажите файл."); }
    }
    // ----------------------------------------------------------
    void knpWord() {        // Открыть файл в редакторе
        try {
            string nameProc = te_list.stringFromCell(te_list.currentRow(), 3);
            version(Windows) {
                auto pid = spawnShell('"' ~ nameProc ~ '"');
            }
            version(linux) {
                auto pid = spawnProcess(["kwrite", nameProc]);
            }
        }
        catch { msgbox("Осуществите поиск и укажите файл."); }
    }
    // ----------------------------------------------------------
    void loadIndex() {      // Прочитать файл в память
        bool f = true;
        bool fLoad;         // Проверка на правильность структуры индексного файла
        StNameFile el; 
        
        void ErrMessage() {
            msgbox("Файл индекса поврежден или не найден!","Внимание!",QMessageBox.Icon.Critical);
            QString qstr = new QString("Файл индекса поврежден или не найден!"); 
            sb_pbar.showMessage(qstr);
        }
        // Прочитаем исходный файл
        if(!exists(nameFileIndex)) { ErrMessage(); }
        File fIndex = File(nameFileIndex, "r");
        int i;
        foreach(line; fIndex.byLine()) {
            if(i==i++/wr*wr) app.processEvents();
            if(line == "#####") {
                f = false; fLoad = true;
            }
            else {
                if(f) {
                    mPath ~= line.dup;
                }
                else {
                    el.FullPath = to!int(Split1251(line, razd, 0)); 
                    el.NameFile = Split1251(line, razd, 1) ~ 0;
                    mName ~= el;
                }
            }
        }
        // --------------------------
        if(fLoad) {
            string frase = format("Загружено: каталогов %s,  файлов %s", mPath.length, mName.length);
            QString qstr = new QString();   qstr.toUnicode(cast(char*)(frase ~ 0 ~ 0).ptr, UTF_8);  
            sb_pbar.showMessage(qstr);
            prb_prog.setValue(0);
        }
        else {
            ErrMessage();
        }
    }
    // ----------------------------------------------------------
    void knpStop() {
        runFind = false;
    }
    // ----------------------------------------------------------
    void ViewStrs() {              // Искать вхождения строк
		size_t indTab;		// строка в таблице
        size_t n; char[] strNames;
        QString qstr = new QString();
        bool pb1, pb2, pb3, pb4;
        bool b1, b2, b3, b4;
        char[] str_cmp1, str_cmp2, str_cmp3, str_cmp4;
        char[] str_empty = cast(char[])"";
        string str_compare;
        
        mNamelength = cast(int)mName.length-1; // Для ProgressBar
        // Подготовим аргументы сравнения
        QString qstr_compare = new QString();
        
        le_s1.text(qstr_compare); 
        if(qstr_compare.size == 0) { str_cmp1 = str_empty;  pb1 = false; } 
        else { str_cmp1 = toUpper1251(cast(char[])qstr_compare.fromUnicode(str_compare, WIN_1251)) ~ 0; pb1 = true;  }

        le_s2.text(qstr_compare); 
        if(qstr_compare.size == 0) { str_cmp2 = str_empty;  pb2 = false; } 
        else { str_cmp2 = toUpper1251(cast(char[])qstr_compare.fromUnicode(str_compare, WIN_1251)) ~ 0; pb2 = true;  }
        
        le_s3.text(qstr_compare); 
        if(qstr_compare.size == 0) { str_cmp3 = str_empty;  pb3 = false; } 
        else { str_cmp3 = toUpper1251(cast(char[])qstr_compare.fromUnicode(str_compare, WIN_1251)) ~ 0; pb3 = true;  }

        le_s4.text(qstr_compare); 
        if(qstr_compare.size == 0) { str_cmp4 = str_empty;  pb4 = false; } 
        else { str_cmp4 = toUpper1251(cast(char[])qstr_compare.fromUnicode(str_compare, WIN_1251)) ~ 0; pb4 = true;  }

        prb_prog.setMinimum(0);   prb_prog.setMaximum(mNamelength);
        int j;
        te_list.setRowCount(0);
        
        void PrintEk(StNameFile el) {
			
 			if(el.NameFile.length > 0) if(el.NameFile[$-1] == 0) el.NameFile = el.NameFile[0..$-1]; 
			char[] chM_shortName = from1251toUtf8(el.NameFile);
			char[] chM_fullName  = from1251toUtf8(mPath[el.FullPath]);
            char[] fullName = chM_fullName ~ dirSeparator ~ chM_shortName;
			// Попробуем внести сразу в таблицу
			te_list.insertRow(indTab);
			QTableWidgetItem tbNameFile = new QTableWidgetItem(to!string(chM_shortName));
			QTableWidgetItem tbFullNameFile = new QTableWidgetItem(to!string(fullName));
			te_list.setItem(tbNameFile, indTab, 0);
			te_list.setRowHeight(indTab, 20);
			// Проверим размер файла и его наличие
			ulong sizeFile; 
			bool isFileOnDisk;
 			try {
				sizeFile = std.file.getSize(fullName);
				isFileOnDisk = true;
			}
			catch {
				sizeFile = 0;
				isFileOnDisk = false;
			}
			// Файл существует
			if(isFileOnDisk) {
				QTableWidgetItem twiSize = new QTableWidgetItem(format("%10s  ", sizeFile));
				twiSize.setTextAlignment(QtE.AlignmentFlag.AlignRight | QtE.AlignmentFlag.AlignVCenter);
				te_list.setItem(twiSize, indTab, 2);
				
				SysTime atf, mtf;	getTimes(chM_fullName, atf, mtf);
				string tmpTime = format("%02s.%02s.%4s", to!int(mtf.day), to!int(mtf.month), to!int(mtf.year));
				QTableWidgetItem twiDate = new QTableWidgetItem(tmpTime);
				twiDate.setTextAlignment(QtE.AlignmentFlag.AlignCenter);
				te_list.setItem(twiDate, indTab, 1);
			}
			te_list.setItem(tbFullNameFile, indTab, 3);
			indTab++;
        }
        
        runFind = true;
        
        // Подпрограмма поиска одиночного вхождения
        void find1(char[] str_cmp) {
            bool b;
            char *uksh = cast(char*)(str_cmp).ptr;
            int i;
            foreach(el; mName) {
                if(!runFind) break;
                if(i==i++/wr*wr) { prb_prog.setValue(j); app.processEvents(); } j++;
                b = null != strstr(cast(char*)(toUpper1251(el.NameFile)), uksh);
                if(b) PrintEk(el); 
            }   
            prb_prog.setValue(mNamelength);
        }
        // Подпрограмма поиска двойного вхождения
        void find2(char[] str_cmp1, char[] str_cmp2, bool bif) {
            bool b1, b2;
            char *uksh1 = cast(char*)(str_cmp1).ptr;
            char *uksh2 = cast(char*)(str_cmp2).ptr;
            int i;
            foreach(el; mName) {
                if(!runFind) break;
                if(i==i++/wr*wr) { prb_prog.setValue(j); app.processEvents(); } j++;
                b1 = null != strstr(cast(char*)(toUpper1251(el.NameFile)), uksh1);
                b2 = null != strstr(cast(char*)(toUpper1251(el.NameFile)), uksh2);
                if(bif) {
                    if(b1 | b2) PrintEk(el);
                }
                else    {
                    if(b1 & b2) PrintEk(el);
                }
            }
            prb_prog.setValue(mNamelength);
        }
        
        // Начнем поиск и сравнение
        if(!pb4 & !pb3 & !pb2 & !pb1) {
            goto M1;
        }
        if(pb4 & !pb3 & !pb2 & !pb1) {
            find1(str_cmp4);
            goto M1;
        }
        if(!pb4 & pb3 & !pb2 & !pb1) {
            find1(str_cmp3);
            goto M1;
        }
        if(pb4 & pb3 & !pb2 & !pb1) {
            if(cb_23.isChecked()) {   // Или
                find2(str_cmp3, str_cmp4, true);
            }
            else {                    // И
                find2(str_cmp3, str_cmp4, false);
            }
            goto M1;
        }
//-----------------------
        if(!pb4 & !pb3 & pb2) {
            int i;
            char *uksh = cast(char*)(str_cmp2).ptr;
            foreach(el; mName) {
                if(!runFind) break;
                if(i==i++/wr*wr) { prb_prog.setValue(j); app.processEvents(); } j++;
                // char[] pf = mPath[el.FullPath].dup;
                b2 = null != strstr(cast(char*)(toUpper1251(mPath[el.FullPath]) ~ 0), uksh);
                if(b2)  {
                    PrintEk(el);
                }
            }   
            goto M1;
        }
        if(pb4 & !pb3 & pb2) {
            int i;
            char *uksh2 = cast(char*)(str_cmp2).ptr;
            char *uksh4 = cast(char*)(str_cmp4).ptr;
            foreach(el; mName) {
                if(!runFind) break;
                if(i==i++/wr*wr) { prb_prog.setValue(j); app.processEvents(); } j++;
                b2 = null != strstr(cast(char*)(toUpper1251(mPath[el.FullPath]) ~ 0), uksh2);
                b4 = null != strstr(cast(char*)(toUpper1251(el.NameFile)), uksh4);
                if(b2 & b4)  {
                    PrintEk(el);
                }
            }   goto M1;
        }
        
        if(!pb4 & pb3 & pb2) {
            int i;
            char *uksh2 = cast(char*)(str_cmp2).ptr;
            char *uksh3 = cast(char*)(str_cmp3).ptr;
            foreach(el; mName) {
                if(!runFind) break;
                if(i==i++/wr*wr) { prb_prog.setValue(j); app.processEvents(); } j++;
                b2 = null != strstr(cast(char*)(toUpper1251(mPath[el.FullPath]) ~ 0), uksh2);
                b3 = null != strstr(cast(char*)(toUpper1251(el.NameFile)), uksh3);
                if(b2 & b3)  {
                    PrintEk(el);
                }
            }   goto M1;
        }
        if(pb4 & pb3 & pb2) {
            if(cb_23.isChecked()) {   // Или
                int i;
                if(i==i++/wr*wr) { prb_prog.setValue(j); app.processEvents(); } j++;
                char *uksh4 = cast(char*)(str_cmp4).ptr;
                char *uksh2 = cast(char*)(str_cmp2).ptr;
                char *uksh3 = cast(char*)(str_cmp3).ptr;
                foreach(el; mName) {
                    if(!runFind) break;
                    if(i==i++/wr*wr) { prb_prog.setValue(j); app.processEvents(); } j++;
                    b2 = null != strstr(cast(char*)(toUpper1251(mPath[el.FullPath]) ~ 0), uksh2);
                    b3 = null != strstr(cast(char*)(toUpper1251(el.NameFile)), uksh3);
                    b4 = null != strstr(cast(char*)(toUpper1251(el.NameFile)), uksh4);
                    if((b3 | b4) & b2)  {
                        PrintEk(el);
                    }
                }
            }
            else {                    // И
                int i;
                if(i==i++/wr*wr) { prb_prog.setValue(j); app.processEvents(); } j++;
                char *uksh4 = cast(char*)(str_cmp4).ptr;
                char *uksh2 = cast(char*)(str_cmp2).ptr;
                char *uksh3 = cast(char*)(str_cmp3).ptr;
                foreach(el; mName) {
                    if(!runFind) break;
                    if(i==i++/wr*wr) { prb_prog.setValue(j); app.processEvents(); } j++;
                    b2 = null != strstr(cast(char*)(toUpper1251(mPath[el.FullPath]) ~ 0), uksh2);
                    b3 = null != strstr(cast(char*)(toUpper1251(el.NameFile)), uksh3);
                    b4 = null != strstr(cast(char*)(toUpper1251(el.NameFile)), uksh4);
                    if((b3 & b4) & b2)  {
                        PrintEk(el);
                    }
                }
            }
            goto M1;
        }

M1:
    // if(!runFind)  prb_prog.setValue(0);
    prb_prog.setValue(mNamelength);
    }
} 
 
int main(string[] args) {
    // Проверим режим загрузки. Если есть '--debug' старт в отладочном режиме
    bool fDebug; fDebug = false; 
    foreach(i, arg; args)  { 
        if(arg=="--debug") { fDebug = true; continue; }
        if(i>0)  nameFileIndex = arg;
    }
    if(nameFileIndex=="") nameFileIndex = "index.txt";
    
    // Загрузка графической библиотеки
    int rez = LoadQt( dll.Core | dll.Gui | dll.QtE, fDebug); if (rez==1) return 1;  // Ошибка загрузки библиотеки
    app = new QApplication(&Runtime.cArgs.argc, Runtime.cArgs.argv, 1); 
    // ----------------------------------
    // Инициализация внутренних перекодировок, для QtE
    UTF_8 = new QTextCodec("UTF-8");    WIN_1251 = new QTextCodec("Windows-1251");
    tmpQs = new QString();
    // ----------------------------------
    wd_Main = new ClassMain();  
    wd_Main.show();
    
    try {
            wd_Main.loadIndex();
    }
    catch { }
    // ----------------------------------
    return app.exec();
}
 
