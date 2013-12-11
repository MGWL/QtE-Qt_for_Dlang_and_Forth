#!/bin/bash
OPTS="-c -pipe -Wall -W -D_REENTRANT -DQT_GUI_LIB -DQT_CORE_LIB -DQT_SHARED -fPIC"
#Change this path according to your distro features, e.g. in case of ALT Linux IQT4="-I/usr/include/qt4"
IQT4="-I/usr/include"
INCL="-I. -I/usr/lib/qt4/mkspecs/linux-g++ $IQT4 $IQT4/QtCore $IQT4/QtGui $IQT4/QtScript $IQT4/QtWebKit $IQT4/QtNetwork"
LIBS="-lQtCore -lQtGui -lQtScript -lQtWebKit -lQtNetwork -lpthread"


g++ $OPTS $INCL qte.cpp
moc-qt4 -o moc_qte.cpp qte.h
g++ $OPTS $INCL moc_qte.cpp
g++ -shared -o QtE.so.1.0.0 qte.o moc_qte.o $LIBS

