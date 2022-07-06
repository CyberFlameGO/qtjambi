#include <qtjambi/qtjambi_global.h>
#include <QtNetwork>
#include <qtjambi/qtjambi_core.h>
#include <qtjambi/qtjambi_jobjectwrapper.h>
#include <qtjambi/qtjambi_repository.h>
#include <qtjambi/qtjambi_cast.h>

extern "C" Q_DECL_EXPORT bool JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_network_QSsl_isAvailable)
(JNIEnv *, jclass)
{
#if defined(QT_NO_SSL)
    return false;
#else
    return true;
#endif
}

// QHostInfo::lookupHost(const QString & name, Functor functor)
extern "C" Q_DECL_EXPORT jint JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_network_QHostInfo_lookupHost)
(JNIEnv *__jni_env,
 jclass,
 jstring name0,
 QtJambiNativeID context1,
 jobject slot)
{
    jint _result{0};
    QTJAMBI_DEBUG_METHOD_PRINT("native", "QHostInfo::lookupHost(const QString & name, Functor functor)")
    QTJAMBI_TRY{
        if(!slot)
            JavaException::raiseNullPointerException(__jni_env, "slot must not be null." QTJAMBI_STACKTRACEINFO );
        const QString&  __qt_name0 = qtjambi_to_qstring(__jni_env, name0);
        QObject*  __qt_context1 = qtjambi_object_from_nativeId<QObject>(context1);
        JObjectWrapper objectWrapper(__jni_env, slot);
        _result = QHostInfo::lookupHost(__qt_name0, __qt_context1, [objectWrapper](const QHostInfo& info){
            if(JNIEnv *env = qtjambi_current_environment()){
                QTJAMBI_JNI_LOCAL_FRAME(env, 200)
                jobject result = qtjambi_cast<jobject>(env, info);
                Java::QtCore::QMetaObject$Slot1::invoke(env, objectWrapper.object(), result);
            }
        });
    }QTJAMBI_CATCH(const JavaException& exn){
        exn.raiseInJava(__jni_env);
    }QTJAMBI_TRY_END
    return _result;
}
