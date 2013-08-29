#ifndef QTE_GLOBAL_H
#define QTE_GLOBAL_H

#include <QtCore/qglobal.h>

#if defined(QTE_LIBRARY)
#  define QTESHARED_EXPORT Q_DECL_EXPORT
#else
#  define QTESHARED_EXPORT Q_DECL_IMPORT
#endif

#endif // QTE_GLOBAL_H
