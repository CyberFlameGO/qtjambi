#include <qtjambi/qtjambi_core.h>
#include <QtScxml/QScxmlStateMachine>
#include <qtjambi/qtjambi_repository.h>
#include <qtjambi/qtjambi_jobjectwrapper.h>
#include <qtjambi/qtjambi_cast.h>

// QScxmlStateMachine::connectToState(const QString &scxmlStateName, Functor functor, Qt::ConnectionType type = Qt::AutoConnection)
extern "C" Q_DECL_EXPORT jobject JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_scxml_QScxmlStateMachine_connectToState)
(JNIEnv *__jni_env,
 jobject __this,
 QtJambiNativeID __this_nativeId,
 jstring scxmlStateName0,
 jobject slot1,
 jint type2)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QScxmlStateMachine::connectToState(const QString &scxmlStateName, Functor functor, Qt::ConnectionType type = Qt::AutoConnection)")
    Q_UNUSED(__this)
    jobject _result{nullptr};
    QTJAMBI_TRY{
        QScxmlStateMachine *__qt_this = qtjambi_object_from_nativeId<QScxmlStateMachine>(__this_nativeId);
        qtjambi_check_resource(__jni_env, __qt_this);
        const QString&  __qt_scxmlStateName0 = qtjambi_to_qstring(__jni_env, scxmlStateName0);
        JObjectWrapper pointer(__jni_env, slot1);
        QMetaObject::Connection connection;
        if(Java::QtCore::QMetaObject$Slot1::isInstanceOf(__jni_env, slot1)){
            connection = __qt_this->connectToState(__qt_scxmlStateName0, [pointer](bool isEnteringState){
                if(JNIEnv *env = qtjambi_current_environment()){
                    QTJAMBI_JNI_LOCAL_FRAME(env, 200)
                    Java::QtCore::QMetaObject$Slot1::invoke(env, pointer.object(), qtjambi_from_boolean(env, isEnteringState));
                }
            }, Qt::ConnectionType(type2));
        }else{
            connection = __qt_this->connectToState(__qt_scxmlStateName0, [pointer](bool){
                if(JNIEnv *env = qtjambi_current_environment()){
                    QTJAMBI_JNI_LOCAL_FRAME(env, 200)
                    Java::QtCore::QMetaObject$Slot0::invoke(env, pointer.object());
                }
            }, Qt::ConnectionType(type2));
        }
        _result = qtjambi_cast<jobject>(__jni_env, connection);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return _result;
}

// QScxmlStateMachine::connectToEvent(const QString &scxmlStateName, Functor functor, Qt::ConnectionType type = Qt::AutoConnection)
extern "C" Q_DECL_EXPORT jobject JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_scxml_QScxmlStateMachine_connectToEvent)
(JNIEnv *__jni_env,
 jobject __this,
 QtJambiNativeID __this_nativeId,
 jstring scxmlStateName0,
 jobject slot1,
 jint type2)
{
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QScxmlStateMachine::connectToEvent(const QString &scxmlStateName, Functor functor, Qt::ConnectionType type = Qt::AutoConnection)")
    Q_UNUSED(__this)
    jobject _result{nullptr};
    QTJAMBI_TRY{
        QScxmlStateMachine *__qt_this = qtjambi_object_from_nativeId<QScxmlStateMachine>(__this_nativeId);
        qtjambi_check_resource(__jni_env, __qt_this);
        const QString&  __qt_scxmlStateName0 = qtjambi_to_qstring(__jni_env, scxmlStateName0);
        JObjectWrapper pointer(__jni_env, slot1);
        QMetaObject::Connection connection;
        if(Java::QtCore::QMetaObject$Slot1::isInstanceOf(__jni_env, slot1)){
            connection = __qt_this->connectToEvent(__qt_scxmlStateName0, [pointer](const QScxmlEvent &event){
                if(JNIEnv *env = qtjambi_current_environment()){
                    QTJAMBI_JNI_LOCAL_FRAME(env, 200)
                    Java::QtCore::QMetaObject$Slot1::invoke(env, pointer.object(), qtjambi_cast<jobject>(env, event));
                }
            }, Qt::ConnectionType(type2));
        }else{
            connection = __qt_this->connectToEvent(__qt_scxmlStateName0, [pointer](const QScxmlEvent &){
                if(JNIEnv *env = qtjambi_current_environment()){
                    QTJAMBI_JNI_LOCAL_FRAME(env, 200)
                    Java::QtCore::QMetaObject$Slot0::invoke(env, pointer.object());
                }
            }, Qt::ConnectionType(type2));
        }

        _result = qtjambi_cast<jobject>(__jni_env, connection);
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return _result;
}
