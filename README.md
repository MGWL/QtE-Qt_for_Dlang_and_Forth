QtE
===

Qt gui library for Dlang (dmd D2).

Qt wrapper for the D language (dmd D2 dlang) and Forth (SPF-4.20) language.

This works in Windows 32 and Linux 32 / 64 

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

<p align="center"></p><h3>The real application. Search for duplicates of enterprises. Written in D + QtE.d</h3><p></p>
<p>Notice the simplicity of the compilation and link.</p>
<table border="2" bordercolor="#0000FF" align="center">
 <tbody><tr> 
 <td> 
 <p><a href="http://qte.ucoz.ru/QtE_win_1.png"><img alt="Windows7" src="http://qte.ucoz.ru/QtE_win_1.png" width="340" height="255" border="0"></a></p>
 </td>
 <td>
-
 </td>
 <td> 
 <p><a href="http://qte.ucoz.ru/QtE_linux_1.png"><img alt="Linux Fedora 18" src="http://qte.ucoz.ru/QtE_linux_1.png" width="340" height="255" border="0"></a></p>
 </td>
 </tr>
 <tr> 
 <td> 
 <div align="center"><font size="-1">Windows 7</font></div>
 </td>
 <td>
-
 </td>
 <td> 
 <div align="center"><font size="-1">Linux Fedora 18</font></div>
 </td>
 </tr>
 </tbody></table>
