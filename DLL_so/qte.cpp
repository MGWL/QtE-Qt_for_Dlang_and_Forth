// +----------------------------------------------------------------+
// | QtE (wrapping QT for SPF and D)                                |
// | MGW,  22.07.13 14:12                                           |
// +----------------------------------------------------------------+

//  This file contains functions that are no opportunities or simply difficult to call from Qt.

#include "qte.h"
#include <QTextCodec>
#include <QMessageBox>
#include <QLayout>
#include <QMainWindow>
#include <QStatusBar>
#include <QSpinBox>
#include <QLCDNumber>

// extern "C" char NameCodec[80];

static char NameCodec[80];
extern "C" void* adrNameCodec(void) {
    return &NameCodec;
}
// ================= QTextCodec ==============
extern "C" QTextCodec* p_QTextCodec(char* strNameCodec) {
    return QTextCodec::codecForName(strNameCodec);
}
// QString
extern "C" void QT_QTextCodec_toUnicode(QTextCodec *codec, QString *qstr, char *strz) {
    *qstr = codec->toUnicode(strz);
}
extern "C" void QT_QTextCodec_fromUnicode(QTextCodec *codec, QString *qstr, char *strz) {
    sprintf(strz, "%s", codec->fromUnicode(*qstr).data());
}

// ================= QWidget =================
extern "C" QWidget* p_QWidget(QWidget* parent, Qt::WindowFlags f) {
    return new eQWidget(parent);
}
extern "C" void resize_QWidget(QWidget* wid, int w, int h) {
    wid->resize(w, h);
}
extern eQWidget::eQWidget( QWidget* parent): QWidget( parent ) {
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
void eSlot::sendSignal0() {
    emit Signal0();
}
extern "C" void* qte_eSlot(QObject * parent) {
     return new eSlot(parent);
}
extern "C" void eSlot_setSlot0(eSlot* slot, void* adr) {
     slot->aSlot0 = adr;
}
extern "C" void eSlot_setSignal0(eSlot* slot) {
     slot->sendSignal0();
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
