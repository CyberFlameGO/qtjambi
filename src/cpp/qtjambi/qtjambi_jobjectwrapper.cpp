/****************************************************************************
**
** Copyright (C) 1992-2009 Nokia. All rights reserved.
** Copyright (C) 2009-2021 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
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

#include <QtCore/QCoreApplication>
#include "qtjambi_core.h"
#include "qtjambi_jobjectwrapper.h"
#include "qtjambi_repository_p.h"
#include "qtjambi_registry_p.h"
#include "qtjambi_exceptions.h"
#include "qtjambitypemanager_p.h"

struct JObjectGlobalWrapperCleanup{
    static void cleanup(jobject object);
};

class JObjectGlobalWrapperData : public JObjectWrapperData{
public:
    JObjectGlobalWrapperData() = default;
    JObjectGlobalWrapperData(JNIEnv* env, jobject object);
    ~JObjectGlobalWrapperData() override = default;
    void clear(JNIEnv *env) override;
    jobject data() const override;
    const void* array() const override {return nullptr;}
    void* array() override {return nullptr;}
private:
    QScopedPointer<_jobject, JObjectGlobalWrapperCleanup> pointer;
};

struct JObjectWeakWrapperCleanup{
    static void cleanup(jobject object);
};

class JObjectWeakWrapperData : public JObjectWrapperData{
public:
    JObjectWeakWrapperData() = default;
    JObjectWeakWrapperData(JNIEnv* env, jobject object);
    ~JObjectWeakWrapperData() override = default;
    void clear(JNIEnv *env) override;
    jobject data() const override;
    const void* array() const override {return nullptr;}
    void* array() override {return nullptr;}
private:
    QScopedPointer<_jobject, JObjectWeakWrapperCleanup> pointer;
};

JNIEnv *qtjambi_current_environment(bool initializeJavaThread);

template<typename JType>
class JArrayGlobalWrapperData : public JObjectWrapperData{
    typedef typename JArray<JType>::Type ArrayType;
public:
    JArrayGlobalWrapperData() = default;
    JArrayGlobalWrapperData(JNIEnv* env, ArrayType object)
        : pointer( env->NewGlobalRef(object) ),
          m_array( object ? (env->*JArray<JType>::GetArrayElements)(object, nullptr) : nullptr)
    {}

    ~JArrayGlobalWrapperData() override{
        try{
            if(JNIEnv* env = qtjambi_current_environment(false)){
                QTJAMBI_JNI_LOCAL_FRAME(env, 500)
                try{
                    (env->*JArray<JType>::ReleaseArrayElements)(JArrayGlobalWrapperData::data(), m_array, 0);
                }catch(const JavaException& exn){
                    exn.report(env);
                } catch (...) {}
            }
        } catch (const std::exception& e) {
            qWarning("%s", e.what());
        }catch(...){}
    }
    void clear(JNIEnv *env) override{
        ArrayType array = JArrayGlobalWrapperData::data();
        if(array){
            (env->*JArray<JType>::ReleaseArrayElements)(array, m_array, 0);
            m_array = nullptr;
            DEREF_JOBJECT;
            jthrowable throwable = nullptr;
            if(env->ExceptionCheck()){
                throwable = env->ExceptionOccurred();
                env->ExceptionClear();
            }
            env->DeleteWeakGlobalRef(pointer.take());
            if(throwable)
                env->Throw(throwable);
        }
    }

    ArrayType data() const override {return ArrayType(pointer.data());}
    const void* array() const override  {return m_array;}
    void* array() override  {return m_array;}
private:
    QScopedPointer<_jobject, JObjectGlobalWrapperCleanup> pointer;
    JType* m_array = nullptr;
};


bool JObjectWrapper::operator==(const JObjectWrapper &other) const
{
    return (*this)==other.object();
}

bool JObjectWrapper::operator==(jobject otherObject) const
{
    jobject myObject = object();
    if (!myObject && !otherObject){
        return true;
    }else if (!myObject || !otherObject){
        return false;
    }else if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        Q_ASSERT(Java::Runtime::Object::isInstanceOf(env, myObject));  // check the java object is right type (objects on JVM don't have to inherit java.lang.Object)
        return Java::Runtime::Object::equals(env, myObject, otherObject);
    }else{
        return false;
    }
}

bool JObjectWrapper::operator<(const JObjectWrapper &other) const
{
    return (*this)<other.object();
}

bool JObjectWrapper::operator<(jobject otherObject) const
{
    jobject myObject = object();
    if (!myObject && !otherObject){
        return false;
    }else if (!myObject || !otherObject){
        return false;
    }else if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        if(Java::QtJambi::QFlags::isInstanceOf(env, myObject) && otherObject && env->IsInstanceOf(otherObject, env->GetObjectClass(myObject))){
            jint h1 = Java::QtJambi::QFlags::value(env, myObject);
            jint h2 = Java::QtJambi::QFlags::value(env, otherObject);
            return h1<h2;
        }else if(Java::QtJambi::QtEnumerator::isInstanceOf(env, myObject) && otherObject && env->IsInstanceOf(otherObject, env->GetObjectClass(myObject))){
            jint h1 = Java::QtJambi::QtEnumerator::value(env, myObject);
            jint h2 = Java::QtJambi::QtEnumerator::value(env, otherObject);
            return h1<h2;
        }else if(Java::QtJambi::QtShortEnumerator::isInstanceOf(env, myObject) && otherObject && env->IsInstanceOf(otherObject, env->GetObjectClass(myObject))){
            jshort h1 = Java::QtJambi::QtShortEnumerator::value(env, myObject);
            jshort h2 = Java::QtJambi::QtShortEnumerator::value(env, otherObject);
            return h1<h2;
        }else if(Java::QtJambi::QtByteEnumerator::isInstanceOf(env, myObject) && otherObject && env->IsInstanceOf(otherObject, env->GetObjectClass(myObject))){
            jbyte h1 = Java::QtJambi::QtByteEnumerator::value(env, myObject);
            jbyte h2 = Java::QtJambi::QtByteEnumerator::value(env, otherObject);
            return h1<h2;
        }else if(Java::QtJambi::QtLongEnumerator::isInstanceOf(env, myObject) && otherObject && env->IsInstanceOf(otherObject, env->GetObjectClass(myObject))){
            jlong h1 = Java::QtJambi::QtLongEnumerator::value(env, myObject);
            jlong h2 = Java::QtJambi::QtLongEnumerator::value(env, otherObject);
            return h1<h2;
        }else if(Java::Runtime::Enum::isInstanceOf(env, myObject) && otherObject && env->IsInstanceOf(otherObject, env->GetObjectClass(myObject))){
            jint h1 = Java::Runtime::Enum::ordinal(env, myObject);
            jint h2 = Java::Runtime::Enum::ordinal(env, otherObject);
            return h1<h2;
        }
        if(Java::Runtime::Comparable::isInstanceOf(env, myObject)){
            try{
                return Java::Runtime::Comparable::compareTo(env, myObject, otherObject)<0;
            }catch(const JavaException&){
            }
        }
        jint h1 = Java::Runtime::Object::hashCode(env, myObject);
        jint h2 = Java::Runtime::Object::hashCode(env, otherObject);
        return h1<h2;
    }else{
        return false;
    }
}

JObjectWrapper::JObjectWrapper() : m_data()
{
}

JObjectWrapper::JObjectWrapper(const JObjectWrapper &wrapper) : m_data(wrapper.m_data)
{
}

JObjectWrapper::JObjectWrapper(JObjectWrapper &&wrapper) : m_data(std::move(wrapper.m_data))
{
}

JObjectWrapper::JObjectWrapper(jobject obj)
    : m_data()
{
    if(obj){
        if(JNIEnv* env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 500)
            REF_JOBJECT;
            m_data = static_cast<JObjectWrapperData*>(new JObjectGlobalWrapperData(env, obj));
        }
    }
}

JObjectWrapper::JObjectWrapper(JNIEnv *env, jobject obj, bool globalRefs)
    : m_data()
{
    if(obj){
        REF_JOBJECT;
        m_data = globalRefs ? static_cast<JObjectWrapperData*>(new JObjectGlobalWrapperData(env, obj)) : static_cast<JObjectWrapperData*>(new JObjectWeakWrapperData(env, obj));
    }
}

JObjectWrapper::JObjectWrapper(JNIEnv *env, jobject obj, bool globalRefs, const std::type_info& typeId)
 : m_data()
{
    if(obj){
        REF_JOBJECT;
        if(globalRefs){
            if(typeId==typeid(jint)){
                m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jint>(env, jintArray(obj)));
            }else if(typeId==typeid(jbyte)){
                m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jbyte>(env, jbyteArray(obj)));
            }else if(typeId==typeid(jshort)){
                m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jshort>(env, jshortArray(obj)));
            }else if(typeId==typeid(jlong)){
                m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jlong>(env, jlongArray(obj)));
            }else if(typeId==typeid(jchar)){
                m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jchar>(env, jcharArray(obj)));
            }else if(typeId==typeid(jboolean)){
                m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jboolean>(env, jbooleanArray(obj)));
            }else if(typeId==typeid(jfloat)){
                m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jfloat>(env, jfloatArray(obj)));
            }else if(typeId==typeid(jdouble)){
                m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jdouble>(env, jdoubleArray(obj)));
            }
        }else{
            m_data = static_cast<JObjectWrapperData*>(new JObjectWeakWrapperData(env, obj));
        }
    }
}

void JObjectWrapper::assign(JNIEnv* env, const JObjectWrapper& wrapper, const std::type_info& typeId)
{
    if(typeid(wrapper.m_data)==typeid(JObjectGlobalWrapperData)){
        if(typeId==typeid(jint)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jint>(env, jintArray(wrapper.object())));
        }else if(typeId==typeid(jbyte)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jbyte>(env, jbyteArray(wrapper.object())));
        }else if(typeId==typeid(jshort)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jshort>(env, jshortArray(wrapper.object())));
        }else if(typeId==typeid(jlong)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jlong>(env, jlongArray(wrapper.object())));
        }else if(typeId==typeid(jchar)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jchar>(env, jcharArray(wrapper.object())));
        }else if(typeId==typeid(jboolean)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jboolean>(env, jbooleanArray(wrapper.object())));
        }else if(typeId==typeid(jfloat)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jfloat>(env, jfloatArray(wrapper.object())));
        }else if(typeId==typeid(jdouble)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jdouble>(env, jdoubleArray(wrapper.object())));
        }else{
            m_data.reset();
        }
    }else{
        m_data = static_cast<JObjectWrapperData*>(new JObjectWeakWrapperData(env, wrapper.object()));
    }
}
void JObjectWrapper::assign(JNIEnv* env, JObjectWrapper&& wrapper, const std::type_info& typeId)
{
    if(typeid(wrapper.m_data)==typeid(JObjectGlobalWrapperData)){
        if(typeId==typeid(jint)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jint>(env, jintArray(wrapper.object())));
        }else if(typeId==typeid(jbyte)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jbyte>(env, jbyteArray(wrapper.object())));
        }else if(typeId==typeid(jshort)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jshort>(env, jshortArray(wrapper.object())));
        }else if(typeId==typeid(jlong)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jlong>(env, jlongArray(wrapper.object())));
        }else if(typeId==typeid(jchar)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jchar>(env, jcharArray(wrapper.object())));
        }else if(typeId==typeid(jboolean)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jboolean>(env, jbooleanArray(wrapper.object())));
        }else if(typeId==typeid(jfloat)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jfloat>(env, jfloatArray(wrapper.object())));
        }else if(typeId==typeid(jdouble)){
            m_data = static_cast<JObjectWrapperData*>(new JArrayGlobalWrapperData<jdouble>(env, jdoubleArray(wrapper.object())));
        }else{
            m_data.reset();
        }
    }else{
        m_data = static_cast<JObjectWrapperData*>(new JObjectWeakWrapperData(env, wrapper.object()));
    }
}

const void* JObjectWrapper::array() const
{
    if(m_data)
        return m_data->array();
    return nullptr;
}

void* JObjectWrapper::array()
{
    if(m_data)
        return m_data->array();
    return nullptr;
}

JObjectWrapper& JObjectWrapper::operator=(jobject object) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(Java::Runtime::Enum::isInstanceOf(env, object)
           || Java::QtJambi::QtEnumerator::isInstanceOf(env, object)
           || Java::QtJambi::QtShortEnumerator::isInstanceOf(env, object)
           || Java::QtJambi::QtByteEnumerator::isInstanceOf(env, object)
           || Java::QtJambi::QtLongEnumerator::isInstanceOf(env, object)){
           *this = JEnumWrapper(env, object);
        }else if(Java::Runtime::Collection::isInstanceOf(env, object)){
            *this = JCollectionWrapper(env, object);
        }else if(Java::Runtime::Map::isInstanceOf(env, object)){
            *this = JMapWrapper(env, object);
        }else if(Java::Runtime::Iterator::isInstanceOf(env, object)){
            *this = JIteratorWrapper(env, object);
        }else{
            jclass cls = env->GetObjectClass(object);
            if(Java::Runtime::Class::isArray(env, cls)){
                jclass componentType = Java::Runtime::Class::getComponentType(env, cls);
                if(Java::Runtime::Integer::isPrimitiveType(env, componentType)){
                    *this = JIntArrayWrapper(env, jintArray(object));
                }else if(Java::Runtime::Byte::isPrimitiveType(env, componentType)){
                    *this = JByteArrayWrapper(env, jbyteArray(object));
                }else if(Java::Runtime::Short::isPrimitiveType(env, componentType)){
                    *this = JShortArrayWrapper(env, jshortArray(object));
                }else if(Java::Runtime::Long::isPrimitiveType(env, componentType)){
                    *this = JLongArrayWrapper(env, jlongArray(object));
                }else if(Java::Runtime::Character::isPrimitiveType(env, componentType)){
                    *this = JCharArrayWrapper(env, jcharArray(object));
                }else if(Java::Runtime::Boolean::isPrimitiveType(env, componentType)){
                    *this = JBooleanArrayWrapper(env, jbooleanArray(object));
                }else if(Java::Runtime::Float::isPrimitiveType(env, componentType)){
                    *this = JFloatArrayWrapper(env, jfloatArray(object));
                }else if(Java::Runtime::Double::isPrimitiveType(env, componentType)){
                    *this = JDoubleArrayWrapper(env, jdoubleArray(object));
                }else{
                    *this = JObjectArrayWrapper(env, jobjectArray(object));
                }
            }else{
                *this = JObjectWrapper(env, object);
            }
        }
    }
    return *this;
}

JObjectWrapper& JObjectWrapper::operator=(const JObjectWrapper &wrapper) {
    m_data = wrapper.m_data;
    return *this;
}

JObjectWrapper& JObjectWrapper::operator=(JObjectWrapper &&wrapper) {
    if(typeid(*this)==typeid(wrapper) || !wrapper.object()){
        m_data = std::move(wrapper.m_data);
    }
    return *this;
}

jobject JObjectWrapper::object() const{
    return m_data ? m_data->data() : nullptr;
}

void JObjectWrapper::clear(JNIEnv *env){
    if(m_data){
        if(m_data->ref.loadRelaxed()==1){
            m_data->clear(env);
        }
        m_data.reset();
    }
}

JObjectWrapper::~JObjectWrapper(){}

QString JObjectWrapper::toString(bool * ok) const {
    jobject _object = object();
    if(_object){
        if(JNIEnv *env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 200)
            if(ok){
                if (Java::QtCore::QMetaType$GenericTypeInterface::isInstanceOf(env, _object)) {
                    QVariant variant = qtjambi_to_qvariant(env, _object);
                    *ok = true;
                    return variant.toString();
                }else if (Java::QtJambi::QtObjectInterface::isInstanceOf(env, _object)) {
                    jstring strg = Java::QtJambi::QtJambiInternal::objectToString(env, _object);
                    *ok = strg;
                    return qtjambi_to_qstring(env, strg);
                }else{
                    return qtjambi_to_qstring(env, Java::Runtime::Object::toString(env, _object));
                }
            }else{
                return qtjambi_to_qstring(env, Java::Runtime::Object::toString(env, _object));
            }
        }
    }
    return "null";
}

jobject JObjectWrapper::filterPrimitiveArray(JNIEnv *env, jobject object, const std::type_info& typeId){
    if(object){
        jclass cls = env->GetObjectClass(object);
        if(Java::Runtime::Class::isArray(env, cls)){
            jclass componentType = Java::Runtime::Class::getComponentType(env, cls);
            if(typeId==typeid(jint) && Java::Runtime::Integer::isPrimitiveType(env, componentType)){
                return object;
            }else if(typeId==typeid(jbyte) && Java::Runtime::Byte::isPrimitiveType(env, componentType)){
                return object;
            }else if(typeId==typeid(jshort) && Java::Runtime::Short::isPrimitiveType(env, componentType)){
                return object;
            }else if(typeId==typeid(jlong) && Java::Runtime::Long::isPrimitiveType(env, componentType)){
                return object;
            }else if(typeId==typeid(jchar) && Java::Runtime::Character::isPrimitiveType(env, componentType)){
                return object;
            }else if(typeId==typeid(jboolean) && Java::Runtime::Boolean::isPrimitiveType(env, componentType)){
                return object;
            }else if(typeId==typeid(jfloat) && Java::Runtime::Float::isPrimitiveType(env, componentType)){
                return object;
            }else if(typeId==typeid(jdouble) && Java::Runtime::Double::isPrimitiveType(env, componentType)){
                return object;
            }
        }
    }
    return nullptr;
}

jobject filterObjectArray(JNIEnv *env, jobject object){
    if(object){
        jclass cls = env->GetObjectClass(object);
        if(Java::Runtime::Class::isArray(env, cls)){
            jclass componentType = Java::Runtime::Class::getComponentType(env, cls);
            if(!Java::Runtime::Class::isPrimitive(env, componentType)){
               return object;
            }
        }
    }
    return nullptr;
}

jobject filterObjectArray(jobject object){
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        return filterObjectArray(env, object);
    }
    return nullptr;
}

jobject filterIterator(JNIEnv *env, jobject object){
    if(Java::Runtime::Iterator::isInstanceOf(env, object)){
       return object;
    }
    return nullptr;
}

jobject filterIterator(jobject object){
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        return filterIterator(env, object);
    }
    return nullptr;
}

jobject filterCollection(JNIEnv *env, jobject object){
    if(Java::Runtime::Collection::isInstanceOf(env, object)){
       return object;
    }
    return nullptr;
}

jobject filterCollection(jobject object){
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        return filterCollection(env, object);
    }
    return nullptr;
}

jobject filterMap(JNIEnv *env, jobject object){
    if(Java::Runtime::Map::isInstanceOf(env, object)){
       return object;
    }
    return nullptr;
}

jobject filterMap(jobject object){
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        return filterMap(env, object);
    }
    return nullptr;
}

jobject filterEnum(JNIEnv *env, jobject object){
    if(Java::Runtime::Enum::isInstanceOf(env, object)
        || Java::QtJambi::QtEnumerator::isInstanceOf(env, object)
        || Java::QtJambi::QtShortEnumerator::isInstanceOf(env, object)
        || Java::QtJambi::QtByteEnumerator::isInstanceOf(env, object)
        || Java::QtJambi::QtLongEnumerator::isInstanceOf(env, object)){
       return object;
    }
    return nullptr;
}

jobject filterEnum(jobject object){
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        return filterEnum(env, object);
    }
    return nullptr;
}

JEnumWrapper::JEnumWrapper(JNIEnv *env, jobject obj, bool globalRefs)
    : JObjectWrapper(env, filterEnum(env, obj), globalRefs) {}

JEnumWrapper::JEnumWrapper(jobject obj)
    : JObjectWrapper(filterEnum(obj)) {}

JEnumWrapper& JEnumWrapper::operator=(jobject object) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        object = filterEnum(env, object);
        if(object){
            m_data = static_cast<JObjectWrapperData*>(new JObjectGlobalWrapperData(env, object));
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JEnumWrapper& JEnumWrapper::operator=(const JObjectWrapper &wrapper) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(filterEnum(env, wrapper.object())){
            m_data = wrapper.m_data;
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JEnumWrapper& JEnumWrapper::operator=(JObjectWrapper &&wrapper) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(filterEnum(env, wrapper.object())){
            m_data = std::move(wrapper.m_data);
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JEnumWrapper& JEnumWrapper::operator=(const JEnumWrapper &wrapper) {
    m_data = wrapper.m_data;
    return *this;
}

JEnumWrapper& JEnumWrapper::operator=(JEnumWrapper &&wrapper) {
    m_data = std::move(wrapper.m_data);
    return *this;
}

#undef filterEnum

qint32 JEnumWrapper::ordinal() const {
    jobject _object = object();
    if(_object){
        if(JNIEnv *env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 200)
            return Java::Runtime::Enum::ordinal(env, _object);
        }
    }
    return -1;
}

JIteratorWrapper::JIteratorWrapper(JNIEnv *env, jobject obj, bool globalRefs)
    : JObjectWrapper(env, filterIterator(env, obj), globalRefs) {}

JIteratorWrapper::JIteratorWrapper(jobject obj)
    : JObjectWrapper(filterIterator(obj)) {}

JIteratorWrapper& JIteratorWrapper::operator=(jobject object) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        object = filterIterator(env, object);
        if(object){
            m_data = static_cast<JObjectWrapperData*>(new JObjectGlobalWrapperData(env, object));
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JIteratorWrapper& JIteratorWrapper::operator=(const JObjectWrapper &wrapper) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(filterIterator(env, wrapper.object())){
            m_data = wrapper.m_data;
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JIteratorWrapper& JIteratorWrapper::operator=(JObjectWrapper &&wrapper) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(filterIterator(env, wrapper.object())){
            m_data = std::move(wrapper.m_data);
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JIteratorWrapper& JIteratorWrapper::operator=(const JIteratorWrapper &wrapper) {
    m_data = wrapper.m_data;
    return *this;
}

JIteratorWrapper& JIteratorWrapper::operator=(JIteratorWrapper &&wrapper) {
    m_data = std::move(wrapper.m_data);
    return *this;
}

bool JIteratorWrapper::hasNext() const {
    jobject _object = object();
    if(_object){
        if(JNIEnv *env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 500)
            return Java::Runtime::Iterator::hasNext(env, _object);
        }
    }
    return false;
}

JObjectWrapper JIteratorWrapper::next() const {
    if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        return JObjectWrapper(env, _next(env));
    }else{
        return JObjectWrapper();
    }
}

jobject JIteratorWrapper::_next(JNIEnv *env) const {
    jobject _object = object();
    if(_object){
        return Java::Runtime::Iterator::next(env, _object);
    }else{
        return nullptr;
    }
}

JCollectionWrapper::JCollectionWrapper(JNIEnv *env, jobject obj, bool globalRefs)
    : JObjectWrapper(env, filterCollection(env, obj), globalRefs) {}

JCollectionWrapper::JCollectionWrapper(jobject obj)
    : JObjectWrapper(filterCollection(obj)) {}

JCollectionWrapper& JCollectionWrapper::operator=(jobject object) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        object = filterCollection(env, object);
        if(object){
            m_data = static_cast<JObjectWrapperData*>(new JObjectGlobalWrapperData(env, object));
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JCollectionWrapper& JCollectionWrapper::operator=(const JObjectWrapper &wrapper) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(filterCollection(env, wrapper.object())){
            m_data = wrapper.m_data;
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JCollectionWrapper& JCollectionWrapper::operator=(JObjectWrapper &&wrapper) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(filterCollection(env, wrapper.object())){
            m_data = std::move(wrapper.m_data);
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JCollectionWrapper& JCollectionWrapper::operator=(const JCollectionWrapper &wrapper) {
    m_data = wrapper.m_data;
    return *this;
}

JCollectionWrapper& JCollectionWrapper::operator=(JCollectionWrapper &&wrapper) {
    m_data = std::move(wrapper.m_data);
    return *this;
}

int JCollectionWrapper::size() const {
    jobject _object = object();
    if(_object){
        if(JNIEnv *env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 200)
           return Java::Runtime::Collection::size(env, _object);
        }
    }
    return 0;
}

JIteratorWrapper JCollectionWrapper::iterator() const {
    jobject _object = object();
    if(_object){
        if(JNIEnv *env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 200)
            jobject iter = Java::Runtime::Collection::iterator(env, _object);
            return JIteratorWrapper(env, iter);
        }
    }
    return JIteratorWrapper();
}

QList<QVariant> JCollectionWrapper::toList() const {
    QList<QVariant> list;
    if(object()){
        if(JNIEnv *env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 200)
            for (JIteratorWrapper iter = iterator(); iter.hasNext();) {
                jobject o = iter._next(env);
                list << qtjambi_to_qvariant(env, o);
            }
        }
    }
    return list;
}

QString qtjambi_to_qstring(JNIEnv *env, jobject object);

QStringList JCollectionWrapper::toStringList(bool * ok) const {
    QStringList list;
    if(object()){
        if(JNIEnv *env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 200)
            for (JIteratorWrapper iter = iterator(); iter.hasNext();) {
                list << qtjambi_to_qstring(env, iter._next(env));
            }
        }
    }
    if(ok) ok[0] = true;
    return list;
}

JMapWrapper::JMapWrapper(JNIEnv *env, jobject obj, bool globalRefs)
    : JObjectWrapper(env, filterMap(env, obj), globalRefs) {}

JMapWrapper::JMapWrapper(jobject obj)
    : JObjectWrapper(filterMap(obj)) {}

JMapWrapper& JMapWrapper::operator=(jobject object) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        object = filterMap(env, object);
        if(object){
            m_data = static_cast<JObjectWrapperData*>(new JObjectGlobalWrapperData(env, object));
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JMapWrapper& JMapWrapper::operator=(const JObjectWrapper &wrapper) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(filterMap(env, wrapper.object())){
            m_data = wrapper.m_data;
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JMapWrapper& JMapWrapper::operator=(JObjectWrapper &&wrapper) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(filterMap(env, wrapper.object())){
            m_data = std::move(wrapper.m_data);
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JMapWrapper& JMapWrapper::operator=(const JMapWrapper &wrapper) {
    m_data = wrapper.m_data;
    return *this;
}

JMapWrapper& JMapWrapper::operator=(JMapWrapper &&wrapper) {
    m_data = std::move(wrapper.m_data);
    return *this;
}

jobject JMapWrapper::_entrySet() const {
    jobject _object = object();
    if(_object){
        JNIEnv *env = qtjambi_current_environment();
        env->PushLocalFrame(100);
        return env->PopLocalFrame(Java::Runtime::Map::entrySet(env, _object));
    }else{
        return jobject();
    }
}

JCollectionWrapper JMapWrapper::entrySet() const {
    return JCollectionWrapper(qtjambi_current_environment(), _entrySet());
}

QMap<QVariant,QVariant> JMapWrapper::toMap() const {
    QMap<QVariant,QVariant> map;
    if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        int type = QMetaType::UnknownType;
        for(JIteratorWrapper iter = entrySet().iterator(); iter.hasNext();){
            jobject entry = iter._next(env);
            jobject key = Java::Runtime::Map$Entry::getKey(env, entry);
            jobject value = Java::Runtime::Map$Entry::getValue(env, entry);
            QVariant k(qtjambi_to_qvariant(env, key));
            QVariant v(qtjambi_to_qvariant(env, value));
            if(k.userType()!=QMetaType::UnknownType){
                if(type==QMetaType::UnknownType){
                    type = k.userType();
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
                    if(!QtJambiTypeManager::hasRegisteredComparators(type)){
                        break;
                    }
#endif //QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
                }else if(type != k.userType()){
                    continue;
                }
                map.insert(k, v);
            }
        }
    }
    return map;
}

QVariantMap JMapWrapper::toStringMap(bool* ok) const {
    QVariantMap map;
    if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        for(JIteratorWrapper iter = entrySet().iterator(); iter.hasNext();){
            jobject entry = iter._next(env);
            jobject key = Java::Runtime::Map$Entry::getKey(env, entry);
            if(ok && key && !Java::Runtime::String::isInstanceOf(env, key)){
                ok[0] = false;
                map.clear();
                return map;
            }
            jobject value = Java::Runtime::Map$Entry::getValue(env, entry);
            map.insert(qtjambi_to_qvariant(env, key).toString(), qtjambi_to_qvariant(env, value));
        }
        if(ok) ok[0] = true;
    }else{
        ok[0] = false;
    }
    return map;
}

QVariantHash JMapWrapper::toStringHash(bool* ok) const {
    QVariantHash map;
    if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        for(JIteratorWrapper iter = entrySet().iterator(); iter.hasNext();){
            jobject entry = iter._next(env);
            jobject key = Java::Runtime::Map$Entry::getKey(env, entry);
            if(ok && key && !Java::Runtime::String::isInstanceOf(env, key)){
                ok[0] = false;
                map.clear();
                return map;
            }
            jobject value = Java::Runtime::Map$Entry::getValue(env, entry);
            map.insert(qtjambi_to_qvariant(env, key).toString(), qtjambi_to_qvariant(env, value));
        }
        if(ok) ok[0] = true;
    }else{
        ok[0] = false;
    }
    return map;
}

JObjectWrapperRef::JObjectWrapperRef(const JObjectWrapper& arrayWrapper, jsize index) : m_arrayWrapper(arrayWrapper), m_index(index) {}

JObjectWrapperRef& JObjectWrapperRef::operator=(jobject newValue)
{
    if(m_arrayWrapper.object()){
        if(JNIEnv *env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 200)
            env->SetObjectArrayElement(jobjectArray(m_arrayWrapper.object()), m_index, newValue);
            qtjambi_throw_java_exception(env)
        }
    }
    return *this;
}

JObjectWrapperRef& JObjectWrapperRef::operator=(const JObjectWrapper &newValue)
{
    if(m_arrayWrapper.object()){
        if(JNIEnv *env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 200)
            env->SetObjectArrayElement(jobjectArray(m_arrayWrapper.object()), m_index, newValue.object());
            qtjambi_throw_java_exception(env)
        }
    }
    return *this;
}

JObjectWrapperRef::operator JObjectWrapper() const
{
    if(m_arrayWrapper.object()){
        if(JNIEnv *env = qtjambi_current_environment()){
            QTJAMBI_JNI_LOCAL_FRAME(env, 200)
            jobject value = env->GetObjectArrayElement(jobjectArray(m_arrayWrapper.object()), m_index);
            qtjambi_throw_java_exception(env)
            return JObjectWrapper(env, value);
        }
    }
    return JObjectWrapper();
}

JObjectWrapperRef::operator jobject() const
{
    if(m_arrayWrapper.object()){
        if(JNIEnv *env = qtjambi_current_environment()){
            env->PushLocalFrame(200);
            jobject value = env->GetObjectArrayElement(jobjectArray(m_arrayWrapper.object()), m_index);
            qtjambi_throw_java_exception(env)
            return env->PopLocalFrame(value);
        }
    }
    return nullptr;
}

JObjectArrayWrapper::JObjectArrayWrapper(JNIEnv *env, jobjectArray obj, bool globalRefs)
    : JObjectWrapper(env, filterObjectArray(env, obj), globalRefs) {}

JObjectArrayWrapper::JObjectArrayWrapper(jobjectArray obj)
    : JObjectWrapper(filterObjectArray(obj)) {}

JObjectArrayWrapper& JObjectArrayWrapper::operator=(jobject object) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        object = filterObjectArray(env, object);
        if(object){
            m_data = static_cast<JObjectWrapperData*>(new JObjectGlobalWrapperData(env, object));
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JObjectArrayWrapper& JObjectArrayWrapper::operator=(const JObjectWrapper &wrapper) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(filterObjectArray(env, wrapper.object())){
            m_data = wrapper.m_data;
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JObjectArrayWrapper& JObjectArrayWrapper::operator=(JObjectWrapper &&wrapper) {
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(filterObjectArray(env, wrapper.object())){
            m_data = std::move(wrapper.m_data);
        }else{
            m_data.reset();
        }
    }
    return *this;
}

JObjectArrayWrapper& JObjectArrayWrapper::operator=(const JObjectArrayWrapper &wrapper) {
    m_data = wrapper.m_data;
    return *this;
}

JObjectArrayWrapper& JObjectArrayWrapper::operator=(JObjectArrayWrapper &&wrapper) {
    m_data = std::move(wrapper.m_data);
    return *this;
}

jsize JObjectArrayWrapper::length() const
{
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        return env->GetArrayLength(object());
    }
    return 0;
}

jobject JObjectArrayWrapper::at(JNIEnv *env, jsize index) const{
    jobject value = env->GetObjectArrayElement(object(), index);
    qtjambi_throw_java_exception(env)
    return value;
}

JObjectWrapper JObjectArrayWrapper::operator[](jsize index) const{
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        jobject value = env->GetObjectArrayElement(object(), index);
        qtjambi_throw_java_exception(env)
        return JObjectWrapper(env, value);
    }
    return JObjectWrapper();
}

JObjectWrapperRef JObjectArrayWrapper::operator[](jsize index){
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        if(index>=0 && index < env->GetArrayLength(object())){
            return JObjectWrapperRef(*this, index);
        }else{
            JavaException::raiseIndexOutOfBoundsException(env, qPrintable(QString("%1").arg(index)) QTJAMBI_STACKTRACEINFO);
        }
    }
    return JObjectWrapperRef(JObjectWrapper(), 0);
}

QString JObjectArrayWrapper::toString(bool * ok) const{
    if(ok)
        *ok = true;
    QString result = QLatin1String("[");
    if(JNIEnv* env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 500)
        jsize length = env->GetArrayLength(object());
        for(jsize i=0; i<length; ++i){
            if(i>0)
                result += QLatin1String(",");
            jobject value = env->GetObjectArrayElement(object(), i);
            qtjambi_throw_java_exception(env)
            result += JObjectWrapper(env, value).toString(ok);
            if(ok && !*ok)
                return QString();
        }
    }
    result += QLatin1String("]");
    return result;
}



void JObjectGlobalWrapperCleanup::cleanup(jobject object){
    try{
        if(object && !QCoreApplication::closingDown()){
            DEREF_JOBJECT;
            if(JNIEnv *env = qtjambi_current_environment(false)){
                QTJAMBI_JNI_LOCAL_FRAME(env, 200)
                jthrowable throwable = nullptr;
                if(env->ExceptionCheck()){
                    throwable = env->ExceptionOccurred();
                    env->ExceptionClear();
                }
                env->DeleteGlobalRef(object);
                if(throwable)
                    env->Throw(throwable);
            }
        }
    }catch(...){}
}

void JObjectWeakWrapperCleanup::cleanup(jobject object){
    try{
        if(object && !QCoreApplication::closingDown()){
            DEREF_JOBJECT;
            if(JNIEnv *env = qtjambi_current_environment(false)){
                QTJAMBI_JNI_LOCAL_FRAME(env, 200)
                jthrowable throwable = nullptr;
                if(env->ExceptionCheck()){
                    throwable = env->ExceptionOccurred();
                    env->ExceptionClear();
                }
                env->DeleteWeakGlobalRef(object);
                if(throwable)
                    env->Throw(throwable);
            }
        }
    }catch(...){}
}

JObjectGlobalWrapperData::JObjectGlobalWrapperData(JNIEnv* env, jobject object)
    : pointer( env->NewGlobalRef(object) ){}
JObjectWeakWrapperData::JObjectWeakWrapperData(JNIEnv* env, jobject object)
    : pointer( env->NewWeakGlobalRef(object) ){}

jobject JObjectGlobalWrapperData::data() const {return pointer.data();}
jobject JObjectWeakWrapperData::data() const {return pointer.data();}

void JObjectGlobalWrapperData::clear(JNIEnv* env) {
    if(pointer.data()){
        jthrowable throwable = nullptr;
        if(env->ExceptionCheck()){
            throwable = env->ExceptionOccurred();
            env->ExceptionClear();
        }
        env->DeleteGlobalRef(pointer.take());
        if(throwable)
            env->Throw(throwable);
    }
}

void JObjectWeakWrapperData::clear(JNIEnv* env) {
    if(pointer.data()){
        DEREF_JOBJECT;
        jthrowable throwable = nullptr;
        if(env->ExceptionCheck()){
            throwable = env->ExceptionOccurred();
            env->ExceptionClear();
        }
        env->DeleteWeakGlobalRef(pointer.take());
        if(throwable)
            env->Throw(throwable);
    }
}

QDataStream &operator<<(QDataStream &out, const JObjectWrapper &myObj){
    if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        try{
            jobject jstream = qtjambi_from_object(env, &out, typeid(QDataStream), false);
            Java::QtJambi::QtJambiInternal::writeSerializableJavaObject(env, jstream, myObj.object());
        }catch(const JavaException& exn){
            if(qtjambi_is_exceptions_blocked()){
                qtjambi_push_blocked_exception(env, exn);
            }else{
                exn.raise( QTJAMBI_STACKTRACEINFO_ENV(env) );
            }
        }
    }
    return out;
}

QDataStream &operator>>(QDataStream &in, JObjectWrapper &myObj){
    if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        try{
            jobject jstream = qtjambi_from_object(env, &in, typeid(QDataStream), false);
            jobject res = Java::QtJambi::QtJambiInternal::readSerializableJavaObject(env, jstream);
            if(!res){
                myObj = JCollectionWrapper();
            }else if(Java::Runtime::Collection::isInstanceOf(env, res)){
                myObj = JCollectionWrapper(env, res);
            }else if(Java::Runtime::Iterator::isInstanceOf(env, res)){
                myObj = JIteratorWrapper(env, res);
            }else if(Java::Runtime::Map::isInstanceOf(env, res)){
                myObj = JMapWrapper(env, res);
            }else if(Java::Runtime::Enum::isInstanceOf(env, res)
                     || Java::QtJambi::QtEnumerator::isInstanceOf(env, res)
                     || Java::QtJambi::QtShortEnumerator::isInstanceOf(env, res)
                     || Java::QtJambi::QtByteEnumerator::isInstanceOf(env, res)
                     || Java::QtJambi::QtLongEnumerator::isInstanceOf(env, res)){
                myObj = JEnumWrapper(env, res);
            }else{
                jclass cls = env->GetObjectClass(res);
                if(Java::Runtime::Class::isArray(env, cls)){
                    jclass componentType = Java::Runtime::Class::getComponentType(env, cls);
                    if(Java::Runtime::Integer::isPrimitiveType(env, componentType)){
                        myObj = JIntArrayWrapper(env, jintArray(res));
                    }else if(Java::Runtime::Byte::isPrimitiveType(env, componentType)){
                        myObj = JByteArrayWrapper(env, jbyteArray(res));
                    }else if(Java::Runtime::Short::isPrimitiveType(env, componentType)){
                        myObj = JShortArrayWrapper(env, jshortArray(res));
                    }else if(Java::Runtime::Long::isPrimitiveType(env, componentType)){
                        myObj = JLongArrayWrapper(env, jlongArray(res));
                    }else if(Java::Runtime::Character::isPrimitiveType(env, componentType)){
                        myObj = JCharArrayWrapper(env, jcharArray(res));
                    }else if(Java::Runtime::Boolean::isPrimitiveType(env, componentType)){
                        myObj = JBooleanArrayWrapper(env, jbooleanArray(res));
                    }else if(Java::Runtime::Float::isPrimitiveType(env, componentType)){
                        myObj = JFloatArrayWrapper(env, jfloatArray(res));
                    }else if(Java::Runtime::Double::isPrimitiveType(env, componentType)){
                        myObj = JDoubleArrayWrapper(env, jdoubleArray(res));
                    }else{
                        myObj = JObjectArrayWrapper(env, jobjectArray(res));
                    }
                }else{
                    myObj = JObjectWrapper(env, res);
                }
            }
        }catch(const JavaException& exn){
            if(qtjambi_is_exceptions_blocked()){
                qtjambi_push_blocked_exception(env, exn);
            }else{
                exn.raise( QTJAMBI_STACKTRACEINFO_ENV(env) );
            }
        }
    }
    return in;
}

QDebug operator<<(QDebug out, const JObjectWrapper &myObj){
    out << myObj.toString();
    return out;
}

void jobjectwrapper_save(QDataStream &stream, const void *_jObjectWrapper)
{
    if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        const JObjectWrapper *jObjectWrapper = static_cast<const JObjectWrapper *>(_jObjectWrapper);
        jobject jstream = qtjambi_from_object(env, &stream, typeid(QDataStream), false);
        Java::QtJambi::QtJambiInternal::writeSerializableJavaObject(env, jstream, jObjectWrapper->object());
    }
}

void jcollectionwrapper_save(QDataStream &stream, const void *_jCollectionWrapper)
{
    const JCollectionWrapper *jCollectionWrapper = static_cast<const JCollectionWrapper *>(_jCollectionWrapper);
    bool ok = false;
    QStringList stringList = jCollectionWrapper->toStringList(&ok);
    if(ok){
        stream << stringList;
    }else{
        stream << jCollectionWrapper->toList();
    }
}

void jmapwrapper_save(QDataStream &stream, const void *_jMapWrapper)
{
    const JMapWrapper *jMapWrapper = static_cast<const JMapWrapper *>(_jMapWrapper);
    bool ok = false;
    QVariantMap variantMap = jMapWrapper->toStringMap(&ok);
    if(ok){
        stream << variantMap;
    }else{
        stream << jMapWrapper->toMap();
    }
}

void jcollectionwrapper_load(QDataStream &stream, void *_jCollectionWrapper)
{
    if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        JCollectionWrapper *jCollectionWrapper = static_cast<JCollectionWrapper *>(_jCollectionWrapper);
        QList<QVariant> list;
        stream >> list;
        jobject res = qtjambi_from_qvariant(env, QVariant::fromValue<QList<QVariant>>(list));
        *jCollectionWrapper = JCollectionWrapper(env, res);
    }
}

void jmapwrapper_load(QDataStream &stream, void *_jMapWrapper)
{
    if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        JMapWrapper *jMapWrapper = static_cast<JMapWrapper *>(_jMapWrapper);
        QMap<QVariant,QVariant> map;
        stream >> map;
        jobject res = qtjambi_from_qvariant(env, QVariant::fromValue<QMap<QVariant,QVariant>>(map));
        *jMapWrapper = JMapWrapper(env, res);
    }
}

void jobjectwrapper_load(QDataStream &stream, void *_jObjectWrapper)
{
    if(JNIEnv *env = qtjambi_current_environment()){
        QTJAMBI_JNI_LOCAL_FRAME(env, 200)
        try{
            JObjectWrapper *jObjectWrapper = static_cast<JObjectWrapper *>(_jObjectWrapper);
            jobject jstream = qtjambi_from_object(env, &stream, typeid(QDataStream), false);
            jobject res = Java::QtJambi::QtJambiInternal::readSerializableJavaObject(env, jstream);
            if(!res){
                *jObjectWrapper = JCollectionWrapper();
            }else if(Java::Runtime::Collection::isInstanceOf(env, res)){
                *jObjectWrapper = JCollectionWrapper(env, res);
            }else if(Java::Runtime::Iterator::isInstanceOf(env, res)){
                *jObjectWrapper = JIteratorWrapper(env, res);
            }else if(Java::Runtime::Map::isInstanceOf(env, res)){
                *jObjectWrapper = JMapWrapper(env, res);
            }else if(Java::Runtime::Enum::isInstanceOf(env, res)
                     || Java::QtJambi::QtEnumerator::isInstanceOf(env, res)
                     || Java::QtJambi::QtShortEnumerator::isInstanceOf(env, res)
                     || Java::QtJambi::QtByteEnumerator::isInstanceOf(env, res)
                     || Java::QtJambi::QtLongEnumerator::isInstanceOf(env, res)){
                *jObjectWrapper = JEnumWrapper(env, res);
            }else{
                jclass cls = env->GetObjectClass(res);
                if(Java::Runtime::Class::isArray(env, cls)){
                    jclass componentType = Java::Runtime::Class::getComponentType(env, cls);
                    if(Java::Runtime::Integer::isPrimitiveType(env, componentType)){
                        *jObjectWrapper = JIntArrayWrapper(env, jintArray(res));
                    }else if(Java::Runtime::Byte::isPrimitiveType(env, componentType)){
                        *jObjectWrapper = JByteArrayWrapper(env, jbyteArray(res));
                    }else if(Java::Runtime::Short::isPrimitiveType(env, componentType)){
                        *jObjectWrapper = JShortArrayWrapper(env, jshortArray(res));
                    }else if(Java::Runtime::Long::isPrimitiveType(env, componentType)){
                        *jObjectWrapper = JLongArrayWrapper(env, jlongArray(res));
                    }else if(Java::Runtime::Character::isPrimitiveType(env, componentType)){
                        *jObjectWrapper = JCharArrayWrapper(env, jcharArray(res));
                    }else if(Java::Runtime::Boolean::isPrimitiveType(env, componentType)){
                        *jObjectWrapper = JBooleanArrayWrapper(env, jbooleanArray(res));
                    }else if(Java::Runtime::Float::isPrimitiveType(env, componentType)){
                        *jObjectWrapper = JFloatArrayWrapper(env, jfloatArray(res));
                    }else if(Java::Runtime::Double::isPrimitiveType(env, componentType)){
                        *jObjectWrapper = JDoubleArrayWrapper(env, jdoubleArray(res));
                    }else{
                        *jObjectWrapper = JObjectArrayWrapper(env, jobjectArray(res));
                    }
                }else{
                    *jObjectWrapper = JObjectWrapper(env, res);
                }
            }
        }catch(const JavaException& exn){
            if(qtjambi_is_exceptions_blocked()){
                qtjambi_push_blocked_exception(env, exn);
            }else{
                exn.raise( QTJAMBI_STACKTRACEINFO_ENV(env) );
            }
        }
    }
}
