/****************************************************************************
**
** This file is part of Qt Jambi.
**
** ** $BEGIN_LICENSE$
**
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain
** additional rights. These rights are described in the Nokia Qt LGPL
** Exception version 1.0, included in the file LGPL_EXCEPTION.txt in this
** package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
** $END_LICENSE$
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

#ifndef QTJAMBI_CORE_QHASHES_H
#define QTJAMBI_CORE_QHASHES_H

#include <qtjambi/qtjambi_global.h>
#include <QtCore/QtCore>
#include <qtjambi_core/qtjambiqfuture.h>

class QWidget;

template<class T>
hash_type genericHash(const T &value, hash_type seed = 0)
{
    return qHashBits(&value, sizeof(T), seed);
}

inline hash_type qHash(const QAbstractEventDispatcher::TimerInfo &value)
{
    return genericHash<QAbstractEventDispatcher::TimerInfo>(value);
}

inline bool operator==(const QAbstractEventDispatcher::TimerInfo &v1, const QAbstractEventDispatcher::TimerInfo &v2){
    return v1.interval==v2.interval
            && v1.timerId==v2.timerId
            && v1.timerType==v2.timerType;
}

inline hash_type qHash(const QMetaType &value)
{
    return qHash(value.id());
}

inline hash_type qHash(const QSizeF &size)
{
    hash_type hashCode = qHash(qint64(size.width()));
    hashCode = hashCode * 31 + qHash(qint64(size.height()));
    return hashCode;
}

inline hash_type qHash(const QByteArrayMatcher &value)
{
    return qHash(value.pattern());
}

inline bool operator==(const QByteArrayMatcher &value1, const QByteArrayMatcher &value2)
{
    return value1.pattern()==value2.pattern();
}

inline hash_type qHash(const QCalendar &value)
{
    return qHash(value.name());
}

inline bool operator==(const QCalendar &value1, const QCalendar &value2)
{
    return value1.name()==value2.name();
}

inline hash_type qHash(const QCalendar::YearMonthDay &value)
{
    return genericHash(value);
}

inline bool operator==(const QCalendar::YearMonthDay &value1, const QCalendar::YearMonthDay &value2)
{
    return value1.year==value2.year && value1.month==value2.month && value1.day==value2.day;
}

inline hash_type qHash(const QCborError &value)
{
    return qHash(QCborError::Code(value));
}

inline bool operator==(const QCborError &value1, const QCborError &value2)
{
    return QCborError::Code(value1)==QCborError::Code(value2);
}

inline hash_type qHash(const QCborParserError &value)
{
    hash_type hashCode = qHash(value.offset);
    hashCode = hashCode * 31 + qHash(value.error);
    return hashCode;
}

inline bool operator==(const QCborParserError &value1, const QCborParserError &value2)
{
    return value1.offset==value2.offset && value1.error==value2.error;
}

inline hash_type qHash(const QOperatingSystemVersion &value)
{
    hash_type hashCode = qHash(value.type());
    hashCode = hashCode * 31 + qHash(value.majorVersion());
    hashCode = hashCode * 31 + qHash(value.minorVersion());
    hashCode = hashCode * 31 + qHash(value.microVersion());
    return hashCode;
}

inline bool operator==(const QOperatingSystemVersion &value1, const QOperatingSystemVersion &value2)
{
    return value1.type()==value2.type()
            && value1.majorVersion()==value2.majorVersion()
            && value1.minorVersion()==value2.minorVersion()
            && value1.microVersion()==value2.microVersion();
}

inline hash_type qHash(const QCollator &value)
{
    hash_type hashCode = qHash(value.locale());
    hashCode = hashCode * 31 + qHash(value.caseSensitivity());
    hashCode = hashCode * 31 + qHash(value.numericMode());
    hashCode = hashCode * 31 + qHash(value.ignorePunctuation());
    return hashCode;
}

inline bool operator==(const QCollator &value1, const QCollator &value2)
{
    return value1.locale()==value2.locale()
            && value1.caseSensitivity()==value2.caseSensitivity()
            && value1.numericMode()==value2.numericMode()
            && value1.ignorePunctuation()==value2.ignorePunctuation();
}

inline hash_type qHash(const QDeadlineTimer &value)
{
    hash_type hashCode = qHash(value.timerType());
    hashCode = hashCode * 31 + qHash(value._q_data().first);
    hashCode = hashCode * 31 + qHash(value._q_data().second);
    return hashCode;
}

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
inline hash_type qHash(const QSize &size)
{
    hash_type hashCode = qHash(size.width());
    hashCode = hashCode * 31 + qHash(size.height());
    return hashCode;
}
#endif //QT_VERSION < QT_VERSION_CHECK(6, 0, 0)

inline hash_type qHash(const QPointF &point)
{
    hash_type hashCode = qHash(qint64(point.x()));
    hashCode = hashCode * 31 + qHash(qint64(point.y()));
    return hashCode;
}

inline hash_type qHash(const QFutureInterfaceBase &value)
{
    return qHash(quintptr(&value.resultStoreBase()));
}

inline hash_type qHash(const QFileInfo &fileInfo)
{
    return qHash(fileInfo.absoluteFilePath());
}

inline hash_type qHash(const QDir &dir)
{
    return qHash(dir.absolutePath());
}

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
inline hash_type qHash(const QRect &rect)
{
    hash_type hashCode = qHash(rect.left());
    hashCode = hashCode * 31 + qHash(rect.top());
    hashCode = hashCode * 31 + qHash(rect.right());
    hashCode = hashCode * 31 + qHash(rect.bottom());
    return hashCode;
}
#endif //QT_VERSION < QT_VERSION_CHECK(6, 0, 0)

inline hash_type qHash(const QRectF &rect)
{
    hash_type hashCode = qHash(rect.left());
    hashCode = hashCode * 31 + qHash(rect.top());
    hashCode = hashCode * 31 + qHash(rect.right());
    hashCode = hashCode * 31 + qHash(rect.bottom());
    return hashCode;
}

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
inline hash_type qHash(const QPoint &point)
{
    hash_type hashCode = qHash(point.x());
    hashCode = hashCode * 31 + qHash(point.y());
    return hashCode;
}
#endif

#if QT_VERSION < 0x050000
inline int qHash(const QDate &date)
{
    return date.toJulianDay();
}

inline int qHash(const QTime &time)
{
    int hashCode = time.hour();
    hashCode = hashCode * 31 + time.minute();
    hashCode = hashCode * 31 + time.second();
    hashCode = hashCode * 31 + time.msec();
    return hashCode;
}

inline int qHash(const QDateTime &dateTime)
{
    int hashCode = qHash(dateTime.date());
    hashCode = hashCode * 31 + qHash(dateTime.time());
    return hashCode;
}
#endif

inline hash_type qHash(const QLineF &line)
{
    hash_type hashCode = qHash(line.p1());
    hashCode = hashCode * 31 + qHash(line.p2());
    return hashCode;
}

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
inline hash_type qHash(const QPartialOrdering &value)
{
    return qHash(reinterpret_cast<const qint8&>(value));
}

inline hash_type qHash(const QItemSelectionRange &value)
{
    hash_type hashCode = qHash(value.topLeft());
    hashCode = hashCode * 31 + qHash(value.bottomRight());
    return hashCode;
}
#endif

inline hash_type qHash(const QJsonValueRef &value)
{
    hash_type hashCode = qHash(int(value.type()));
    switch(value.type()){
    case QJsonValue::Null:    hashCode = hashCode * 31; break;
    case QJsonValue::Bool:    hashCode = hashCode * 31 + qHash(value.toBool()); break;
    case QJsonValue::Double:    hashCode = hashCode * 31 + qHash(value.toDouble()); break;
    case QJsonValue::String:    hashCode = hashCode * 31 + qHash(value.toString()); break;
    case QJsonValue::Array:    hashCode = hashCode * 31 + qHash(value.toArray()); break;
    case QJsonValue::Object:    hashCode = hashCode * 31 + qHash(value.toObject()); break;
    default: break;
    }
    return hashCode;
}

inline hash_type qHash(const QItemSelection &value)
{
    hash_type hashCode = qHash(value.size());
    for(const QItemSelectionRange& r : value){
        hashCode = hashCode * 31 + qHash(r);
    }
    return hashCode;
}

#if QT_VERSION < QT_VERSION_CHECK(5, 12, 0)
hash_type qHash(const QJsonObject &value);
hash_type qHash(const QJsonArray &value);

inline hash_type qHash(const QJsonValue &value)
{
    hash_type hashCode = qHash(int(value.type()));
    switch(value.type()){
    case QJsonValue::Null:    hashCode = hashCode * 31; break;
    case QJsonValue::Bool:    hashCode = hashCode * 31 + qHash(value.toBool()); break;
    case QJsonValue::Double:    hashCode = hashCode * 31 + qHash(value.toDouble()); break;
    case QJsonValue::String:    hashCode = hashCode * 31 + qHash(value.toString()); break;
    case QJsonValue::Array:    hashCode = hashCode * 31 + qHash(value.toArray()); break;
    case QJsonValue::Object:    hashCode = hashCode * 31 + qHash(value.toObject()); break;
    default: break;
    }
    return hashCode;
}

inline hash_type qHash(const QJsonObject &value)
{
    hash_type hashCode = qHash(value.keys().size());
    for(const QString& key : value.keys()){
        hashCode = hashCode * 31 + qHash(key);
//        hashCode = hashCode * 31 + qHash(value[key]);
    }
    return hashCode;
}

inline hash_type qHash(const QJsonArray &value)
{
    hash_type hashCode = qHash(value.size());
    for(const QJsonValue& r : value){
        hashCode = hashCode * 31 + qHash(r);
    }
    return hashCode;
}
#endif

inline hash_type qHash(const QJsonDocument &value)
{
    hash_type hashCode = qHash(value.isArray());
    hashCode = hashCode * 31 + qHash(value.isObject());
    hashCode = hashCode * 31 + qHash(value.isNull());
    hashCode = hashCode * 31 + qHash(value.isEmpty());
    if(value.isArray()){
        hashCode = hashCode * 31 + qHash(value.array());
    }else if(value.isObject()){
        hashCode = hashCode * 31 + qHash(value.object());
    }
    return hashCode;
}

inline hash_type qHash(const QEasingCurve &curve)
{
    hash_type hashCode = qHash(curve.amplitude());
    hashCode = hashCode * 31 + qHash(curve.period());
    hashCode = hashCode * 31 + qHash(curve.overshoot());
    hashCode = hashCode * 31 + qHash(int(curve.type()));
    if(curve.type()==QEasingCurve::Custom){
        hashCode = hashCode * 31 + qHash(qint64( reinterpret_cast<const void*>(curve.customType() )));
    }
    return hashCode;
}

inline hash_type qHash(const QLine &line)
{
    hash_type hashCode = qHash(line.p1());
    hashCode = hashCode * 31 + qHash(line.p2());
    return hashCode;
}

inline hash_type qHash(const QMargins &value)
{
    hash_type hashCode = qHash(value.top());
    hashCode = hashCode * 31 + qHash(value.right());
    hashCode = hashCode * 31 + qHash(value.bottom());
    hashCode = hashCode * 31 + qHash(value.left());
    return hashCode;
}

inline hash_type qHash(const QMarginsF &value)
{
    hash_type hashCode = qHash(value.top());
    hashCode = hashCode * 31 + qHash(value.right());
    hashCode = hashCode * 31 + qHash(value.bottom());
    hashCode = hashCode * 31 + qHash(value.left());
    return hashCode;
}

inline hash_type qHash(const QXmlStreamAttribute &value)
{
    hash_type hashCode = qHash(value.name());
    hashCode = hashCode * 31 + qHash(value.namespaceUri());
    hashCode = hashCode * 31 + qHash(value.prefix());
    hashCode = hashCode * 31 + qHash(value.qualifiedName());
    hashCode = hashCode * 31 + qHash(value.value());
    hashCode = hashCode * 31 + qHash(value.isDefault());
    return hashCode;
}

inline hash_type qHash(const QXmlStreamAttributes &value)
{
    hash_type hashCode = qHash(value.size());
    for(const QXmlStreamAttribute& a : value){
        hashCode = hashCode * 31 + qHash(a);
    }
    return hashCode;
}

inline hash_type qHash(const QTimeZone &value)
{
    hash_type hashCode = qHash(value.id());
    return hashCode;
}

#if QT_CONFIG(processenvironment)
inline hash_type qHash(const QProcessEnvironment &value)
{
    hash_type hashCode = qHash(value.keys().size());
    for(const QString& key : value.keys()){
        hashCode = hashCode * 31 + qHash(key);
        hashCode = hashCode * 31 + qHash(value.value(key));
    }
    return hashCode;
}
#endif

inline hash_type qHash(const QXmlStreamEntityDeclaration &value)
{
    hash_type hashCode = qHash(value.name());
    hashCode = hashCode * 31 + qHash(value.notationName());
    hashCode = hashCode * 31 + qHash(value.publicId());
    hashCode = hashCode * 31 + qHash(value.systemId());
    hashCode = hashCode * 31 + qHash(value.value());
    return hashCode;
}

inline hash_type qHash(const QXmlStreamNamespaceDeclaration &value)
{
    hash_type hashCode = qHash(value.namespaceUri());
    hashCode = hashCode * 31 + qHash(value.prefix());
    return hashCode;
}

inline hash_type qHash(const QXmlStreamNotationDeclaration &value)
{
    hash_type hashCode = qHash(value.name());
    hashCode = hashCode * 31 + qHash(value.publicId());
    hashCode = hashCode * 31 + qHash(value.systemId());
    return hashCode;
}

hash_type qHash(const QMetaMethod &value);

inline hash_type qHash(const QStorageInfo &value)
{
    hash_type hashCode = qHash(value.name());
    hashCode = hashCode * 31 + qHash(value.rootPath());
    hashCode = hashCode * 31 + qHash(value.device());
    hashCode = hashCode * 31 + qHash(value.isRoot());
    hashCode = hashCode * 31 + qHash(value.isReady());
    hashCode = hashCode * 31 + qHash(value.isValid());
    hashCode = hashCode * 31 + qHash(value.blockSize());
    hashCode = hashCode * 31 + qHash(value.subvolume());
    hashCode = hashCode * 31 + qHash(value.isReadOnly());
    hashCode = hashCode * 31 + qHash(value.displayName());
    return hashCode;
}

inline hash_type qHash(const QElapsedTimer &value)
{
    struct ElapsedTimer{
        qint64 t1;
        qint64 t2;
    };
    const ElapsedTimer* t = reinterpret_cast<const ElapsedTimer*>(&value);
    hash_type hashCode = qHash(t->t1);
    hashCode = hashCode * 31 + qHash(t->t2);
    return hashCode;
}

inline hash_type qHash(const QVoidFuture &value)
{
    struct Future{
        QFutureInterfaceBase d;
    };
    return qHash(reinterpret_cast<const Future*>(&value)->d);
}

inline hash_type qHash(const QtJambiFuture &value)
{
    struct Future{
        QFutureInterfaceBase d;
    };
    return qHash(reinterpret_cast<const Future*>(&value)->d);
}

inline hash_type qHash(const QMetaObject &value)
{
    return hash_type(31 * 1 + (qintptr(&value) ^ (qintptr(&value) >> 32)));
}

inline hash_type qHash(const QMetaEnum &value)
{
    if(!value.isValid())
        return 0;
    hash_type prime = 31;
    hash_type result = 1;
    result = prime * result + qHash(value.enclosingMetaObject());
    result = prime * result + hash_type(value.enclosingMetaObject()->indexOfEnumerator(value.name()));
    return result;
}

inline hash_type qHash(const QMetaMethod &value)
{
    if(!value.isValid())
        return 0;
    hash_type prime = 31;
    hash_type result = 1;
    result = prime * result + qHash(value.enclosingMetaObject());
    result = prime * result + hash_type(value.methodIndex());
    return result;
}

inline hash_type qHash(const QMetaProperty &value)
{
    if(!value.isValid())
        return 0;
    hash_type prime = 31;
    hash_type result = 1;
    result = prime * result + qHash(value.enclosingMetaObject());
    result = prime * result + hash_type(value.propertyIndex());
    return result;
}

inline bool operator==(const QMetaEnum &value1, const QMetaEnum &value2)
{
    return value1.enclosingMetaObject()==value2.enclosingMetaObject()
            && value1.enclosingMetaObject()->indexOfEnumerator(value1.name())==value2.enclosingMetaObject()->indexOfEnumerator(value2.name());
}

inline bool operator==(const QMetaProperty &value1, const QMetaProperty &value2)
{
    return value1.enclosingMetaObject()==value2.enclosingMetaObject()
            && value2.propertyIndex()==value2.propertyIndex();
}

#endif // QTJAMBI_CORE_QHASHES_H 
