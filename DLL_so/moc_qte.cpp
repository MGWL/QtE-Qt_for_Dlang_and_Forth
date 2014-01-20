/****************************************************************************
** Meta object code from reading C++ file 'qte.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.5)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "qte.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'qte.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.5. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_eSlot[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       8,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: signature, parameters, type, tag, flags
       7,    6,    6,    6, 0x05,
      17,    6,    6,    6, 0x05,

 // slots: signature, parameters, type, tag, flags
      32,    6,    6,    6, 0x0a,
      40,    6,    6,    6, 0x0a,
      48,    6,    6,    6, 0x0a,
      60,    6,    6,    6, 0x0a,
      71,    6,    6,    6, 0x0a,
     107,    6,    6,    6, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_eSlot[] = {
    "eSlot\0\0Signal0()\0Signal1(void*)\0SlotN()\0"
    "Slot0()\0Slot1(bool)\0Slot1(int)\0"
    "Slot1(QAbstractSocket::SocketError)\0"
    "Slot1_int(size_t)\0"
};

void eSlot::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        eSlot *_t = static_cast<eSlot *>(_o);
        switch (_id) {
        case 0: _t->Signal0(); break;
        case 1: _t->Signal1((*reinterpret_cast< void*(*)>(_a[1]))); break;
        case 2: _t->SlotN(); break;
        case 3: _t->Slot0(); break;
        case 4: _t->Slot1((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 5: _t->Slot1((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 6: _t->Slot1((*reinterpret_cast< QAbstractSocket::SocketError(*)>(_a[1]))); break;
        case 7: _t->Slot1_int((*reinterpret_cast< size_t(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData eSlot::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject eSlot::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_eSlot,
      qt_meta_data_eSlot, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &eSlot::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *eSlot::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *eSlot::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_eSlot))
        return static_cast<void*>(const_cast< eSlot*>(this));
    return QObject::qt_metacast(_clname);
}

int eSlot::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 8)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 8;
    }
    return _id;
}

// SIGNAL 0
void eSlot::Signal0()
{
    QMetaObject::activate(this, &staticMetaObject, 0, 0);
}

// SIGNAL 1
void eSlot::Signal1(void * _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}
static const uint qt_meta_data_eQWidget[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

       0        // eod
};

static const char qt_meta_stringdata_eQWidget[] = {
    "eQWidget\0"
};

void eQWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    Q_UNUSED(_o);
    Q_UNUSED(_id);
    Q_UNUSED(_c);
    Q_UNUSED(_a);
}

const QMetaObjectExtraData eQWidget::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject eQWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_eQWidget,
      qt_meta_data_eQWidget, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &eQWidget::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *eQWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *eQWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_eQWidget))
        return static_cast<void*>(const_cast< eQWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int eQWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    return _id;
}
static const uint qt_meta_data_eQMainWindow[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

       0        // eod
};

static const char qt_meta_stringdata_eQMainWindow[] = {
    "eQMainWindow\0"
};

void eQMainWindow::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    Q_UNUSED(_o);
    Q_UNUSED(_id);
    Q_UNUSED(_c);
    Q_UNUSED(_a);
}

const QMetaObjectExtraData eQMainWindow::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject eQMainWindow::staticMetaObject = {
    { &QMainWindow::staticMetaObject, qt_meta_stringdata_eQMainWindow,
      qt_meta_data_eQMainWindow, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &eQMainWindow::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *eQMainWindow::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *eQMainWindow::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_eQMainWindow))
        return static_cast<void*>(const_cast< eQMainWindow*>(this));
    return QMainWindow::qt_metacast(_clname);
}

int eQMainWindow::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QMainWindow::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    return _id;
}
static const uint qt_meta_data_eLineEdit[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       2,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      11,   10,   10,   10, 0x0a,
      32,   28,   10,   10, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_eLineEdit[] = {
    "eLineEdit\0\0returnPressed1()\0str\0"
    "sTextChanged(QString)\0"
};

void eLineEdit::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        eLineEdit *_t = static_cast<eLineEdit *>(_o);
        switch (_id) {
        case 0: _t->returnPressed1(); break;
        case 1: _t->sTextChanged((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData eLineEdit::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject eLineEdit::staticMetaObject = {
    { &QLineEdit::staticMetaObject, qt_meta_stringdata_eLineEdit,
      qt_meta_data_eLineEdit, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &eLineEdit::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *eLineEdit::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *eLineEdit::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_eLineEdit))
        return static_cast<void*>(const_cast< eLineEdit*>(this));
    return QLineEdit::qt_metacast(_clname);
}

int eLineEdit::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QLineEdit::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 2)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 2;
    }
    return _id;
}
static const uint qt_meta_data_eAction[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       1,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
       9,    8,    8,    8, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_eAction[] = {
    "eAction\0\0OnClick()\0"
};

void eAction::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        eAction *_t = static_cast<eAction *>(_o);
        switch (_id) {
        case 0: _t->OnClick(); break;
        default: ;
        }
    }
    Q_UNUSED(_a);
}

const QMetaObjectExtraData eAction::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject eAction::staticMetaObject = {
    { &QAction::staticMetaObject, qt_meta_stringdata_eAction,
      qt_meta_data_eAction, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &eAction::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *eAction::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *eAction::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_eAction))
        return static_cast<void*>(const_cast< eAction*>(this));
    return QAction::qt_metacast(_clname);
}

int eAction::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QAction::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 1)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
