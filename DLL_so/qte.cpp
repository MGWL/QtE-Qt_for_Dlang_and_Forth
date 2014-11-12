// +----------------------------------------------------------------+
// | Проект QtE (wrapping QT for SPF and D)                         |
// | MGW,  22.07.13 14:12                                           |
// +----------------------------------------------------------------+

#include "qte.h"

// Lazarus
typedef int           PTRINT;
typedef unsigned int PTRUINT;

typedef struct QApplication__ { PTRINT dummy; } *QApplicationH;
typedef struct QWidget__ { PTRINT dummy; } *QWidgetH;

extern "C" QApplicationH lzQApplication_create(int* argc, char** argv, int AnonParam3)
{
    return (QApplicationH) new QApplication(*(int*)argc, argv, AnonParam3);
}
extern "C" QWidgetH lzQWidget_create(QWidgetH parent, unsigned int f)
{
    return (QWidgetH) new QWidget((QWidget*)parent, (Qt::WindowFlags)f);
}
extern "C" void lzQWidget_destroy(QWidgetH handle)
{
    delete (QWidget *)handle;
}


static char NameCodec[80];
extern "C" void* adrNameCodec(void) {
    return &NameCodec;
}

// Хм, интересно - так сделано в Lazarus, проверим .....
extern "C" int QApplication_exec()
{
    return (int) QApplication::exec();
}
extern "C" void* QApplication_create(int argc, char** argv, bool GUIenabled)
{
    return (void*) new QApplication(argc, argv, GUIenabled);
}
// --------- Lazarus ---------
// Фигня...  В Linux не работае, ошибка сегментации.

// ==================== QComboBox ======================
eQComboBox::eQComboBox(QWidget* parent) : QComboBox(parent)
{
        // aReturnPressed = NULL;
        // aTextChanged = NULL;
}
eQComboBox::~eQComboBox()
{
}
// !!! Выдать QComboBox на стек
extern "C" void *QT_QComboBox(QWidget* parent) {
        return  new eQComboBox(parent);
}
extern "C" void QT_QComboBox_addItem1(eQComboBox* cmb, QString *qstr, int i) {
    cmb->addItem(*qstr, i);
}
extern "C" int QT_QComboBox_currentIndex(eQComboBox* cmb) {
    return cmb->currentIndex();
}
extern "C" void QT_QComboBox_setCurrentIndex(eQComboBox* cmb, int i) {
    cmb->setCurrentIndex(i);
}


// ==================== QLineEdit ======================
eLineEdit::eLineEdit(QWidget * parent) : QLineEdit(parent)
{
        aReturnPressed = NULL;
        aTextChanged = NULL;
}
eLineEdit::~eLineEdit()
{
}
void eLineEdit::returnPressed1()
{
        if (aReturnPressed != NULL)
        {
            ((ExecZIM_0_0)aReturnPressed)();
        }
}
void eLineEdit::sTextChanged(const QString& str)
{
        if (aTextChanged != NULL)
        {
            ((ExecZIM_0_0)aTextChanged)();
        }
}
// !!! Выдать QLineEdit на стек
extern "C" void *QT_QLineEdit(QWidget* parent) {
        return  new eLineEdit(parent);
}
// !!! Установить обработчик
extern "C" void QT_QLineEdit_onreturnPressed(eLineEdit* qw, void *uk) {
    qw->aReturnPressed = uk;
    qw->connect(qw, SIGNAL(returnPressed()), qw, SLOT(returnPressed1()));
}
// !!! Установить обработчик
extern "C" void QT_QLineEdit_TextChanged(eLineEdit* qw, void *uk) {
    qw->aTextChanged = uk;
    qw->connect(qw, SIGNAL(textChanged(const QString &)), qw, SLOT( sTextChanged(const QString &)));
}
// !!! Текст строки LineEdit в QString
extern "C" void QT_QLineEdit_text(eLineEdit* qw, QString *qstr) {
     *qstr = qw->text();
}
extern "C" void QT_QLineEdit_set(eLineEdit* qw, QString *qstr) {
    qw->setText(*qstr);
}
// !!! SetFocus LineEdit
extern "C" void QT_QLineEdit_setfocus(eLineEdit* qw) {
     qw->setFocus();
}
// !!! Clear LineEdit
extern "C" void QT_QLineEdit_clear(eLineEdit* qw) {
     qw->clear();
}

// ================= QTextCodec ==============
extern "C" QTextCodec* p_QTextCodec(char* strNameCodec) {
    return QTextCodec::codecForName(strNameCodec);
}
// Переприсваивание QString
extern "C" void QT_QTextCodec_toUnicode(QTextCodec *codec, QString *qstr, char *strz) {
    *qstr = codec->toUnicode(strz);
}
extern "C" void QT_QTextCodec_fromUnicode(QTextCodec *codec, QString *qstr, char *strz) {
    sprintf(strz, "%s", codec->fromUnicode(*qstr).data());
}
// ================= QWidget =================
extern "C" void* p_QWidget(QWidget* parent, Qt::WindowFlags f) {
    // if (f == 0) {};
    return new eQWidget(parent);
}
extern "C" void resize_QWidget(QWidget* wid, int w, int h) {
    wid->resize(w, h);
}
eQWidget::eQWidget( QWidget* parent): QWidget( parent ) {
    aOnResize = NULL;
    aCloseEvent = NULL;
    aPaintEvent = NULL;
    aKeyPressEvent = NULL;
}
eQWidget::~eQWidget()
{
}
void eQWidget::paintEvent(QPaintEvent* event)
{
    if (aPaintEvent!= NULL) {
        QPainter p(this);
        ((ExecZIM_2_0)aPaintEvent)((void *)this, (void*)&p);
    }
}
extern "C" void eQWidget_setPaintEvent( eQWidget* wid, void* adr )
{
    wid->aPaintEvent = adr;
}
extern "C" void setCloseEvent( eQWidget* wid, void* adr )
{
    wid->aCloseEvent = adr;
}
void eQWidget::closeEvent(QCloseEvent *event)
{
    if (aCloseEvent!= NULL) ((ExecZIM_1_0)aCloseEvent)((void *)event);
}

extern "C" void setResizeEvent( eQWidget* wid, void* adr )
{
    wid->aOnResize = adr;
}
void eQWidget::resizeEvent( QResizeEvent *a )
{
    if (aOnResize!= NULL) ((ExecZIM_1_0)aOnResize)((void *)a);
}
// ------ обработка KeyEvent ------
void eQWidget::setaKeyPressEvent(void* adr)
{
    aKeyPressEvent = adr;
}
extern "C" void setkeyPressEvent( eQWidget* wid, void* adr )
{
    wid->setaKeyPressEvent(adr);
}

void eQWidget::keyPressEvent( QKeyEvent *event)
{
    if (aKeyPressEvent != NULL) ((ExecZIM_1_0)aKeyPressEvent)((void *)event);
    QWidget::keyPressEvent(event);
}
extern "C" int fromQKeyEvent_key(QKeyEvent *e)
{
    return e->key();
}
extern "C" int fromQKeyEvent_Modifiers(QKeyEvent *e)
{
    return (Qt::KeyboardModifiers)e->modifiers();
}

// ---------------------------
// -------------------->   void setCloseEvent( eQWidget* wid, void* adr )

extern "C" bool eQWidget_isVisible(QWidget* w) {
    return w->isVisible();
}

extern "C" eQWidget* p_eQWidget(QWidget* parent) {
    return new eQWidget(parent);
}
extern "C" void p_eQWidget_del(eQWidget* parent) {
    delete parent;
}
extern "C" int size_eQWidget(void) {
    return sizeof(QString);
}
extern "C" int width_eQWidget(QWidget* w) {
    return w->width();
}
extern "C" int height_eQWidget(QWidget* w) {
    return w->height();
}
// ?????????????????????????????????????????????????
extern "C" QString* qs_test(void) {
    QString* a  = new QString("ABC");
    return a;
}
extern "C" QString* new_QString(void) {
    return new QString();
}
extern "C" void del_QString(QString* s) {
    delete s;
}
// QString из wchar
extern "C" QString* new_QString_wchar(QChar* s, int size) {
    return new QString(s, size);
}
// !!! Запись строки в QString
extern "C" void QT_QString_set(QString *qstr, char *strz) {
    QTextCodec *codec = QTextCodec::codecForName(NameCodec);  // "Windows-1251"
    *qstr = codec->toUnicode(strz);
}
// Для перекодировки строки из/в необходимо участие QTextCodec
extern "C" void QT_QString_toUnicode(QString *qstr, char *strz, QTextCodec *codec) {
    // QTextCodec *codec1 = QTextCodec::codecForName("UTF-8");  // "Windows-1251"
    // printf("Debug toUnicode: strz = %s\n", strz);
    *qstr = codec->toUnicode(strz);
}
// Для перекодировки строки из/в необходимо участие QTextCodec
extern "C" int QT_QString_fromUnicode(QString *qstr, char *strz, QTextCodec *codec) {
    // QTextCodec *codec = QTextCodec::codecForName(NameCodec);  // "Windows-1251"
    // sprintf((strz+1), "%s", codec->fromUnicode(*qstr).data());    *strz = strlen(strz+1);
    sprintf(strz, "%s", codec->fromUnicode(*qstr).data());  //   *strz = strlen(strz+1);
    return strlen(strz);
}
// !!! Из QString в CHAR *
extern "C" void QT_QString_text(QString *qstr, char *strz) {
    QTextCodec *codec = QTextCodec::codecForName(NameCodec);  // "Windows-1251"
    sprintf((strz+1), "%s", codec->fromUnicode(*qstr).data());
    *strz = strlen(strz+1);
}
extern "C" QByteArray* new_QByteArray(void) {
    return new QByteArray();
}
extern "C" void delete_QByteArray(QByteArray* buf) {
    delete buf;
}
extern "C" QByteArray* new_QByteArray_vc(char* buf) {
    return new QByteArray(buf);
}
extern "C" char* new_QByteArray_data(QByteArray* buf) {
    return buf->data();
}
extern "C" int QByteArray_size(QByteArray* s) {
    return s->size();
}
extern "C" bool QByteArray_operator2r1(QByteArray* s1, QByteArray* s2) {
    return *s1 == *s2;
}
extern "C" QByteArray* QByteArray_left(QByteArray* s1, QByteArray* z, int i) {
    *z = s1->left(i);
    return z;
}
extern "C" QByteArray* QByteArray_mid(QByteArray* s1, QByteArray* z, int pos, int len) {
    *z = s1->mid(pos, len);
    return z;
}
extern "C" QByteArray* QByteArray_trimmed(QByteArray* s1) {
    *s1 = s1->trimmed();
    return s1;
}
extern "C" QByteArray* QByteArray_simplified(QByteArray* s1) {
    *s1 = s1->simplified();
    return s1;
}


extern "C" QChar* QString_data(QString *s) {
    return s->data();
}
extern "C" int QString_size(QString *s) {
    return s->size();
}
// ==================== QPlainTextEdit =================
eQPlainTextEdit::eQPlainTextEdit( QWidget* parent): QPlainTextEdit( parent ) {
    // aOnResize = NULL;
}
eQPlainTextEdit::~eQPlainTextEdit()
{
}

extern "C" void *p_QPlainTextEdit_new(QWidget* parent) {
        return  new eQPlainTextEdit(parent);
}
extern "C" void  p_QPlainTextEdit_del(eQPlainTextEdit* pte) {
        delete pte;
}
extern "C" void*  QT_QPlainTextEdit_toPlainText(eQPlainTextEdit* pte, QString* qs) {
    qs->clear();
    qs->append(pte->toPlainText());
    return qs;
}
extern "C" void* QT_QPlainTextEdit_document(eQPlainTextEdit* qw) {
        return qw->document();
}


// ==================== QTextEdit ======================
extern "C" void *p_QTextEdit(QWidget* parent) {
        return  new QTextEdit(parent);
}
extern "C" void QtE_QTextEdit_GetQString(QTextEdit* te, QString* s) {
    QTextBlock tb = te->textCursor().block(); //..block().text().trimmed();
    *s = tb.text().trimmed();
}
extern "C"  void* QT_QTextEdit_toPlainText(QTextEdit* te, QString* qs) {
    qs->clear();
    qs->append(te->toPlainText());
    return qs;
}
extern "C"  void* QT_QTextEdit_toHTML(QTextEdit* te, QString* qs) {
    qs->clear();
    qs->append(te->toHtml());
    return qs;
}
extern "C" void* QT_QTextEdit_document(QTextEdit* qw) {
        return qw->document();
}


// ==================== QPushButton ====================
extern "C" void *QT_QPushButton(QWidget* parent, QString name) {
        return  new QPushButton(name, parent);
}
// ==================== QObject ====================
extern "C" void* QT_QObject(QObject * parent) {
     return new QObject(parent);
}
extern "C" void* QT_QObject_parent(QObject* obj) {
     return obj->parent();
}

// ==================== eSlot ======================
eSlot::eSlot(QObject* parent) : QObject(parent)
{
    aSlot0 = NULL;
    aSlot1 = NULL;
    aSlotN = NULL;
         N = 0;
}
eSlot::~eSlot()
{
}
void eSlot::SlotN() // Вызвать глобальную функцию с параметром N (диспетчерезатор)
{
    if (aSlotN != NULL)  ((ExecZIM_v__i)aSlotN)(N);
}
void eSlot::Slot0()
{
    if (aSlot0 != NULL)  ((ExecZIM_0_0)aSlot0)();
}
void eSlot::Slot1(bool par1)
{
    if (aSlot1 != NULL) ((ExecZIM_1_0)aSlot1)((void*)par1);
}
void eSlot::Slot1(int par1)
{
    if (aSlot1 != NULL) ((ExecZIM_v__i)aSlot1)(par1);
}
void eSlot::Slot1(QAbstractSocket::SocketError par1)
{
    if (aSlot1 != NULL) ((ExecZIM_v__i)aSlot1)(par1);
}
void eSlot::Slot1_int(size_t par1)
{
    if (aSlot1 != NULL) ((ExecZIM_1_0)aSlot1)((void*)par1);
}
void eSlot::sendSignal0() {
    emit Signal0();
}
void eSlot::sendSignal1(void* par1) {
    emit Signal1(par1);
}

extern "C" void* qte_eSlot(QObject * parent) {
     return new eSlot(parent);
}
extern "C" void eSlot_setSlot(size_t n, eSlot* slot, void* adr) {
    if (n==0) slot->aSlot0 = adr;
    if (n==1) slot->aSlot1 = adr;
}
extern "C" void eSlot_setSlotN(eSlot* slot, void* adr, int n) {
    slot->aSlotN = adr;
    slot->N = n;
}
extern "C" void eSlot_setSlot0(eSlot* slot, void* adr) {
     slot->aSlot0 = adr;
}
extern "C" void eSlot_setSlot1(eSlot* slot, void* adr) {
     slot->aSlot1 = adr;
}
extern "C" void eSlot_setSignal0(eSlot* slot) {
     slot->sendSignal0();
}
extern "C" void eSlot_setSignal1(eSlot* slot, void* par1) {
     slot->sendSignal1(par1);
}
// ==================== QMsgBox ======================
extern "C" void* QT_QMessageBox(QWidget* parent)
{
        return new QMessageBox(parent);
}
extern "C" int QT_QMessageBox_exec(QMessageBox* box)
{
        return box->exec();
}
// ===================== QLyout ====================
extern "C" void* QT_QVBoxLayout(void)
{
        return  new QVBoxLayout();
}
extern "C" void* QT_QHBoxLayout(void)
{
        return  new QHBoxLayout();
}
extern "C" void* QT_QBoxLayout( QBoxLayout::Direction dir, QWidget * parent)
{
        return  new QBoxLayout(dir, parent);
}
extern "C" void QT_QBoxLayout_addWidget(QBoxLayout *BoxLyout, QWidget *widget)
{
     BoxLyout->addWidget(widget);
}
extern "C" void QT_QBoxLayout_addLayout(QBoxLayout *BoxLyout, QLayout *layout)
{
     BoxLyout->addLayout(layout);
}
// ===================== QMainWindow =====================
eQMainWindow::eQMainWindow(QWidget* parent = 0, Qt::WindowFlags flags = 0 ): QMainWindow(parent, flags) {
// eQMainWindow::eQMainWindow(QWidget* parent = 0, Qt::WindowFlags flags = 0 ) {
    aOnResize = NULL;
    aCloseEvent = NULL;
    aOnTimer = NULL;
}
eQMainWindow::~eQMainWindow()
{
}
extern "C" void* QT_QMainWindow(void)
{
     return new eQMainWindow();
}
extern "C"  void QMainWindowDel(eQMainWindow* parent) {
    delete parent;
}
extern "C" void QT_QMainWindow_setMenuBar(eQMainWindow *mw, QMenuBar *sb)
{
     mw->setMenuBar(sb);
}
extern "C" void QMainWindow_setCloseEvent( eQMainWindow* wid, void* adr )
{
    wid->aCloseEvent = adr;
}
void eQMainWindow::closeEvent(QCloseEvent *event)
{
    if (aCloseEvent!= NULL) ((ExecZIM_1_0)aCloseEvent)((void *)event);
}
extern "C" void QMainWindow_setResizeEvent( eQMainWindow* wid, void* adr )
{
    wid->aOnResize = adr;
}
void eQMainWindow::resizeEvent( QResizeEvent *a )
{
    if (aOnResize!= NULL) ((ExecZIM_1_0)aOnResize)((void *)a);
}
void eQMainWindow::timerEvent(QTimerEvent* event)
{
    if (aOnTimer != NULL) ((ExecZIM_v__i)aOnTimer)(event->timerId());
    // printf("\n ----- C++ eQMainWindow::timerEvent --> ID = %d -----\n", event->timerId());
}
extern "C" void QMainWindow_setOnTimer( eQMainWindow* wid, void* adr )
{
    wid->aOnTimer = adr;
}
extern "C" void QT_QMainWindow_addToolBar(QMainWindow *mw, QToolBar *sb)
{
     mw->addToolBar(sb);
}
// ===================== StatusBar =====================
extern "C" void* QT_QStatusBar(QWidget* parent)
{
       return new QStatusBar(parent);
}
// ===================== QLCDNumber =====================
extern "C" void* QT_QLCDNumber(QWidget* parent)
{
       return new QLCDNumber(parent);
}
// ===================== QSpinBox =====================
extern "C" void* QT_QSpinBox(QWidget* parent)
{
       return new QSpinBox(parent);
}
extern "C"  void QT_QSpinBoxDel(QSpinBox* parent) {
    delete parent;
}
extern "C" void QT_QSpinBox_setValue(QSpinBox* sp, int n) {
    sp->setValue(n);
}
extern "C" int QT_QSpinBox_value(QSpinBox* sp) {
    return sp->value();
}
extern "C" void QT_QSpinBox_setMin(QSpinBox* sp, int n) {
    sp->setMinimum(n);
}
extern "C" void QT_QSpinBox_setMax(QSpinBox* sp, int n) {
    sp->setMaximum(n);
}

// ===================== QPalette =====================
extern "C" void* QT_QPalette(void)
{
       return new QPalette();
}
extern "C" void QT_QPalette_setColor(QPalette* pal, QPalette::ColorGroup cg, QPalette::ColorRole cr, QColor color)
{
       pal->setColor(cg, cr, color);
}
extern "C" void QT_QPalette_setColor2(QPalette* pal, QPalette::ColorGroup cg, QPalette::ColorRole cr, Qt::GlobalColor color)
{
       pal->setColor(cg, cr, color);
}
// ===================== QColor =====================
extern "C" void* QT_QColor(void)
{
       return new QColor();
}
// ================ QSyntaxHighlighter ==============
zQSyntaxHighlighter::zQSyntaxHighlighter(QTextDocument *parent) : QSyntaxHighlighter(parent) {
    mparserEvent = NULL;
}
void zQSyntaxHighlighter::setFormatFont(int start, int count, QFont *font) {
    this->setFormat(start, count, *font);
}
void zQSyntaxHighlighter::setFormatColor(int start, int count, QColor *color) {
    this->setFormat(start, count, *color);
}
void zQSyntaxHighlighter::highlightBlock(const QString &text ) {
   if (mparserEvent != NULL)  ((ExecZIM_1_0)mparserEvent)((void *)&text);
}
extern "C" void* QT_QSyntaxHighlighterNEW(QTextDocument *te) {
    return new zQSyntaxHighlighter(te);
}
extern "C" void QT_QSyntaxHighlighter_OnParser(zQSyntaxHighlighter *hl, void* adr) {
    hl->mparserEvent = adr;    // Указатель на слово
}
extern "C" void QT_QSyntaxHighlighter_FormatFont(zQSyntaxHighlighter *hl, QFont *font, int count, int start) {
     hl->setFormatFont(start, count, font);
}
extern "C" void QT_QSyntaxHighlighter_FormatColor(zQSyntaxHighlighter *hl, QColor *color, int count, int start) {
     hl->setFormatColor(start, count, color);
}
// ===================== QTextDocument =====================
extern "C" void* QT_QTextDocumentNEW1(QPlainTextEdit *te) {
    return te->document();
}
extern "C" void* QT_QTextDocumentNEW2(QTextEdit *te) {
    return te->document();
}

// ===================== QApplication =====================
extern "C" void QT_QApp_setPalette(QApplication* app, QPalette* pal)
{
       app->setPalette(*pal);
}
extern "C" void * QT_QApp_appFilePath(QApplication *adrthis, QString *adrqs) {
    *adrqs = adrthis->applicationFilePath();
    return adrthis;
}
extern "C" void * QT_QApp_appDirPath(QApplication *adrthis, QString *adrqs) {
    *adrqs = adrthis->applicationDirPath();
    return adrthis;
}
extern "C" void * QT_QApp_arg(QApplication *adrthis, int n, QString *adrqs) {
    *adrqs =  adrthis->arguments().at(n);
    return NULL;
}
extern "C" void * QT_QApp_processEvents(QApplication *adrthis) {
    adrthis->processEvents();
    return NULL;
}
// ===================== QPoint =============================
extern "C" void * QT_QPoint_new1() {
    return new QPoint();
}
extern "C" void * QT_QPoint_new2(int xpos, int ypos) {
    return new QPoint(xpos, ypos);
}
// ===================== QRect =============================
extern "C" void * QT_QRect_new1() {
    return new QRect();
}
extern "C" void * QT_QRect_new2(int left, int top, int width, int height) {
    return new QRect(left, top, width, height);
}

// ===================== QScriptEngine =====================
extern "C" void* QT_QScriptEngine(void)
{
       return new QScriptEngine();
}
// ================= QAction ==================================
eAction::eAction(QObject* parent)  : QAction(parent)
{
                aOnClick = NULL;
}
eAction::~eAction()
{
}
void eAction::OnClick()
{
                if (aOnClick!= NULL)  ((ExecZIM_0_0)aOnClick)();
}
extern "C" void* QT_QAction(QObject * parent) {
     return new eAction(parent);
}
extern "C" void QT_QAction_setHotKey(eAction *act, int kl) {
                act->setShortcut(kl);
}
extern "C" void QT_QAction_onClick(eAction *act, void* adr) {
                act->aOnClick = adr;
                act->connect(act, SIGNAL(triggered()), act, SLOT(OnClick()));
}
extern "C" void QT_QAction_setIcon(eAction *act, QIcon *ik) {
                act->setIcon(*ik);
}
extern "C" void QT_QAction_setEnabled(eAction *act, bool p) {
                act->setEnabled(p);
}
// ================= QMenu ==================================
extern "C"  void *QT_QMenu(QWidget * parent) {
     return new QMenu(parent);
}
extern "C"  void QT_QMenu_addAction(QMenu *menu, QAction *ac) {
    menu->addAction(ac);
}
// ============ QMenuBar =======================================
extern "C"  void *QT_QMenuBar(QWidget * parent) {
     return new QMenuBar(parent);
}
// ============ QWebView =======================================
extern "C"  void* QT_QWebView(QWidget * parent) {
    return new QWebView(parent);
}
extern "C"  int QT_QWebView_size(void) {
    return sizeof(QWebView);
}
extern "C"  void QT_QWebViewDel(QWebView* parent) {
    delete parent;
}
extern "C"  void QT_QWebView_load(QWebView* wv, QUrl* url) {
    wv->load(*url);
}
// ============ QLabel =======================================
extern "C"  void* QT_QLabel_new(QWidget * parent) {
     return new QLabel(parent);
}
extern "C" void delete_QT_QLabel(QLabel* lb) {
    delete lb;
}
extern "C" void QT_QLabel_text(QLabel* lb, QString* s) {
    *s = lb->text();
}
// ============ QUrl =======================================
extern "C"  void* QT_QUrl() {
     return new QUrl();
}
extern "C" void QT_QUrl_setUrl(QUrl* url, QString *qstr) {
    url->setUrl(*qstr);
}
// ============ QProgressBar =======================================
extern "C"  void *QT_QProgressBar(QWidget * parent) {
     return new QProgressBar(parent);
}
// ============ QCheckBox =======================================
extern "C"  void *QT_QCheckBox(QWidget * parent) {
     return new QCheckBox(parent);
}
// ============ QTcpSocket =======================================
extern "C"  void *QT_QTcpSocket(QObject * parent) {
     return new QTcpSocket(parent);
}
extern "C"  void QT_QTcpSocket_connectToHost(QTcpSocket* soket, QString* host,  quint16 port, QIODevice::OpenModeFlag openMode) {
    soket->connectToHost(*host, port, openMode);
}
// ============ QIODevice =======================================
extern "C"  qint64 QIODevice_readLine(QIODevice* dev, char* buf, qint64 size) {
    return dev->readLine(buf, size);
}
extern "C"  qint64 QIODevice_write(QIODevice* dev, char* buf, qint64 size) {
    return dev->write(buf, size);
}
extern "C"  void QIODevice_setTextModeEnabled(QIODevice* dev, bool mode) {
    dev->setTextModeEnabled(mode);
}
extern "C"  void QIODevice_readAll(QIODevice* dev, QString* qs) {
    QString s = dev->readAll();
    qs->append(s);
}

// ============ QFile ===================
extern "C"  void *QT_QFile_new(QObject* parent) {
    return new QFile(parent);
}
extern "C"  void *QT_QFile_new1(QString* str) {
    return new QFile(*str);
}
// ============ QTextStream =======================================
extern "C"  void* QT_QTextStream3(QByteArray* ba, int mode) {
    return new QTextStream(ba, (QIODevice::OpenMode)mode);
}
extern "C"  void* QT_QTextStream4(QIODevice* dev) {
    return new QTextStream(dev);
}
extern "C"  void* QT_QTextStream_readAll(QTextStream* ts, QString* qs) {
    qs->clear();
    qs->append(ts->readAll());
    return qs;
}

// ============ QDataStream =======================================
extern "C"  void *QT_QDataStream(void) {
    // printf("\n ----- C++ QDataStream -------\n");
    QDataStream* z;
    QByteArray* ba;
    char* buf = "ABC";
    ba = new QByteArray();
    z =  new QDataStream(ba, (QIODevice::OpenMode)3);
    // int r =
            z->writeRawData(buf, 3);
    // printf("\n C++ QT_QDataStream.writeRawData r = %d \n", r);
    // printf("\n ---------------------\n");
    return z;
}
extern "C"  void* QT_QDataStream3(QByteArray* ba, int mode) {
    return new QDataStream(ba, (QIODevice::OpenMode)mode);
}
extern "C"  int QT_QDataStream_ReadRawData(QDataStream* stream, char* s, int len) {
     return stream->readRawData(s, len);
}
extern "C"  int QT_QDataStream_WriteRawData(QDataStream* stream, char* s, int len) {
     return stream->writeRawData(s, len);
}
extern "C"  void QT_QDataStream_setVersion(QDataStream* stream, int ver) {
     return stream->setVersion(ver);
}

// ===================================================
typedef QList<void *> gQList;

extern "C" void* QT_QList() {
        return  new gQList();
}
extern "C" void* QT_QListDELETE(gQList *pm) {
    delete pm;
    return NULL;
}
extern "C" void* QT_QList_append(gQList *pm, void *element) {
        pm->append(element);
        return  NULL;
}

extern "C" void* QT_QList_at(gQList *pm, int nomer) {
        return  pm->at(nomer);
}
extern "C" void* QT_QList_clear(gQList *pm) {
        pm->clear();
        return NULL;
}
extern "C" void* QT_QList_size(gQList *pm) {
        return (void *)pm->size();
}
extern "C" void* QT_QList_removeAt(gQList *pm, int nomer) {
        pm->removeAt(nomer);
        return NULL;
}
// ==================== QGroupBox ======================
extern "C" void *p_QGroupBox(QWidget* parent) {
        return  new QGroupBox(parent);
}

// ============ QRadioButton =======================================
extern "C"  void *QT_QRadioButton(QWidget * parent) {
     return new QRadioButton(parent);
}

// ============== QFileDialog ================
extern "C" void* QT_QFileDialog(QWidget* parent) {
    return  new QFileDialog(parent);
}
extern "C" void QT_QFileDialogDELETE(QFileDialog *pm) {
    delete pm;
}
extern "C" QString* QT_QFileDialog_getOpenFileName(QFileDialog *pm,
                                                QWidget *parent,
                                                QString *caption,
                                                QString *dir,
                                                QString *filter,
                                                QString *Selectedfilter,
                                                QFileDialog::Option options,
                                                QString *rez) {
    *rez =  pm->getOpenFileName(parent, *caption, *dir, *filter, Selectedfilter, options);
    return rez;
}
// ============== QPainter ================
extern "C" void* QT_QPainterNEW(QPaintDevice* device) {
    return new QPainter(device);
}
extern "C" void QT_QPainterDELETE(QPainter* p) {
    delete p;
}
extern "C" void QT_QPainter_drawLine(QPainter* p, int a, int b, int c, int d) {
    p->drawLine(a, b, c, d);
}
extern "C" void QT_QPainter_begin(QPainter* p, QPaintDevice* dev) {
    p->begin(dev);
}
extern "C" void QT_QPainter_end(QPainter* p) {
    p->end();
}
extern "C" void QT_QPainter_drawText1(QPainter* p, QString* str, int x, int y) {
    p->drawText(x, y, *str);
}
extern "C" void QT_QPainter_setFont(QPainter* p, QFont* str) {
    p->setFont(*str);
}
// ================= QPrinter =================
eQPrinter::eQPrinter(void): QPrinter() {
}
eQPrinter::~eQPrinter(void) {
}
void* eQPrinter::getThis(void) {
    return (void*)this;
}
extern "C" void* QT_QPrinterNEW(QPrinter::PrinterMode mode) {
    return new eQPrinter();
}
extern "C" void* QT_QPrinter_getThis(eQPrinter* pr) {
    return pr->getThis();
}
// ================= QFrame =================
extern "C" void* QT_QFrameNEW(QWidget* parent, Qt::WindowType f) {
    return new QFrame(parent, f);
}
extern "C" void QT_QQFrameDELETE(QFrame* p) {
    delete p;
}

// ================= QFont =================
extern "C" void* QT_QFontNEW(void) {
    return new QFont();
}
extern "C" void QT_QFontDELETE(QFont* p) {
    delete p;
}
// ================= QTime =================
extern "C" void* QT_QTimeNEW(void) {
    return new QTime();
}
extern "C" void QT_QTimeDELETE(QTime* d) {
    delete d;
}
extern "C" QTime* QT_QTime_currentTime(QTime* d) {
    *d = d->currentTime();
    return d;
}
// extern "C" QString* QT_QDate_toString(QDate* d, QString* rez, QString* shabl) {
extern "C" void* QT_QTime_toString(QTime* d, QString* rez, QString* shabl) {
     *rez = d->toString(*shabl);
     return rez;
}

// ================= QDate =================
extern "C" void* QT_QDateNEW(void) {
    return new QDate();
}
extern "C" void QT_QDateDELETE(QDate* d) {
    delete d;
}
extern "C" QDate* QT_QDate_currentDate(QDate* d) {
    *d = d->currentDate();
    return d;
}
// extern "C" QString* QT_QDate_toString(QDate* d, QString* rez, QString* shabl) {
extern "C" void* QT_QDate_toString(QDate* d, QString* rez, QString* shabl) {
     *rez = d->toString(*shabl);
     return rez;
}
// ================= QTemporaryFile =================
extern "C" void* QT_QTemporaryFileNEW(QObject* parent) {
    return new QTemporaryFile(parent);
}
extern "C" void QT_QTemporaryFileDELETE(QTemporaryFile* d) {
    delete d;
}
extern "C" void QT_QTemporaryFile_text(QTemporaryFile* qw, QString *qstr) {
     *qstr = qw->fileName();
}
// ============ QListWidget =======================================
zQListWidget::zQListWidget(QWidget *parent)  : QListWidget(parent)
{
}

zQListWidget::~zQListWidget()
{
}
void zQListWidget::zitemClicked(QListWidgetItem *it)
{
        if (aItemClicked != NULL)
        {
            ((ExecZIM_0_0)aItemClicked)();
        }
}
extern "C" void *QT_QListWidget(QWidget *parent) {
        return  new zQListWidget(parent);
}
extern "C" void * QT_QListWidgetDEL(zQListWidget *lw) {
    delete lw;
    return NULL;
}
extern "C" void *QT_QListWidget_addItemStr(zQListWidget *lw, QString *qs) {
    lw->addItem(*qs);
    return  NULL;
}
// !!! Установить обработчик
extern "C" void QT_QListWidget_onItemClicked(zQListWidget *lw, void *uk) {
    lw->aItemClicked = uk;
//    lw->connect(lw, SIGNAL( itemClicked(QListWidgetItem *) ), lw, SLOT( zitemClicked(QListWidgetItem *)) );
    lw->connect(lw, SIGNAL( itemPressed(QListWidgetItem *) ), lw, SLOT( zitemClicked(QListWidgetItem *)) );
}
extern "C" void QT_QListWidget_currentText(zQListWidget *lw, QString *qstr) {
     *qstr = lw->currentItem()->text();
}
extern "C" void * QT_QListWidget_clear(zQListWidget *lw) {
    lw->clear();
    return NULL;
}
// ================= QDialog =================
extern "C" void* QT_QDialogNEW(QWidget* parent) {
    return new QDialog(parent);
}
extern "C" void QDialogDELETE(QDialog* d) {
    delete d;
}
// ================= QDialogButtonBox =================
extern "C" void* QT_QDialogButtonBoxNEW(QWidget* parent) {
    return new QDialogButtonBox(parent);
}
extern "C" void QDialogButtonBoxDELETE(QDialogButtonBox* d) {
    delete d;
}
// ================= QTranslator =================
extern "C" void* QT_QTranslatorNEW(void) {
    return new QTranslator();
}
extern "C" void QT_QTranslatorDELETE(QTranslator* d) {
    delete d;
}
extern "C" void QT_QTranslatorLoad(QTranslator* d, QString* qs) {
     d->load(*qs);
}
extern "C" void QT_QApp_InstallTranslator(QApplication* app, QTranslator* d) {
    app->installTranslator(d);
}
// ================= QToolBar =================
extern "C" void* QT_QToolBarNew(QWidget* parent) {
     return new QToolBar(parent);
}
extern "C" void  QT_QToolBar_addAction(QToolBar* menu, QAction *ac) {
    menu->addAction(ac);
}
extern "C" void  QT_QToolBar_addSep(QToolBar *menu) {
    menu->addSeparator();
}
// ================= QIcon =====================
extern "C" void* QT_QIconNEW() {
    return new QIcon();
}
extern "C" void QT_QIconDELETE(QIcon *pm) {
    delete pm;
}
extern "C" void QT_QIcon_addFile(QIcon *pm, QString *file) {
    pm->addFile(*file);
}
// ================= QDateEdit =====================
extern "C" void* QT_QDateEditNEW1(QWidget* parent) {
    return new QDateEdit(parent);
}


// ============ ВНИМАНИЕ - эксперементльный и функции ========
class CL1 {
public:
    int i;
    int j;
    CL1(void) {
        i=3; j=5;
    }
};
extern "C"  void* QT_newCL1(void) {
     return new CL1();
}
extern "C"  int pr1(CL1 c) {
    printf("\nWarning! C++ pr(CL) function &c.j = %p   c.j = %d", &c, c.j);
    return c.j;
}
extern "C"  int pr2(CL1* c) {
    printf("\nWarning! C++ pr(CL*) функция &c->j = %p   c->j = %d", &c, c->j);
    return c->j;
}
extern "C"  void* pr3(CL1* c) {
    CL1 z = *c;
    printf("\nWarning! C++ pr(CL*) &z = %p   c.j = %d", &z, z.j);
    return NULL; // &z;
}
extern "C"  int pr4(const CL1& c) {
    printf("\nWarning! C++ pr(CL*) &c = %p   c.j = %d", &c, c.j);
    return c.j;
}


// ============================================================
