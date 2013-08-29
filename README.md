QtE
===

Qt wrapper for the D language (dmd D2 dlang) and Forth (SPF-4.20) language. 

The idea is suitable for any language generating executable code:

+--------------+   +-------------+                   +------- Qt -----+
| Program on D |   | QtE.d for D |------------------>| QtCore.DLL(so) |
|              |-->| or QtE.f    |                   | QtGui.DLL(so)  |
|   or Forth   |   |  for Forth  |--> QtE.DLL(so) -->|      .....     |
+--------------+   +-------------+      on C++       +----------------+
