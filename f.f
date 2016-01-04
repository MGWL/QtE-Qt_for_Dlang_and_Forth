1 2 3 4 5 

// Примем адрес таблицы методов Qt
// 0 COMMONADR@ CONST АдресТаблицыМетодовQt

// Примем адрес экземпляра объекта w1 (QWidget)
// 1 COMMONADR@ CONST АдресW1obj

// Получить адрес функции Qt из массива pFunQt[], содержащим
// некотоые адреса методов их QtGui.dll (so)
// : МетодQt  // ( Nв_табл -- Aфункqt ) Получить адрес функции Qt 
    // CELL * АдресТаблицыМетодовQt + @ ;

// Моделируем вызов  D: w1.show();
// что фактически есть: (5 МетодQt)(QtObj, f); -- вызов функции с 2 параметрами 
// : ShowW1
    // TRUE       >R           // второй параметр
    // АдресW1obj >R    // Указатель на объект w1 (QWidget) в стек (фактически push АдресW1obj) 
    // 5 МетодQt CALL_CDECL   // w1.setVisible(TRUE); - вызов функции из Qt
    // R> DROP                 // очистим стек от парамера (АдресW1obj), после вызова функции Qt
    // R> DROP                 // очистим стек от парамера (АдресW1obj), после вызова функции Qt
    // DROP                      // очистим стек от Ret_CALLD
    // ;

// IF=L ShowW1 S" This Linux Return from w1.setVisible(TRUE):"     1+ TYPE .
// IF=W ShowW1 S" This Windows Return from w1.setVisible(TRUE):" 1+ TYPE .

// Работа с функциями DLL. Использует структуру даных двух типов: 
// library - начало списка, адрес загруженной DLL
// call - адрес функции и указатель на след в списке
1 CONST LibraryLoad    // Загрузить DLL и загрузить функции в связанном списке
2 CONST Library@       // Выдать адрес структуры Library
// Создаёт слово для создания активных слов загрузки динамич библиотек
// Использование:  Library" fqt.dll" fqt   // создать слово fqt
//                 LibraryLoad fqt         // загрузить библиотеку и иниц список функций
// Внутренняя структура library:
//  +----------- CELL ----------+----------- CELL ------------------+---- длина + 0 в конце --+
//  | адрес загрузки библиотеки | Указатель на слова функций        | имя библиотеки (ascciz) |
//  +---------------------------+-----------------------------------+-------------------------+
: ASCIIZ" [CHAR] " WORD DUP B@ 1+ 1+ ALLOT ; // ( Слово_из_потока -- Astrz ) вставить строку и обойти

// : CONST CREATE COMPILE (CREATE) , DOES> @ ;

VAR AdrStruc
VAR a1
VAR a2

: Lib"                                                // "
    HERE >R 0 HERE ! CELL ALLOT 0 HERE ! CELL ALLOT   // выделить две ячейки и занулить их
    ASCIIZ" DROP                                      // "сохранение имени DLL
    R> CREATE COMPILE (CREATE) ,
  DOES> @
    SWAP DUP                                          // Анализируем параметр
    1 = IF DROP                                       // Идем по списку, грузим адреса функций
            DUP 2 CELL * + 1+                         // Alibrary Astrz без байта длины
IF=W        >R LOADLIBRARYA CALL_CDECL RDROP DROP
            DUP 0 = 
            IF S" Error load DLL " 1+ TYPE DROP 2 CELL * + 1+ TYPE EXIT THEN
            // В этом месте уже есть адрес загруженной DLL
            DUP >R OVER !                // Сохраним адр загруженной DLL в структуре и в SP                                    
            CELL + @                     // Берем структуру Call по указателю
            // Если функции для этой библ не определены УказНаСлова=0 то выйти
            DUP 0 = IF DROP RDROP EXIT THEN
            // В этот момент на стеке Astruk
            BEGIN  
                // ---- Грузим функции из списка ---------
                DUP 4 CELLS + 1+ DUP >L R@ //  Acall Aстроки Adll
IF=W            SWAP >R >R GPADRESS CALL_CDECL DROP
                DUP 0 = IF DROP S" Error find function: " 1+ TYPE L> TYPE EXIT
                        ELSE L> DROP    // Найден адрес
                        THEN
                OVER !                  //  Сохраним адрес функции в структуре Call
                // ---------------------------------------
                2 CELLS + @ DUP 0 =     // След структура в списке или последняя
            UNTIL DROP
            RDROP
        ELSE
            2 = IF ELSE S" Error parametr for Library" 1+ TYPE . THEN
        THEN
    ;
// Создаёт слово для работы с адресом функции DLL и выполнением вызова
// Перед использованием необходима инициализация:  LibraryLoad fqt   // загрузить библиотеку и иниц
// Использование: Library@ fqt #Кол_вход_параметров CDECL-Call" QT_App" QT_App  // Добавить в список вызова
// Вызов функции:          аргументы  QT_App  // Перед 
// Внутренняя структура call:
//  +--- CELL ------+------ CELL ------+----- CELL --------+-----CELL ----+-- длина + 0 в конце --+
//  | адрес функции | Кол входн парам  | адрес след или 0  | тип вызова   | имя функции (ascciz)  |
//  +---------------+------------------+-------------------+--------------+-----------------------+
//
: _-Call"   // "( Aструкт_library #Кол_параметров #типвызова -- )
    HERE DUP >L >R 0 HERE ! CELL ALLOT SWAP HERE ! CELL ALLOT
    R@ 3 CELLS + ! R@ SWAP CELL + DUP   // A H4 H4 
    >R @ HERE ! R> ! 2 CELLS ALLOT ASCIIZ" DROP    // " сохранение имени вызываемой функции
    R> CREATE COMPILE (CREATE) , 
  DOES> @
    DUP >R 3 CELLS + @ 
    DUP 1 = IF DROP R> DUP CELL + @ SWAP @
                >L      // Сохраним адрес вызова
                DUP 1 = IF DROP   // 1 Параметр на входе
                            >R L> CALL_CDECL RDROP DROP
                        ELSE
                DUP 2 = IF DROP   // 2 параметра на входе
                            >R >R L> CALL_CDECL RDROP RDROP DROP
                        ELSE
                            DROP L> DROP
                        THEN
                        THEN
            ELSE
  // DUP 11 = IF DROP R> @  C-EXEC        // CDECL для N аргументов
      // ELSE
  // DUP 2 = IF DROP R> DUP CELL + @ SWAP @  PAS-EXEC           // STDCAL/WINAPI
      // ELSE
  // DUP 12 = IF DROP R> @  PAS-EXEC      // STDCAL/WINAPI для N арг
      // ELSE
  // DUP 4 = IF DROP R> DROP // Отключить VC DUP CELL + @ SWAP @  THIS-CDECL-CALL-ECX    // По типу MS VC
      // ELSE
  // DUP 5 = IF DROP R> DUP CELL + @ 1+ SWAP @ C-EXEC
      // ELSE
  // DUP 3 = IF DROP R> @                                       // GLOBAL Extern
  // THEN
  // THEN
  // THEN
  // THEN
          // THEN
          // THEN
            THEN
    ;      
: CDECL-Call" 1 _-Call" ;
// Library@ user32 3 WINAPI-Call" GetWindowTextA" GetWindowText

Lib" CRTDLL.DLL" CrtDll
Library@ CrtDll 1 CDECL-Call" strlen"  strlen
Library@ CrtDll 2 CDECL-Call" strcmp"  strcmp
Library@ CrtDll 1 CDECL-Call" strncmp" strncmp
LibraryLoad CrtDll

S" ABC" 1+ S" ABC" 1+ strcmp .
. . .

// LibraryLoad CrtDll


// TestLoadDLL  // ( Astrz -- 0/Ahendl ) Загрузить в память нужную библиотеку 
    // IF=W >R LOADLIBRARYA CALL_CDECL  R> DROP  DROP
    // ;
// : TestGetProcAdres  // ( Astrz Ahendl -- 0/Afunc )
    // IF=W SWAP >R >R GPADRESS CALL_CDECL R> DROP DROP
    // ;

// S" CRTDLL.DLL" 1+ TestLoadDLL
// CONST CrtDll   // Это handl CrtDll
// S" strlen" 1+ CrtDll TestGetProcAdres
// CONST adrStrLen

// : strlen   // ( Astrz -- Nдлина ) Длина строки
    // >R adrStrLen CALL_CDECL R> DROP DROP
    // ;
// S" ABCD" 1+  strlen

// : LoadDLL      //  Загрузка SO  или  DLL  в память ( 0/As  --  H/creat )
// if=W    1+ llibrary creat , does> 
// if=W    over if @ swap 1+ gpaddres else @ swap drop then ;
// "lib.dll" LoadDLL libdll "funk1" libdll const adr-funk1


// ' ShowW1 
// EXECUTE DROP  // Очистим возврат из функции

// . . . . .
