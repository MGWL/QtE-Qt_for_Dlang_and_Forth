// +----------------------------------------------------------------+
// | Проект QtE (wrapping QT for SPF and D)                         |
// | MGW,  22.07.13 14:12                                           |
// +----------------------------------------------------------------+


#ifndef QTE_H
#define QTE_H

// For compile in Windows define WINDOWF, disable LINUXF
#define WINDOWSF
// For compile in Linux define LINUXF, disable WINDOWF
// #define LINUXF

#ifdef LINUXF
  #include <QApplication>
  #include <QPushButton>
  #include <QTextEdit>
  #include <QLineEdit>
  #include <QTextCodec>
  #include <QMessageBox>
  #include <QtGui>
  #include <QAction>
  #include <QtScript>
  #include <QWebView>
  #include <QtNetwork/QTcpSocket>
  // /usr/include/QtNetwork
#endif

#ifdef WINDOWSF
  #include "qte_global.h"
  #include <stdio.h>

  #include <Qt>
  #include <QtGui\QApplication>
  #include <QtGui\QPushButton>
  #include <QtGui\QTextEdit>
  #include <QtGui\QLineEdit>
  #include <QtGui\QAction>
  #include <QtGui\QPalette>
  #include <QtGui\QColor>
  #include <QtGui\QSpinBox>
  #include <QtGui\QLCDNumber>
  #include <QtGui\QMainWindow>
  #include <QtGui\QStatusBar>
  #include <QtGui\QMessageBox>
  #include <QtGui\QLayout>
  #include <QtGui\QMenu>
  #include <QtGui\QCheckBox>
  #include <QtGui\QAbstractButton>
  #include <QtGui\QMenuBar>
  #include <QtGui\QProgressBar>
  #include <QtGui\QLabel>
  #include <QtCore\QTextCodec>
  #include <QtScript>
  #include <QtWebKit\QWebView>
  #include <QtNetwork\QTcpSocket>
  #include <QtNetwork\QAbstractSocket>
#endif

#define FQT_API QTESHARED_EXPORT

typedef void (*ExecZIM_1_0)( void* );    //  определим  тип  для вызываемой функции
typedef void (*ExecZIM_0_0)( void  );
typedef void (*ExecZIM_v__i)( int );    //  определим  тип  для вызываемой функции

class eSlot : public QObject
{
    Q_OBJECT
public:
    void* aSlot0;       // Хранит адрес D функции
    void* aSlot1;       // Хранит адрес D функции
    eSlot(QObject* parent = 0);
    ~eSlot();
    void sendSignal0();
    void sendSignal1(void*);
public slots:
    void Slot0();
    void Slot1(bool);
    void Slot1(int);
    void Slot1(QAbstractSocket::SocketError);
    void Slot1_int(size_t);
signals:
    void Signal0();
    void Signal1(void*);
};

class eQWidget : public QWidget
{
    Q_OBJECT
public:
    void* aOnResize;
    void* aCloseEvent;
    eQWidget( QWidget* );
    ~eQWidget();
    void resizeEvent( QResizeEvent* );
    void closeEvent(QCloseEvent*);
};

class eQMainWindow : public QMainWindow
{
    Q_OBJECT
public:
    void* aOnResize;
    void* aCloseEvent;
    eQMainWindow(QWidget*, Qt::WindowFlags);
    ~eQMainWindow();
    void resizeEvent(QResizeEvent*);
    void closeEvent(QCloseEvent*);
};


class eLineEdit : public QLineEdit
{
    Q_OBJECT
public:
        eLineEdit(QWidget * parent = 0);
        ~eLineEdit();
        void *aReturnPressed;
public slots:
        void returnPressed1();
};

class eAction : public QAction
{
    Q_OBJECT
public:
        eAction(QObject *parent);
        ~eAction();
        void* aOnClick;
public slots:
        void OnClick();
};
#endif // QTE_H


