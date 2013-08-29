// +----------------------------------------------------------------+
// | QtE (wrapping QT for SPF and D)                               |
// | MGW,  22.07.13 14:12                                           |
// +----------------------------------------------------------------+


#ifndef QTE_H
#define QTE_H

// Delete comment for Windows and set for Linux
#define WINDOWSF
// #define LINUXF
// -------------------------------------------

#ifdef LINUXF
  #include <QApplication>
  #include <QPushButton>
  #include <QTextEdit>
  #include <QLineEdit>
  #include <QTextCodec>
  #include <QMessageBox>
  #include <QtGui>
#endif

#ifdef WINDOWSF
  #include "qte_global.h"
  #include <stdio.h>

  #include <QtGui\QApplication>
  #include <QtGui\QPushButton>
  #include <QtGui\QTextEdit>
  #include <QtGui\QLineEdit>
#endif

#define FQT_API QTESHARED_EXPORT

typedef void (*ExecZIM_1_0)( void* );   
typedef void (*ExecZIM_0_0)( void  );

#ifdef LINUXF
   // extern "C" char NameCodec[80] = "UTF-8\0";  // для Linux
#endif

#ifdef WINDOWSF
    // extern "C" FQT_API char NameCodec[80] = "Windows-1251\0";  // Для Windows
#endif

class eSlot : public QObject
{
    Q_OBJECT
public:
    void* aSlot0;       // save adr D function
    eSlot(QObject* parent = 0);
    ~eSlot();
    void sendSignal0();
public slots:
    void Slot0();
signals:
    void Signal0();
};

class eQWidget : public QWidget
{
    Q_OBJECT
public:
    void* aOnResize;
    eQWidget( QWidget* parent = 0 );
    ~eQWidget();
    void resizeEvent( QResizeEvent *a );
};
extern "C" eQWidget* p_eQWidget(QWidget*);


#endif // QTE_H


