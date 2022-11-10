/****************************************************************************
**
** Copyright (C) 2009-2022 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
**
** This file is part of Qt Jambi.
**
** ** $BEGIN_LICENSE$
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
** $END_LICENSE$
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

#ifndef Included_io_qt_qml_QQmlList_H
#define Included_io_qt_qml_QQmlList_H

#include <QtCore/qglobal.h>
#include <QtQml/QQmlScriptString>
#include <QtQml/QQmlError>
#include <QtQml/QJSValue>
#include <QtQml/QQmlListProperty>
#include <qtjambi/qtjambi_global.h>

/* Header for class io_qt_qml_QQmlListReference */

#ifndef QT_JAMBI_RUN
jobject qtjambi_from_object(JNIEnv *env, const void *qt_object, const std::type_info& typeId, bool makeCopyOfValueTypes, bool invalidateAfterUse);
void qtjambi_set_java_ownership(JNIEnv *env, jobject object);
#endif //QT_JAMBI_RUN

inline hash_type qHash(const QQmlScriptString &value)
{
    hash_type hashCode = qHash(value.isEmpty());
    hashCode = hashCode * 31 + qHash(value.isNullLiteral());
    hashCode = hashCode * 31 + qHash(value.isUndefinedLiteral());
    hashCode = hashCode * 31 + qHash(value.stringLiteral());
    bool ok = false;
    hashCode = hashCode * 31 + qHash(value.numberLiteral(&ok));
    hashCode = hashCode * 31 + qHash(ok);
    ok = false;
    hashCode = hashCode * 31 + qHash(value.booleanLiteral(&ok));
    hashCode = hashCode * 31 + qHash(ok);
    return hashCode;
}

inline hash_type qHash(const QQmlError &value)
{
    hash_type hashCode = qHash(value.url());
    hashCode = hashCode * 31 + qHash(value.description());
    hashCode = hashCode * 31 + qHash(value.line());
    hashCode = hashCode * 31 + qHash(value.column());
    hashCode = hashCode * 31 + qHash(quintptr(value.object()));
    hashCode = hashCode * 31 + qHash(value.messageType());
    return hashCode;
}

Q_DECL_EXPORT hash_type qHash(const QQmlListReference &value);

namespace QtQml {
    typedef QObject *(*QQmlAttachedPropertiesFunc)(QObject *);
#if QT_VERSION >= QT_VERSION_CHECK(5,14,0)
    typedef std::function<QObject*(QQmlEngine *, QJSEngine *)> ObjectCallback;
#else
    typedef QObject *(*ObjectCallback)(QQmlEngine *, QJSEngine *);
#endif
#if QT_VERSION >= QT_VERSION_CHECK(6,0,0)
    typedef std::function<QJSValue(QQmlEngine *, QJSEngine *)> ValueCallback;
#else
    typedef QJSValue (*ValueCallback)(QQmlEngine *, QJSEngine *);
#endif
}


#endif
