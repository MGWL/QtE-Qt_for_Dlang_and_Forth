// +----------------------------------------------------------------+
// | Проект QtE (wrapping QT for SPF and D)                               |
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
  #include <QPlainTextEdit>
  #include <QLineEdit>
  #include <QTextCodec>
  #include <QMessageBox>
  #include <QtGui>
  #include <QAction>
  #include <QtScript>
  #include <QWebView>
  #include <QtNetwork/QTcpSocket>
  #include <QList>
  #include <QFileDialog>
// /usr/include/QtNetwork
#endif

#ifdef WINDOWSF
  #include "qte_global.h"
  #include <stdio.h>

  #include <Qt>
  #include <QtGui\QApplication>
  #include <QtGui\QPushButton>
  #include <QtGui\QTextEdit>
  #include <QtGui\QPlainTextEdit>
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
  #include <QtGui\QLabel>
  #include <QtGui\QCheckBox>
  #include <QtGui\QAbstractButton>
  #include <QtGui\QMenuBar>
  #include <QtGui\QFileDialog>
  #include <QtGui\QProgressBar>
  #include <QtGui\QGroupBox>
  #include <QtGui\QRadioButton>
  #include <QtGui\QPainter>
  #include <QtGui\QPrinter>
  #include <QtGui\QComboBox>
  #include <QtGui\QPaintEvent>
  #include <QtGui\QListWidget>
  #include <QtCore\QTextCodec>
  #include <QtScript>
  #include <QtWebKit\QWebView>
  #include <QtNetwork\QTcpSocket>
  #include <QtNetwork\QAbstractSocket>
  #include <QtGui\QDialog>
  #include <QtGui\QDialogButtonBox>
  #include <QtGui\QTextCursor>
  #include <QtGui\QTextBlock>
  #include <QtGui\QSyntaxHighlighter>
  #include <QtGui\QToolBar>
  #include <QtGui\QDateEdit>
#endif

#define FQT_API QTESHARED_EXPORT

typedef void (*ExecZIM_1_0)( void* );    //  определим  тип  для вызываемой функции
typedef void (*ExecZIM_0_0)( void  );
typedef void (*ExecZIM_v__i)( int );    //  определим  тип  для вызываемой функции
typedef void (*ExecZIM_2_0)( void*, void* );    //  определим  тип  для вызываемой функции

class eSlot : public QObject
{
    Q_OBJECT
public:
    void* aSlot0;       // Хранит адрес D функции
    void* aSlot1;       // Хранит адрес D функции
    void* aSlotN;       // Хранит адрес D функции для вызова с параметром
    int        N;       // параметр для aSlotN. Идея запомнить параметр при установке слота и выдать 
                        // при срабатывании слота. А ля - диспечерезация
    // -----------------------------------
    eSlot(QObject* parent = 0);
    ~eSlot();
    void sendSignal0();
    void sendSignal1(void*);
public slots:
    void SlotN();
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
protected:
    void keyPressEvent(QKeyEvent *event);
    void resizeEvent( QResizeEvent* );
    void closeEvent(QCloseEvent*);
    void paintEvent(QPaintEvent*);
public:
    void* aOnResize;
    void* aCloseEvent;
    void* aPaintEvent;
    void* aKeyPressEvent;

    eQWidget( QWidget* );
    ~eQWidget();
    // void timerEvent(QTimerEvent*);

    void setaKeyPressEvent(void*);
};

class eQPrinter : public QPrinter
{
    // Q_OBJECT
public:
    eQPrinter();
    ~eQPrinter();
    void* getThis();
};

class eQMainWindow : public QMainWindow
{
    Q_OBJECT
public:
    void* aOnTimer;
    void* aOnResize;
    void* aCloseEvent;
    eQMainWindow(QWidget*, Qt::WindowFlags);
    ~eQMainWindow();
    void timerEvent(QTimerEvent*);
    void resizeEvent(QResizeEvent*);
    void closeEvent(QCloseEvent*);
};

class eQPlainTextEdit : public QPlainTextEdit
{
    Q_OBJECT
public:
    // void* aOnTimer;
    eQPlainTextEdit(QWidget*);
    ~eQPlainTextEdit();
    // void timerEvent(QTimerEvent*);
};


class eLineEdit : public QLineEdit
{
    Q_OBJECT
public:
        eLineEdit(QWidget * parent = 0);
        ~eLineEdit();
        void *aReturnPressed;
        void *aTextChanged;
public slots:
        void returnPressed1();
        void sTextChanged(const QString& str);
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

class zQListWidget : public QListWidget {
    Q_OBJECT
public:
    zQListWidget(QWidget *parent = 0);
    ~zQListWidget();
    void *aItemClicked;
public slots:
    void zitemClicked(QListWidgetItem * item);
};

class eQComboBox : public QComboBox
{
    Q_OBJECT
public:
        eQComboBox(QWidget * parent = 0);
        ~eQComboBox();
        // void *aReturnPressed;
        // void *aTextChanged;
public slots:
        // void returnPressed1();
        // void sTextChanged(const QString& str);
};

#pragma pack(push, 4)
class zQSyntaxHighlighter : public QSyntaxHighlighter {
    Q_OBJECT
protected:
    void highlightBlock(const QString &text);
public:
    void* mparserEvent;                      // Указатель на обработчик

    zQSyntaxHighlighter(QTextDocument *parent = 0);
    void setFormatFont(int start, int count, QFont *font);
    void setFormatColor(int start, int count, QColor *color);
};
#pragma pack(pop)

#endif // QTE_H


