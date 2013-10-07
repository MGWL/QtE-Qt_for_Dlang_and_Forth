// +----------------------------------------------------------------+
<<<<<<< HEAD
// | Ïðîåêò QtE (wrapping QT for SPF and D)                               |
=======
// | ÐŸÑ€Ð¾ÐµÐºÑ‚ QtE (wrapping QT for SPF and D)                         |
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
// | MGW,  22.07.13 14:12                                           |
// +----------------------------------------------------------------+


#ifndef QTE_H
#define QTE_H

// For compile in Windows define WINDOWF, disable LINUXF
<<<<<<< HEAD
// #define WINDOWSF
// For compile in Linux define LINUXF, disable WINDOWF
#define LINUXF
=======
#define WINDOWSF
// For compile in Linux define LINUXF, disable WINDOWF
// #define LINUXF
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95

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

<<<<<<< HEAD
typedef void (*ExecZIM_1_0)( void* );    //  îïðåäåëèì  òèï  äëÿ âûçûâàåìîé ôóíêöèè
=======
typedef void (*ExecZIM_1_0)( void* );    //  Ð¾Ð¿Ñ€ÐµÐ´ÐµÐ»Ð¸Ð¼  Ñ‚Ð¸Ð¿  Ð´Ð»Ñ Ð²Ñ‹Ð·Ñ‹Ð²Ð°ÐµÐ¼Ð¾Ð¹ Ñ„ÑƒÐ½ÐºÑ†Ð¸Ð¸
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
typedef void (*ExecZIM_0_0)( void  );

class eSlot : public QObject
{
    Q_OBJECT
public:
<<<<<<< HEAD
    void* aSlot0;       // Õðàíèò àäðåñ D ôóíêöèè
    void* aSlot1;       // Õðàíèò àäðåñ D ôóíêöèè
=======
    void* aSlot0;       // Ð¥Ñ€Ð°Ð½Ð¸Ñ‚ Ð°Ð´Ñ€ÐµÑ D Ñ„ÑƒÐ½ÐºÑ†Ð¸Ð¸
    void* aSlot1;       // Ð¥Ñ€Ð°Ð½Ð¸Ñ‚ Ð°Ð´Ñ€ÐµÑ D Ñ„ÑƒÐ½ÐºÑ†Ð¸Ð¸
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
    eSlot(QObject* parent = 0);
    ~eSlot();
    void sendSignal0();
    void sendSignal1(void*);
public slots:
    void Slot0();
<<<<<<< HEAD
    void Slot1_int(size_t);
=======
    void Slot1_int(int);
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
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


