g++ -c -pipe -Wall -W -D_REENTRANT -DQT_GUI_LIB -DQT_CORE_LIB -DQT_SHARED -I/usr/lib/qt4/mkspecs/linux-g++ -I. -I/usr/include -I/usr/include/QtCore -I/usr/include/QtGui -I/usr/include/QtScript -fPIC qte.cpp
moc-qt4 -o moc_qte.cpp qte.h
g++ -c -pipe -Wall -W -D_REENTRANT -DQT_GUI_LIB -DQT_CORE_LIB -DQT_SHARED -I/usr/lib/qt4/mkspecs/linux-g++ -I. -I/usr/include -I/usr/include/QtCore -I/usr/include/QtGui -I/usr/include/QtScript -fPIC moc_qte.cpp
g++ -shared -o QtE.so.1.0.0 qte.o moc_qte.o -lQtCore -lQtGui -lQtScript -lpthread
