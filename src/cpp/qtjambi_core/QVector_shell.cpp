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

#include <QtCore/QDataStream>
#include <QtCore/QDebug>
#include <qtjambi/qtjambi_core.h>
#include <qtjambi/qtjambi_repository.h>
#include <qtjambi/qtjambi_containers.h>
#include <qtjambi/qtjambi_application.h>
#include "qtjambi_core_repository.h"
#include <qtjambi/qtjambi_cast.h>

#if QT_VERSION < QT_VERSION_CHECK(6,0,0)

extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector_initialize)
(JNIEnv * env, jobject _this, jclass elementType, QtJambiNativeID elementMetaType, jobject other)
{
    QTJAMBI_TRY{
        initialize_QVector(env, _this, elementType, elementMetaType, other);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(env);
    }QTJAMBI_TRY_END
}

extern "C" Q_DECL_EXPORT jobject JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector_elementMetaType)
(JNIEnv * env, jclass, QtJambiNativeID __this_nativeId)
{
    jobject result{nullptr};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        AbstractVectorAccess* containerAccess = dynamic_cast<AbstractVectorAccess*>(container.second);
        Q_ASSERT(containerAccess);
        result = qtjambi_cast<jobject>(env, containerAccess->elementMetaType());
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(env);
    }QTJAMBI_TRY_END
    return result;
}

// emitting  (functionsInTargetLang writeFinalFunction)

// QVector<T>::append(const QVector<T> & t)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1appendVector__JLjava_util_Collection_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject t0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::append(const QVector<T> & t)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->appendVector(__jni_env, container.first, t0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::append(const T & t)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1append__JLjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject t0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::append(const T & t)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->append(__jni_env, container.first, t0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::at(int i) const
extern "C" Q_DECL_EXPORT jobject JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1at__JI)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint i0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::at(int i) const")
    jobject result{nullptr};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->at(__jni_env, container.first, i0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::begin() const
extern "C" Q_DECL_EXPORT jobject JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1begin__J)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::begin() const")
    jobject result{nullptr};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->begin(__jni_env, __this_nativeId, container.first);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::capacity() const
extern "C" Q_DECL_EXPORT jint JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1capacity__J)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::capacity() const")
    jint result{0};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->capacity(__jni_env, container.first);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::clear()
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1clear__J)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::clear()")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->clear(__jni_env, container.first);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::contains(const T & t) const
extern "C" Q_DECL_EXPORT jboolean JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1contains__JLjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject t0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::contains(const T & t) const")
    jboolean result{false};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->contains(__jni_env, container.first, t0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::count(const T & t) const
extern "C" Q_DECL_EXPORT jint JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1count__JLjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject t0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::count(const T & t) const")
    jint result{0};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->count(__jni_env, container.first, t0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::end() const
extern "C" Q_DECL_EXPORT jobject JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1end__J)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::end() const")
    jobject result{nullptr};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->end(__jni_env, __this_nativeId, container.first);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::endsWith(const T & t) const
extern "C" Q_DECL_EXPORT jboolean JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1endsWith__JLjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject t0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::endsWith(const T & t) const")
    jboolean result{false};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->endsWith(__jni_env, container.first, t0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::fill(const T &value, int size = ...)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1fill__JLjava_lang_Object_2I)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject value0,
 jint size1)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::fill(const T &value, int size = ...)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->fill(__jni_env, container.first, value0, size1);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::indexOf(const T & t, int from) const
extern "C" Q_DECL_EXPORT jint JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1indexOf__JLjava_lang_Object_2I)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject t0,
 jint from1)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::indexOf(const T & t, int from) const")
    jint result{-1};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->indexOf(__jni_env, container.first, t0, from1);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::insert(int i, const T & t)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1insert__JILjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint i0,
 jobject t1)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::insert(int i, const T & t)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->insert(__jni_env, container.first, i0, t1);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::insert(int i, int count, const T & t)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1insertN__JIILjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint i0,
 jint count1,
 jobject t2)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::insert(int i, int count, const T & t)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->insert(__jni_env, container.first, i0, count1, t2);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::lastIndexOf(const T & t, int from) const
extern "C" Q_DECL_EXPORT jint JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1lastIndexOf__JLjava_lang_Object_2I)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject t0,
 jint from1)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::lastIndexOf(const T & t, int from) const")
    jint result{-1};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->lastIndexOf(__jni_env, container.first, t0, from1);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::mid(int pos, int length) const
extern "C" Q_DECL_EXPORT jobject JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1mid__JII)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint pos0,
 jint length1)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::mid(int pos, int length) const")
    jobject result{nullptr};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->mid(__jni_env, container.first, pos0, length1);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::move(int from, int to)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1move__JII)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint from0,
 jint to1)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::move(int from, int to)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->move(__jni_env, container.first, from0, to1);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::operator==(const QVector & l) const
extern "C" Q_DECL_EXPORT jboolean JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1operator_1equal__JLjava_util_Collection_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject l0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::operator==(const QVector<T> & l) const")
    jboolean result{false};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->equal(__jni_env, container.first, l0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::prepend(const T & t)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1prepend__JLjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject t0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::prepend(const T & t)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->prepend(__jni_env, container.first, t0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::removeAll(const T & t)
extern "C" Q_DECL_EXPORT jint JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1removeAll__JLjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject t0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::removeAll(const T & t)")
    jint result{-1};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->removeAll(__jni_env, container.first, t0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::remove(int i, int count)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1removeN__JII)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint i0,
 jint count1)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::remove(int i, int count)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->remove(__jni_env, container.first, i0, count1);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::removeAt(int i)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1removeAt__JI)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint i0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::removeAt(int i)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->removeAt(__jni_env, container.first, i0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::removeOne(const T & t)
extern "C" Q_DECL_EXPORT jboolean JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1removeOne__JLjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject t0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::removeOne(const T & t)")
    jboolean result{false};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->removeOne(__jni_env, container.first, t0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::replace(int i, const T & t)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1replace__JILjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint i0,
 jobject t1)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::replace(int i, const T & t)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->replace(__jni_env, container.first, i0, t1);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::reserve(int size)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1reserve__JI)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint size0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::reserve(int size)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->reserve(__jni_env, container.first, size0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::resize(int size)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1resize__JI)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint size0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::resize(int size)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->resize(__jni_env, container.first, size0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::squeeze()
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1squeeze__J)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::squeeze()")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->squeeze(__jni_env, container.first);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

// QVector<T>::size() const
extern "C" Q_DECL_EXPORT jint JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1size__J)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::size() const")
    jint result{0};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->size(__jni_env, container.first);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::startsWith(const T & t) const
extern "C" Q_DECL_EXPORT jboolean JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1startsWith__JLjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jobject t0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::startsWith(const T & t) const")
    jboolean result{false};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->startsWith(__jni_env, container.first, t0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::value(int i) const
extern "C" Q_DECL_EXPORT jobject JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1value__JI)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint i0)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::value(int i) const")
    jobject result{nullptr};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->value(__jni_env, container.first, i0);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::value(int i, const T & defaultValue) const
extern "C" Q_DECL_EXPORT jobject JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1valueDefault__JILjava_lang_Object_2)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint i0,
 jobject defaultValue1)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QVector<T>::value(int i, const T & defaultValue) const")
    jobject result{nullptr};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        result = dynamic_cast<AbstractVectorAccess*>(container.second)->value(__jni_env, container.first, i0, defaultValue1);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// QVector<T>::swapItemsAt(int i, int j)
extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1swapItemsAt__JII)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 jint i0,
 jint j1)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QList<T>::swapItemsAt(int i, int j)")
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QList<QVariant>));
        dynamic_cast<AbstractVectorAccess*>(container.second)->swapItemsAt(__jni_env, container.first, i0, j1);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1writeTo)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 QtJambiNativeID stream0)
{
    QTJAMBI_TRY{
        const QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        QDataStream* stream = qtjambi_object_from_nativeId<QDataStream>(stream0);
        qtjambi_check_resource(__jni_env, stream, typeid(QDataStream));
        QByteArray containerName = "QVector<";
        containerName += dynamic_cast<AbstractVectorAccess*>(container.second)->elementMetaType().name();
        containerName += ">";
        int metaType = container.second->registerContainer(containerName);
        if(!QMetaType::save(*stream, metaType, container.first)){
            containerName.prepend("QDataStream& << ");
            JavaException::raiseQNoImplementationException(__jni_env, containerName QTJAMBI_STACKTRACEINFO );
        }
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

extern "C" Q_DECL_EXPORT void JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector__1_1qt_1QVector_1readFrom)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId,
 QtJambiNativeID stream0)
{
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        QDataStream* stream = qtjambi_object_from_nativeId<QDataStream>(stream0);
        qtjambi_check_resource(__jni_env, stream, typeid(QDataStream));
        QByteArray containerName = "QVector<";
        containerName += dynamic_cast<AbstractVectorAccess*>(container.second)->elementMetaType().name();
        containerName += ">";
        int metaType = container.second->registerContainer(containerName);
        if(!QMetaType::load(*stream, metaType, container.first)){
            containerName.prepend("QDataStream& >> ");
            JavaException::raiseQNoImplementationException(__jni_env, containerName QTJAMBI_STACKTRACEINFO );
        }
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
}

extern "C" Q_DECL_EXPORT jstring JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector_toString)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId)
{
    jstring result{nullptr};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        AbstractVectorAccess* containerAccess = dynamic_cast<AbstractVectorAccess*>(container.second);
        Q_ASSERT(containerAccess);
        QString strg;
        {
            QDebug stream(&strg);
            QByteArray containerName = "QVector<";
            containerName += containerAccess->elementMetaType().name();
            containerName += ">";
            int metaType = containerAccess->registerContainer(containerName);
            debug_stream(stream, metaType, container.first);
            if(strg.isEmpty()){
                containerName.prepend("QDebug >> ");
                JavaException::raiseQNoImplementationException(__jni_env, containerName QTJAMBI_STACKTRACEINFO );
            }
        }
        result = qtjambi_from_qstring(__jni_env, strg);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

extern "C" Q_DECL_EXPORT jint JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QVector_hashCode)
(JNIEnv *__jni_env,
 jclass,
 QtJambiNativeID __this_nativeId)
{
    jint result{0};
    QTJAMBI_TRY{
        QPair<void*,AbstractContainerAccess*> container = qtjambi_container_from_nativeId(__this_nativeId);
        qtjambi_check_resource(__jni_env, container.first, typeid(QVector<QVariant>));
        AbstractVectorAccess* containerAccess = dynamic_cast<AbstractVectorAccess*>(container.second);
        Q_ASSERT(containerAccess);
        QByteArray containerName = "QVector<";
        containerName += containerAccess->elementMetaType().name();
        containerName += ">";
        QMetaType metaType(containerAccess->registerContainer(containerName));
        hash_type h = qHash(metaType, container.first);
        result = jint(h);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return result;
}

// emitting (AbstractMetaClass::NormalFunctions|AbstractMetaClass::AbstractFunctions writeFinalFunction)
// emitting Field accessors (writeFieldAccessors)
// emitting (writeInterfaceCastFunction)
// emitting (writeSignalInitialization)
// emitting (writeJavaLangObjectOverrideFunctions)

#endif
