// +----------------------------------------------------------------+
<<<<<<< HEAD
// | Ïðîåêò QtE (wrapping QT for SPF and D)                               |
=======
// | ÐŸÑ€Ð¾ÐµÐºÑ‚ QtE (wrapping QT for SPF and D)                         |
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
// | MGW,  22.07.13 14:12                                           |
// +----------------------------------------------------------------+

#include "qte.h"

static char NameCodec[80];
extern "C" void* adrNameCodec(void) {
    return &NameCodec;
}

<<<<<<< HEAD
// Õì, èíòåðåñíî - òàê ñäåëàíî â Lazarus, ïðîâåðèì .....
=======
// Ð¥Ð¼, Ð¸Ð½Ñ‚ÐµÑ€ÐµÑÐ½Ð¾ - Ñ‚Ð°Ðº ÑÐ´ÐµÐ»Ð°Ð½Ð¾ Ð² Lazarus, Ð¿Ñ€Ð¾Ð²ÐµÑ€Ð¸Ð¼ .....
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
extern "C" int QApplication_exec()
{
    return (int) QApplication::exec();
}
extern "C" void* QApplication_create(int* argc, char** argv, bool GUIenabled)
{
    return (void*) new QApplication(*(int*)argc, argv, GUIenabled);
}
// --------- Lazarus ---------
<<<<<<< HEAD
// Ôèãíÿ...  Â Linux íå ðàáîòàå, îøèáêà ñåãìåíòàöèè.
=======
// Ð¤Ð¸Ð³Ð½Ñ...  Ð’ Linux Ð½Ðµ Ñ€Ð°Ð±Ð¾Ñ‚Ð°Ðµ, Ð¾ÑˆÐ¸Ð±ÐºÐ° ÑÐµÐ³Ð¼ÐµÐ½Ñ‚Ð°Ñ†Ð¸Ð¸.
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95


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
<<<<<<< HEAD
// !!! Âûäàòü QLineEdit íà ñòåê
extern "C" void *QT_QLineEdit(QWidget* parent) {
        return  new eLineEdit(parent);
}
// !!! Óñòàíîâèòü îáðàáîò÷èê
=======
// !!! Ð’Ñ‹Ð´Ð°Ñ‚ÑŒ QLineEdit Ð½Ð° ÑÑ‚ÐµÐº
extern "C" void *QT_QLineEdit(QWidget* parent) {
        return  new eLineEdit(parent);
}
// !!! Ð£ÑÑ‚Ð°Ð½Ð¾Ð²Ð¸Ñ‚ÑŒ Ð¾Ð±Ñ€Ð°Ð±Ð¾Ñ‚Ñ‡Ð¸Ðº
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
extern "C" void QT_QLineEdit_onreturnPressed(eLineEdit* qw, void *uk) {
    qw->aReturnPressed = uk;
    qw->connect(qw, SIGNAL( returnPressed() ), qw, SLOT( returnPressed1()));
}
<<<<<<< HEAD
// !!! Òåêñò ñòðîêè LineEdit â QString
=======
// !!! Ð¢ÐµÐºÑÑ‚ ÑÑ‚Ñ€Ð¾ÐºÐ¸ LineEdit Ð² QString
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
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
<<<<<<< HEAD
// Ïåðåïðèñâàèâàíèå QString
=======
// ÐŸÐµÑ€ÐµÐ¿Ñ€Ð¸ÑÐ²Ð°Ð¸Ð²Ð°Ð½Ð¸Ðµ QString
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
extern "C" void QT_QTextCodec_toUnicode(QTextCodec *codec, QString *qstr, char *strz) {
    *qstr = codec->toUnicode(strz);
}
extern "C" void QT_QTextCodec_fromUnicode(QTextCodec *codec, QString *qstr, char *strz) {
    sprintf(strz, "%s", codec->fromUnicode(*qstr).data());
}

// ================= QWidget =================
<<<<<<< HEAD
extern "C" void* p_QWidget(QWidget* parent, Qt::WindowFlags f) {
//    if (f == 0) {};
    return new eQWidget(parent);
=======
extern "C" QWidget* p_QWidget(QWidget* parent, Qt::WindowFlags f) {
    return new QWidget(parent);
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
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
// QString Ð¸Ð· wchar
extern "C" QString* new_QString_wchar(QChar* s, int size) {
    return new QString(s, size);
}
// !!! Ð—Ð°Ð¿Ð¸ÑÑŒ ÑÑ‚Ñ€Ð¾ÐºÐ¸ Ð² QString
extern "C" void QT_QString_set(QString *qstr, char *strz) {
    QTextCodec *codec = QTextCodec::codecForName(NameCodec);  // "Windows-1251"
    *qstr = codec->toUnicode(strz);
}
<<<<<<< HEAD
// Äëÿ ïåðåêîäèðîâêè ñòðîêè èç/â íåîáõîäèìî ó÷àñòèå QTextCodec
=======
// Ð”Ð»Ñ Ð¿ÐµÑ€ÐµÐºÐ¾Ð´Ð¸Ñ€Ð¾Ð²ÐºÐ¸ ÑÑ‚Ñ€Ð¾ÐºÐ¸ Ð¸Ð·/Ð² Ð½ÐµÐ¾Ð±Ñ…Ð¾Ð´Ð¸Ð¼Ð¾ ÑƒÑ‡Ð°ÑÑ‚Ð¸Ðµ QTextCodec
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
extern "C" void QT_QString_toUnicode(QString *qstr, char *strz, QTextCodec *codec) {
    // QTextCodec *codec1 = QTextCodec::codecForName("UTF-8");  // "Windows-1251"
    // printf("Debug toUnicode: strz = %s\n", strz);
    *qstr = codec->toUnicode(strz);
}
<<<<<<< HEAD
// Äëÿ ïåðåêîäèðîâêè ñòðîêè èç/â íåîáõîäèìî ó÷àñòèå QTextCodec
=======
// Ð”Ð»Ñ Ð¿ÐµÑ€ÐµÐºÐ¾Ð´Ð¸Ñ€Ð¾Ð²ÐºÐ¸ ÑÑ‚Ñ€Ð¾ÐºÐ¸ Ð¸Ð·/Ð² Ð½ÐµÐ¾Ð±Ñ…Ð¾Ð´Ð¸Ð¼Ð¾ ÑƒÑ‡Ð°ÑÑ‚Ð¸Ðµ QTextCodec
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
extern "C" int QT_QString_fromUnicode(QString *qstr, char *strz, QTextCodec *codec) {
    // QTextCodec *codec = QTextCodec::codecForName(NameCodec);  // "Windows-1251"
    // sprintf((strz+1), "%s", codec->fromUnicode(*qstr).data());    *strz = strlen(strz+1);
    sprintf(strz, "%s", codec->fromUnicode(*qstr).data());  //   *strz = strlen(strz+1);
    return strlen(strz);
}
<<<<<<< HEAD
// !!! Èç QString â CHAR *
=======
// !!! Ð˜Ð· QString Ð² CHAR *
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
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
<<<<<<< HEAD
void eSlot::Slot1_int(size_t par1)
=======
void eSlot::Slot1_int(int par1)
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
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
<<<<<<< HEAD
// ===================== QScriptEngine =====================
=======
// ===================== QApplication =====================
>>>>>>> 1dbcd71dfa94e5a14aae6d25830747c2fb24bc95
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
