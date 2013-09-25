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
extern "C" void* QApplication_create(int* argc, char** argv, bool GUIenabled)
{
    return (void*) new QApplication(*(int*)argc, argv, GUIenabled);
}
// --------- Lazarus ---------
// Фигня...  В Linux не работае, ошибка сегментации.


// ==================== QLineEdit ======================
eLineEdit::eLineEdit(QWidget * parent) : QLineEdit(parent)
{
        aReturnPressed = NULL;
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
// !!! Выдать QLineEdit на стек
extern "C" void *QT_QLineEdit(QWidget* parent) {
        return  new eLineEdit(parent);
}
// !!! Установить обработчик
extern "C" void QT_QLineEdit_onreturnPressed(eLineEdit* qw, void *uk) {
    qw->aReturnPressed = uk;
    qw->connect(qw, SIGNAL( returnPressed() ), qw, SLOT( returnPressed1()));
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
extern "C" QWidget* p_QWidget(QWidget* parent, Qt::WindowFlags f) {
    return new QWidget(parent);
}
extern "C" void resize_QWidget(QWidget* wid, int w, int h) {
    wid->resize(w, h);
}
eQWidget::eQWidget( QWidget* parent): QWidget( parent ) {
    aOnResize = NULL;
}
eQWidget::~eQWidget()
{
}
extern "C" void setResizeEvent( eQWidget* wid, void* adr )
{
    wid->aOnResize = adr;
}
void eQWidget::resizeEvent( QResizeEvent *a )
{
    if (aOnResize!= NULL) ((ExecZIM_1_0)aOnResize)((void *)a);
}
extern "C" eQWidget* p_eQWidget(QWidget* parent) {
    return new eQWidget(parent);
}
extern "C" int size_eQWidget(void) {
    return sizeof(QString);
}
// ?????????????????????????????????????????????????
extern "C" QString* qs_test(void) {
    QString* a  = new QString("ABC");
    return a;
}
extern "C" QString* new_QString(void) {
    return new QString();
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
// ==================== eSlot ======================
eSlot::eSlot(QObject* parent) : QObject(parent)
{
}
eSlot::~eSlot()
{
}
void eSlot::Slot0()
{
    if (aSlot0 != NULL)  ((ExecZIM_0_0)aSlot0)();
}
void eSlot::Slot1_int(int par1)
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
extern "C" void* QT_QMainWindow(void)
{
     return new QMainWindow();
}
extern "C" void QT_QMainWindow_setMenuBar(QMainWindow *mw, QMenuBar *sb)
{
     mw->setMenuBar(sb);
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
// ===================== QApplication =====================
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
