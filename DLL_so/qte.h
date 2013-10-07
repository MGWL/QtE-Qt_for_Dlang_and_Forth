// +----------------------------------------------------------------+
// | ������ QtE (wrapping QT for SPF and D)                               |
// | MGW,  22.07.13 14:12                                           |
// +----------------------------------------------------------------+


#ifndef QTE_H
#define QTE_H

// For compile in Windows define WINDOWF, disable LINUXF
// #define WINDOWSF
// For compile in Linux define LINUXF, disable WINDOWF
#define LINUXF

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
#endif

#ifdef WINDOWSF
  #include "qte_global.h"
  #include <stdio.h>

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
  #include <QtGui\QMenuBar>
  #include <QtCore\QTextCodec>
  #include <QtScript>
#endif

#define FQT_API QTESHARED_EXPORT

typedef void (*ExecZIM_1_0)( void* );    //  ���������  ���  ��� ���������� �������
typedef void (*ExecZIM_0_0)( void  );

class eSlot : public QObject
{
    Q_OBJECT
public:
    void* aSlot0;       // ������ ����� D �������
    void* aSlot1;       // ������ ����� D �������
    eSlot(QObject* parent = 0);
    ~eSlot();
    void sendSignal0();
    void sendSignal1(void*);
public slots:
    void Slot0();
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
    eQWidget( QWidget* parent = 0 );
    ~eQWidget();
    void resizeEvent( QResizeEvent *a );
};
extern "C" eQWidget* p_eQWidget(QWidget*);

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


