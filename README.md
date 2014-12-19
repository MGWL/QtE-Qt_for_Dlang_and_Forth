QtE
===

Qt gui library for Dlang (dmd D2).

Qt wrapper for the D language (dmd D2 dlang) and Forth (SPF-4.20) language.

This works in Windows 32/64 and Linux 32/64. 

This is a small study library to work with Qt. It uses dynamic linking and easy to use. 
It works on Windows and Linux. The way it works is simple: through the modules 
QtE.d (D) or QtE.f (Forth), take all necessary methods and properties of Qt, references to objects 
created using QtE.DLL(so) in C++. This method allows reducing programming in C++ to a minimum, 
making the QtE library.

Compile Windows:
  `dmd XXX.d qte.d`

Compile Linux:
  `dmd XXX.d qte.d -L-ldl`

Home page: http://qte.ucoz.ru

<b>Important!</b> For detailed explanations and receptions of the newest versions write to mgw@yandex.ru

This link:
http://yadi.sk/d/l4rd7-QPHdpHM
will help you can upload a set of ready DLL (so) to test the QtE. The archive contains the minimum set of ready files for Qt and QtE for Windows 32 and Linux 32. This will allow you to test QtE without installing Qt on your PC. Just copy the DLL (so) in your directory dmd/windows/bin or dmd/linux/bin32 and work with QtE.

<p align="center"></p><h3>The real application. Search for duplicates of enterprises.</h3><p></p>
<p align="center"></p><h4>Written in <b>D + QtE.d</b></h4><p></p>
<p>Notice the simplicity of the compilation and link.</p>
<table border="2" bordercolor="#0000FF" align="center">
 <tbody><tr> 
 <td> 
 <p><a href="http://qte.ucoz.ru/QtE_win_1.png"><img alt="Windows 7 (Qt 4.5.2)" src="http://qte.ucoz.ru/QtE_win_1.png" width="340" height="255" border="0"></a></p>
 </td>
 <td>
-
 </td>
 <td> 
 <p><a href="http://qte.ucoz.ru/QtE_linux_1.png"><img alt="Linux Fedora 18 (Qt 4.8)" src="http://qte.ucoz.ru/QtE_linux_1.png" width="340" height="255" border="0"></a></p>
 </td>
 </tr>
 <tr> 
 <td> 
 <div align="center"><font size="-1">Windows 7 (Qt 4.5.2)</font></div>
 </td>
 <td>
-
 </td>
 <td> 
 <div align="center"><font size="-1">Linux Fedora 18 (Qt 4.8)</font></div>
 </td>
 </tr>
 </tbody></table>
