/****************************************************************************
**
** Copyright (C) 1992-2009 Nokia. All rights reserved.
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

#include <QtCore/qcompilerdetection.h>
QT_WARNING_DISABLE_DEPRECATED
#include "qtjambi_functionpointer.h"
#include "qtjambimetaobject_p.h"
#include "qtjambi_core.h"
#include "qtjambi_application.h"
#include "qtjambi_utils.h"
#include "qtjambi_repository_p.h"
#include "qtjambi_registry_p.h"
#include "qtjambitypemanager_p.h"
#include "qtjambi_thread_p.h"
#include "qtjambilink_p.h"

#include <cstring>
#include <QtCore/QHash>
#include <QtCore/QVarLengthArray>
#include <QtCore/QMetaEnum>
#include <QtCore/private/qthread_p.h>
#include <QtCore/private/qcoreapplication_p.h>
#include <QtCore/private/qmetaobject_p.h>

#include "qtjambi_cast.h"

#define QTJAMBI_MAX_NUMBER_OF_CLASSES 1024
#define QTJAMBI_MAX_NUMBER_OF_CLASSES_DIVISOR 100
#define QTJAMBI_MAX_NUMBER_OF_CLASSES_MAX 1024

static const char* QtJambiMetaObjectID = "QtJambiMetaObject";

enum class JMethodType {
    v = 0,
    z = int(jValueType::z),
    b = int(jValueType::b),
    c = int(jValueType::c),
    s = int(jValueType::s),
    i = int(jValueType::i),
    j = int(jValueType::j),
    f = int(jValueType::f),
    d = int(jValueType::d),
    l = int(jValueType::l),
};

struct JMethodInfo{
    JMethodType methodType = JMethodType::v;
    jmethodID methodId = nullptr;
    jclass staticAccessContext = nullptr;
    QList<ParameterTypeInfo> parameterTypeInfos;
};

typedef QPair<jfieldID, JMethodInfo > FieldPair;

struct JMemberInfo{
    jfieldID member = nullptr;
    jValueType type = jValueType::l;
    ParameterTypeInfo memberTypeInfo;
    bool canWrite = false;
};

struct JSignalInfo{
    jfieldID signalField = nullptr;
    jobject signalTypes = nullptr;
    jclass signalClass = nullptr;
    JMethodInfo emitMethodInfo;
    bool isClone = false;
};

struct QPropertyInfo{
    jfieldID propertyField = nullptr;
    JMethodInfo valueMethod;
    JMethodInfo setValueMethod;
};

typedef QHash<hash_type, jobject> SignalTypesHash;
typedef QHash<hash_type, const QList<ParameterTypeInfo>*> ParameterTypeHash;
Q_GLOBAL_STATIC(QReadWriteLock, gJMethodInfoInfosLock)
Q_GLOBAL_STATIC(ParameterTypeHash, gParameterTypeInfos)
typedef QHash<int, const QMetaObject *> MetaObjectHash;
Q_GLOBAL_STATIC(MetaObjectHash, gMetaObjects);
Q_GLOBAL_STATIC_WITH_ARGS(QReadWriteLock, gMetaObjectsLock, (QReadWriteLock::Recursive));
Q_GLOBAL_STATIC(SignalTypesHash, gSignalTypes);

JNIEnv *qtjambi_current_environment(bool initializeJavaThread);

InternalToExternalConverter ParameterTypeInfo::default_internalToExternalConverter()
{
    return InternalToExternalConverter([](JNIEnv*, QtJambiScope*, const void*, jvalue*, bool)->bool{ return false; });
}

ExternalToInternalConverter ParameterTypeInfo::default_externalToInternalConverter()
{
    return ExternalToInternalConverter([](JNIEnv*, QtJambiScope*, const jvalue&, void* &, jValueType) ->bool { return false; });
}

ParameterTypeInfo::ParameterTypeInfo()
    : m_qTypeId(QMetaType::UnknownType),
      m_javaClass(nullptr),
      m_internalToExternalConverter(ParameterTypeInfo::default_internalToExternalConverter()),
      m_externalToInternalConverter(ParameterTypeInfo::default_externalToInternalConverter())
{}

ParameterTypeInfo ParameterTypeInfo::voidTypeInfo(JNIEnv* env){
    return ParameterTypeInfo(
                QMetaType::Void,
                Java::Runtime::Void::primitiveType(env),
                ParameterTypeInfo::default_internalToExternalConverter(),
                ParameterTypeInfo::default_externalToInternalConverter()
          );
}

ParameterTypeInfo::ParameterTypeInfo(
        int qTypeId,
        jclass _javaClass,
        const InternalToExternalConverter& _internalToExternalConverter,
        const ExternalToInternalConverter& _externalToInternalConverter
        )
    :
      m_qTypeId(qTypeId),
      m_javaClass(_javaClass),
      m_internalToExternalConverter(_internalToExternalConverter),
      m_externalToInternalConverter(_externalToInternalConverter)
{
//    if(JNIEnv* env = qtjambi_current_environment()){
//        Q_ASSERT(env->GetObjectRefType(m_javaClass)==JNIGlobalRefType);
//    }
}

ParameterTypeInfo::ParameterTypeInfo(const ParameterTypeInfo& other)
    :
      m_qTypeId(other.m_qTypeId),
      m_javaClass(other.m_javaClass),
      m_internalToExternalConverter(other.m_internalToExternalConverter),
      m_externalToInternalConverter(other.m_externalToInternalConverter)
{}

ParameterTypeInfo& ParameterTypeInfo::operator=(const ParameterTypeInfo& other){
    m_qTypeId = other.m_qTypeId;
    m_javaClass = other.m_javaClass;
    m_internalToExternalConverter = other.m_internalToExternalConverter;
    m_externalToInternalConverter = other.m_externalToInternalConverter;
    return *this;
}

bool ParameterTypeInfo::convertInternalToExternal(JNIEnv* env, QtJambiScope* scope, const void* in, jvalue* out, bool forceBoxedType) const {
    return m_internalToExternalConverter && m_internalToExternalConverter(env, scope, in, out, forceBoxedType);
}

bool ParameterTypeInfo::convertExternalToInternal(JNIEnv* env, QtJambiScope* scope, const jvalue& in,void* & out, jValueType valueType) const {
    return m_externalToInternalConverter && m_externalToInternalConverter(env, scope, in, out, valueType);
}

jclass ParameterTypeInfo::javaClass() const{
    return m_javaClass;
}

int ParameterTypeInfo::metaType() const{
    return m_qTypeId;
}

void static_metacall_QObject(const QtJambiMetaObject* q, QObject * o, QMetaObject::Call cl, int idx, void ** argv)
{
    switch(cl){
    case QMetaObject::InvokeMetaMethod:
        if(o){
            o->metaObject()->metacall(o, cl, idx+o->metaObject()->methodOffset(), argv);
        }else{
            q->static_metacall(cl, idx+q->methodOffset(), argv);
        }
        return;
    case QMetaObject::CreateInstance:
        if(JNIEnv* env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 200)
            q->invokeConstructor(env, idx, argv);
        }
        return;
    default: break;
    }
}

void static_metacall_QtSubType(const QtJambiMetaObject* q, QObject * o, QMetaObject::Call cl, int idx, void ** argv)
{
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        if(jobject object = o ? qtjambi_from_object(env, o, q->javaClass(), false, false) : nullptr){
            switch(cl){
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
            case QMetaObject::QueryPropertyUser:
                q->queryPropertyUser(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyDesignable:
                q->queryPropertyDesignable(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyScriptable:
                q->queryPropertyScriptable(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyStored:
                q->queryPropertyStored(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyEditable:
                q->queryPropertyEditable(env, object, idx, argv, true);
                break;
#else
            case QMetaObject::BindableProperty:
                q->bindableProperty(env, object, idx, argv, true);
                break;
#endif // QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
            case QMetaObject::ResetProperty:
                q->resetProperty(env, object, idx, argv, true);
                break;
            case QMetaObject::ReadProperty:
                q->readProperty(env, object, idx, argv, true);
                break;
            case QMetaObject::WriteProperty:
                q->writeProperty(env, object, idx, argv, true);
                break;
            case QMetaObject::InvokeMetaMethod:
                q->invokeSignalOrSlot(env, object, idx, argv, true);
                break;
#if 0
            case QMetaObject::IndexOfMethod:
                printf("QMetaObject::IndexOfMethod\n");
                break;
            case QMetaObject::RegisterPropertyMetaType:
                printf("QMetaObject::RegisterPropertyMetaType\n");
                break;
            case QMetaObject::RegisterMethodArgumentMetaType:
                printf("QMetaObject::RegisterMethodArgumentMetaType\n");
                break;
#endif
            default:
                break;
            }
        }else{
            switch(cl){
            case QMetaObject::InvokeMetaMethod:
                q->static_metacall(cl, idx+q->methodOffset(), argv);
                break;
            case QMetaObject::CreateInstance:
                q->invokeConstructor(env, idx, argv);
                break;
            default: break;
            }
        }
    }
}

void static_metacall_any_type(const QtJambiMetaObject* q, QObject * o, QMetaObject::Call cl, int idx, void ** argv)
{
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        switch(cl){
        case QMetaObject::CreateInstance:
            q->invokeConstructor(env, idx, argv);
            return;
        case QMetaObject::InvokeMetaMethod:
            if(!o){
                q->static_metacall(cl, idx + q->methodOffset(), argv);
                return;
            }
            break;
        default:
            break;
        }
        if(jobject object = reinterpret_cast<jobject>(o)){
            switch(cl){
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
            case QMetaObject::QueryPropertyUser:
                q->queryPropertyUser(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyDesignable:
                q->queryPropertyDesignable(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyScriptable:
                q->queryPropertyScriptable(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyStored:
                q->queryPropertyStored(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyEditable:
                q->queryPropertyEditable(env, object, idx, argv, true);
                break;
#else
            case QMetaObject::BindableProperty:
                q->bindableProperty(env, object, idx, argv, true);
                break;
#endif
            case QMetaObject::ResetProperty:
                q->resetProperty(env, object, idx, argv, true);
                break;
            case QMetaObject::ReadProperty:
                q->readProperty(env, object, idx, argv, true);
                break;
            case QMetaObject::WriteProperty:
                q->writeProperty(env, object, idx, argv, true);
                break;
            case QMetaObject::InvokeMetaMethod:
                q->invokeSignalOrSlot(env, object, idx, argv, true);
                break;
#if 0
            case QMetaObject::IndexOfMethod:
                printf("QMetaObject::IndexOfMethod\n");
                break;
            case QMetaObject::RegisterPropertyMetaType:
                printf("QMetaObject::RegisterPropertyMetaType\n");
                break;
            case QMetaObject::RegisterMethodArgumentMetaType:
                printf("QMetaObject::RegisterMethodArgumentMetaType\n");
                break;
#endif
            default:
                break;
            }
        }
    }
}

typedef void (*StaticMetacallFunction)(const QtJambiMetaObject* q, QObject * o, QMetaObject::Call cl, int idx, void ** argv);

StaticMetaCallFunction create_static_metacall(const QtJambiMetaObject* q, StaticMetacallFunction fct){
    return qtjambi_function_pointer<16,void(QObject *, QMetaObject::Call, int, void **)>(
                [q,fct](QObject * o, QMetaObject::Call cl, int idx, void ** argv){
                    fct(q, o, cl, idx, argv);
                },
                hashSum({qHash(qint64(q)), qHash(qint64(fct))}));
}


class QtJambiMetaObjectPrivate
{
public:
    QtJambiMetaObjectPrivate(QtJambiMetaObject *q, JNIEnv *env, jclass java_class, const QMetaObject *original_meta_object, bool hasCustomMetaObject, JavaException& exceptionHandler);
    ~QtJambiMetaObjectPrivate();

    void initialize(JNIEnv *jni_env, jclass java_class, const QMetaObject *original_meta_object, bool hasCustomMetaObject);
    void invokeMethod(JNIEnv *env, jobject object, const JMethodInfo& methodInfo, void **_a, bool forceObjectType = false) const;
    void invokeConstructor(JNIEnv *env, const JMethodInfo& methodInfo, void **_a) const;

    int methodFromJMethod(jmethodID methodId) const;
    QtJambiMetaObject::SignalInfo signalInfo(jfieldID fieldId, jmethodID emitMethodID) const;
    QVector<QtJambiMetaObject::SignalInfo> signalInfos(jfieldID fieldId) const;
    const JMethodInfo* methodInfo(int index) const;
    const JMethodInfo* constructorInfo(int index) const;
    jclass javaClass() const;
    jweak javaInstance() const;
    void setJavaInstance(jweak weak);
private:
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    /**
     * this list stores all texts describing the class meta object.
     */
    QList<char*> stringdataList;
#else
    QByteArray m_stringData;
#endif //QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QScopedArrayPointer<jint> m_intData;
    QtJambiMetaObject *q_ptr;
    mutable QSharedPointer<const QtJambiMetaObject> m_this_ptr;
    Q_DECLARE_PUBLIC(QtJambiMetaObject)

    int m_method_count;
    int m_signal_count;
    int m_constructor_count;
    int m_property_count;

    jclass const m_clazz;
    QVector<JMethodInfo> m_methods;
    QHash<jmethodID,int> m_methodIndexes;
    QVector<JSignalInfo> m_signals;
    QHash<jfieldID,QHash<jmethodID,int>> m_signalIndexes;
    QVector<JMethodInfo> m_constructors;

    QMap<int,JMethodInfo> m_property_readers;
    QMap<int,JMethodInfo> m_property_writers;
    QMap<int,JMethodInfo> m_property_resetters;
    QMap<int,int> m_property_notifies;
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QMap<int,JMethodInfo> m_property_designable_resolvers;
    QMap<int,JMethodInfo> m_property_scriptable_resolvers;
    QMap<int,JMethodInfo> m_property_editable_resolvers;
    QMap<int,JMethodInfo> m_property_stored_resolvers;
    QMap<int,JMethodInfo> m_property_user_resolvers;
#else
    QMap<int,JMethodInfo> m_property_bindables;
    QMap<int,QPropertyInfo> m_property_QProperty_fields;
#endif
    QMap<int,JMemberInfo> m_propertyMembers;

    mutable jweak m_javaInstance;

    friend const QMetaObject *qtjambi_metaobject_for_class(JNIEnv *env, jclass object_class, const std::function<const QMetaObject *(bool&)>& original_meta_object_provider);
};

QtJambiMetaObjectPrivate::QtJambiMetaObjectPrivate(QtJambiMetaObject *q, JNIEnv *env, jclass java_class, const QMetaObject *original_meta_object, bool hasCustomMetaObject, JavaException& exceptionHandler)
    :
      q_ptr(q), m_this_ptr(q), m_method_count(-1), m_signal_count(0), m_constructor_count(0), m_property_count(0),
      m_clazz(getGlobalClassRef(env, java_class)),
      m_methods(), m_methodIndexes(), m_signals(), m_signalIndexes(), m_constructors(),
      m_property_readers(), m_property_writers(), m_property_resetters(), m_property_notifies(),
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
      m_property_designable_resolvers(),
      m_property_scriptable_resolvers(),
      m_property_editable_resolvers(),
      m_property_stored_resolvers(),
      m_property_user_resolvers(),
#else
      m_property_bindables(),
      m_property_QProperty_fields(),
#endif
      m_propertyMembers(),
      m_javaInstance(nullptr)
{
    Q_ASSERT(env);
    Q_ASSERT(java_class);
    try{
        initialize(env, java_class, original_meta_object, hasCustomMetaObject);
    }catch(const JavaException& exn){
        exceptionHandler.addSuppressed(env, exn);
    }
}

QtJambiMetaObjectPrivate::~QtJambiMetaObjectPrivate()
{
    if(m_javaInstance){
        if (JNIEnv *env = qtjambi_current_environment(false)) {
            QTJAMBI_JNI_LOCAL_FRAME(env, 100)
            env->DeleteWeakGlobalRef(m_javaInstance);
            m_javaInstance = nullptr;
            for(JSignalInfo& sigInfo : m_signals){
                if(!env->IsSameObject(sigInfo.signalTypes, nullptr)){
                    env->DeleteGlobalRef(sigInfo.signalTypes);
                    sigInfo.signalTypes = nullptr;
                }
            }
        }
    }

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    for(char* strg : stringdataList){
        delete[] strg;
    }
    stringdataList.clear();
#endif //QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
}

template<class MethodInfoContainer>
void analyze_methods(JNIEnv *env, jobject classLoader, int count, jobject methodList, jobject listOfMetaTypes, MethodInfoContainer& methodInfoContainer, QHash<jmethodID,int>* methodIndexes = nullptr){
    Q_ASSERT(count == qtjambi_collection_size(env, methodList));
    Q_UNUSED(classLoader)
    for(int i=0; i<count; ++i){
        jobject methodObject = qtjambi_list_get(env, methodList, i);
        if(methodObject){
            JIntArrayPointer metaTypes(env, listOfMetaTypes ? jintArray(qtjambi_list_get(env, listOfMetaTypes, i)) : nullptr, false);
            JMethodInfo info;
            qtjambi_throw_java_exception(env);
            info.methodId = env->FromReflectedMethod(methodObject);
            jclass returnClassType(nullptr);
            jobjectArray parameterClassTypes(nullptr);
            if(Java::Runtime::Method::isInstanceOf(env, methodObject)){
                returnClassType = Java::Runtime::Method::getReturnType(env, methodObject);
                parameterClassTypes = Java::Runtime::Executable::getParameterTypes(env, methodObject);
                int modif = Java::Runtime::Executable::getModifiers(env, methodObject);
                if(Java::Runtime::Modifier::isStatic(env, modif)){
                    info.staticAccessContext = Java::Runtime::Method::getDeclaringClass(env, methodObject);
                    info.staticAccessContext = getGlobalClassRef(env, info.staticAccessContext);
                }else{
                    info.staticAccessContext = nullptr;
                }
            }else if(Java::Runtime::Constructor::isInstanceOf(env, methodObject)){
                returnClassType = Java::Runtime::Void::primitiveType(env);
                parameterClassTypes = Java::Runtime::Executable::getParameterTypes(env, methodObject);
                info.staticAccessContext = Java::Runtime::Constructor::getDeclaringClass(env, methodObject);
                info.staticAccessContext = getGlobalClassRef(env, info.staticAccessContext);
            }else{
                JavaException::raiseNullPointerException(env, "Method is null." QTJAMBI_STACKTRACEINFO );
                continue;
            }
            int length = env->GetArrayLength(parameterClassTypes)+1;
            info.parameterTypeInfos.reserve(length);
            for(int j=0; j<length; ++j){
                jclass javaClass = j==0 ? returnClassType : jclass(env->GetObjectArrayElement(parameterClassTypes, j-1));
                qtjambi_throw_java_exception(env);
                QMetaType qMetaType( [&]() -> int {
                    if(Java::Runtime::Void::isPrimitiveType(env, javaClass)){
                        return QMetaType::Void;
                    }else if(listOfMetaTypes){
                        return j<metaTypes.size() ? metaTypes.pointer()[j] : 0;
                    }else if(Java::Runtime::Boolean::isPrimitiveType(env, javaClass)){
                        return QMetaType::Bool; // in case of property resolver
                    }else{
                        return QMetaType::UnknownType; // in case of property bindable
                    }
                } () );
                if(j==0){
                    if(Java::Runtime::Void::isPrimitiveType(env, javaClass)){
                        info.methodType = JMethodType::v;
                    }else if(Java::Runtime::Integer::isPrimitiveType(env, javaClass)){
                        info.methodType = JMethodType::i;
                    }else if(Java::Runtime::Long::isPrimitiveType(env, javaClass)){
                        info.methodType = JMethodType::j;
                    }else if(Java::Runtime::Short::isPrimitiveType(env, javaClass)){
                        info.methodType = JMethodType::s;
                    }else if(Java::Runtime::Byte::isPrimitiveType(env, javaClass)){
                        info.methodType = JMethodType::b;
                    }else if(Java::Runtime::Boolean::isPrimitiveType(env, javaClass)){
                        info.methodType = JMethodType::z;
                    }else if(Java::Runtime::Character::isPrimitiveType(env, javaClass)){
                        info.methodType = JMethodType::c;
                    }else if(Java::Runtime::Float::isPrimitiveType(env, javaClass)){
                        info.methodType = JMethodType::f;
                    }else if(Java::Runtime::Double::isPrimitiveType(env, javaClass)){
                        info.methodType = JMethodType::d;
                    }else{
                        info.methodType = JMethodType::l;
                    }
                }
                InternalToExternalConverter internalToExternalConverter = QtJambiTypeManager::getInternalToExternalConverter(
                                                                                                                    env,
                                                                                                                    QLatin1String(qMetaType.name()),
                                                                                                                    qMetaType,
                                                                                                                    javaClass,
                                                                                                                    true
                                                                                                                );
                ExternalToInternalConverter externalToInternalConverter = QtJambiTypeManager::getExternalToInternalConverter(
                                                                                                                    env,
                                                                                                                    javaClass,
                                                                                                                    QLatin1String(qMetaType.name()),
                                                                                                                    qMetaType
                                                                                                                );
                info.parameterTypeInfos << ParameterTypeInfo{
                                               qMetaType.id(),
                                               getGlobalClassRef(env, javaClass),
                                               internalToExternalConverter,
                                               externalToInternalConverter};
            }
            methodInfoContainer[i] = info;
            if(methodIndexes){
                methodIndexes->insert(info.methodId, i);
            }
        }
    }
}

void QtJambiMetaObjectPrivate::initialize(JNIEnv *env, jclass java_class, const QMetaObject *original_meta_object, bool hasCustomMetaObject)
{
    Q_Q(QtJambiMetaObject);

    QTJAMBI_JNI_LOCAL_FRAME(env, 1000)
    jobject classLoader = Java::Runtime::Class::getClassLoader(env, java_class);
    jobject meta_data_struct = Java::QtJambi::MetaObjectTools::buildMetaData(env, java_class);
    if (!meta_data_struct)
        return;
    jobject meta_data = Java::QtJambi::MetaObjectTools$MetaData::metaData(env, meta_data_struct);
    Q_ASSERT(meta_data);

    jobject string_data = Java::QtJambi::MetaObjectTools$MetaData::stringData(env,meta_data_struct);
    Q_ASSERT(string_data);

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    jsize number_of_strings = qtjambi_collection_size(env, string_data);
    QByteArrayData* __stringdata = reinterpret_cast<QByteArrayData*>(new char[size_t(number_of_strings)*sizeof(QByteArrayData)]);
    {
        static int string_size = int(std::strlen(QtJambiMetaObjectID)+1);
        __stringdata[0].ref.atomic._q_value = -1L;
        __stringdata[0].alloc = 0;
        __stringdata[0].capacityReserved = 0;
        __stringdata[0].size = string_size;
        __stringdata[0].offset = reinterpret_cast<qptrdiff>(reinterpret_cast<const void*>(QtJambiMetaObjectID)) - reinterpret_cast<qptrdiff>(reinterpret_cast<const void*>(&(__stringdata[0])));
    }
    for(int i=1; i<number_of_strings; i++){
        jstring string_data_entry = jstring(qtjambi_list_get(env, string_data, i));
        jsize string_data_len = env->GetStringUTFLength(string_data_entry);
        char* stringdata = new char[size_t(string_data_len+1)];
        stringdata[string_data_len] = '\0';
        env->GetStringUTFRegion(string_data_entry, 0, string_data_len, stringdata);
        qtjambi_throw_java_exception(env);
        stringdataList.append(stringdata);
        __stringdata[i].ref.atomic._q_value = -1L;
        __stringdata[i].alloc = 0;
        __stringdata[i].capacityReserved = 0;
        __stringdata[i].size = string_data_len;
        __stringdata[i].offset = reinterpret_cast<qptrdiff>(reinterpret_cast<const void*>(stringdata)) - reinterpret_cast<qptrdiff>(reinterpret_cast<const void*>(&(__stringdata[i])));
    }
    q->d.stringdata = __stringdata;
#else
    jsize number_of_strings = qtjambi_collection_size(env, string_data);
    size_t totalCharCount = sizeof(const char*) + 1;
    for(int i=1; i<number_of_strings; i++){
        jstring string_data_entry = jstring(qtjambi_list_get(env, string_data, i));
        totalCharCount += size_t(env->GetStringUTFLength(string_data_entry)) + 1;
    }
    m_stringData.fill('\0', int(totalCharCount + size_t(number_of_strings)*2*sizeof(uint)));
    QPair<uint,uint>* offsetsAndSize = reinterpret_cast<QPair<uint,uint>*>(m_stringData.data());
    uint totalOffset = uint(size_t(number_of_strings)*2*sizeof(uint));
    {
        offsetsAndSize[0].first = totalOffset;
        offsetsAndSize[0].second = sizeof(const char*);
        char* __stringdata = m_stringData.data()+totalOffset;
        const void*& pointer = *reinterpret_cast<const void**>(__stringdata);
        pointer = QtJambiMetaObjectID;
        totalOffset += sizeof(const char*) + 1;
    }
    for(int i=1; i<number_of_strings; i++){
        jstring string_data_entry = jstring(qtjambi_list_get(env, string_data, i));
        jsize string_data_len = env->GetStringUTFLength(string_data_entry);
        offsetsAndSize[i].first = totalOffset;
        offsetsAndSize[i].second = uint(string_data_len);
        char* __stringdata = m_stringData.data()+totalOffset;
        env->GetStringUTFRegion(string_data_entry, 0, string_data_len, __stringdata);
        qtjambi_throw_java_exception(env);
        totalOffset += uint(string_data_len) + 1;
    }
    q->d.stringdata = reinterpret_cast<uint*>(m_stringData.data());
#endif //QT_VERSION < QT_VERSION_CHECK(6, 0, 0)

    {
        jclass java_super_class = env->GetSuperclass(java_class);
#if QT_VERSION < QT_VERSION_CHECK(5,14,0)
        if(java_super_class)
            q->d.superdata = qtjambi_metaobject_for_class(env, java_super_class, original_meta_object, hasCustomMetaObject);
        else
            q->d.superdata = nullptr;
#else
        if(java_super_class)
            q->d.superdata.direct = qtjambi_metaobject_for_class(env, java_super_class, original_meta_object, hasCustomMetaObject);
        else
            q->d.superdata.direct = nullptr;
#endif
    }

    jsize meta_data_len = qtjambi_collection_size(env, meta_data);
    m_intData.reset(new jint[size_t(meta_data_len)]);
    for(int i=0; i< meta_data_len; ++i){
        jobject entry = qtjambi_list_get(env, meta_data, i);
        m_intData[i] = qtjambi_to_int(env, entry);
    }
    q->d.data = reinterpret_cast<uint*>(m_intData.get());
    /*if(QMetaObjectPrivate::get(q)->flags & DynamicMetaObject){

    }*/

    q->d.extradata = nullptr;
    q->d.relatedMetaObjects = nullptr;

    {
        jobject methods = Java::QtJambi::MetaObjectTools$MetaData::methods(env,meta_data_struct);
        jobject methodMetaTypes = Java::QtJambi::MetaObjectTools$MetaData::methodMetaTypes(env,meta_data_struct);
        m_method_count = qtjambi_collection_size(env, methods);
        m_methods.resize(m_method_count);
        analyze_methods(env, classLoader, m_method_count, methods, methodMetaTypes, m_methods, &m_methodIndexes);
    }

    {
        jobject signalInfos = Java::QtJambi::MetaObjectTools$MetaData::signalInfos(env,meta_data_struct);
        m_signal_count = qtjambi_collection_size(env, signalInfos);
        m_signals.resize(m_signal_count);
        for(int i=0; i<m_signal_count; ++i){
            jobject signalInfo = qtjambi_list_get(env, signalInfos, i);
            if(signalInfo){
                JSignalInfo& signal = m_signals[i];
                signal.emitMethodInfo.methodType = JMethodType::v;
                signal.emitMethodInfo.methodId = jmethodID(Java::QtJambi::MetaObjectTools$SignalInfo::methodId(env, signalInfo));
                Q_ASSERT(signal.emitMethodInfo.methodId);
                signal.signalField = env->FromReflectedField(Java::QtJambi::MetaObjectTools$SignalInfo::field(env, signalInfo));
                signal.signalTypes = env->NewGlobalRef(Java::QtJambi::MetaObjectTools$SignalInfo::signalTypes(env, signalInfo));
                signal.signalClass = getGlobalClassRef(env, Java::QtJambi::MetaObjectTools$SignalInfo::signalClass(env, signalInfo));
                if(m_signalIndexes.contains(signal.signalField))
                    signal.isClone = true;

                m_signalIndexes[signal.signalField][signal.emitMethodInfo.methodId] = i;

                JIntArrayPointer signalMetaTypes(env, Java::QtJambi::MetaObjectTools$SignalInfo::signalMetaTypes(env, signalInfo));
                int length = qtjambi_collection_size(env, signal.signalTypes);
                signal.emitMethodInfo.parameterTypeInfos.reserve(length+1);
                signal.emitMethodInfo.parameterTypeInfos.append({QMetaType::Void,
                                                getGlobalClassRef(env, Java::Runtime::Void::primitiveType(env)),
                                                ParameterTypeInfo::default_internalToExternalConverter(),
                                                ParameterTypeInfo::default_externalToInternalConverter()});
                jobject parameterClassTypes = qtjambi_arraylist_new(env, length);
                for(int j=0; j<length; ++j){
                    jobject signalParameterType = qtjambi_list_get(env, signal.signalTypes, j);
                    QMetaType qMetaType(signalMetaTypes.pointer()[j]);
                    jclass javaClass = Java::QtJambi::QtJambiSignals$SignalParameterType::type(env, signalParameterType);
                    qtjambi_collection_add(env, parameterClassTypes, javaClass);
                    InternalToExternalConverter internalToExternalConverter = QtJambiTypeManager::getInternalToExternalConverter(
                                                               env,
                                                               QLatin1String(qMetaType.name()),
                                                               qMetaType,
                                                               javaClass,
                                                               true
                                                            );
                    ExternalToInternalConverter externalToInternalConverter = QtJambiTypeManager::getExternalToInternalConverter(
                                                                env,
                                                                javaClass,
                                                                QLatin1String(qMetaType.name()),
                                                                qMetaType
                            );
                    signal.emitMethodInfo.parameterTypeInfos.append({qMetaType.id(),
                                                    getGlobalClassRef(env, javaClass),
                                                    internalToExternalConverter,
                                                    externalToInternalConverter});
                }
                signal.emitMethodInfo.staticAccessContext = nullptr;
            }
        }
    }

    {
        jobject methods = Java::QtJambi::MetaObjectTools$MetaData::constructors(env,meta_data_struct);
        jobject constructorMetaTypes = Java::QtJambi::MetaObjectTools$MetaData::constructorMetaTypes(env,meta_data_struct);
        m_constructor_count = qtjambi_collection_size(env, methods);
        m_constructors.resize(m_constructor_count);
        analyze_methods(env, classLoader, m_constructor_count, methods, constructorMetaTypes, m_constructors);
    }

    {
        jobject property_readers = Java::QtJambi::MetaObjectTools$MetaData::propertyReaders(env,meta_data_struct);
        jobject propertyMetaTypes = Java::QtJambi::MetaObjectTools$MetaData::propertyMetaTypes(env,meta_data_struct);
        jobject propertyClassTypes = Java::QtJambi::MetaObjectTools$MetaData::propertyClassTypes(env,meta_data_struct);
        m_property_count = qtjambi_collection_size(env, property_readers);
        analyze_methods(env, classLoader, m_property_count, property_readers, propertyMetaTypes, m_property_readers);
        analyze_methods(env, classLoader, m_property_count,
                        Java::QtJambi::MetaObjectTools$MetaData::propertyWriters(env,meta_data_struct),
                        propertyMetaTypes,
                        m_property_writers);
        analyze_methods(env, classLoader, m_property_count,
                        Java::QtJambi::MetaObjectTools$MetaData::propertyResetters(env,meta_data_struct),
                        nullptr,
                        m_property_resetters);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
        analyze_methods(env, classLoader, m_property_count,
                        Java::QtJambi::MetaObjectTools$MetaData::propertyDesignableResolvers(env,meta_data_struct),
                        nullptr,
                        m_property_designable_resolvers);
        analyze_methods(env, classLoader, m_property_count,
                        Java::QtJambi::MetaObjectTools$MetaData::propertyScriptableResolvers(env,meta_data_struct),
                        nullptr,
                        m_property_scriptable_resolvers);
        analyze_methods(env, classLoader, m_property_count,
                        Java::QtJambi::MetaObjectTools$MetaData::propertyEditableResolvers(env,meta_data_struct),
                        nullptr,
                        m_property_editable_resolvers);
        analyze_methods(env, classLoader, m_property_count,
                        Java::QtJambi::MetaObjectTools$MetaData::propertyUserResolvers(env,meta_data_struct),
                        nullptr,
                        m_property_user_resolvers);
        analyze_methods(env, classLoader, m_property_count,
                        Java::QtJambi::MetaObjectTools$MetaData::propertyStoredResolvers(env,meta_data_struct),
                        nullptr,
                        m_property_stored_resolvers);
#else
        analyze_methods(env, classLoader, m_property_count,
                        Java::QtJambi::MetaObjectTools$MetaData::propertyBindables(env,meta_data_struct),
                        nullptr,
                        m_property_bindables);
#endif
        jobject propertyNotifies = Java::QtJambi::MetaObjectTools$MetaData::propertyNotifies(env,meta_data_struct);
        Q_ASSERT(m_property_count == qtjambi_collection_size(env, propertyNotifies));
        for(int i=0; i<m_property_count; ++i){
            jobject fieldIndex = qtjambi_list_get(env, propertyNotifies, i);
            if(fieldIndex){
                jint idx = qtjambi_to_int(env, fieldIndex);
                m_property_notifies[i] = idx;
            }else{
                m_property_notifies[i] = -1;
            }
        }

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        jobject propertyQPropertyFields = Java::QtJambi::MetaObjectTools$MetaData::propertyQPropertyFields(env,meta_data_struct);
        Q_ASSERT(m_property_count == qtjambi_collection_size(env, propertyQPropertyFields));
        for(int i=0; i<m_property_count; ++i){
            jobject fieldObject = qtjambi_list_get(env, propertyQPropertyFields, i);
            if(fieldObject){
                JIntArrayPointer metaTypes(env, jintArray(qtjambi_list_get(env, propertyMetaTypes, i)));
                jclass javaClass = jclass(qtjambi_list_get(env, propertyClassTypes, i));
                QMetaType qMetaType(metaTypes.pointer()[0]);
                InternalToExternalConverter internalToExternalConverter = QtJambiTypeManager::getInternalToExternalConverter(
                                                           env,
                                                           QLatin1String(qMetaType.name()),
                                                           qMetaType,
                                                           javaClass,
                                                           true
                                                        );
                ExternalToInternalConverter externalToInternalConverter = QtJambiTypeManager::getExternalToInternalConverter(
                                                            env,
                                                            javaClass,
                                                            QLatin1String(qMetaType.name()),
                                                            qMetaType
                                                        );
                ParameterTypeInfo propertyTypeInfo{qMetaType.id(),
                                                        getGlobalClassRef(env, javaClass),
                                                        internalToExternalConverter,
                                                        externalToInternalConverter};
                m_property_QProperty_fields[i].propertyField = env->FromReflectedField(fieldObject);
                m_property_QProperty_fields[i].valueMethod.parameterTypeInfos << propertyTypeInfo;
                jclass propertyClassType = Java::Runtime::Field::getType(env, fieldObject);
                if(Java::QtCore::QObject$QAbstractComputedProperty::isAssignableFrom(env, propertyClassType)){
                    if(Java::QtCore::QObject$QComputedBooleanProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::z;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QComputedBooleanProperty::value_ID(env);
                    }else if(Java::QtCore::QObject$QComputedByteProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::b;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QComputedByteProperty::value_ID(env);
                    }else if(Java::QtCore::QObject$QComputedShortProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::s;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QComputedShortProperty::value_ID(env);
                    }else if(Java::QtCore::QObject$QComputedIntProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::i;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QComputedIntProperty::value_ID(env);
                    }else if(Java::QtCore::QObject$QComputedLongProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::j;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QComputedLongProperty::value_ID(env);
                    }else if(Java::QtCore::QObject$QComputedFloatProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::f;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QComputedFloatProperty::value_ID(env);
                    }else if(Java::QtCore::QObject$QComputedDoubleProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::d;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QComputedDoubleProperty::value_ID(env);
                    }else if(Java::QtCore::QObject$QComputedCharProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::c;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QComputedCharProperty::value_ID(env);
                    }else if(Java::QtCore::QObject$QComputedProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::l;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QComputedProperty::value_ID(env);
                    }
                }else{
                    m_property_QProperty_fields[i].setValueMethod.parameterTypeInfos << ParameterTypeInfo::voidTypeInfo(env) << propertyTypeInfo;
                    m_property_QProperty_fields[i].setValueMethod.methodType = JMethodType::v;
                    if(Java::QtCore::QObject$QBooleanProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::z;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QBooleanProperty::value_ID(env);
                        m_property_QProperty_fields[i].setValueMethod.methodId = Java::QtCore::QObject$QBooleanProperty::setValue_ID(env);
                    }else if(Java::QtCore::QObject$QByteProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::b;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QByteProperty::value_ID(env);
                        m_property_QProperty_fields[i].setValueMethod.methodId = Java::QtCore::QObject$QByteProperty::setValue_ID(env);
                    }else if(Java::QtCore::QObject$QShortProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::s;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QShortProperty::value_ID(env);
                        m_property_QProperty_fields[i].setValueMethod.methodId = Java::QtCore::QObject$QShortProperty::setValue_ID(env);
                    }else if(Java::QtCore::QObject$QIntProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::i;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QIntProperty::value_ID(env);
                        m_property_QProperty_fields[i].setValueMethod.methodId = Java::QtCore::QObject$QIntProperty::setValue_ID(env);
                    }else if(Java::QtCore::QObject$QLongProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::j;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QLongProperty::value_ID(env);
                        m_property_QProperty_fields[i].setValueMethod.methodId = Java::QtCore::QObject$QLongProperty::setValue_ID(env);
                    }else if(Java::QtCore::QObject$QFloatProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::f;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QFloatProperty::value_ID(env);
                        m_property_QProperty_fields[i].setValueMethod.methodId = Java::QtCore::QObject$QFloatProperty::setValue_ID(env);
                    }else if(Java::QtCore::QObject$QDoubleProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::d;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QDoubleProperty::value_ID(env);
                        m_property_QProperty_fields[i].setValueMethod.methodId = Java::QtCore::QObject$QDoubleProperty::setValue_ID(env);
                    }else if(Java::QtCore::QObject$QCharProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::c;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QCharProperty::value_ID(env);
                        m_property_QProperty_fields[i].setValueMethod.methodId = Java::QtCore::QObject$QCharProperty::setValue_ID(env);
                    }else if(Java::QtCore::QObject$QProperty::isAssignableFrom(env, propertyClassType)){
                        m_property_QProperty_fields[i].valueMethod.methodType = JMethodType::l;
                        m_property_QProperty_fields[i].valueMethod.methodId = Java::QtCore::QObject$QProperty::value_ID(env);
                        m_property_QProperty_fields[i].setValueMethod.methodId = Java::QtCore::QObject$QProperty::setValue_ID(env);
                    }
                }
            }
        }
#endif

        jobject propertyMemberFields = Java::QtJambi::MetaObjectTools$MetaData::propertyMemberFields(env,meta_data_struct);
        Q_ASSERT(m_property_count == qtjambi_collection_size(env, propertyMemberFields));
        for(int i=0; i<m_property_count; ++i){
            jobject fieldObject = qtjambi_list_get(env, propertyMemberFields, i);
            if(fieldObject){
                JIntArrayPointer metaTypes(env, jintArray(qtjambi_list_get(env, propertyMetaTypes, i)));
                jclass javaClass = jclass(qtjambi_list_get(env, propertyClassTypes, i));
                jclass fieldType = Java::Runtime::Field::getType(env, fieldObject);
                m_propertyMembers[i].member = env->FromReflectedField(fieldObject);
                m_propertyMembers[i].canWrite = !Java::Runtime::Modifier::isFinal(env, Java::Runtime::Field::getModifiers(env, fieldObject));
                if(Java::Runtime::Boolean::isPrimitiveType(env, fieldType)){
                    m_propertyMembers[i].type = jValueType::z;
                }else if(Java::Runtime::Byte::isPrimitiveType(env, fieldType)){
                    m_propertyMembers[i].type = jValueType::b;
                }else if(Java::Runtime::Short::isPrimitiveType(env, fieldType)){
                    m_propertyMembers[i].type = jValueType::s;
                }else if(Java::Runtime::Integer::isPrimitiveType(env, fieldType)){
                    m_propertyMembers[i].type = jValueType::i;
                }else if(Java::Runtime::Long::isPrimitiveType(env, fieldType)){
                    m_propertyMembers[i].type = jValueType::j;
                }else if(Java::Runtime::Float::isPrimitiveType(env, fieldType)){
                    m_propertyMembers[i].type = jValueType::f;
                }else if(Java::Runtime::Double::isPrimitiveType(env, fieldType)){
                    m_propertyMembers[i].type = jValueType::d;
                }else if(Java::Runtime::Character::isPrimitiveType(env, fieldType)){
                    m_propertyMembers[i].type = jValueType::c;
                }else{
                    m_propertyMembers[i].type = jValueType::l;
                    QMetaType qMetaType(metaTypes.pointer()[0]);
                    InternalToExternalConverter internalToExternalConverter = QtJambiTypeManager::getInternalToExternalConverter(
                                                               env,
                                                               QLatin1String(qMetaType.name()),
                                                               qMetaType,
                                                               javaClass,
                                                               true
                                                            );
                    ExternalToInternalConverter externalToInternalConverter = QtJambiTypeManager::getExternalToInternalConverter(
                                                                env,
                                                                javaClass,
                                                                QLatin1String(qMetaType.name()),
                                                                qMetaType
                                                            );
                    m_propertyMembers[i].memberTypeInfo = ParameterTypeInfo{qMetaType.id(),
                                                                            getGlobalClassRef(env, javaClass),
                                                                            internalToExternalConverter,
                                                                            externalToInternalConverter};
                }
            }
        }
    }

    jobject extra_data = Java::QtJambi::MetaObjectTools$MetaData::relatedMetaObjects(env, meta_data_struct);
    jsize extra_data_count = extra_data != nullptr ? qtjambi_collection_size(env, extra_data) : 0;
    if (extra_data_count == 1) {
        jclass el = jclass(qtjambi_list_get(env, extra_data, 0));
        QMetaObject const* superType = qtjambi_metaobject_for_class(env, el);
        if(q->d.relatedMetaObjects)
            delete[] q->d.relatedMetaObjects;
#if QT_VERSION < QT_VERSION_CHECK(5,14,0)
        q->d.relatedMetaObjects = new QMetaObject const*(superType);
#else
        q->d.relatedMetaObjects = new QMetaObject::SuperData(superType);
#endif
    }else if (extra_data_count > 1) {
        // ensure to not have a pointer to a static_metacall method
#if QT_VERSION < QT_VERSION_CHECK(5,14,0)
        QMetaObject  const* * _relatedMetaObjects = new QMetaObject const*[size_t(extra_data_count)];
#else
        QMetaObject::SuperData* _relatedMetaObjects = new QMetaObject::SuperData[size_t(extra_data_count)];
#endif
        for (jsize i=0; i<extra_data_count; ++i) {
            jclass el = jclass(qtjambi_list_get(env, extra_data, i));
            QMetaObject const* superType = qtjambi_metaobject_for_class(env, el);
#if QT_VERSION < QT_VERSION_CHECK(5,14,0)
            _relatedMetaObjects[i] = superType;
#else
            _relatedMetaObjects[i].direct = superType;
#endif
        }
        q->d.relatedMetaObjects = _relatedMetaObjects;
    }

    bool hasStaticMembers = Java::QtJambi::MetaObjectTools$MetaData::hasStaticMembers(env,meta_data_struct);
    const QMetaObjectPrivate* priv = QMetaObjectPrivate::get(q);
    if(hasStaticMembers || (priv->flags & PropertyAccessInStaticMetaCall) == PropertyAccessInStaticMetaCall){
        if(Java::QtCore::QObject::isAssignableFrom(env, java_class)){
            q->d.static_metacall = create_static_metacall(q, &static_metacall_QObject);
        }else if(Java::QtJambi::QtObjectInterface::isAssignableFrom(env, java_class)){
            q->d.static_metacall = create_static_metacall(q, &static_metacall_QtSubType);
        }else{
            q->d.static_metacall = create_static_metacall(q, &static_metacall_any_type);
        }
    }else{
        q->d.static_metacall = nullptr;
    }
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    jobject metaTypesList = Java::QtJambi::MetaObjectTools$MetaData::metaTypes(env, meta_data_struct);
    jint parameterCount = qtjambi_collection_size(env, metaTypesList);
    const QtPrivate::QMetaTypeInterface ** metaTypes = parameterCount==0 ? nullptr : new const QtPrivate::QMetaTypeInterface *[size_t(parameterCount)];
    for(jint i=0; i<parameterCount; ++i){
        jobject entry = qtjambi_list_get(env, metaTypesList, i);
        jint metaTypeId = qtjambi_to_int(env, entry);
        QMetaType t(metaTypeId);
        metaTypes[i] = t.iface();
    }
    q->d.metaTypes = metaTypes;
#endif
}

void QtJambiMetaObjectPrivate::invokeMethod(JNIEnv *env, jobject object, const JMethodInfo& methodInfo, void **_a, bool forceObjectType) const
{
    QtJambiExceptionHandler __exceptionHandler;
    QTJAMBI_JNI_LOCAL_FRAME(env, 1000)
    QtJambiScope scope(nullptr);
    try{
        //fprintf(stderr, "QtJambiMetaObjectPrivate::invokeMethod: %s.%s(...[%i])\n", qPrintable(qtjambi_object_class_name(env, object)), qPrintable(methodInfo.methodName), methodInfo.parameterTypeInfos.size());
        Q_ASSERT(methodInfo.parameterTypeInfos.size()==methodInfo.parameterTypeInfos.size());
        if(env->IsSameObject(object, nullptr)){
            qWarning("QtJambiMetaObject::invokeMethod: Object is null");
            return;
        }
        Q_ASSERT(methodInfo.methodId);
        QVector<jvalue> converted_arguments(methodInfo.parameterTypeInfos.size()-1);

        bool success = true;
        for (int i = 0; i < converted_arguments.size(); ++i) {
            const ParameterTypeInfo& parameterTypeInfo = methodInfo.parameterTypeInfos[i + 1];
            converted_arguments[i].l = nullptr;
            if (!parameterTypeInfo.convertInternalToExternal(env, &scope, _a[i+1], &converted_arguments[i], forceObjectType || !Java::Runtime::Class::isPrimitive(env, parameterTypeInfo.javaClass()))) {
                success = false;
                break;
            }
        }

        if (success) {
            jvalue returnValue;
            returnValue.j = 0;
            jvalue *args = converted_arguments.data();

            bool isVoid = false;
            if(methodInfo.staticAccessContext){
                switch(methodInfo.methodType){
                case JMethodType::v:
                    isVoid = true;
                    env->CallStaticVoidMethodA(methodInfo.staticAccessContext, methodInfo.methodId, args); break;
                case JMethodType::z:
                    returnValue.z = env->CallStaticBooleanMethodA(methodInfo.staticAccessContext, methodInfo.methodId, args); break;
                case JMethodType::b:
                    returnValue.b = env->CallStaticByteMethodA(methodInfo.staticAccessContext, methodInfo.methodId, args); break;
                case JMethodType::i:
                    returnValue.i = env->CallStaticIntMethodA(methodInfo.staticAccessContext, methodInfo.methodId, args); break;
                case JMethodType::s:
                    returnValue.s = env->CallStaticShortMethodA(methodInfo.staticAccessContext, methodInfo.methodId, args); break;
                case JMethodType::j:
                    returnValue.j = env->CallStaticLongMethodA(methodInfo.staticAccessContext, methodInfo.methodId, args); break;
                case JMethodType::f:
                    returnValue.f = env->CallStaticFloatMethodA(methodInfo.staticAccessContext, methodInfo.methodId, args); break;
                case JMethodType::d:
                    returnValue.d = env->CallStaticDoubleMethodA(methodInfo.staticAccessContext, methodInfo.methodId, args); break;
                case JMethodType::c:
                    returnValue.c = env->CallStaticCharMethodA(methodInfo.staticAccessContext, methodInfo.methodId, args); break;
                default:
                    returnValue.l = env->CallStaticObjectMethodA(methodInfo.staticAccessContext, methodInfo.methodId, args); break;
                }
            }else{
                switch(methodInfo.methodType){
                case JMethodType::v:
                    isVoid = true;
                    env->CallVoidMethodA(object, methodInfo.methodId, args); break;
                case JMethodType::z:
                    returnValue.z = env->CallBooleanMethodA(object, methodInfo.methodId, args); break;
                case JMethodType::b:
                    returnValue.b = env->CallByteMethodA(object, methodInfo.methodId, args); break;
                case JMethodType::i:
                    returnValue.i = env->CallIntMethodA(object, methodInfo.methodId, args); break;
                case JMethodType::s:
                    returnValue.s = env->CallShortMethodA(object, methodInfo.methodId, args); break;
                case JMethodType::j:
                    returnValue.j = env->CallLongMethodA(object, methodInfo.methodId, args); break;
                case JMethodType::f:
                    returnValue.f = env->CallFloatMethodA(object, methodInfo.methodId, args); break;
                case JMethodType::d:
                    returnValue.d = env->CallDoubleMethodA(object, methodInfo.methodId, args); break;
                case JMethodType::c:
                    returnValue.c = env->CallCharMethodA(object, methodInfo.methodId, args); break;
                default:
                    returnValue.l = env->CallObjectMethodA(object, methodInfo.methodId, args); break;
                }
            }
            qtjambi_throw_java_exception(env);
            if(_a[0]){
                if(!isVoid){
                    methodInfo.parameterTypeInfos[0].convertExternalToInternal(env, nullptr, returnValue, _a[0], jValueType(methodInfo.methodType));
                }
            }
        }
    }catch(const JavaException& exn){
        __exceptionHandler.handle(env, exn, nullptr);
    }
}

/**
 * This method calls the constructor of a Java class caused by a meta object constructor call.
 */
void QtJambiMetaObjectPrivate::invokeConstructor(JNIEnv *env, const JMethodInfo& methodInfo, void **_a) const
{
    QtJambiExceptionHandler __exceptionHandler;
    QTJAMBI_JNI_LOCAL_FRAME(env, 100)
    QtJambiScope scope(nullptr);
    try{
        QVector<jvalue> converted_arguments(methodInfo.parameterTypeInfos.size() - 1);
        bool success = true;

        for (int i = 0; i < converted_arguments.size(); ++i) {
            const ParameterTypeInfo& parameterTypeInfo = methodInfo.parameterTypeInfos[i + 1];
            converted_arguments[i].l = nullptr;
            if (!parameterTypeInfo.convertInternalToExternal(env, &scope, _a[i+1], &converted_arguments[i], !Java::Runtime::Class::isPrimitive(env, parameterTypeInfo.javaClass()))) {
                success = false;
                break;
            }
        }

        if (success) {
            jvalue *args = converted_arguments.data();
            jobject object = env->NewObjectA(m_clazz, methodInfo.methodId, args);
            qtjambi_throw_java_exception(env);
            if(Java::QtJambi::QtObjectInterface::isAssignableFrom(env, m_clazz)){
                void* &pointer = *reinterpret_cast<void**>(_a[0]);
                if(QSharedPointer<QtJambiLink> link = QtJambiLink::findLinkForJavaInterface(env, object))
                    pointer = link->pointer();
            }else{
                jobject &pointer = *reinterpret_cast<jobject*>(_a[0]);
                pointer = object;
            }
        } else {
            qWarning("QtJambiMetaObject::invokeConstructor: Failed to convert arguments");
        }
    }catch(const JavaException& exn){
        __exceptionHandler.handle(env, exn, nullptr);
    }
}


QtJambiMetaObject::QtJambiMetaObject(JNIEnv *jni_env, jclass java_class, const QMetaObject *original_meta_object, bool hasCustomMetaObject, JavaException& exceptionHandler)
    : d_ptr(new QtJambiMetaObjectPrivate(this, jni_env, java_class, original_meta_object, hasCustomMetaObject, exceptionHandler)) {
}

QtJambiMetaObject::~QtJambiMetaObject()
{
    delete d_ptr;
}

jweak QtJambiMetaObjectPrivate::javaInstance() const{
    return m_javaInstance;
}

void QtJambiMetaObjectPrivate::setJavaInstance(jweak weak){
    m_javaInstance = weak;
}

jclass QtJambiMetaObjectPrivate::javaClass() const{
    return m_clazz;
}

jweak QtJambiMetaObject::javaInstance(const QtJambiMetaObject* metaObject){
    return metaObject->d_ptr->javaInstance();
}

void QtJambiMetaObject::setJavaInstance(const QtJambiMetaObject* metaObject, jweak weak){
    metaObject->d_ptr->setJavaInstance(weak);
}

const QtJambiMetaObject* QtJambiMetaObject::cast(const QMetaObject* metaObject){
    return isInstance(metaObject) ? static_cast<const QtJambiMetaObject*>(metaObject) : nullptr;
}

bool QtJambiMetaObject::isInstance(const QMetaObject* metaObject){
    if(!metaObject)
        return false;
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    return metaObject->d.stringdata[0].data()==QtJambiMetaObjectID;
#else
    uint offset = metaObject->d.stringdata[0];
    uint length = metaObject->d.stringdata[1];
    if(length==sizeof(const char*)){
        const char* stringdata = reinterpret_cast<const char*>(metaObject->d.stringdata);
        const char* __stringdata = stringdata + offset;
        const void*const pointer = *reinterpret_cast<const void*const*>(__stringdata);
        return pointer==QtJambiMetaObjectID;
    }
    return false;
#endif //QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
}

jobject qtjambi_metaobject_javatype(JNIEnv *env, const QMetaObject *metaObject, bool exactOrNull)
{
    return QtJambiMetaObject::javaClass(env, metaObject, exactOrNull);
}


jclass QtJambiMetaObject::javaClass() const{
    return d_ptr->javaClass();
}

bool QtJambiMetaObject::hasSignals() const{
    return d_ptr->m_signal_count>0;
}

jobject QtJambiMetaObject::signalTypes(int index) const{
    return d_ptr->m_signals[index].signalTypes;
}

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
jfieldID QtJambiMetaObject::getQPropertyField(int index) const{
    return d_ptr->m_property_QProperty_fields[index].propertyField;
}

void QtJambiMetaObject::registerQPropertyField(int index, jfieldID field){
    if(!d_ptr->m_property_QProperty_fields[index].propertyField)
        d_ptr->m_property_QProperty_fields[index].propertyField = field;
}
#endif //QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)

jclass QtJambiMetaObject::javaClass(JNIEnv * env, const QMetaObject* metaObject, bool exactOrNull){
    if(!metaObject){
        return nullptr;
    }else if(const QtJambiMetaObject* dynamicMetaObject = QtJambiMetaObject::cast(metaObject)){
        return jclass(env->NewLocalRef(dynamicMetaObject->javaClass()));
    }else{
        if(const std::type_info* typeId = getTypeByMetaObject(metaObject)){
            jclass result = env->FindClass(getJavaName(*typeId));
            qtjambi_throw_java_exception(env);
            return result;
        }else if(const std::type_info* typeId = getTypeByQtName(metaObject->className())){
            if(!registeredOriginalMetaObject(*typeId)){
                jclass result = env->FindClass(getJavaName(*typeId));
                qtjambi_throw_java_exception(env);
                return result;
            }
        }
        if(exactOrNull){
            return nullptr;
        }else if(metaObject->superClass()){
            return javaClass(env, metaObject->superClass(), exactOrNull);
        }else{
            return Java::QtJambi::QtGadget::getClass(env);
        }
    }
}

jobject QtJambiMetaObject::toReflected(JNIEnv * env, const QMetaMethod& method)
{
    Q_ASSERT(method.isValid());
    const QMetaObject* metaObject = method.enclosingMetaObject();
    if(const QtJambiMetaObject* dynamicMetaObject = QtJambiMetaObject::cast(metaObject)){
        if(method.methodType()==QMetaMethod::Constructor){
            for(int i=0; i<method.enclosingMetaObject()->constructorCount(); ++i){
                if(method==method.enclosingMetaObject()->constructor(i)){
                    if(const JMethodInfo* info = dynamicMetaObject->d_ptr->constructorInfo(i)){
                        if(info->methodId)
                            return env->ToReflectedMethod(dynamicMetaObject->javaClass(), info->methodId, false);
                    }
                }
            }
        }else{
            if(const JMethodInfo* info = dynamicMetaObject->d_ptr->methodInfo(method.methodIndex() - method.enclosingMetaObject()->methodOffset())){
                if(info->methodId){
                    if(info->staticAccessContext){
                        return env->ToReflectedMethod(info->staticAccessContext, info->methodId, true);
                    }else{
                        return env->ToReflectedMethod(dynamicMetaObject->javaClass(), info->methodId, false);
                    }
                }
            }
        }
    }
    return nullptr;
}

const QList<ParameterTypeInfo>& QtJambiMetaObject::methodParameterInfo(JNIEnv * env, const QMetaMethod& method)
{
    Q_ASSERT(method.isValid());
    const QMetaObject* metaObject = method.enclosingMetaObject();
    if(const QtJambiMetaObject* dynamicMetaObject = QtJambiMetaObject::cast(metaObject)){
        if(method.methodType()==QMetaMethod::Constructor){
            for(int i=0; i<method.enclosingMetaObject()->constructorCount(); ++i){
                if(method==method.enclosingMetaObject()->constructor(i)){
                    if(const JMethodInfo* info = dynamicMetaObject->d_ptr->constructorInfo(i)){
                        return info->parameterTypeInfos;
                    }
                }
            }
        }else{
            if(const JMethodInfo* info = dynamicMetaObject->d_ptr->methodInfo(method.methodIndex() - method.enclosingMetaObject()->methodOffset())){
                return info->parameterTypeInfos;
            }
        }
    }
    const QList<ParameterTypeInfo>* cresult = nullptr;
    hash_type key = hashSum({qHash(qintptr(method.enclosingMetaObject())), qHash(method.methodIndex())});
    {
        QReadLocker locker(gJMethodInfoInfosLock());
        Q_UNUSED(locker)
        cresult = (*gParameterTypeInfos)[key];
    }
    if(!cresult){
        QList<ParameterTypeInfo>* result = new QList<ParameterTypeInfo>();
        ParameterInfoProvider ptip = registeredParameterInfoProvider(method.enclosingMetaObject());
        QList<ParameterInfo> parameterInfos;
        if(ptip && ptip(method, parameterInfos)){
            result->reserve(parameterInfos.size());
            for(const ParameterInfo& info : parameterInfos){
                if(!info.javaClass){
                    switch(info.metaTypeId){
                    case QMetaType::Void:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::Void::primitiveType(env)),
                                        ParameterTypeInfo::default_internalToExternalConverter(),
                                        ParameterTypeInfo::default_externalToInternalConverter()
                                  ));
                        break;
                    case QMetaType::UChar:
                    case QMetaType::Char:
                    case QMetaType::SChar:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::Byte::primitiveType(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool forceBoxedType)->bool{
                                               out->b = *reinterpret_cast<const qint8*>(in);
                                               if(forceBoxedType)
                                                   out->l = qtjambi_from_byte(env, out->b);
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType valueType) -> bool {
                                               qint8 _in;
                                               switch(valueType){
                                               case jValueType::l:
                                                   _in = qtjambi_to_byte(env, in.l);
                                               break;
                                               default:
                                                   _in = in.b;
                                               break;
                                               }
                                               if(scope && !out){
                                                   qint8* _out = new qint8;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<qint8*>(out) = _in;
                                               return true;
                                        }
                                  ));
                        break;
                    case QMetaType::UShort:
                    case QMetaType::Short:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::Short::primitiveType(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool forceBoxedType)->bool{
                                               out->s = *reinterpret_cast<const qint16*>(in);
                                               if(forceBoxedType)
                                                   out->l = qtjambi_from_short(env, out->s);
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType valueType) -> bool {
                                               qint16 _in;
                                               switch(valueType){
                                               case jValueType::l:
                                                   _in = qtjambi_to_short(env, in.l);
                                               break;
                                               default:
                                                   _in = in.s;
                                               break;
                                               }
                                               if(scope && !out){
                                                   qint16* _out = new qint16;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<qint16*>(out) = _in;
                                               return true;
                                        }
                                  ));
                        break;
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
                    case QMetaType::Char32:
#endif
                    case QMetaType::UInt:
                    case QMetaType::Int:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::Integer::primitiveType(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool forceBoxedType)->bool{
                                               out->i = *reinterpret_cast<const qint32*>(in);
                                               if(forceBoxedType)
                                                   out->l = qtjambi_from_int(env, out->i);
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType valueType) -> bool {
                                               qint32 _in;
                                               switch(valueType){
                                               case jValueType::l:
                                                   _in = qtjambi_to_int(env, in.l);
                                               break;
                                               default:
                                                   _in = in.i;
                                               break;
                                               }
                                               if(scope && !out){
                                                   qint32* _out = new qint32;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<qint32*>(out) = _in;
                                               return true;
                                        }
                                  ));
                        break;
                    case QMetaType::ULongLong:
                    case QMetaType::LongLong:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::Long::primitiveType(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool forceBoxedType)->bool{
                                               out->j = *reinterpret_cast<const qint64*>(in);
                                               if(forceBoxedType)
                                                   out->l = qtjambi_from_long(env, out->j);
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType valueType) -> bool {
                                               qint64 _in;
                                               switch(valueType){
                                               case jValueType::l:
                                                   _in = qtjambi_to_long(env, in.l);
                                               break;
                                               default:
                                                   _in = in.j;
                                               break;
                                               }
                                               if(scope && !out){
                                                   qint64* _out = new qint64;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<qint64*>(out) = _in;
                                               return true;
                                        }
                                  ));
                        break;
                    case QMetaType::ULong:
                    case QMetaType::Long:
                        if(QMetaType(info.metaTypeId).sizeOf()==4){
                            result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::Integer::primitiveType(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool forceBoxedType)->bool{
                                               out->i = *reinterpret_cast<const qint32*>(in);
                                               if(forceBoxedType)
                                                   out->l = qtjambi_from_int(env, out->i);
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType valueType) -> bool {
                                               qint32 _in;
                                               switch(valueType){
                                               case jValueType::l:
                                                   _in = qtjambi_to_int(env, in.l);
                                               break;
                                               default:
                                                   _in = in.i;
                                               break;
                                               }
                                               if(scope && !out){
                                                   qint32* _out = new qint32;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<qint32*>(out) = _in;
                                               return true;
                                        }
                                  ));
                        }else{
                            result->append(ParameterTypeInfo(
                                    info.metaTypeId,
                                    getGlobalClassRef(env, Java::Runtime::Long::primitiveType(env)),
                                    [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool forceBoxedType)->bool{
                                           out->j = *reinterpret_cast<const qint64*>(in);
                                           if(forceBoxedType)
                                               out->l = qtjambi_from_long(env, out->j);
                                           return true;
                                    },
                                    [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType valueType) -> bool {
                                           qint64 _in;
                                           switch(valueType){
                                           case jValueType::l:
                                               _in = qtjambi_to_long(env, in.l);
                                           break;
                                           default:
                                               _in = in.j;
                                           break;
                                           }
                                           if(scope && !out){
                                               qint64* _out = new qint64;
                                               scope->addDeletion(_out);
                                               out = _out;
                                           }
                                           if(!out)
                                               return false;
                                           *reinterpret_cast<qint64*>(out) = _in;
                                           return true;
                                    }
                              ));
                        }
                        break;
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
                    case QMetaType::Char16:
#endif
                    case QMetaType::QChar:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::Character::primitiveType(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool forceBoxedType)->bool{
                                               out->c = jchar(reinterpret_cast<const QChar*>(in)->unicode());
                                               if(forceBoxedType)
                                                   out->l = qtjambi_from_char(env, out->c);
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType valueType) -> bool {
                                               QChar _in;
                                               switch(valueType){
                                               case jValueType::l:
                                                   _in = qtjambi_to_char(env, in.l);
                                               break;
                                               default:
                                                   _in = in.c;
                                               break;
                                               }
                                               if(scope && !out){
                                                   QChar* _out = new QChar;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<QChar*>(out) = _in;
                                               return true;
                                        }
                                  ));
                        break;
                    case QMetaType::Float:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::Float::primitiveType(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool forceBoxedType)->bool{
                                               out->f = *reinterpret_cast<const float*>(in);
                                               if(forceBoxedType)
                                                   out->l = qtjambi_from_float(env, out->f);
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType valueType) -> bool {
                                               float _in;
                                               switch(valueType){
                                               case jValueType::l:
                                                   _in = qtjambi_to_float(env, in.l);
                                               break;
                                               default:
                                                   _in = in.f;
                                               break;
                                               }
                                               if(scope && !out){
                                                   float* _out = new float;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<float*>(out) = _in;
                                               return true;
                                        }
                                  ));
                        break;
                    case QMetaType::Double:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::Double::primitiveType(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool forceBoxedType)->bool{
                                               out->d = *reinterpret_cast<const double*>(in);
                                               if(forceBoxedType)
                                                   out->l = qtjambi_from_double(env, out->d);
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType valueType) -> bool {
                                               double _in;
                                               switch(valueType){
                                               case jValueType::l:
                                                   _in = qtjambi_to_double(env, in.l);
                                               break;
                                               default:
                                                   _in = in.d;
                                               break;
                                               }
                                               if(scope && !out){
                                                   double* _out = new double;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<double*>(out) = _in;
                                               return true;
                                        }
                                  ));
                        break;
                    case QMetaType::Bool:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::Boolean::primitiveType(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool forceBoxedType)->bool{
                                               out->z = *reinterpret_cast<const bool*>(in);
                                               if(forceBoxedType)
                                                   out->l = qtjambi_from_boolean(env, out->z);
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType valueType) -> bool {
                                               bool _in;
                                               switch(valueType){
                                               case jValueType::l:
                                                   _in = qtjambi_to_boolean(env, in.l);
                                               break;
                                               default:
                                                   _in = in.z;
                                               break;
                                               }
                                               if(scope && !out){
                                                   bool* _out = new bool;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<bool*>(out) = _in;
                                               return true;
                                        }
                                  ));
                        break;
                    case QMetaType::QString:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::String::getClass(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool)->bool{
                                               out->l = qtjambi_cast<jobject>(env, *reinterpret_cast<const QString*>(in));
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType) -> bool {
                                               if(scope && !out){
                                                   QString* _out = new QString;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<QString*>(out) = qtjambi_cast<QString>(env, in.l);
                                               return true;
                                        }
                                  ));
                        break;
                    case QMetaType::QByteArray:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::QtCore::QByteArray::getClass(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool)->bool{
                                               out->l = qtjambi_cast<jobject>(env, *reinterpret_cast<const QByteArray*>(in));
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType) -> bool {
                                               if(scope && !out){
                                                   QByteArray* _out = new QByteArray;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<QByteArray*>(out) = qtjambi_cast<QByteArray>(env, in.l);
                                               return true;
                                        }
                                  ));
                        break;
                    case QMetaType::QVariant:
                        result->append(ParameterTypeInfo(
                                        info.metaTypeId,
                                        getGlobalClassRef(env, Java::Runtime::Object::getClass(env)),
                                        [](JNIEnv* env, QtJambiScope*, const void* in, jvalue* out, bool)->bool{
                                               out->l = qtjambi_cast<jobject>(env, *reinterpret_cast<const QVariant*>(in));
                                               return true;
                                        },
                                        [](JNIEnv* env, QtJambiScope* scope, const jvalue& in, void* &out, jValueType) -> bool {
                                               if(scope && !out){
                                                   QVariant* _out = new QVariant;
                                                   scope->addDeletion(_out);
                                                   out = _out;
                                               }
                                               if(!out)
                                                   return false;
                                               *reinterpret_cast<QVariant*>(out) = qtjambi_cast<QVariant>(env, in.l);
                                               return true;
                                        }
                                  ));
                        break;
                    default:
                        break;
                    }
                }else{
                    result->append({info.metaTypeId,
                                    resolveClass(env, info.javaClass),
                                    info.qtToJavaConverterFunction,
                                    info.javaToQtConverterFunction});
                }
            }
        }else{
            int length = method.parameterCount()+1;
            result->reserve(length);
            jobject classLoader = nullptr;
            QList<QByteArray> parameterTypes = method.parameterTypes();
            for (int i=0; i<length; ++i){
                QByteArray qTypeName;
                int metaType;
                if(i==0){
                    if(method.methodType()==QMetaMethod::Constructor){
                        result->append({QMetaType::UnknownType,nullptr,nullptr,nullptr});
                        continue;
                    }
                    qTypeName = method.typeName();
                    metaType = method.returnType();
                }else{
                    qTypeName = parameterTypes.at(i-1).data();
                    metaType = method.parameterType(i-1);
                }
                if(metaType==QMetaType::UnknownType)
                    metaType = QMetaType::type(qTypeName);
                else if(metaType!=QMetaType::UnknownType && qTypeName.isEmpty())
                        qTypeName = QMetaType::typeName(metaType);
                QMetaType _metaType(metaType);
                QString externalTypeName = QtJambiTypeManager::getExternalTypeName(env, qTypeName, method.enclosingMetaObject(), _metaType);
                jclass javaClass = resolveClass(env, qPrintable(externalTypeName), classLoader);
                //Q_ASSERT(javaClass);
                if(javaClass){
                    // Find usage pattern
                    InternalToExternalConverter internalToExternalConverter = QtJambiTypeManager::getInternalToExternalConverter(
                                                                    env,
                                                                    qTypeName,
                                                                    _metaType,
                                                                    javaClass,
                                                                    true);
                    ExternalToInternalConverter externalToInternalConverter = QtJambiTypeManager::getExternalToInternalConverter(
                                                                    env,
                                                                    javaClass,
                                                                    qTypeName,
                                                                    _metaType);

                    if(Java::Runtime::Map::isAssignableFrom(env, javaClass)){
                        javaClass = getGlobalClassRef(env, Java::Runtime::Map::getClass(env));
                    }else if(Java::Runtime::Collection::isAssignableFrom(env, javaClass)){
                        javaClass = getGlobalClassRef(env, Java::Runtime::Collection::getClass(env));
                    }

                    result->append({metaType,
                                    javaClass,
                                    internalToExternalConverter,
                                    externalToInternalConverter});
                }else{
                    InternalToExternalConverter internalToExternalConverter;
                    if(method.methodType()==QMetaMethod::Signal && i>0){
                        internalToExternalConverter = [](JNIEnv* env, QtJambiScope* scope, const void* in, jvalue* p, bool) -> bool{
                            p->l = Java::QtJambi::QNativePointer::fromNative(env, jlong(in), int(QNativePointer::Type::Pointer), jlong(-1), 0, true);
                            Java::QtJambi::QNativePointer::setVerificationEnabled(env, p->l, true);
                            if(scope){
                                JObjectWrapper obj(env, p->l);
                                scope->addFinalAction([obj](){
                                    if(JNIEnv* env = qtjambi_current_environment()){
                                        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
                                        Java::QtJambi::QNativePointer::invalidate(env, obj.object());
                                    }
                                });
                            }
                            return true;
                        };
                    }
                    result->append({QMetaType::UnknownType,nullptr,std::move(internalToExternalConverter),nullptr});
                }
            }
        }
        QWriteLocker locker(gJMethodInfoInfosLock());
        Q_UNUSED(locker)
        gParameterTypeInfos->insert(key, result);
        cresult = result;
    }
    Q_ASSERT(cresult);
    return *cresult;
}

int QtJambiMetaObject::methodFromJMethod(const QMetaObject* metaObject, jmethodID methodId){
    if(const QtJambiMetaObject* dynamicMetaObject = QtJambiMetaObject::cast(metaObject)){
        return dynamicMetaObject->d_ptr->methodFromJMethod(methodId);
    }
    return -1;
}

QtJambiMetaObject::SignalInfo QtJambiMetaObject::signalInfo(const QMetaObject* metaObject, jfieldID fieldId, jmethodID emitMethodID){
    if(const QtJambiMetaObject* dynamicMetaObject = QtJambiMetaObject::cast(metaObject)){
        return dynamicMetaObject->d_ptr->signalInfo(fieldId, emitMethodID);
    }
    return SignalInfo();
}

QVector<QtJambiMetaObject::SignalInfo> QtJambiMetaObject::signalInfos(const QMetaObject* metaObject, jfieldID fieldId){
    if(const QtJambiMetaObject* dynamicMetaObject = QtJambiMetaObject::cast(metaObject)){
        return dynamicMetaObject->d_ptr->signalInfos(fieldId);
    }
    return {};
}

const JMethodInfo* QtJambiMetaObjectPrivate::constructorInfo(int index) const{
    const JMethodInfo* result = nullptr;
    if(index>=0 && index<m_constructors.size()){
        result = &m_constructors[index];
    }
    return result;
}

const JMethodInfo* QtJambiMetaObjectPrivate::methodInfo(int index) const{
    const JMethodInfo* result = nullptr;
    if(index>=0){
        if(index<m_signals.size()){
            result = &m_signals[index].emitMethodInfo;
        }else{
            index -= m_signal_count;
            if(index>=0 && index<m_methods.size()){
                result = &m_methods[index];
            }
        }
    }
    return result;
}

int QtJambiMetaObjectPrivate::methodFromJMethod(jmethodID methodId) const{
    Q_Q(const QtJambiMetaObject);
    int index = m_methodIndexes.value(methodId, -1);
    if(index>=0){
        index += m_signal_count + q->methodOffset();
    }
    return index;
}

QtJambiMetaObject::SignalInfo QtJambiMetaObjectPrivate::signalInfo(jfieldID fieldId, jmethodID emitMethodId) const{
    Q_Q(const QtJambiMetaObject);
    QHash<jmethodID,int> indexesByEmit = m_signalIndexes.value(fieldId);
    int index(-1);
    if(emitMethodId){
        index = indexesByEmit.value(emitMethodId, -1);
    }else if(!indexesByEmit.isEmpty()){
        index = *indexesByEmit.begin();
    }
    if(index>=0){
        return QtJambiMetaObject::SignalInfo(q, index+q->methodOffset(), m_signals[index].signalTypes, m_signals[index].signalClass);
    }
    return QtJambiMetaObject::SignalInfo();
}

QVector<QtJambiMetaObject::SignalInfo> QtJambiMetaObjectPrivate::signalInfos(jfieldID fieldId) const{
    Q_Q(const QtJambiMetaObject);
    QHash<jmethodID,int> indexesByEmit = m_signalIndexes.value(fieldId);
    QVector<QtJambiMetaObject::SignalInfo> result;
    for(int index : indexesByEmit){
        result << QtJambiMetaObject::SignalInfo(q, index+q->methodOffset(), m_signals[index].signalTypes, m_signals[index].signalClass);
    }
    return result;
}

int QtJambiMetaObject::metaCall(QObject * o, QMetaObject::Call cl, int idx, void **argv){
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        switch(cl){
        case QMetaObject::CreateInstance:
            return invokeConstructor(env, idx, argv);
        case QMetaObject::InvokeMetaMethod:
            if(!o){
                return static_metacall(cl, idx + methodOffset(), argv);
            }
            break;
        default:
            break;
        }
        if(jobject object = o ? qtjambi_from_qobject(env, o) : nullptr){
            switch(cl){
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
            case QMetaObject::QueryPropertyUser:
                queryPropertyUser(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyDesignable:
                queryPropertyDesignable(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyScriptable:
                queryPropertyScriptable(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyStored:
                queryPropertyStored(env, object, idx, argv, true);
                break;
            case QMetaObject::QueryPropertyEditable:
                queryPropertyEditable(env, object, idx, argv, true);
                break;
#else
            case QMetaObject::BindableProperty:
                bindableProperty(env, object, idx, argv, true);
                break;
#endif
            case QMetaObject::ResetProperty:
                resetProperty(env, object, idx, argv, true);
                break;
            case QMetaObject::ReadProperty:
                readProperty(env, object, idx, argv, true);
                break;
            case QMetaObject::WriteProperty:
                writeProperty(env, object, idx, argv, true);
                break;
            case QMetaObject::InvokeMetaMethod:
                invokeSignalOrSlot(env, object, idx, argv, true);
                break;
#if 0
            case QMetaObject::IndexOfMethod:
                printf("QMetaObject::IndexOfMethod\n");
                break;
            case QMetaObject::RegisterPropertyMetaType:
                printf("QMetaObject::RegisterPropertyMetaType\n");
                break;
            case QMetaObject::RegisterMethodArgumentMetaType:
                printf("QMetaObject::RegisterMethodArgumentMetaType\n");
                break;
#endif
            default:
                break;
            }
        }
    }
    return idx;
}

int QtJambiMetaObject::metaCall(QMetaObject::Call cl, int idx, void ** argv){
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        switch(cl){
        case QMetaObject::CreateInstance:
            return invokeConstructor(env, idx, argv);
        case QMetaObject::InvokeMetaMethod:
            return static_metacall(cl, idx + methodOffset(), argv);
        default:
            break;
        }
    }
    return idx;
}

int QtJambiMetaObject::invokeSignalOrSlot(JNIEnv *env, jobject object, int _id, void **_a, bool direct) const
{
    Q_D(const QtJambiMetaObject);

    const QMetaObject *super_class = superClass();
    if (!direct && super_class && QtJambiMetaObject::isInstance(super_class))
        _id = static_cast<const QtJambiMetaObject *>(super_class)->invokeSignalOrSlot(env, object, _id, _a);
    if (_id < 0) return _id;

    // Emit the correct signal
    if (_id < d->m_signal_count) {
        const JSignalInfo& signal = d->m_signals[_id];
        if(Java::QtCore::QObject::isInstanceOf(env, object) && !signal.isClone){
            QMetaObject::activate(qtjambi_cast<QObject*>(env, object), this, _id, _a);
        }else{
            jobject signal_object = env->GetObjectField(object, signal.signalField);
            qtjambi_throw_java_exception(env);
            Q_ASSERT(signal_object);
            d->invokeMethod(env, signal_object, signal.emitMethodInfo, _a);
        }
    } else if (_id < d->m_signal_count + d->m_method_count) { // Call the correct method
        d->invokeMethod(env, object, d->m_methods[_id - d->m_signal_count], _a);
    } else if (_id < d->m_signal_count + d->m_method_count + d->m_constructor_count) { // Call the correct constructor
        d->invokeConstructor(env, d->m_constructors[_id - d->m_signal_count - d->m_method_count], _a);
    }
    qtjambi_throw_java_exception(env);

    return _id - d->m_method_count - d->m_signal_count - d->m_constructor_count;
}

int QtJambiMetaObject::invokeConstructor(JNIEnv *env, int _id, void **_a) const
{
    Q_D(const QtJambiMetaObject);
    if (_id < d->m_signal_count + d->m_method_count + d->m_constructor_count) { // Call the correct constructor
        d->invokeConstructor(env, d->m_constructors[_id], _a);
    }
    return _id - d->m_constructor_count;
}

int QtJambiMetaObject::readProperty(JNIEnv *env, jobject object, int _id, void **_a, bool direct) const
{
    Q_D(const QtJambiMetaObject);

    const QMetaObject *super_class = superClass();
    if (!direct && super_class && QtJambiMetaObject::isInstance(super_class))
        _id = static_cast<const QtJambiMetaObject *>(super_class)->readProperty(env, object, _id, _a);
    if (_id < 0) return _id;

    if (_id < d->m_property_count) {
        if(d->m_property_readers[_id].methodId){
            d->invokeMethod(env, object, d->m_property_readers[_id], _a);
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        }else if (d->m_property_QProperty_fields[_id].propertyField && d->m_property_QProperty_fields[_id].valueMethod.methodId){
            jobject qProperty = env->GetObjectField(object, d->m_property_QProperty_fields[_id].propertyField);
            d->invokeMethod(env, qProperty, d->m_property_QProperty_fields[_id].valueMethod, _a);
#endif
        }else if (d->m_propertyMembers[_id].member){
            QtJambiExceptionHandler __exceptionHandler;
            try{
                switch(d->m_propertyMembers[_id].type){
                case jValueType::z:
                    *reinterpret_cast<jboolean*>(_a[0]) = env->GetBooleanField(object, d->m_propertyMembers[_id].member);
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::b:
                    *reinterpret_cast<jbyte*>(_a[0]) = env->GetByteField(object, d->m_propertyMembers[_id].member);
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::s:
                    *reinterpret_cast<jshort*>(_a[0]) = env->GetShortField(object, d->m_propertyMembers[_id].member);
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::i:
                    *reinterpret_cast<jint*>(_a[0]) = env->GetIntField(object, d->m_propertyMembers[_id].member);
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::j:
                    *reinterpret_cast<jlong*>(_a[0]) = env->GetLongField(object, d->m_propertyMembers[_id].member);
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::f:
                    *reinterpret_cast<float*>(_a[0]) = env->GetFloatField(object, d->m_propertyMembers[_id].member);
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::d:
                    *reinterpret_cast<double*>(_a[0]) = env->GetDoubleField(object, d->m_propertyMembers[_id].member);
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::c:
                    *reinterpret_cast<jchar*>(_a[0]) = env->GetCharField(object, d->m_propertyMembers[_id].member);
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::l:{
                        jvalue value;
                        value.l = env->GetObjectField(object, d->m_propertyMembers[_id].member);
                        qtjambi_throw_java_exception(env);
                        QtJambiScope scope;
                        d->m_propertyMembers[_id].memberTypeInfo.convertExternalToInternal(env, &scope, value, _a[0], jValueType::l);
                    }
                    break;
                }
            }catch(const JavaException& exn){
                __exceptionHandler.handle(env, exn, nullptr);
            }
        }
    }
    return _id - d->m_property_count;
}

int QtJambiMetaObject::writeProperty(JNIEnv *env, jobject object, int _id, void **_a, bool direct) const
{
    Q_D(const QtJambiMetaObject);

    const QMetaObject *super_class = superClass();
    if (!direct && super_class && QtJambiMetaObject::isInstance(super_class))
        _id = static_cast<const QtJambiMetaObject *>(super_class)->writeProperty(env, object, _id, _a);
    if (_id < 0) return _id;

    if (_id < d->m_property_count) {
        if(d->m_property_writers[_id].methodId){
            // invokeMethod expects a place holder for return value, but write property meta calls
            // do not since all property writers return void by convention.
            void *a[2] = { nullptr, _a[0] };
            d->invokeMethod(env, object, d->m_property_writers[_id], a);
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        }else if (d->m_property_QProperty_fields[_id].propertyField && d->m_property_QProperty_fields[_id].setValueMethod.methodId){
            jobject qProperty = env->GetObjectField(object, d->m_property_QProperty_fields[_id].propertyField);
            void *a[2] = { nullptr, _a[0] };
            d->invokeMethod(env, qProperty, d->m_property_QProperty_fields[_id].setValueMethod, a, d->m_property_QProperty_fields[_id].valueMethod.methodType==JMethodType::l);
#endif
        }else if (d->m_propertyMembers[_id].member && d->m_propertyMembers[_id].canWrite){
            QtJambiExceptionHandler __exceptionHandler;
            try{
                switch(d->m_propertyMembers[_id].type){
                case jValueType::z:
                    env->SetBooleanField(object, d->m_propertyMembers[_id].member, *reinterpret_cast<jboolean*>(_a[0]));
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::b:
                    env->SetByteField(object, d->m_propertyMembers[_id].member, *reinterpret_cast<jbyte*>(_a[0]));
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::s:
                    env->SetShortField(object, d->m_propertyMembers[_id].member, *reinterpret_cast<jshort*>(_a[0]));
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::i:
                    env->SetIntField(object, d->m_propertyMembers[_id].member, *reinterpret_cast<jint*>(_a[0]));
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::j:
                    env->SetLongField(object, d->m_propertyMembers[_id].member, *reinterpret_cast<jlong*>(_a[0]));
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::f:
                    env->SetFloatField(object, d->m_propertyMembers[_id].member, *reinterpret_cast<float*>(_a[0]));
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::d:
                    env->SetDoubleField(object, d->m_propertyMembers[_id].member, *reinterpret_cast<double*>(_a[0]));
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::c:
                    env->SetCharField(object, d->m_propertyMembers[_id].member, jchar(*reinterpret_cast<jchar*>(_a[0])));
                    qtjambi_throw_java_exception(env);
                    break;
                case jValueType::l:
                    jvalue value;
                    value.l = nullptr;
                    if (d->m_propertyMembers[_id].memberTypeInfo.convertInternalToExternal(env, nullptr, _a[0], &value, true)) {
                        env->SetObjectField(object, d->m_propertyMembers[_id].member, value.l);
                        qtjambi_throw_java_exception(env);
                        break;
                    }
                    break;
                }
            }catch(const JavaException& exn){
                __exceptionHandler.handle(env, exn, nullptr);
            }
        }
    }

    return _id - d->m_property_count;
}

int QtJambiMetaObject::resetProperty(JNIEnv *env, jobject object, int _id, void **_a, bool direct) const
{
    Q_D(const QtJambiMetaObject);

    const QMetaObject *super_class = superClass();
    if (!direct && super_class && QtJambiMetaObject::isInstance(super_class))
        _id = static_cast<const QtJambiMetaObject *>(super_class)->resetProperty(env, object, _id, _a);
    if (_id < 0) return _id;

    if (_id < d->m_property_count && d->m_property_resetters.contains(_id)) {
        d->invokeMethod(env, object, d->m_property_resetters[_id], _a);
    }

    return _id - d->m_property_count;
}

int QtJambiMetaObject::notifyProperty(JNIEnv *env, jobject object, int _id, void **_a, bool direct) const
{
    Q_D(const QtJambiMetaObject);

    const QMetaObject *super_class = superClass();
    if (!direct && super_class && QtJambiMetaObject::isInstance(super_class))
        _id = static_cast<const QtJambiMetaObject *>(super_class)->notifyProperty(env, object, _id, _a);
    if (_id < 0) return _id;

    if (_id < d->m_property_count
            && d->m_property_notifies.contains(_id)
            && d->m_property_notifies[_id]>=0
            && d->m_property_notifies[_id]<=d->m_signals.size()) {
        const JSignalInfo& signal = d->m_signals[d->m_property_notifies[_id]];
        if(signal.signalField && signal.emitMethodInfo.methodId){
            jobject signal_object = env->GetObjectField(object, signal.signalField);
            qtjambi_throw_java_exception(env);
            Q_ASSERT(signal_object);
            d->invokeMethod(env, signal_object, signal.emitMethodInfo, _a);
        }
    }

    return _id - d->m_property_count;
}

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
int QtJambiMetaObject::queryPropertyDesignable(JNIEnv *env, jobject object, int _id, void **_a, bool direct) const
{
    Q_D(const QtJambiMetaObject);

    const QMetaObject *super_class = superClass();
    if (!direct && super_class && QtJambiMetaObject::isInstance(super_class))
        _id = static_cast<const QtJambiMetaObject *>(super_class)->queryPropertyDesignable(env, object, _id, _a);
    if (_id < 0) return _id;

    if (_id < d->m_property_count && d->m_property_designable_resolvers.contains(_id)) {
        d->invokeMethod(env, object, d->m_property_designable_resolvers[_id], _a);
    }

    return _id - d->m_property_count;
}

int QtJambiMetaObject::queryPropertyScriptable(JNIEnv *env, jobject object, int _id, void **_a, bool direct) const
{
    Q_D(const QtJambiMetaObject);

    const QMetaObject *super_class = superClass();
    if (!direct && super_class && QtJambiMetaObject::isInstance(super_class))
        _id = static_cast<const QtJambiMetaObject *>(super_class)->queryPropertyScriptable(env, object, _id, _a);
    if (_id < 0) return _id;

    if (_id < d->m_property_count && d->m_property_scriptable_resolvers.contains(_id)) {
        d->invokeMethod(env, object, d->m_property_scriptable_resolvers[_id], _a);
    }

    return _id - d->m_property_count;
}

int QtJambiMetaObject::queryPropertyStored(JNIEnv *env, jobject object, int _id, void **_a, bool direct) const
{
    Q_D(const QtJambiMetaObject);

    const QMetaObject *super_class = superClass();
    if (!direct && super_class && QtJambiMetaObject::isInstance(super_class))
        _id = static_cast<const QtJambiMetaObject *>(super_class)->queryPropertyStored(env, object, _id, _a);
    if (_id < 0) return _id;

    if (_id < d->m_property_count && d->m_property_stored_resolvers.contains(_id)) {
        d->invokeMethod(env, object, d->m_property_stored_resolvers[_id], _a);
    }

    return _id - d->m_property_count;
}

int QtJambiMetaObject::queryPropertyUser(JNIEnv *env, jobject object, int _id, void **_a, bool direct) const
{
    Q_D(const QtJambiMetaObject);

    const QMetaObject *super_class = superClass();
    if (!direct && super_class && QtJambiMetaObject::isInstance(super_class))
        _id = static_cast<const QtJambiMetaObject *>(super_class)->queryPropertyUser(env, object, _id, _a);
    if (_id < 0) return _id;

    if (_id < d->m_property_count && d->m_property_user_resolvers.contains(_id)) {
        d->invokeMethod(env, object, d->m_property_user_resolvers[_id], _a);
    }

    return _id - d->m_property_count;
}

int QtJambiMetaObject::queryPropertyEditable(JNIEnv *env, jobject object, int _id, void **_a, bool direct) const
{
    Q_D(const QtJambiMetaObject);

    const QMetaObject *super_class = superClass();
    if (!direct && super_class && QtJambiMetaObject::isInstance(super_class))
        _id = static_cast<const QtJambiMetaObject *>(super_class)->queryPropertyEditable(env, object, _id, _a);
    if (_id < 0) return _id;

    if (_id < d->m_property_count && d->m_property_editable_resolvers.contains(_id)) {
        d->invokeMethod(env, object, d->m_property_editable_resolvers[_id], _a);
    }

    return _id - d->m_property_count;
}
#else
int QtJambiMetaObject::bindableProperty(JNIEnv *env, jobject object, int _id, void **_a, bool direct) const
{
    Q_D(const QtJambiMetaObject);

    const QMetaObject *super_class = superClass();
    if (!direct && super_class && QtJambiMetaObject::isInstance(super_class))
        _id = static_cast<const QtJambiMetaObject *>(super_class)->bindableProperty(env, object, _id, _a);
    if (_id < 0) return _id;

    if (_id < d->m_property_count) {
        if(d->m_property_bindables[_id].methodId){
            d->invokeMethod(env, object, d->m_property_bindables[_id], _a);
        }else if (d->m_property_QProperty_fields[_id].propertyField){
            jobject qProperty = env->GetObjectField(object, d->m_property_QProperty_fields[_id].propertyField);
            jobject bindable = Java::QtCore::QBindable::createBinding(env, qProperty);
            *reinterpret_cast<QUntypedBindable*>(_a[0]) = qtjambi_cast<QUntypedBindable>(env, bindable);
        }
    }

    return _id - d->m_property_count;
}
#endif //QT_VERSION < QT_VERSION_CHECK(6, 0, 0)

jclass QtJambiMetaObject::typeOfProperty(int _id) const
{
    Q_D(const QtJambiMetaObject);
    if (_id < d->m_property_count) {
        if(d->m_property_readers[_id].methodId){
            Q_ASSERT(d->m_property_readers[_id].parameterTypeInfos.size()>0);
            return d->m_property_readers[_id].parameterTypeInfos[0].javaClass();
        }
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        if (d->m_property_QProperty_fields[_id].valueMethod.methodId) {
            Q_ASSERT(d->m_property_QProperty_fields[_id].valueMethod.parameterTypeInfos.size()>0);
            return d->m_property_QProperty_fields[_id].valueMethod.parameterTypeInfos[0].javaClass();
        }
#endif
        if (d->m_propertyMembers[_id].member) {
            return d->m_propertyMembers[_id].memberTypeInfo.javaClass();
        }
        if (d->m_property_writers[_id].methodId) {
            Q_ASSERT(d->m_property_writers[_id].parameterTypeInfos.size()>1);
            return d->m_property_writers[_id].parameterTypeInfos[1].javaClass();
        }
    }
    return nullptr;
}

InternalToExternalConverter QtJambiMetaObject::internalToExternalConverterOfProperty(int _id) const
{
    Q_D(const QtJambiMetaObject);
    if (_id < d->m_property_count) {
        if(d->m_property_readers[_id].methodId){
            Q_ASSERT(d->m_property_readers[_id].parameterTypeInfos.size()>0);
            return d->m_property_readers[_id].parameterTypeInfos[0].m_internalToExternalConverter;
        }
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        if (d->m_property_QProperty_fields[_id].valueMethod.methodId) {
            Q_ASSERT(d->m_property_QProperty_fields[_id].valueMethod.parameterTypeInfos.size()>0);
            return d->m_property_QProperty_fields[_id].valueMethod.parameterTypeInfos[0].m_internalToExternalConverter;
        }
#endif
        if (d->m_propertyMembers[_id].member) {
            return d->m_propertyMembers[_id].memberTypeInfo.m_internalToExternalConverter;
        }
        if (d->m_property_writers[_id].methodId) {
            Q_ASSERT(d->m_property_writers[_id].parameterTypeInfos.size()>1);
            return d->m_property_writers[_id].parameterTypeInfos[1].m_internalToExternalConverter;
        }
    }
    return nullptr;
}

ExternalToInternalConverter QtJambiMetaObject::externalToInternalConverterOfProperty(int _id) const
{
    Q_D(const QtJambiMetaObject);
    if (_id < d->m_property_count) {
        if(d->m_property_readers[_id].methodId){
            Q_ASSERT(d->m_property_readers[_id].parameterTypeInfos.size()>0);
            return d->m_property_readers[_id].parameterTypeInfos[0].m_externalToInternalConverter;
        }
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        if (d->m_property_QProperty_fields[_id].valueMethod.methodId) {
            Q_ASSERT(d->m_property_QProperty_fields[_id].valueMethod.parameterTypeInfos.size()>0);
            return d->m_property_QProperty_fields[_id].valueMethod.parameterTypeInfos[0].m_externalToInternalConverter;
        }
#endif
        if (d->m_propertyMembers[_id].member) {
            return d->m_propertyMembers[_id].memberTypeInfo.m_externalToInternalConverter;
        }
        if (d->m_property_writers[_id].methodId) {
            Q_ASSERT(d->m_property_writers[_id].parameterTypeInfos.size()>1);
            return d->m_property_writers[_id].parameterTypeInfos[1].m_externalToInternalConverter;
        }
    }
    return nullptr;
}

const QSharedPointer<const QtJambiMetaObject>& QtJambiMetaObject::thisPointer() const
{
    Q_D(const QtJambiMetaObject);
    return d->m_this_ptr;
}

QSharedPointer<const QtJambiMetaObject> QtJambiMetaObject::dispose(JNIEnv * env) const
{
    Q_D(const QtJambiMetaObject);
    QSharedPointer<const QtJambiMetaObject> pointer = d->m_this_ptr;
    d->m_this_ptr.clear();
    if(d->m_javaInstance){
        env->DeleteWeakGlobalRef(d->m_javaInstance);
        d->m_javaInstance = nullptr;
    }
    return pointer;
}

const QMetaObject *qtjambi_metaobject_for_class(JNIEnv *env, jclass object_class, const std::function<const QMetaObject *(bool&)>& original_meta_object_provider)
{
    Q_ASSERT(object_class != nullptr);

    // If original_meta_object is null then we have to look it up

    int classHash = Java::Runtime::Object::hashCode(env,object_class);
    const QMetaObject *returned = nullptr;
    {
        QReadLocker locker(gMetaObjectsLock());
        Q_UNUSED(locker)
        returned = gMetaObjects->value(classHash, nullptr);
    }
    {
        if (returned == nullptr) {
            // Return original meta object for generated classes, and
            // create a new dynamic meta object for subclasses
            QtJambiMetaObject* dynamicResult = nullptr;
            bool basedOnCustomMetaObject = false;
            if (Java::QtJambi::QtJambiInternal::isGeneratedClass(env, object_class)) {
                returned = original_meta_object_provider(basedOnCustomMetaObject);
                if(!returned && !basedOnCustomMetaObject){
                    JavaException exceptionHandler;
                    dynamicResult = new QtJambiMetaObject(env, object_class, nullptr, false, exceptionHandler);
                    if(exceptionHandler.object()){
                        dynamicResult->dispose(env);
                        exceptionHandler.raise();
                    }else{
                        returned = dynamicResult;
                    }
                }
            } else {
                const QMetaObject *original_meta_object = original_meta_object_provider(basedOnCustomMetaObject);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
                if (original_meta_object==qt_getQtMetaObject()) {
#else
                if (original_meta_object==&Qt::staticMetaObject) {
#endif
                    returned = original_meta_object;
                }else {
                    JavaException exceptionHandler;
                    dynamicResult = new QtJambiMetaObject(env, object_class, original_meta_object, basedOnCustomMetaObject, exceptionHandler);
                    if(exceptionHandler.object()){
                        dynamicResult->dispose(env);
                        exceptionHandler.raise();
                    }else if(basedOnCustomMetaObject){
                        if(dynamicResult->d_ptr->m_signal_count>0){
                            QString class_name = qtjambi_class_name(env, object_class).replace("$", ".");
                            JavaException::raiseUnsupportedOperationException(env, qPrintable(QString("Cannot define signals in class %1 because it extends type with dynamic meta object.").arg(class_name)) QTJAMBI_STACKTRACEINFO );
                        }
                        dynamicResult->dispose(env);
                        returned = original_meta_object;
                    }else{
                        returned = dynamicResult;
                    }
                }
            }
            QWriteLocker locker(gMetaObjectsLock());
            Q_UNUSED(locker)
            // check if someone added a meta object meanwhile
            if(const QMetaObject *_returned = gMetaObjects->value(classHash, nullptr)){
                if(dynamicResult){
                    dynamicResult->dispose(env);
                }
                return _returned;
            }
            gMetaObjects->insert(classHash, returned);
        }
    }
    Q_ASSERT(returned);
    return returned;
}

const QMetaObject *qtjambi_metaobject_for_class(JNIEnv *env, jclass object_class, const QMetaObject *original_meta_object, bool _hasCustomMetaObject)
{
    return qtjambi_metaobject_for_class(env, object_class,
                                        [env, object_class, original_meta_object, _hasCustomMetaObject](bool& basedOnCustomMetaObject) -> const QMetaObject * {
                                            if (original_meta_object == nullptr) {
                                                QString class_name = qtjambi_class_name(env, object_class).replace(".", "/");
                                                if (class_name=="io/qt/core/Qt") {
#if QT_VERSION < QT_VERSION_CHECK(6,0,0)
                                                    return qt_getQtMetaObject();
#else
                                                    return &Qt::staticMetaObject;
#endif
                                                } else {
                                                    Q_ASSERT(!class_name.isEmpty());
                                                    if(const std::type_info* typeId = getTypeByJavaName(class_name)){
                                                        const QMetaObject* superType = superTypeForCustomMetaObject(*typeId);
                                                        return (basedOnCustomMetaObject = superType) ? superType : registeredOriginalMetaObject(*typeId);
                                                    }else if(jclass _object_class = resolveClosestQtSuperclass(env, object_class)){
                                                        class_name = qtjambi_class_name(env, _object_class).replace(".", "/");
                                                        Q_ASSERT(!class_name.isEmpty());
                                                        if(const std::type_info* typeId = getTypeByJavaName(class_name)){
                                                            const QMetaObject* superType = superTypeForCustomMetaObject(*typeId);
                                                            return (basedOnCustomMetaObject = superType) ? superType : registeredOriginalMetaObject(*typeId);
                                                        }
                                                    }
                                                }
                                            }
                                            basedOnCustomMetaObject = _hasCustomMetaObject;
                                            return original_meta_object;
                                        }
                                    );
}

const QMetaObject *qtjambi_metaobject_for_class(JNIEnv *env, jclass object_class, const std::type_info& typeId)
{
    return qtjambi_metaobject_for_class(env, object_class,
                                        [&typeId](bool& basedOnCustomMetaObject) -> const QMetaObject * {
                                            const QMetaObject* superType = superTypeForCustomMetaObject(typeId);
                                            return (basedOnCustomMetaObject = superType) ? superType : registeredOriginalMetaObject(typeId);
                                        }
                                    );
}

jobject qtjambi_get_signal_types(JNIEnv *env, jobject signal, const QMetaMethod& metaMethod){
    jobject result = nullptr;
    hash_type key = hashSum({qHash(qintptr(metaMethod.enclosingMetaObject())), qHash(metaMethod.methodIndex())});
    {
        QReadLocker locker(gJMethodInfoInfosLock());
        Q_UNUSED(locker)
        if(gSignalTypes->contains(key)){
            result = (*gSignalTypes)[key];
            if(result)
                return result;
        }
    }
    int count = metaMethod.isValid() ? metaMethod.parameterCount() : -1;
    jbooleanArray argumentIsPointerType = count > 0 ? env->NewBooleanArray(count) : nullptr;
    jbooleanArray argumentIsReferenceType = count > 0 ? env->NewBooleanArray(count) : nullptr;
    if(count>0){
        JBooleanArrayPointer isPointer(env, argumentIsPointerType, true);
        JBooleanArrayPointer isReference(env, argumentIsReferenceType, true);
        QList<QByteArray> parameterTypeNames = metaMethod.parameterTypes();
        for(int i=0; i<count; ++i){
            QByteArray& parameterTypeName = parameterTypeNames[i];
            if(parameterTypeName.endsWith("&")){
                isReference[i] = true;
            }else if(parameterTypeName.endsWith("*")){
                parameterTypeName.chop(1);
                parameterTypeName = parameterTypeName.trimmed();
                if(const std::type_info* typeId = getTypeByQtName(parameterTypeName)){
                    switch(getEntryType(*typeId)){
                    case EntryTypes::ValueTypeInfo:
                    case EntryTypes::InterfaceValueTypeInfo:
                        isPointer[i] = true;
                        break;
                    default: break;
                    }
                }
            }
        }
    }
    if(!signal){ // -> is extra signal
        const QList<ParameterTypeInfo>& parameterTypeInfos = QtJambiMetaObject::methodParameterInfo(env, metaMethod);
        jobjectArray signalParameterTypes = env->NewObjectArray(jsize(parameterTypeInfos.size()-1), Java::Runtime::Class::getClass(env), nullptr);
        for (decltype(parameterTypeInfos.size()) i=1; i<parameterTypeInfos.size(); ++i){
            env->SetObjectArrayElement(signalParameterTypes, jsize(i-1), parameterTypeInfos[i].javaClass());
        }
        signal = signalParameterTypes;
    }
    result = Java::QtJambi::QtJambiSignals::resolveSignal(env, signal, argumentIsPointerType, argumentIsReferenceType);
    {
        QWriteLocker locker(gJMethodInfoInfosLock());
        Q_UNUSED(locker)
        if(gSignalTypes->contains(key)){
            result = (*gSignalTypes)[key];
            if(result)
                return result;
        }
        gSignalTypes->insert(key, env->NewGlobalRef(result));
    }
    return result;
}

void clear_metaobjects_at_shutdown(JNIEnv * env)
{
    SignalTypesHash signalTypes;
    QList<const QList<ParameterTypeInfo>*> list;
    {
        QWriteLocker locker(gJMethodInfoInfosLock());
        Q_UNUSED(locker)
        if(!gParameterTypeInfos.isDestroyed()){
            list = gParameterTypeInfos->values();
            gParameterTypeInfos->clear();
        }
        if(!gSignalTypes.isDestroyed())
            signalTypes.swap(*gSignalTypes);
    }
    qDeleteAll(list);
    if(env){
        for(jobject obj : signalTypes){
            if(obj)
                env->DeleteGlobalRef(obj);
        }
    }
    QList<QSharedPointer<const QtJambiMetaObject>> metaObjects;
    MetaObjectHash metaObjectsHash;
    {
        QWriteLocker locker(gMetaObjectsLock());
        Q_UNUSED(locker)
        if(!gMetaObjects.isDestroyed())
            metaObjectsHash.swap(*gMetaObjects);
    }
    if(env){
        for(const QMetaObject* mo : metaObjectsHash){
            if(const QtJambiMetaObject* dynamo = QtJambiMetaObject::cast(mo)){
                // delete self-reference
                metaObjects << dynamo->dispose(env);
            }
        }
    }
    if(QThread *thread = QCoreApplicationPrivate::theMainThread.loadRelaxed()){
        if(QThreadUserData* data = QTJAMBI_GET_OBJECTUSERDATA(QThreadUserData, thread)){
            data->doAtThreadEnd([metaObjects](){/*delete captured list after function call*/});
        }
    }
}

