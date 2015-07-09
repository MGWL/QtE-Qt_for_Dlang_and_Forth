/**
 * Быстрый поиск в именах файлов Win 32/64, Linux 32/64
 *
 * MGW 26.04.2014 18:56:44
 *
 * Программа состоит из двух частей:
 *
 * ffc.exe - Консольная. Создаёт индексый файл.
 * ff.exe  - GUI. Поиск по индексному файлу и визуализация.
 *
 * Компиляция Linux 32/64 где -mXX соответственно -m32 или -m64:
 *
 * dmd ff.d asc1251.d qte.d -mXX -release -O -L-ldl -offf.exe
 * dmd ffc.d asc1251.d -mXX -release -O -L-ldl -offfc.exe
 *
 * Компиляция Windows 32/64 где -mXX соответственно -m32 или -m64:
 *
 * dmd ff.d asc1251.d qte.d -mXX -release -O -offf.exe
 * dmd ffc.d asc1251.d -mXX -release -O -offfc.exe
  *
 */

import std.file;
import std.stdio;
import std.path;
import asc1251;

string  dirs[];                 // Список точек входа для индексации
string  nameFileIndex;          // Имя файла индекса
size_t  vec[1000];              // вектор кеша на строки до 1000 символов 

struct StNameFile {
    size_t      FullPath;       // Полный путь из массива mPath
    char[]      NameFile;       // Имя файла
}
StNameFile mName[];             // массив имен файлов

char[]  mPath[];                // массив Путей. Номер соответствует полнуму пути
size_t  iPath[];                // Массив списка длинн

void help() {
    writeln();
    writeln("usage: ffc NameFileIndex.txt Dir1 Dir2 ...");
    writeln("------------------------------------------");
    writeln(`ffc index.txt C:\windows D:\ E:\  ---> Example for Windows`);
    writeln(`./ffc index.txt / ---> Start with root user. Example for Linux`);
}

int main(string[] args) {
    char[] nameFile, pathFile; 
    
    foreach (i, arg; args)  { 
        switch(i) {
            case 0:         // Имя программы
                break;
            case 1:         // Имя файла индекса
                nameFileIndex = arg;    break;
            default:
                dirs ~= arg;            break;
        }
    }
    // Проверка имени индекса
    if(nameFileIndex.length == 0) { writeln("Error: Not name file index");  help(); return 1;  }
    // Проверка точек входа
    if(dirs.length == 0) {  writeln("Error: Not dir for index");  help(); return 2;    }
    
    size_t predNom; char[] predPath;                   // Ускоритель
    
    // Вернуть номер пути из массива
    size_t getNomPath(char[] path) {      
        size_t rez, i; bool f = false;
        size_t dlPath = path.length;   // Длина пути уже известна, отлично!
        if(predPath == path)  return predNom;
            
        // Взять длину и посмотреть, если там == 0, то выйти и добавить
        if(vec[dlPath] > 0) {
            size_t nomTest = vec[dlPath] - 1;
            for(;nomTest != 0;) {
                if(path == mPath[nomTest]) {  
                    rez = nomTest; f = true;            // Найдено!!!
                    predPath = path; predNom = rez;     // Запомним в ускорителе
                    break;  
                }  
                else {
                    nomTest = iPath[nomTest];           // Ищем дальше ...
                    if(nomTest>0) nomTest--; 
                }
            }
        }
        
        if(!f) {    // Ни чего не найдено, надо создавать запись
            mPath ~= path;                              // Добавить путь в массив
            rez = mPath.length-1;                       // Запомним новый размер
            // нужно сделать объмен с кешом
            iPath ~= vec[dlPath]; vec[dlPath] = rez + 1;
        }
        return rez;
    } // end getNomPath -----------------------------
    
    File fError = File("err" ~ nameFileIndex, "w");
    foreach(nameDir; dirs) {
        // Формируем массивы mPath и iPath
        try {
            // Здесь обрабатываем точки входа
            auto p = dirEntries(nameDir, SpanMode.depth, false);
            while(!p.empty) {
                try  {
                    auto name = p.front;
                    char[] tmpName = cast(char[])name;
                    if(!isDir(tmpName)) {
                        pathFile = fromUtf8to1251(dirName(tmpName));
                        nameFile = fromUtf8to1251(baseName(tmpName));
                        size_t nom = getNomPath(pathFile);
                        // Добавить элемент в массивы
                        StNameFile el; el.FullPath = nom; el.NameFile = nameFile; mName ~= el;
                    }
                    p.popFront();  // NEXT
                }
                catch(Exception e)  {
version(Windows) {
                    fError.writeln(fromUtf8to1251(cast(char[])e.msg), "  - while()");
}
version(linux) {
                    fError.writeln(e.msg, "  - while()");
}					
                    p.popFront();  // NEXT
                }
            }
        }
        catch(Exception ee) {   
version(Windows) {
            fError.writeln(fromUtf8to1251(cast(char[])ee.msg), "  - dirEntries()");
}	
version(linux) {
            fError.writeln(ee.msg, "  - dirEntries()");
}	
        }    
    }
    // Массивы построены. Сохраняем в файл.
    File fIndex = File(nameFileIndex, "w");
    foreach(el; mPath) { fIndex.writeln(el); }
    fIndex.writeln("#####");
    foreach(el; mName) { fIndex.writeln(el.FullPath, "|", el.NameFile); }
    
    return 0;
}
