// +----------------------------------------------------------------+
// | Проект QtE (wrapping QT for SPF and D)                         |
// | MGW,  22.07.13 14:12                                           |
// +----------------------------------------------------------------+

#include "qte.h"

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
// -------------------->   void setCloseEvent( eQWidget* wid, void* adr )

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


extern "C" QChar* QString_data(QString *s) {
    return s->data();
}
extern "C" int QString_size(QString *s) {
    return s->size();
}

// ==================== QTextEdit ======================
extern "C" void *p_QTextEdit(QWidget* parent) {
        return  new QTextEdit(parent);
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
extern "C" void* QT_QMessageBox(void)
{
        return new QMessageBox();
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
// ===================== QApplication =====================
extern "C" void QT_QApp_setPalette(QApplication* app, QPalette* pal)
{
       app->setPalette(*pal);
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
// ================= QFont =================
extern "C" void* QT_QFontNEW(void) {
    return new QFont();
}
extern "C" void QT_QFontDELETE(QFont* p) {
    delete p;
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
