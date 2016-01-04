1 2 3 4 5 

S" stdlib.f" 1+ INCLUDED // Загрузить стандартную библиотеку

// поместить на вершину стека данных значение сетчика команд процессора RDTC
: TIMER@ // ( --> ud )
    [ 137 B, 69 B, 252 B, 15 B, 49 B, 137 B,
    85 B, 248 B, 141 B, 109 B, 248 B, 135 B, 69 B, 0 B, ] ;
: (measure) // ( xt --> dt ) // измерить длительность исполнения слова, представленного своим xt
    TIMER@ >R >R EXECUTE TIMER@ R> R> DROP SWAP DROP - ;

// Проверим Windows
IF=W Lib" CRTDLL.DLL" CrtDll
IF=W Library@ CrtDll 1 CDECL-Call" strlen"  strlen
IF=W Library@ CrtDll 2 CDECL-Call" strcmp"  strcmp
IF=W Library@ CrtDll 1 CDECL-Call" strncmp" strncmp
IF=W Library@ CrtDll 2 CDECL-Call" fputc"   putc
IF=W Library@ CrtDll 1 CDECL-Call" _fputchar"   _fputchar
IF=W Library@ CrtDll 2 CDECL-Call" fputwc"   fputwc
IF=W Library@ CrtDll 2 CDECL-Call" fputs"   fputs
IF=W Library@ CrtDll 2 CDECL-Call" fputwc"   fputwc

IF=W Library@ CrtDll 1 CDECL-Call" fgetwc"   fgetwc

IF=W Library@ CrtDll 2 CDECL-Call" fopen"   fopen
IF=W Library@ CrtDll 1 CDECL-Call" fclose"  fclose
IF=W Library@ CrtDll 0 GADR-Call" _iob"  ms6_iob
// : putc >R >R 1 COMMONADR@ CALL_A RDROP RDROP DROP ;

// Проверим возможность открыть PostGres из форт
// IF=W Lib" libpq.dll" libpq
// IF=W Library@ libpq 1 CDECL-Call" PQconnectdb"    PQconnectdb
// IF=W Library@ libpq 1 CDECL-Call" PQstatus"       PQstatus
// IF=W Library@ libpq 1 CDECL-Call" PQfinish"       PQfinish
// IF=W Library@ libpq 2 CDECL-Call" PQexec"         PQexec
// IF=W Library@ libpq 1 CDECL-Call" PQresultStatus" PQresultStatus

// Проверим Linux
IF=L Lib" libc.so.6" libcSo
IF=L Library@ libcSo 1 CDECL-Call" strlen"  strlen
IF=L Library@ libcSo 3 CDECL-Call" printf"  printf
IF=L Library@ libcSo 2 CDECL-Call" putc"    putc
IF=L Library@ libcSo 2 CDECL-Call" fopen"   fopen
IF=L Library@ libcSo 2 CDECL-Call" fputs"   fputs
IF=L Library@ libcSo 1 CDECL-Call" fclose"  fclose

// Проверим Загрузку SC DLL
// IF=W Lib" g:\SC7\SAMPLES\WIN32\Q_A\SIMPLDLL\THE_DLL.DLL" CsDll
// IF=W Library@ CsDll 1 CDECL-Call" DLLFunction2"  DLLFunction2
// IF=W Library@ CsDll 1 CDECL-Call" DLLDialogBox"  DLLDialogBox
// IF=W Library@ CsDll 2 CDECL-Call" sc_fputc"   putc
// IF=W Library@ CsDll 0 CDECL-Call" sc_stdout"  sc_stdout

// Проверим загрузку MS6DLL
// IF=W Lib" g:\tmp\ms6\dll1\Release\dll1.dll" Ms6Dll
// IF=W Library@ Ms6Dll 0 CDECL-Call" ms6_stdout"  ms6_stdout

// IF=W LibraryLoad Ms6Dll
// IF=W LibraryLoad  CsDll
IF=W LibraryLoad CrtDll
IF=L LibraryLoad libcSo
// IF=W LibraryLoad libpq

S" ~~~~~~~~~~1~~~~~~~~~" 1+ TYPE

// Переменные хранящие указатли на открытые файлы 
VAR v_STDOUT        // stdout
VAR v_STDIN         // stdin
VAR v_STDERR        // stderr

IF=L (STDOUT)     v_STDOUT ! // В Linux  stdout == С++ gcc
IF=W ms6_iob 32 + v_STDOUT ! // В Winows stdout получаем непосредственно из _iob[1];
IF=W ms6_iob      v_STDIN  ! // В Winows stdin получаем из _iob[0];


// Моделирую работу с консолью через функции библиотеки stdc
: EMIT v_STDOUT @ putc DROP ; // ( N -- ) Вывод символа на стандартный вывод

: F_EMIT // ( File N -- ) Вывести символ в файл
    SWAP putc DROP ;
: CR  // ( -- ) Перевод строки
IF=W 13 EMIT
     10 EMIT
    ;
S" ----------2---------" 1+ TYPE CR

: F_CR  // ( File -- ) Перевод строки
    >R
IF=W R@ 13 F_EMIT
     R@ 10 F_EMIT RDROP
    ;
S" ----------3---------" 1+ TYPE CR
: TYPE  // ( Astrz N -- ) Напечатать строку
    DUP B@ BEGIN DUP WHILE SWAP 1+ DUP B@ EMIT SWAP 1- REPEAT DROP DROP ;
S" ----------4---------" TYPE CR
: F_TYPE // ( File Astrz -- ) Напечатать строку в файл
    SWAP >R DUP B@ BEGIN DUP WHILE SWAP 1+ DUP B@ R@ SWAP F_EMIT SWAP 1- REPEAT
    DROP DROP RDROP ;
S" ----------5---------" TYPE CR
: PUTS 1+ v_STDOUT @ fputs DROP ;

// Проверим компиляцию
: Проверка
    S" Hello" TYPE 32 EMIT S" pipels!" TYPE CR
    S" _______________________________" TYPE CR
    ;
: t 100 0 DO I . CELL +LOOP ;

. . . . .

