/****************************************************************************
**
** Copyright (C) 1992-2009 Nokia. All rights reserved.
** Copyright (C) 2009-2021 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
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

#include "qtjambi_core.h"
#include "qtjambi_repository_p.h"
#include "qtjambi_thread_p.h"
#include "qtjambi_registry.h"
#include "qtjambi_registry_p.h"
#include "qtjambilink_p.h"
#include "qtjambitypemanager_p.h"
#include "qtjambimetaobject_p.h"
#include "qtjambi_application.h"

#include <cstring>
#include <QtCore/QMetaType>
#include <QtCore/QRect>
#include <QtCore/QTime>
#include <QtCore/QSize>
#include <QtCore/QBasicTimer>
#include <QtCore/QTextStream>
#include <QtCore/QFileInfo>
#include <QtCore/QThreadStorage>

#include <QtGui/QMouseEvent>
#include <QtGui/QColor>
#include <QtGui/QPalette>
#include <QtGui/QCursor>
#include <QtGui/QIcon>
#include <QtGui/QPainter>
#include <QtGui/QPolygon>
#include <QtCore/QMetaObject>
#include <QtCore/QMetaProperty>
#include <QtCore/private/qmetaobject_p.h>

#include <QDebug>
#include "qtjambi_cast.h"

typedef QHash<const QMetaObject *, jweak> JavaMetaObjectHash;
Q_GLOBAL_STATIC(JavaMetaObjectHash, javaMetaObjects);
Q_GLOBAL_STATIC(QRecursiveMutex, javaMetaObjectsLock);


typedef QHash<hash_type,const QMetaObject *> MetaObjectByNameHash;
Q_GLOBAL_STATIC(MetaObjectByNameHash, metaObjectsByName);

const QMetaObject * findMetaObject(const char* name){
    const QMetaObject* metaObject = nullptr;
    if(const std::type_info* typeId = getTypeByQtName(name)){
        metaObject = registeredOriginalMetaObject(*typeId);
    }
    if(!metaObject)
        metaObject = metaObjectsByName()->value(qHash(name), nullptr);
    return metaObject;
}

jobject qtjambi_from_QMetaObject(JNIEnv *env, const QMetaObject *metaObject){
    if(const QtJambiMetaObject* dyMetaObject = QtJambiMetaObject::cast(metaObject)){
        jweak javaInstance = QtJambiMetaObject::javaInstance(dyMetaObject);
        if(env->IsSameObject(javaInstance, nullptr)){
            jobject jmetaObject = Java::QtCore::QMetaObject::newInstance(env, jlong(reinterpret_cast<const void*>(metaObject)));
            QtJambiMetaObject::setJavaInstance(dyMetaObject, env->NewWeakGlobalRef(jmetaObject));
            return jmetaObject;
        }else{
            return env->NewLocalRef(javaInstance);
        }
    }else{
        QRecursiveMutexLocker locker(javaMetaObjectsLock());
        Q_UNUSED(locker)
        jweak javaInstance = javaMetaObjects->value(metaObject, nullptr);
        if(env->IsSameObject(javaInstance, nullptr)){
            jobject jmetaObject = Java::QtCore::QMetaObject::newInstance(env, jlong(reinterpret_cast<const void*>(metaObject)));
            javaMetaObjects->insert(metaObject, env->NewWeakGlobalRef(jmetaObject));
            QLatin1String javaName;
            if(const std::type_info* typeId = getTypeByMetaObject(metaObject)){
                javaName = QLatin1String(getJavaName(*typeId));
            }
            if(javaName.isEmpty()){
                if(const std::type_info* typeId = getTypeByQtName(metaObject->className()))
                    javaName = QLatin1String(getJavaName(*typeId));
            }
            if(javaName.isEmpty()){
                metaObjectsByName->insert(qHash(metaObject->className()), metaObject);
            }
            return jmetaObject;
        }else{
            return env->NewLocalRef(javaInstance);
        }
    }
}

const char * registeredInterfaceID(const std::type_info& typeId);

jobject qtjambi_metaobject_cast(JNIEnv *env, QtJambiNativeID object__id, jclass targetType){
    jobject result = nullptr;
    QSharedPointer<QtJambiLink> objectLink = QtJambiLink::fromNativeId(object__id);
    if(objectLink){
        QString javaName = qtjambi_class_name(env, targetType).replace(QLatin1Char('.'), QLatin1Char('/'));
        if(const std::type_info* typeId = getTypeByJavaName(javaName)){
            void* basicPointer = objectLink->pointer();
            void* interfacePointer = nullptr;
            if(objectLink->isQObject()){
                if(Java::Runtime::Class::isInterface(env, targetType)){
                    if(const char* iid = registeredInterfaceID(*typeId)){
                        interfacePointer = objectLink->qobject()->qt_metacast(iid);
                    }
                }
                if(!interfacePointer)
                    interfacePointer = objectLink->qobject()->qt_metacast(getQtName(*typeId));
                if(!interfacePointer){
                    interfacePointer = objectLink->typedPointer(*typeId);
                    if(interfacePointer==basicPointer)
                        interfacePointer = nullptr;
                }
            }else{
                interfacePointer = objectLink->typedPointer(*typeId);
                if(interfacePointer==basicPointer)
                    interfacePointer = nullptr;
            }
            if(interfacePointer){
                if(interfacePointer!=basicPointer){
                    for(QSharedPointer<QtJambiLink> link : QtJambiLink::findLinksForPointer(interfacePointer)){
                        if(link && link!=objectLink){
                            jobject obj = link->getJavaObjectLocalRef(env);
                            if(!obj && link->ownership()==QtJambiLink::Ownership::Split){
                                link->invalidate(env);
                            }else if(env->IsInstanceOf(obj, targetType)){
                                return obj;
                            }
                        }
                    }
                }else if(!objectLink->createdByJava() && objectLink->isQObject() && Java::QtCore::QObject::isAssignableFrom(env, targetType)){
                    if(jobject obj = objectLink->getJavaObjectLocalRef(env)){
                        if(!env->IsInstanceOf(obj, targetType)){
                            objectLink->invalidate(env);
                        }else return obj;
                    }
                }
                if(const QtJambiTypeEntry* typeEntry = QtJambiTypeEntry::getTypeEntry(env, *typeId)){
                    result = env->NewObject(typeEntry->creatableClass(), typeEntry->creatorMethod(), 0);
                    qtjambi_throw_java_exception(env)
                    QtJambiLink::createLinkForInterface(env, result, interfacePointer,
#if defined(QTJAMBI_DEBUG_TOOLS) || defined(QTJAMBI_LINK_NAME) || !defined(QT_NO_DEBUG)
                                                        getQtName(*typeId),
#endif
                                                        objectLink);
                }else{
                    result = qtjambi_from_object(env, interfacePointer, targetType, false, false);
                }
            }
        }else{
            void* basicPointer = objectLink->pointer();
            void* interfacePointer = nullptr;
            if(objectLink->isQObject()){
                interfacePointer = objectLink->qobject()->qt_metacast(qPrintable(javaName.replace("/", "::").replace("$", "::")));
                if(interfacePointer){
                    if(interfacePointer!=basicPointer){
                        for(QSharedPointer<QtJambiLink> link : QtJambiLink::findLinksForPointer(interfacePointer)){
                            if(link && link!=objectLink){
                                jobject obj = link->getJavaObjectLocalRef(env);
                                if(!obj && link->ownership()==QtJambiLink::Ownership::Split){
                                    link->invalidate(env);
                                }else if(env->IsInstanceOf(obj, targetType)){
                                    return obj;
                                }
                            }
                        }
                    }else if(!objectLink->createdByJava() && objectLink->isQObject() && Java::QtCore::QObject::isAssignableFrom(env, targetType)){
                        if(jobject obj = objectLink->getJavaObjectLocalRef(env)){
                            if(!env->IsInstanceOf(obj, targetType)){
                                objectLink->invalidate(env);
                            }else return obj;
                        }
                    }
                    result = qtjambi_from_object(env, interfacePointer, targetType, false, false);
                }
            }
        }
    }
    return result;
}

QMetaMethod qtjambi_metaobject_get_method(const QMetaObject *metaObject, const QString& sig){
    QMetaMethod method;
    if(metaObject){
        method = metaObject->method(metaObject->indexOfMethod(qPrintable(sig)));
        if(!method.isValid()){
            QString methodName;
            QStringList arguments = QtJambiTypeManager::parseSignature(sig, &methodName);
            const int methodCount = metaObject->methodCount();
            for(int i=0; i<methodCount; ++i){
                QMetaMethod _method = metaObject->method(i);
                QString qmethodName = _method.name();
                if(const QHash<int,const char*>* _renamedMethods = renamedMethods(_method.enclosingMetaObject())){
                    if(const char* newName = _renamedMethods->value(_method.methodIndex(), nullptr)){
                        qmethodName = QLatin1String(newName);
                    }
                }
                const int parameterCount = _method.parameterCount();
                if(qmethodName==methodName && arguments.size()==parameterCount+1){
                    QList<QByteArray> parameterTypes = _method.parameterTypes();
                    bool found = true;
                    for(int p=0; p<parameterCount; ++p){
                        if(_method.parameterType(p)==QMetaType::UnknownType){
                            if(QMetaObject::normalizedType(arguments.at(p+1).toLatin1())!=parameterTypes.at(p)){
                                QString arg = arguments.at(p+1);
                                if(arg.startsWith("const ") && arg.endsWith("&")){
                                    arg = arg.mid(6).chopped(1).trimmed();
                                    if(arg.toLatin1()==parameterTypes.at(p)){
                                        continue;
                                    }
                                }
                                found = false;
                                break;
                            }
                        }else{
                            if(_method.parameterType(p) != QMetaType::type(qPrintable(arguments.at(p+1)))){
                                found = false;
                                break;
                            }
                        }
                    }
                    if(found){
                        method = _method;
                        break;
                    }
                }
            }
        }
    }
    return method;
}

jobject qtjambi_metaobject_new_instance(JNIEnv *env, jlong metaObjectPointer, jint methodIndex, jobject argTypes, jobjectArray args){
    const QMetaObject *metaObject = reinterpret_cast<const QMetaObject *>(metaObjectPointer);
    if(metaObject){
        QtJambiScope scope(nullptr);
        env->EnsureLocalCapacity(500);
        QMetaMethod method = metaObject->method(methodIndex);
        if(!method.isValid()){
            for(int i=0; i<metaObject->constructorCount(); ++i){
                QMetaMethod constr = metaObject->constructor(i);
                if(constr.methodIndex()==methodIndex){
                    method = constr;
                    break;
                }
            }
        }
        if(method.isValid()){
            const QList<ParameterTypeInfo>& parameterTypeInfos = QtJambiMetaObject::methodParameterInfo(env, method);
            jobjectArray argTypesArray = jobjectArray(argTypes);
            int argsCount = env->GetArrayLength(args);
            const int parameterCount = method.parameterCount();
            if(parameterCount==env->GetArrayLength(argTypesArray) && parameterCount==argsCount && argsCount<10){
                QGenericArgument val[10];
                QList<QByteArray> parameterTypes = method.parameterTypes();
                bool failed = false;
                for(int i=0; i<argsCount; ++i){
                    jvalue jval;
                    jval.l = env->GetObjectArrayElement(args, i);
                    void* qtPtr = nullptr;
                    const ParameterTypeInfo& parameterTypeInfo = parameterTypeInfos[i+1];
                    if(!parameterTypeInfo.convertExternalToInternal(env, &scope, jval, qtPtr, jValueType::l)){
                        failed = true;
                        break;
                    }
                    val[i] = QGenericArgument(parameterTypes[i].constData(), qtPtr);
                }
                QObject* obj = nullptr;
                if(!failed){
                    obj = metaObject->newInstance(
                                        val[0],
                                        val[1],
                                        val[2],
                                        val[3],
                                        val[4],
                                        val[5],
                                        val[6],
                                        val[7],
                                        val[8],
                                        val[9]);
                }
                if(obj){
                    if(metaObject->inherits(&QObject::staticMetaObject)){
                        return qtjambi_from_QObject(env, obj);
                    }else{
                        if(const QtJambiMetaObject* dynamicMetaObject = QtJambiMetaObject::cast(metaObject)){
                            if(Java::QtJambi::QtObjectInterface::isAssignableFrom(env, dynamicMetaObject->javaClass())){
                                return qtjambi_from_object(env, obj, dynamicMetaObject->javaClass(), false, false);
                            }else{
                                return reinterpret_cast<jobject>(obj);
                            }
                        }else if(const std::type_info* typeId = getTypeByQtName(metaObject->className())){
                            return qtjambi_from_object(env, obj, *typeId, false, false);
                        }
                    }
                }
            }
        }
    }
    return nullptr;
}

class ConnectionAccess{
public: void *d_ptr;
};

extern "C" Q_DECL_EXPORT jboolean JNICALL
QTJAMBI_FUNCTION_PREFIX(Java_io_qt_internal_QtJambiSignals_00024NativeConnection_isConnected)
    (JNIEnv *env, jclass, QtJambiNativeID nativeId)
{
    try{
        QMetaObject::Connection* connection = qtjambi_object_from_nativeId<QMetaObject::Connection>(nativeId);
        if(*connection)
            return true;
    }catch(const JavaException& exn){
        exn.raiseInJava(env);
    }
    return false;
}

extern "C" Q_DECL_EXPORT jboolean JNICALL
QTJAMBI_FUNCTION_PREFIX(Java_io_qt_internal_QtJambiSignals_00024NativeConnection_equals)
    (JNIEnv *env, jclass, QtJambiNativeID nativeId, QtJambiNativeID otherNativeId)
{
    try{
        QMetaObject::Connection* connection = qtjambi_object_from_nativeId<QMetaObject::Connection>(nativeId);
        QMetaObject::Connection* otherConnection = qtjambi_object_from_nativeId<QMetaObject::Connection>(otherNativeId);
        if(connection && otherConnection){
            void * ptr1 = reinterpret_cast<ConnectionAccess*>(connection)->d_ptr;
            void * ptr2 = reinterpret_cast<ConnectionAccess*>(otherConnection)->d_ptr;
            QObjectPrivate::Connection* _ptr1 = reinterpret_cast<QObjectPrivate::Connection*>(ptr1);
            QObjectPrivate::Connection* _ptr2 = reinterpret_cast<QObjectPrivate::Connection*>(ptr2);
            return _ptr1==_ptr2;
        }
    }catch(const JavaException& exn){
        exn.raiseInJava(env);
    }
    return false;
}

QObject* connectionSender(const QMetaObject::Connection* connection){
    if(connection && *connection){
        void * ptr = reinterpret_cast<const ConnectionAccess*>(connection)->d_ptr;
        return reinterpret_cast<QObjectPrivate::Connection*>(ptr)->sender;
    }
    return nullptr;
}

extern "C" Q_DECL_EXPORT jobject JNICALL
QTJAMBI_FUNCTION_PREFIX(Java_io_qt_internal_QtJambiSignals_00024NativeConnection_sender)
    (JNIEnv * env, jclass, QtJambiNativeID nativeId)
{
    try{
        QMetaObject::Connection* connection = qtjambi_object_from_nativeId<QMetaObject::Connection>(nativeId);
        return qtjambi_from_QObject(env, connectionSender(connection));
    }catch(const JavaException& exn){
        exn.raiseInJava(env);
    }
    return nullptr;
}

extern "C" Q_DECL_EXPORT jobject JNICALL
QTJAMBI_FUNCTION_PREFIX(Java_io_qt_internal_QtJambiSignals_00024NativeConnection_receiver)
    (JNIEnv * env, jclass, QtJambiNativeID nativeId)
{
    try{
        QMetaObject::Connection* connection = qtjambi_object_from_nativeId<QMetaObject::Connection>(nativeId);
        if(*connection){
            void * ptr = reinterpret_cast<ConnectionAccess*>(connection)->d_ptr;
            QObjectPrivate::Connection* _ptr = reinterpret_cast<QObjectPrivate::Connection*>(ptr);
            QObject* receiver = _ptr->receiver;
            return qtjambi_from_QObject(env, receiver);
        }
    }catch(const JavaException& exn){
        exn.raiseInJava(env);
    }
    return nullptr;
}

extern "C" Q_DECL_EXPORT jobject JNICALL
QTJAMBI_FUNCTION_PREFIX(Java_io_qt_internal_QtJambiSignals_00024NativeConnection_signal)
    (JNIEnv * env, jclass, QtJambiNativeID nativeId)
{
    try{
        QMetaObject::Connection* connection = qtjambi_object_from_nativeId<QMetaObject::Connection>(nativeId);
        if(*connection){
            env->EnsureLocalCapacity(100);
            void * ptr = reinterpret_cast<ConnectionAccess*>(connection)->d_ptr;
            QObject* sender = reinterpret_cast<QObjectPrivate::Connection*>(ptr)->sender;
            QMetaMethod signal = QMetaObjectPrivate::signal(sender->metaObject(), reinterpret_cast<QObjectPrivate::Connection*>(ptr)->signal_index);
            return qtjambi_cast<jobject>(env, signal);
        }
    }catch(const JavaException& exn){
        exn.raiseInJava(env);
    }
    return nullptr;
}

extern "C" Q_DECL_EXPORT jobject JNICALL
QTJAMBI_FUNCTION_PREFIX(Java_io_qt_internal_QtJambiSignals_00024NativeConnection_method)
    (JNIEnv * env, jclass, QtJambiNativeID nativeId)
{
    try{
        QMetaObject::Connection* connection = qtjambi_object_from_nativeId<QMetaObject::Connection>(nativeId);
        if(*connection){
            env->EnsureLocalCapacity(100);
            void * ptr = reinterpret_cast<ConnectionAccess*>(connection)->d_ptr;
            QObjectPrivate::Connection* cnn = reinterpret_cast<QObjectPrivate::Connection*>(ptr);
            if(!cnn->isSlotObject){
                QObject* receiver = cnn->receiver;
                QMetaMethod method = receiver->metaObject()->method(reinterpret_cast<QObjectPrivate::Connection*>(ptr)->method());
                return qtjambi_cast<jobject>(env, method);
            }
        }
    }catch(const JavaException& exn){
        exn.raiseInJava(env);
    }
    return nullptr;
}

extern "C" Q_DECL_EXPORT jboolean JNICALL
QTJAMBI_FUNCTION_PREFIX(Java_io_qt_internal_QtJambiSignals_00024NativeConnection_isSlotObject)
    (JNIEnv * env, jclass, QtJambiNativeID nativeId)
{
    try{
        QMetaObject::Connection* connection = qtjambi_object_from_nativeId<QMetaObject::Connection>(nativeId);
        if(*connection){
            void * ptr = reinterpret_cast<ConnectionAccess*>(connection)->d_ptr;
            QObjectPrivate::Connection* _ptr = reinterpret_cast<QObjectPrivate::Connection*>(ptr);
            return _ptr->isSlotObject;
        }
    }catch(const JavaException& exn){
        exn.raiseInJava(env);
    }
    return false;
}

extern "C" Q_DECL_EXPORT void JNICALL
QTJAMBI_FUNCTION_PREFIX(Java_io_qt_internal_QtJambiSignals_emitNativeSignal)
(JNIEnv *env,
 jclass,
 QtJambiNativeID senderNativeId,
 jint methodIndex,
 jobjectArray args)
{
    QTJAMBI_DEBUG_METHOD_PRINT("java", "QtJambiSignals::emitNativeSignal(...)")
    QTJAMBI_JNI_LOCAL_FRAME(env, 1000)
    QtJambiScope scope(senderNativeId);
    try{
        QSharedPointer<QtJambiLink> link = QtJambiLink::fromNativeId(senderNativeId);
        if (link && link->isQObject()) {
            if(QObject *o = link->qobject()){
                QMetaMethod method = o->metaObject()->method(methodIndex);
                if(method.isValid()){
                    const QList<ParameterTypeInfo>& parameterTypeInfos = QtJambiMetaObject::methodParameterInfo(env, method);
                    QVector<void *> convertedArguments;
                    bool failed = false;
                    int size = args ? env->GetArrayLength(args) : 0;
                    convertedArguments.fill(nullptr, size+1);
                    for (int i = 0; i < size; ++i) {
                        const ParameterTypeInfo& parameterTypeInfo = parameterTypeInfos[i+1];
                        jvalue jv;
                        jv.l = env->GetObjectArrayElement(args, i);
                        if(!parameterTypeInfo.convertExternalToInternal(env, &scope, jv, convertedArguments[i+1], jValueType::l)){
                            failed = true;
                            break;
                        }
                    }
                    if (!failed) {
                        Q_ASSERT(method.isValid());
                        int signalIndex = QMetaObjectPrivate::signalIndex(method);
                        Q_ASSERT(signalIndex>=0);
                        if(signalIndex>=0)
                            QMetaObject::activate(o, 0, signalIndex, convertedArguments.data());
                    }
                }
            }
        }
    }catch(const JavaException& exn){
        exn.raiseInJava(env);
    }
}

class NativeSlotObject : public QtPrivate::QSlotObjectBase
{
public:
    NativeSlotObject(JNIEnv * env, const QSharedPointer<QtJambiLink>& link, const QMetaMethod& signal, jobject connection, jint argumentCount, jint connectionType, bool nothrow, QObject* receiver = nullptr);
    ~NativeSlotObject();
    int* types();
private:
    static void impl(int which, QSlotObjectBase *this_, QObject *r, void **a, bool *ret);
    QMetaMethod m_signal;
    QWeakPointer<QtJambiLink> m_link;
    JObjectWrapper m_connection;
    int m_argumentCount;
    int* const m_types;
    QObject* m_receiver;
    bool m_nothrow;
};

extern "C" Q_DECL_EXPORT jobject JNICALL
QTJAMBI_FUNCTION_PREFIX(Java_io_qt_internal_QtJambiSignals_connectNative)
    (JNIEnv * env, jclass, QtJambiNativeID senderObjectId, jint signal, jobject connection, jint argumentCount, jint connectionType)
{
    try{
        QSharedPointer<QtJambiLink> senderLink = QtJambiLink::fromNativeId(senderObjectId);
        NativeSlotObject *slotObj;
        QObject* sender = senderLink->qobject();
        QMetaMethod qt_signalMethod = sender->metaObject()->method(signal);
        QObject* receiver = sender;
        connectionType = connectionType & ~Qt::UniqueConnection;
        if(connectionType==Qt::AutoConnection || connectionType==Qt::DirectConnection){
            connectionType = Qt::DirectConnection;
            receiver = new QObject();
            receiver->moveToThread(nullptr);
        }else if(qt_signalMethod.enclosingMetaObject()==&QThread::staticMetaObject && QThreadData::get2(static_cast<QThread*>(sender))->isAdopted){
            QString _connectionType;
            if(connectionType==Qt::BlockingQueuedConnection){
                _connectionType = "BlockingQueuedConnection";
            }else{
                _connectionType = "QueuedConnection";
            }
            JavaException::raiseIllegalStateException(env, qPrintable(QString("Cannot use signal QThread::%1 from adopted thread with connection type %2.").arg(qt_signalMethod.methodSignature().data()).arg(_connectionType)) QTJAMBI_STACKTRACEINFO);
            return nullptr;
        }
        int signalIndex = QMetaObjectPrivate::signalIndex(qt_signalMethod);
        slotObj = new NativeSlotObject(env, senderLink, qt_signalMethod, connection, argumentCount, connectionType, signalIndex==0, receiver == sender ? nullptr : receiver);
        QMetaObject::Connection c = QObjectPrivate::connectImpl(sender,
                                                                signalIndex,
                                                                receiver,
                                                                nullptr,
                                                                slotObj,
                                                                Qt::ConnectionType(connectionType),
                                                                slotObj->types(),
                                                                qt_signalMethod.enclosingMetaObject());
        return c ? qtjambi_cast<jobject>(env, c) : nullptr;
    }catch(const JavaException& exn){
        exn.raiseInJava(env);
    }
    return nullptr;
}

extern "C" Q_DECL_EXPORT jobject JNICALL
QTJAMBI_FUNCTION_PREFIX(Java_io_qt_internal_QtJambiSignals_connectNativeToMetaMethod)
    (JNIEnv * env, jclass, QtJambiNativeID senderObjectId, jint signal, QtJambiNativeID receiverObjectId, jint slot, jint connectionType)
{
    try{
        QSharedPointer<QtJambiLink> senderLink = QtJambiLink::fromNativeId(senderObjectId);
        QSharedPointer<QtJambiLink> receiverLink = QtJambiLink::fromNativeId(receiverObjectId);
        QObject* sender = senderLink ? senderLink->qobject() : nullptr;
        QMetaMethod signalMethod;
        if(signal)
            signalMethod = sender->metaObject()->method(signal);
        QObject* receiver = receiverLink ? receiverLink->qobject() : nullptr;
        QMetaMethod slotMethod;
        if(receiver)
            slotMethod = receiver->metaObject()->method(slot);
        if(!QMetaObject::checkConnectArgs(signalMethod, slotMethod)){
            QString message("Signal and slot signatures misfit: %1 != %2");
            message = message.arg(QLatin1String(signalMethod.methodSignature())).arg(QLatin1String(slotMethod.methodSignature()));
            jthrowable t = Java::QtJambi::QMisfittingSignatureException::newInstance(env, qtjambi_from_qstring(env, message));
            env->Throw(t);
            return nullptr;
        }
        QMetaObject::Connection c = QObject::connect(sender, signalMethod, receiver, slotMethod, Qt::ConnectionType(connectionType));
        if(c){
            return qtjambi_cast<jobject>(env, c);
        }
    }catch(const JavaException& exn){
        exn.raiseInJava(env);
    }
    return nullptr;
}

extern "C" Q_DECL_EXPORT jboolean JNICALL
QTJAMBI_FUNCTION_PREFIX(Java_io_qt_internal_QtJambiSignals_disconnectNative)
    (JNIEnv *env, jclass, QtJambiNativeID senderObjectId, jint signal, QtJambiNativeID receiverObjectId, jint slot)
{
    try{
        QSharedPointer<QtJambiLink> senderLink = QtJambiLink::fromNativeId(senderObjectId);
        QSharedPointer<QtJambiLink> receiverLink = QtJambiLink::fromNativeId(receiverObjectId);
        QObject* sender = senderLink ? senderLink->qobject() : nullptr;
        QMetaMethod signalMethod;
        if(signal)
            signalMethod = sender->metaObject()->method(signal);
        QObject* receiver = receiverLink ? receiverLink->qobject() : nullptr;
        QMetaMethod slotMethod;
        if(receiver)
            slotMethod = receiver->metaObject()->method(slot);
        return QObject::disconnect(sender, signalMethod, receiver, slotMethod);
    }catch(const JavaException& exn){
        exn.raiseInJava(env);
    }
    return false;
}

NativeSlotObject::NativeSlotObject(JNIEnv * env, const QSharedPointer<QtJambiLink>& link, const QMetaMethod& signal, jobject connection, jint argumentCount, jint connectionType, bool nothrow, QObject* receiver)
    : QSlotObjectBase(&NativeSlotObject::impl),
      m_signal(signal),
      m_link(link),
      m_connection(env, connection),
      m_argumentCount(argumentCount),
      m_types(
          [](JNIEnv * env, const QMetaMethod& signal, jint connectionType)->int*{
          if (connectionType == Qt::QueuedConnection || connectionType == Qt::BlockingQueuedConnection){
              const QList<ParameterTypeInfo>& parameterTypeInfos = QtJambiMetaObject::methodParameterInfo(env, signal);
              if(parameterTypeInfos.size()>1){
                  int *types = new int[size_t(parameterTypeInfos.size())];
                  for (int i = 0; i < parameterTypeInfos.size(); ++i) {
                      if(i == parameterTypeInfos.size()-1){
                          types[i] = 0;
                      }else{
                          types[i] = parameterTypeInfos[i+1].metaType();
                      }
                  }
                  return types;
              }
            }
            return nullptr;
          }(env, signal, connectionType)
      ),
      m_receiver(receiver),
      m_nothrow(nothrow)
{
}

NativeSlotObject::~NativeSlotObject()
{
    if(m_types)
        delete[] m_types;
    if(m_receiver)
        delete m_receiver;
}

int* NativeSlotObject::types() { return m_types; }

void NativeSlotObject::impl(int which, QSlotObjectBase *this_, QObject *, void **a, bool *ret){
    switch (which) {
    case Destroy:
        delete static_cast<NativeSlotObject*>(this_);
        break;
    case Call:{
            NativeSlotObject* _this = static_cast<NativeSlotObject*>(this_);
            if(QSharedPointer<QtJambiLink> link = _this->m_link.toStrongRef()){
                if(JNIEnv* env = qtjambi_current_environment()){
                    QTJAMBI_JNI_LOCAL_FRAME(env, 200)
                    QtJambiLinkScope scope(link);
                    try{
                        if(link->isQObject()){
                            const QList<ParameterTypeInfo>& parameterTypeInfos = QtJambiMetaObject::methodParameterInfo(env, _this->m_signal);
                            if(parameterTypeInfos.size()){
                                QVector<jvalue> converted_arguments(_this->m_argumentCount<0 ? parameterTypeInfos.size()-1 : qMin(_this->m_argumentCount, parameterTypeInfos.size()-1));

                                bool success = true;
                                for (int i = 0; i < converted_arguments.size(); ++i) {
                                    const ParameterTypeInfo& parameterTypeInfo = parameterTypeInfos[i+1];
                                    converted_arguments[i].l = nullptr;
                                    if(!parameterTypeInfo.convertInternalToExternal(env, &scope, a[i+1], &converted_arguments[i], true)){
                                        success = false;
                                        break;
                                    }
                                }
                                if (success) {
                                    jobjectArray args = Java::Runtime::Object::newArray(env, jsize(converted_arguments.size()));
                                    for (int i=0; i<converted_arguments.size();++i) {
                                        env->SetObjectArrayElement(args, i, converted_arguments[i].l);
                                        qtjambi_throw_java_exception(env)
                                    }
                                    Java::QtJambi::QtJambiSignals$AbstractConnection::invoke(env,_this->m_connection.object(), args);
                                } else {
                                    qWarning("SlotObject::CallSignal: Failed to convert arguments");
                                }
                            }else{
                                qWarning()<< "SlotObject::CallSignal: Failed to convert method types for signal " << _this->m_signal.methodSignature();
                            }
                        }
                    } catch (const JavaException& exn) {
                        if(_this->m_nothrow){
                            exn.report(env);
                        }else{
                            throw;
                        }
                    }
                }
            }
        }
        break;
    case Compare:
        *ret = false;
        break;
    case NumOperations: ;
    }
}